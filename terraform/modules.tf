# module "base" {
#   source = "./modules/00_base"
#   count  = 1
# }

module "ec2_practice" {
  source = "./modules/01_ec2"
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
  count  = 1
}

module "rds_practice" {
  source = "./modules/05_rds"
  count  = 0
}

module "apigateway_openapi_practice" {
  source        = "./modules/06_apigateway_openapi"
  aws_region    = data.aws_region.current.name
  bucket_prefix = "practice"
  count         = 0
}

output "api_gateway_openapi_invoke_url" {
  depends_on = [module.apigateway_openapi_practice]
  value      = can(module.apigateway_openapi_practice[0]) ? module.apigateway_openapi_practice[0].api_invoke_url : null
}

module "apigateway_proxyresource_practice" {
  source     = "./modules/07_apigateway_proxyresource"
  aws_region = data.aws_region.current.name
  count      = 0
}

output "api_gateway_proxyresource_invoke_url" {
  depends_on = [module.apigateway_proxyresource_practice]
  value      = can(module.apigateway_proxyresource_practice[0]) ? module.apigateway_proxyresource_practice[0].api_invoke_url : null
}