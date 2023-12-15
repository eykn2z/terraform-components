module "base" {
  source = "./modules/base"
  count = 0
}

module "flask" {
  source = "./modules/flask"
  gcp_zone = var.gcp_zone
}
