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
terraform workspace use aws
```

# 共通パラメータ
- count
  - moduleごとに設定し、リソースを作成するかどうか分岐可能
    - vpc_network等一部リソースでcountが使えないためmoduleにcountをつける方がよさそう

