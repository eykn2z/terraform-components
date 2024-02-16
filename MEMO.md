# command
```bash
terraform init # moduleとしてimportさせないとサブディレクトリは認識されない
terraform plan #事前確認
terraform plan -var-file env/dev.tfvars
terraform apply
terraform apply -var "instance_name=YetAnotherName" # var.instance_name
terraform destroy

terrafom output

# terraform管理されていないリソースをterraform管理にする
terraform import <option> resource ID
```

# AWS,GCP等環境による使い分け
```
terraform workspace new aws
terraform workspace new gcp
terraform workspace select aws
```
この場合、環境ごとの管理はどうなる
共通部分をvariablesに入れる

# 共通パラメータ
- count
  - moduleごとに設定し、リソースを作成するかどうか分岐可能
    - vpc_network等一部リソースでcountが使えないためmoduleにcountをつける方がよさそう

# github actions
- aws,gcpに向けてdeploy
- *.tfの修正があった場合にactionを走らせる
- deployブランチにpushがあった場合applyする
- どちらの環境に適用するかは環境変数で指定
- 認証パターン
  - secretsにキーを入れて認証させるパターン
  - https://note.com/shift_tech/n/n61146784b54f
---
- prod,dev
  - PRがマージされたタイミングでapply
    - 対象branchへのpushを許可しない
    - マージルールの明確化
- prod
  - より厳密なマージルール

# コーディング規約
https://miraitranslate-tech.hatenablog.jp/entry/2023/03/10/120000

# 差分
apply後、planすると差分が表示される
```bash
% terraform plan --detailed-exitcode
module.flask.module.aws[0].aws_instance.flask_server_aws: Refreshing state... [id=i-0e4b1d033f10aee3c]

Terraform used the selected providers to generate the following execution plan. Resource actions
are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # module.flask.module.aws[0].aws_instance.flask_server_aws will be updated in-place
  ~ resource "aws_instance" "flask_server_aws" {
        id                                   = "i-0e4b1d033f10aee3c"
      ~ tags                                 = {
            "Name" = "FlaskServerAWS"
          - "Test" = "TestValue" -> null
        }
      ~ tags_all                             = {
          - "Test" = "TestValue" -> null
            # (1 unchanged element hidden)
        }
        # (31 unchanged attributes hidden)

        # (8 unchanged blocks hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.

───────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take
exactly these actions if you run "terraform apply" now.
```

# terraform管理repository以外からの操作禁止
- ユーザーに割り当てるポリシーに禁止事項を追加
- 管理repository用ロールは操作を許可

# cloudformationのようにマネジメントコンソールからも作成したリソースをグループ化したい
- tag付のルール化
- AWS: Service Catalogの1活用

# state管理
- リソースのstateはterraform applyされた環境に残る.tfstateで管理される
- 共同開発する際は.tfstateを共有する/リモートバックエンドを使う
    > - Amazon S3: AWSのS3バケットを使用して状態ファイルを保存し、オプションでDynamoDBを使ってロックと一貫性の管理を行う
    > - Terraform Cloud/Enterprise: HashiCorpが提供するTerraform CloudやTerraform Enterpriseを使用して、状態ファイルを安全に管理
    > - Google Cloud Storage: GCPのCloud Storageバケットを使用して状態ファイルを保存
    > - Azure Blob Storage: AzureのBlob Storageを使用して状態ファイルを保存
- S3のリモートバックエンドはS3バケットの管理が必要になるので、大人しくTerraform Cloudでマージトリガーでapplyするようにするでよさそう
  - https://qiita.com/hiyanger/items/e60ed7600d0cda120482

# 既存のリソースをterraform管理下にする
1. 空のリソースを作成(デフォルトの)
2. import
```
terraform import <リソース名> ID
```
3. 設定コード化
```
# 現在の設定の確認->copy&paste
terraform state show <リソース名>
```
