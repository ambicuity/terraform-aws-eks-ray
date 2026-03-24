# Core Configuration
variable "region" {
  description = "AWS region for infrastructure deployment"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "production"

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "ray-ml-cluster"
}



variable "repo_name" {
  description = "GitHub repository name for resource tagging"
  type        = string
  default     = "unknown"
}

variable "commit_sha" {
  description = "Git commit SHA for resource tagging"
  type        = string
  default     = "unknown"
}

# Networking
variable "vpc_id" {
  description = "ID of the existing VPC to deploy the EKS cluster into"
  type        = string
}

variable "control_plane_subnet_ids" {
  description = "List of subnet IDs for the EKS Control Plane ENIs (preferably isolated private subnets)"
  type        = list(string)
}

variable "worker_node_subnet_ids" {
  description = "List of subnet IDs for the EKS Worker Nodes (preferably isolated private subnets)"
  type        = list(string)
}

# EKS Configuration
variable "kubernetes_version" {
  description = "Kubernetes version for EKS"
  type        = string
  default     = "1.31"
}

variable "kms_key_arn" {
  description = "The Amazon Resource Name (ARN) of the KMS key to use for envelope encryption of Kubernetes secrets. If not provided, a new key will be created."
  type        = string
  default     = ""
}

variable "enable_oidc_thumbprint_management" {
  description = "Whether Terraform should manage the OIDC thumbprint. Set to false to prevent perpetual drift where AWS populates the thumbprint natively."
  type        = bool
  default     = false
}

variable "cluster_endpoint_public_access" {
  description = "Enable public access to cluster endpoint"
  type        = bool
  default     = false
}

variable "eks_addons" {
  description = "Map of EKS addons to enable"
  type        = map(any)
  default = {
    vpc-cni = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      configuration_values        = "{\"env\":{\"ENABLE_PREFIX_DELEGATION\":\"true\"}}"
    }
    kube-proxy = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
    coredns = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      configuration_values        = "{\"replicaCount\":4,\"resources\":{\"limits\":{\"cpu\":\"200m\",\"memory\":\"256Mi\"},\"requests\":{\"cpu\":\"100m\",\"memory\":\"128Mi\"}}}"
    }
  }
}


# Node Pool Configuration - CPU Workers
variable "cpu_node_instance_types" {
  description = "Instance types for CPU worker nodes"
  type        = list(string)
  default     = ["m5.xlarge", "m5.2xlarge"]
}

variable "cpu_node_min_size" {
  description = "Minimum number of CPU worker nodes"
  type        = number
  default     = 2

  validation {
    condition     = var.cpu_node_min_size >= 1 && var.cpu_node_min_size <= 10
    error_message = "CPU node min size must be between 1 and 10."
  }
}

variable "cpu_node_max_size" {
  description = "Maximum number of CPU worker nodes"
  type        = number
  default     = 10

  validation {
    condition     = var.cpu_node_max_size >= 1 && var.cpu_node_max_size <= 20
    error_message = "CPU node max size must be between 1 and 20."
  }
}

variable "cpu_node_desired_size" {
  description = "Desired number of CPU worker nodes"
  type        = number
  default     = 3
}

# Node Pool Configuration - GPU Workers
variable "enable_gpu_nodes" {
  description = "DEPRECATED: Enable the legacy single GPU worker node pool when gpu_worker_groups is not set."
  type        = bool
  default     = true
}

variable "gpu_node_instance_types" {
  description = "DEPRECATED: Instance types for the legacy single GPU worker node pool."
  type        = list(string)
  default     = ["g4dn.xlarge", "g4dn.2xlarge"]
}

variable "gpu_node_min_size" {
  description = "DEPRECATED: Minimum number of nodes for the legacy single GPU worker node pool."
  type        = number
  default     = 0

  validation {
    condition     = var.gpu_node_min_size >= 0 && var.gpu_node_min_size <= 5
    error_message = "GPU node min size must be between 0 and 5."
  }
}

variable "gpu_node_max_size" {
  description = "DEPRECATED: Maximum number of nodes for the legacy single GPU worker node pool."
  type        = number
  default     = 5

  validation {
    condition     = var.gpu_node_max_size >= 0 && var.gpu_node_max_size <= 10
    error_message = "GPU node max size must be between 0 and 10."
  }
}

variable "gpu_node_desired_size" {
  description = "DEPRECATED: Desired number of nodes for the legacy single GPU worker node pool."
  type        = number
  default     = 0
}

variable "cpu_capacity_type" {
  description = "Capacity type for CPU worker nodes (ON_DEMAND or SPOT)"
  type        = string
  default     = "ON_DEMAND"

  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.cpu_capacity_type)
    error_message = "CPU capacity type must be ON_DEMAND or SPOT."
  }
}

variable "gpu_capacity_type" {
  description = "DEPRECATED: Capacity type for the legacy single GPU worker node pool (ON_DEMAND or SPOT)."
  type        = string
  default     = "SPOT"

  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.gpu_capacity_type)
    error_message = "GPU capacity type must be ON_DEMAND or SPOT."
  }
}

variable "enable_gpu_ondemand_fallback" {
  description = "DEPRECATED: Create a legacy On-Demand fallback GPU node group when legacy primary GPU uses SPOT."
  type        = bool
  default     = true
}

variable "gpu_ondemand_fallback_instance_types" {
  description = "DEPRECATED: Instance types for the legacy On-Demand fallback GPU worker pool."
  type        = list(string)
  default     = ["g4dn.xlarge"]
}

variable "gpu_ondemand_fallback_min_size" {
  description = "DEPRECATED: Minimum number of nodes in the legacy On-Demand fallback GPU worker pool."
  type        = number
  default     = 0

  validation {
    condition     = var.gpu_ondemand_fallback_min_size >= 0 && var.gpu_ondemand_fallback_min_size <= 2
    error_message = "GPU On-Demand fallback min size must be between 0 and 2."
  }
}

variable "gpu_ondemand_fallback_max_size" {
  description = "DEPRECATED: Maximum number of nodes in the legacy On-Demand fallback GPU worker pool."
  type        = number
  default     = 1

  validation {
    condition     = var.gpu_ondemand_fallback_max_size >= 0 && var.gpu_ondemand_fallback_max_size <= 5
    error_message = "GPU On-Demand fallback max size must be between 0 and 5."
  }
}

variable "gpu_ondemand_fallback_desired_size" {
  description = "DEPRECATED: Desired number of nodes in the legacy On-Demand fallback GPU worker pool."
  type        = number
  default     = 0
}

variable "gpu_worker_groups" {
  description = "Preferred multi-GPU worker group configuration. When set, this overrides legacy gpu_node_* variables."
  type = map(object({
    instance_types = list(string)
    min_size       = number
    max_size       = number
    desired_size   = number
    capacity_type  = optional(string, "SPOT")
    labels         = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })))
  }))
  default = {}

  validation {
    condition = alltrue([
      for group_name, group in var.gpu_worker_groups : (
        length(group.instance_types) > 0 &&
        contains(["ON_DEMAND", "SPOT"], group.capacity_type) &&
        group.min_size >= 0 &&
        group.max_size >= group.min_size &&
        group.desired_size >= group.min_size &&
        group.desired_size <= group.max_size
      )
    ])
    error_message = "Each gpu_worker_groups entry must define non-empty instance_types, valid ON_DEMAND/SPOT capacity_type, and min/desired/max values where min <= desired <= max."
  }

  validation {
    condition = alltrue([
      for _, group in var.gpu_worker_groups : alltrue([
        for taint in coalesce(try(group.taints, null), []) : contains(["NO_SCHEDULE", "NO_EXECUTE", "PREFER_NO_SCHEDULE"], taint.effect)
      ])
    ])
    error_message = "gpu_worker_groups taints.effect must be one of: NO_SCHEDULE, NO_EXECUTE, PREFER_NO_SCHEDULE."
  }
}

variable "gpu_policy_max_per_group" {
  description = "Maximum allowed potential GPUs for any single GPU worker group."
  type        = number
  default     = 8
}

variable "gpu_policy_max_total" {
  description = "Maximum allowed total potential GPUs across all GPU worker groups."
  type        = number
  default     = 24
}

# Storage
variable "enable_ebs_csi_driver" {
  description = "Enable EBS CSI driver for persistent volumes"
  type        = bool
  default     = true
}



# Autoscaling
variable "enable_cluster_autoscaler" {
  description = "Enable Kubernetes cluster autoscaler"
  type        = bool
  default     = true
}





# Monitoring
variable "enable_cloudwatch_logs" {
  description = "Enable CloudWatch logs for control plane"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 365
}

# Tags
variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default = {
    ManagedBy   = "Terraform"
    Environment = "production"
    Service     = "Ray-ML-Platform"
    Repository  = "terraform-aws-eks-ray"
  }
}
