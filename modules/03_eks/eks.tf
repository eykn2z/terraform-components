module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 19.0"
  cluster_name    = local.cluster_name
  cluster_version = local.cluster_version

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.public_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  create_cluster_security_group   = true
  create_node_security_group      = true
  eks_managed_node_groups = {
    ng-1 = {
      desired_capacity        = 2
      max_capacity            = 2
      min_capacity            = 2
      launch_template_id      = aws_launch_template.eks_example.id
      launch_template_version = aws_launch_template.eks_example.latest_version
      #   cluster_primary_security_group_id = aws_security_group.node_example.id
    }
  }

  tags = {
    Terraform   = "true",
    Environment = terraform.workspace
  }
}


data "aws_eks_cluster_auth" "cluster" {
  name = local.cluster_name
}

resource "aws_launch_template" "eks_example" {
  instance_type = "t3.small"
  network_interfaces {
    security_groups = [
      module.eks.cluster_primary_security_group_id,
      aws_security_group.node_example.id
    ]
  }
}

resource "aws_autoscaling_attachment" "eks_example" {
  autoscaling_group_name = module.eks.eks_managed_node_groups_autoscaling_group_names[0]
  lb_target_group_arn    = aws_lb_target_group.example.arn
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}
output "cluster_token" {
  value = data.aws_eks_cluster_auth.cluster.token
}
