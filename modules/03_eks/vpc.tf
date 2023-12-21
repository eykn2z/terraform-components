data "aws_availability_zones" "available" {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "vpc-example"
  cidr = "10.0.0.0/16"
  azs  = data.aws_availability_zones.available.names

  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"] # mask:clusterの規模で変える
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  # enable_nat_gateway = true
  # single_nat_gateway  = false
  # one_nat_gateway_per_az = false
  # enable_vpn_gateway     = true
  # enable_dns_hostnames   = true
  # map_public_ip_on_launch = true

  vpc_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }
  # required tag for EKS creation
  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }

  tags = {
    Terraform   = "true",
    Environment = terraform.workspace
  }
}
