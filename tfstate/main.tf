terraform {
  required_version = ">= 0.11.0"
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      created_by = "terraform"
      env = terraform.workspace
    }
  }
}

resource "random_string" "random" {
  length           = 5
  numeric = true
  lower = false
  upper = false
  special = false
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-${random_string.random.result}"
}

resource "aws_s3_bucket_versioning" "terraform_state" {
    bucket = aws_s3_bucket.terraform_state.id
    versioning_configuration {
      status = "Enabled"
    }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name = "terraform_state_lock"
  read_capacity = 1
  write_capacity = 1
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
