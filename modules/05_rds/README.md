# RDS
## エンジンの設定、インスタンスクラスの設定
### エンジンの設定
[ここ](https://docs.aws.amazon.com/cli/latest/reference/rds/describe-orderable-db-instance-options.html#options)から選択する
```
aurora-mysql
aurora-postgresql
custom-oracle-ee
db2-ae
db2-se
mariadb
mysql
oracle-ee
oracle-ee-cdb
oracle-se2
oracle-se2-cdb
postgres
sqlserver-ee
sqlserver-se
sqlserver-ex
sqlserver-web
```
### インスタンスクラスの設定
エンジンが対応しているインスタンスクラスを取得
```
aws rds describe-orderable-db-instance-options --engine aurora-mysql --query 'OrderableDBInstanceOptions[].DBInstanceClass' --output table
```

### 使いたいインスタンスクラスに合わせたversion
```
$ aws rds describe-orderable-db-instance-options --engine aurora-mysql --db-instance-class db.t2.small --query 'OrderableDBInstanceOptions[].[DBInstanceClass,StorageType,Engine,EngineVersion]' --output table
-----------------------------------------------------------------------
|                 DescribeOrderableDBInstanceOptions                  |
+-------------+---------+---------------+-----------------------------+
|  db.t2.small|  aurora |  aurora-mysql |  5.7.mysql_aurora.2.07.9    |
|  db.t2.small|  aurora |  aurora-mysql |  5.7.mysql_aurora.2.07.10   |
|  db.t2.small|  aurora |  aurora-mysql |  5.7.mysql_aurora.2.11.1    |
|  db.t2.small|  aurora |  aurora-mysql |  5.7.mysql_aurora.2.11.2    |
|  db.t2.small|  aurora |  aurora-mysql |  5.7.mysql_aurora.2.11.3    |
|  db.t2.small|  aurora |  aurora-mysql |  5.7.mysql_aurora.2.11.4    |
|  db.t2.small|  aurora |  aurora-mysql |  5.7.mysql_aurora.2.12.0    |
|  db.t2.small|  aurora |  aurora-mysql |  5.7.mysql_aurora.2.12.1    |
+-------------+---------+---------------+-----------------------------+
```

## 料金
### 無料利用枠
> Amazon RDS の Single-AZ db.t2.micro、db.t3.micro、db.t4g.micro 750 時間/月

- https://aws.amazon.com/jp/rds/free/
- memo: autora-mysqlでは無料枠対象インスタンスは対応していない:db.t2.smallが最小そう

## 実施してわかったこと
- RDS作成結構時間かかる: 3つインスタンス作成->15分以上かかる
- clusterのavailability_zoneは4つ以上指定できない
```
  availability_zones      = ["us-east-1a", "us-east-1b", "us-east-1c","us-east-1d", "us-east-1e"]
```
こうすると
```
│ Error: creating RDS Cluster (aurora-cluster-demo): InvalidParameterValue: You cannot specify more than 3 availability zones.
```
こうなる
- a,b,cを指定して3つインスタンスを作成した場合、ライターb, リーダーa,リーダーcが作成された
- a,b,cを指定して5つインスタンスを作成した場合、順番にリーダー*4 acaa ライター*1 bで作成された
  - 3つインスタンスに戻した際、リーダーa,ライターbが削除された
  - ライターインスタンスは最後に作成される？
  - 新しいものから順に削除する？
  - ライターインスタンスがなくなった際、0番目のリーダーaがライターに置き換わって ライターa,リーダーcaになった
  - -> 初期動作はライターに割り当てたもの以外のazにランダムに割り当てている?
- aws_db_instanceでauroraを指定して作成: できないとされている
  - エラーになった
  ```
  InvalidParameterCombination: VPC Multi-AZ DB Instances are not available for engine: aurora-mysql
  ```
  - ここまで進んだけどiops to storage ratioの組み合わせが合っていないと出た
  ```
  resource "aws_db_instance" "rds" {
  allocated_storage           = 100
  # storage_type                = "gp2"
  engine             = aws_rds_cluster.default.engine
  engine_version     = aws_rds_cluster.default.engine_version
  username = aws_rds_cluster.default.master_username
  instance_class              = "db.t2.small"
  password = aws_rds_cluster.default.master_password
  # manage_master_user_password = false
  skip_final_snapshot         = true
  db_subnet_group_name        = aws_db_subnet_group.rds.name
  # multi_az=true
}
  ```
  ```
  Error: creating RDS DB Instance (terraform-20240216111518034600000001): InvalidParameterCombination: Invalid iops to storage (GB) ratio for engine name aurora-mysql and storage type aurora: 0.0000
  ```

- マルチAZ設定とは
  - multi_az = trueはaws_db_instanceでは指定可能、aws_rds_cluster_instanceでは指定不可
- aws_rds_cluster_instanceとaws_db_instanceの違い
  - [aurora以外はaws_db_instanceって書いてある](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster)

->
- rds_cluster_instanceでrds_clusterで設定したazにインスタンスが作成されるが、分配はランダム
  - 別azにきちんと建てたい場合は明示する

## クロスリージョンレプリケーション
auroraは元々multi_az指定が出来る
リージョンにレプリケーションすることで耐障害性(地理的障害への対応)を向上させる
```
# プライマリリージョンのプロバイダ
provider "aws" {
  region = "us-east-1"
  alias  = "primary"
}

# セカンダリリージョンのプロバイダ
provider "aws" {
  region = "us-west-1"
  alias  = "secondary"
}

# プライマリデータベースクラスター
resource "aws_rds_cluster" "primary_cluster" {
  provider = aws.primary
  # ... (その他の設定)
}

# セカンダリデータベースクラスター
resource "aws_rds_cluster" "secondary_cluster" {
  provider = aws.secondary
  replication_source_identifier = aws_rds_cluster.primary_cluster.id
  # ... (その他の設定)
}
```

## 疑問
- 変更した時にinstanceがdestroyされたりする
  - つまりデータがなくなる？
    - どの変更だとデータが無くならない？
  - 新規作成になる場合のデータ投入プロセス
- deploy戦略の設定
  - DBの更新は難しい？
- サブネットグループの定義がよくわからない


