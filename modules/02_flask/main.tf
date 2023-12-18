module "aws" {
  source = "./aws"
  startup_script = var.startup_script
  count  = terraform.workspace == "aws" ? 1 : 0
}

module "gcp" {
  source = "./gcp"
  count  = terraform.workspace == "gcp" ? 1 : 0
  gcp_zone = var.gcp_zone
  startup_script = var.startup_script
}
