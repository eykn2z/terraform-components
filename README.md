# Description

Infrastructure practice repository using Terraform modules orchestrated by Terragrunt.
Remote state is stored in S3 with DynamoDB for state locking.

# Layout

- terraform/
  - terragrunt.hcl (root settings: remote_state, provider, inputs)
  - components/
    - 01_ec2/ ... 08_datadog_monitoring/ (each stack dir has its own terragrunt.hcl and module code)
  - tfvars/
    - default.tfvars, dev.tfvars, ... (environment-specific inputs merged at root)
  - backend/
    - main.tf (optional bootstrap to create S3 bucket and DynamoDB table)

# Prerequisites

1. Terraform and Terragrunt

```bash
brew install tfenv terragrunt
tf_version=$(tfenv list-remote | head -n 1)
tfenv install $tf_version
tfenv use $tf_version
```

2. AWS CLI configured (credentials/profile or env vars)

# Backend bootstrap (optional)

If the S3 bucket and DynamoDB table do not exist, create them:

```bash
cd terraform/backend
terraform init
terraform apply --auto-approve
```

This will create:

- S3 bucket: practice-terraform-state-<workspace>
- DynamoDB table: terraform-state-lock

# Configure environment inputs

Put shared and per-env variables under `terraform/tfvars/`:

- `terraform/tfvars/default.tfvars` (base)
- `terraform/tfvars/dev.tfvars`, `stg.tfvars`, `prod.tfvars`, ... (override)
  The root `terragrunt.hcl` merges `default.tfvars` first and then `${TG_ENV}.tfvars`.

# How to run

Terragrunt uses these variables:

- TG_ENV: environment name (e.g., dev, stg, prod). Defaults to `dev`.
- AWS_REGION: AWS region (default `us-east-1`).
- Optionally set AWS_PROFILE for credentials.

Plan all components:

```bash
cd terraform
TG_ENV=dev AWS_REGION=us-east-1 terragrunt run-all init -reconfigure
TG_ENV=dev AWS_REGION=us-east-1 terragrunt run-all plan
```

Apply all components:

```bash
cd terraform
TG_ENV=dev AWS_REGION=us-east-1 terragrunt run-all apply -auto-approve
```

Destroy all components:

```bash
cd terraform
TG_ENV=dev AWS_REGION=us-east-1 terragrunt run-all destroy -auto-approve
```

# Notes

- Remote state config in `terragrunt.hcl`:
  - S3 bucket: `practice-terraform-state-${local.env}`
  - Key: `${local.env}/${path_relative_to_include()}/terraform.tfstate`
  - DynamoDB table: `terraform-state-lock`
- Environment inputs are now under `terraform/tfvars/` (not `terraform/env/`).
