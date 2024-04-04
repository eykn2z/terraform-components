module "base" {
  source = "./modules/01_base"
  count  = 0
}

module "flask" {
  source   = "./modules/02_flask"
  gcp_zone = var.gcp_zone
  count    = 0
}

module "eks_practice" {
  source = "./modules/03_eks"
  count  = 0
}

module "ecs_practice" {
  source = "./modules/04_ecs"
  count  = 0
}

module "rds_practice" {
  source = "./modules/05_rds"
  count  = 0
}

module "apigateway_openapi_practice" {
  source        = "./modules/06_apigateway_openapi"
  aws_region    = var.aws_region
  bucket_prefix = "practice"
  count         = 0
}

output "api_gateway_openapi_invoke_url" {
  depends_on = [module.apigateway_openapi_practice]
  value      = can(module.apigateway_openapi_practice[0]) ? module.apigateway_openapi_practice[0].api_invoke_url : null
}

module "apigateway_resourceproxy_practice" {
  source     = "./modules/07_apigateway_resourceproxy"
  aws_region = var.aws_region
  count      = 1
}

output "api_gateway_resourceproxy_invoke_url" {
  depends_on = [module.apigateway_resourceproxy_practice]
  value      = can(module.apigateway_resourceproxy_practice[0]) ? module.apigateway_resourceproxy_practice[0].api_invoke_url : null
}
