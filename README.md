# terraform-components

Reusable AWS components built with Terraform and orchestrated by Terragrunt, used to test infrastructure patterns before applying them in real environments.

- **Components:** EKS, ECS (deployed with ecspresso), RDS, API Gateway, Datadog monitoring
- **Environments:** dev / stg / prod via Terragrunt and per-environment tfvars
- **CI/CD:** GitHub Actions authenticates to AWS via OIDC (no long-lived keys); tflint and `terraform fmt` on every plan; Renovate for dependency updates
- **Deployments:** IssueOps with github/branch-deploy — `.noop` for plan, `.deploy` for apply, from PR comments
- **State:** S3 remote state with DynamoDB locking

## Layout

```
terraform/
  terragrunt.hcl          # root settings: remote_state, provider, inputs
  components/
    01_ec2/
    02_flask/
    03_eks/
    04_ecs/
    05_rds/
    06_apigateway_openapi/
    07_apigateway_proxyresource/
    08_datadog_monitoring/
  tfvars/
    default.tfvars         # shared inputs
    dev.tfvars             # environment overrides
    stg.tfvars
    prod.tfvars
  backend/
    main.tf                # bootstrap: creates S3 bucket and DynamoDB table
```

## Prerequisites

1. Terraform and Terragrunt

```bash
brew install tfenv terragrunt
tf_version=$(tfenv list-remote | head -n 1)
tfenv install $tf_version
tfenv use $tf_version
```

2. AWS CLI configured (credentials/profile or env vars)

## Backend bootstrap (optional)

If the S3 bucket and DynamoDB table do not exist:

```bash
cd terraform/backend
terraform init
terraform apply --auto-approve
```

Creates:
- S3 bucket: `practice-terraform-state-<env>`
- DynamoDB table: `terraform-state-lock`

## How to run

Environment is controlled by `TG_ENV` (default: `dev`). `AWS_REGION` defaults to `us-east-1`.

```bash
cd terraform

# Plan all components
TG_ENV=dev AWS_REGION=us-east-1 terragrunt run-all init -reconfigure
TG_ENV=dev AWS_REGION=us-east-1 terragrunt run-all plan

# Apply all components
TG_ENV=dev AWS_REGION=us-east-1 terragrunt run-all apply -auto-approve

# Destroy all components
TG_ENV=dev AWS_REGION=us-east-1 terragrunt run-all destroy -auto-approve
```

> **Note:** The EKS component (`03_eks`) is being updated to module v21. Run `terragrunt plan` inside `terraform/components/03_eks` to verify before applying.
