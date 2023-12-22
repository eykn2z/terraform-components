terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~>3.0.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
  backend "s3" {
    bucket  = "example-terraform-state-000001"
    region  = "us-east-1"
    key     = "terraform.tfstate"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region
}

provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
  zone    = var.gcp_zone
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "example-terraform-state-000001"
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "terraform_state_lock"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}


# locals {
#   eks_practice_exists = length(module.eks_practice) > 0
#   cluster_endpoint    = local.eks_practice_exists ? module.eks_practice[0].cluster_endpoint : ""
#   cluster_ca_cert     = local.eks_practice_exists ? base64decode(module.eks_practice[0].cluster_certificate_authority_data) : ""
#   cluster_token       = local.eks_practice_exists ? module.eks_practice[0].cluster_token : ""
# }

# provider "kubernetes" {
#   host                   = local.cluster_endpoint
#   cluster_ca_certificate = local.cluster_ca_cert
#   token                  = local.cluster_token
# }
