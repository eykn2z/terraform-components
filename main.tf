module "base" {
  source = "./modules/01_base"
  count  = 0
}

module "flask" {
  source   = "./modules/02_flask"
  gcp_zone = var.gcp_zone
  count    = 1
}

module "eks_practice" {
  source = "./modules/03_eks"
  count  = 0
}
