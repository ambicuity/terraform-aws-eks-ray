provider "aws" {
  region = var.region
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.ray_eks_cluster.cluster_name
}

module "vpc" {
  # checkov:skip=CKV_TF_1: Version-pinned registry module — commit hash not applicable for public registry sources
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.3"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets = [for k, v in ["a", "b", "c"] : cidrsubnet(var.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in ["a", "b", "c"] : cidrsubnet(var.vpc_cidr, 4, k + 3)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

module "ray_eks_cluster" {
  # checkov:skip=CKV_AWS_355: Cluster Autoscaler requires wildcard Describe permissions; mutating permissions remain tag-scoped in the module.
  # checkov:skip=CKV_AWS_144: Velero backup replication is an opt-in cost tradeoff and is disabled by default in the module.
  # checkov:skip=CKV_AWS_18: Access logging for the optional Velero bucket is an opt-in cost tradeoff and is disabled by default in the module.
  # checkov:skip=CKV2_AWS_61: Lifecycle rules for the optional Velero bucket are workload-specific and intentionally left configurable.
  # checkov:skip=CKV2_AWS_62: Event notifications are not required for the optional Velero backup bucket.
  source = "../.."

  cluster_name = var.cluster_name
  region       = var.region

  vpc_id                   = module.vpc.vpc_id
  control_plane_subnet_ids = module.vpc.private_subnets
  worker_node_subnet_ids   = module.vpc.private_subnets

  # For the example, keep sizes small to avoid excessive costs if applied
  cpu_node_min_size     = 1
  cpu_node_max_size     = 3
  cpu_node_desired_size = 1

  # Multi-GPU worker groups (issue #12) with conservative desired size defaults.
  gpu_worker_groups = {
    inference = {
      instance_types = ["g4dn.xlarge", "g5.xlarge"]
      min_size       = 0
      desired_size   = 0
      max_size       = 2
      capacity_type  = "SPOT"
      labels = {
        workload = "inference"
      }
    }
    training = {
      instance_types = ["p4d.24xlarge"]
      min_size       = 0
      desired_size   = 0
      max_size       = 1
      capacity_type  = "ON_DEMAND"
      labels = {
        workload = "training"
      }
    }
  }

  gpu_policy_max_per_group = 8
  gpu_policy_max_total     = 12
}
