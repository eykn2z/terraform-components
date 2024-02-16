# description
terraform関連の検証リソースをmodule化
main.tfにmodule文を書き、実際に作成したいリソースのcountを増やすことによって利用する
tfstateはs3,dynamodbで管理する

# install
1. tfenvでterraformをinstall
```bash
brew install tfenv
tf_version=$(tfenv list-remote | head -n 1)
tfenv install $tf_version
tfenv use $tf_version
```
2. awsのCLIを利用可能にする
3. S3, DynamoDBでstate管理を行う
```bash
cd tfstate
terraform init
terraform plan
terrafrom apply --auto-approve
```
4. main.tfに記載がある各モジュールのcountを任意で1にする
5. 実行
```bash
terraform init
terraform plan
terrafrom apply --auto-approve
```
6. 削除
```bash
terraform destroy --auto-approve
```
