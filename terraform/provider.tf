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
    key            = "terraform.state"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      created_by = "terraform"
      env        = terraform.workspace
    }
  }
}

# provider "google" {
#   project = var.gcp_project
#   region  = var.gcp_region
#   zone    = var.gcp_zone
# }


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
