include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

terraform {
  source = "."
}

inputs = { bucket_prefix = "practice" }


