locals {
  env        = get_env("TG_ENV", "dev")
  aws_region = get_env("AWS_REGION", "us-east-1")
  env_dir    = "${get_terragrunt_dir()}/tfvars"
}

remote_state {
  backend = "s3"
  config = {
    bucket         = "practice-terraform-state-${local.env}"
    key            = "${local.env}/${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

generate "provider" {
  path      = "provider.auto.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

provider "aws" {
  region = "${local.aws_region}"

  default_tags {
    tags = {
      created_by = "terragrunt"
      env        = "${local.env}"
    }
  }
}
EOF
}

inputs = merge(
  try(read_tfvars_file("${local.env_dir}/default.tfvars"), {}),
  try(read_tfvars_file("${local.env_dir}/${local.env}.tfvars"), {})
)


