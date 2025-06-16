provider "aws" {
  region = var.region
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.37"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  eks_managed_node_groups = {
    one = {
      name = "node_group_1"

      instance_types = var.instance_types

      min_size     = var.min_nodes
      max_size     = var.max_nodes
      desired_size = var.desired_nodes
    }
  }

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

resource "null_resource" "k8s_config" {
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region $REGION --name $CLUSTER"
    environment = {
      REGION  = var.region
      CLUSTER = var.cluster_name
    }
  }
  depends_on = [module.eks]
}
