# Commands

```bash
terraform init # Subdirectories are not recognized unless imported as a module
terraform plan # Pre-check
terraform plan -var-file env/dev.tfvars
terraform apply
terraform apply -var "instance_name=YetAnotherName" # var.instance_name
terraform destroy

terrafom output

# Bring non-Terraform-managed resources under Terraform management
terraform import <option> resource ID
```

# Environment separation for AWS and GCP

```
terraform workspace new aws
terraform workspace new gcp
terraform workspace select aws
```

In this case, how should environment-specific management be handled?
Put common parts into variables.

# Common parameters

- count
  - Set per module to control whether to create resources
    - Some resources (e.g., vpc_network) do not support count, so it's better to place count on modules

# GitHub Actions

- Deploy to AWS and GCP
- Trigger actions when \*.tf files are modified
- Apply when pushing to the deploy branch
- Specify which environment to apply to via environment variables
- Authentication patterns
  - Use secrets to store keys for authentication
  - https://note.com/shift_tech/n/n61146784b54f

---

- prod, dev
  - Apply when PRs are merged
    - Disallow direct push to target branches
    - Clarify merge rules
- prod
  - Stricter merge rules

# Coding conventions

https://miraitranslate-tech.hatenablog.jp/entry/2023/03/10/120000

# Diffs

After apply, running plan will show the differences

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

# Prohibit operations outside the Terraform management repository

- Add restrictions to policies assigned to users
- Allow operations only via the role used by the management repository

# Group resources created from the Management Console as with CloudFormation

- Establish tagging rules
- AWS: Consider using Service Catalog

# State management

- Resource state is managed in the .tfstate left in the environment where terraform apply was run
- For collaborative work, share .tfstate or use a remote backend
  > - Amazon S3: Store state files in an S3 bucket and optionally use DynamoDB for locking and consistency
  > - Terraform Cloud/Enterprise: Use Terraform Cloud or Terraform Enterprise by HashiCorp to manage state securely
  > - Google Cloud Storage: Store state files in GCP Cloud Storage
  > - Azure Blob Storage: Store state files in Azure Blob Storage
- Since the S3 remote backend requires managing an S3 bucket, it may be simpler to use Terraform Cloud and apply on merge triggers
  - https://qiita.com/hiyanger/items/e60ed7600d0cda120482

# Bring existing resources under Terraform management

1. Create an empty (default) resource
2. Import

```
terraform import <resource_name> ID
```

3. Codify the configuration

```
# Check current settings -> copy & paste
terraform state show <resource_name>
```
