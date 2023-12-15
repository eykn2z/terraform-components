# install
```bash
brew install tfenv
tfenv list-remote
tfenv install 1.6.6
tfenv use 1.6.6
tfenv list
```

# command
```bash
terraform init # moduleとしてimportさせないとサブディレクトリは認識されない
terraform plan #事前確認
terraform apply
terraform apply -var "instance_name=YetAnotherName" # var.instance_name
terraform destroy

terrafom output
```

# AWS,GCP等環境による使い分け
```
terraform workspace new aws
terraform workspace new gcp
terraform workspace select aws
```

# 共通パラメータ
- count
  - moduleごとに設定し、リソースを作成するかどうか分岐可能
    - vpc_network等一部リソースでcountが使えないためmoduleにcountをつける方がよさそう

# github actions
aws,gcpに向けてdeploy
*.tfの修正があった場合にactionを走らせる
deployブランチにpushがあった場合applyする
どちらの環境に適用するかは環境変数で指定
認証パターン
  - secretsにキーを入れて認証させるパターン
  - https://note.com/shift_tech/n/n61146784b54f


- prod,dev
  - PRがマージされたタイミングでapply
    - 対象branchへのpushを許可しない
    - マージルールの明確化
- prod
  - より厳密なマージルール


