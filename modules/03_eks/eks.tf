module "eks" {
    source = "terraform-aws-modules/eks/aws"
    version = "~> 19.0"
    cluster_name = local.cluster_name
    cluster_version = local.cluster_version
    subnet_ids = module.vpc.public_subnets

    vpc_id = module.vpc.vpc_id

    eks_managed_node_groups = {
        ng-1 = {
            desired_capacity = 2
            max_capacity = 2
            min_capacity = 2
            instance_type = "t3.small"
        }
    }
}

data "aws_eks_cluster" "cluster" {
    name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
    name = module.eks.cluster_name
}
