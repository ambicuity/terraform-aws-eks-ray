# Terraform 1.5 discovers tests from the module root, so keep this file here.
mock_provider "aws" {}
mock_provider "tls" {}

variables {
  cluster_name             = "test-cluster"
  region                   = "us-east-1"
  vpc_id                   = "vpc-12345"
  control_plane_subnet_ids = ["subnet-12345", "subnet-67890"]
  worker_node_subnet_ids   = ["subnet-12345", "subnet-67890"]
}

run "legacy_spot_primary_creates_fallback" {
  command = plan

  assert {
    condition     = aws_eks_cluster.main.name == "test-cluster"
    error_message = "Cluster name did not match input variable"
  }

  assert {
    condition     = aws_eks_node_group.cpu_workers.capacity_type == "ON_DEMAND"
    error_message = "CPU nodes should default to ON_DEMAND"
  }

  assert {
    condition     = length(aws_eks_node_group.cpu_workers.launch_template) == 1
    error_message = "CPU node group should use the managed launch template"
  }

  assert {
    condition     = aws_eks_node_group.gpu_workers["primary"].capacity_type == "SPOT"
    error_message = "Primary GPU nodes should default to SPOT"
  }

  assert {
    condition     = length(aws_eks_node_group.gpu_workers["primary"].launch_template) == 1
    error_message = "Primary GPU node group should use the managed launch template"
  }

  assert {
    condition     = length(aws_eks_node_group.gpu_workers) == 2
    error_message = "Spot GPU clusters should create an On-Demand fallback node group by default"
  }

  assert {
    condition     = aws_eks_node_group.gpu_workers["on-demand-fallback"].capacity_type == "ON_DEMAND"
    error_message = "Fallback GPU nodes must always use ON_DEMAND capacity"
  }
}

run "disable_spot_fallback_explicitly" {
  command = plan

  variables {
    enable_gpu_ondemand_fallback = false
  }

  assert {
    condition     = length(aws_eks_node_group.gpu_workers) == 1 && !contains(keys(aws_eks_node_group.gpu_workers), "on-demand-fallback")
    error_message = "Fallback GPU node group should be removable when explicitly disabled"
  }
}

run "pure_ondemand_gpu_mode" {
  command = plan

  variables {
    gpu_capacity_type = "ON_DEMAND"
  }

  assert {
    condition     = aws_eks_node_group.gpu_workers["primary"].capacity_type == "ON_DEMAND"
    error_message = "Primary GPU node group should respect ON_DEMAND mode"
  }

  assert {
    condition     = !contains(keys(aws_eks_node_group.gpu_workers), "on-demand-fallback")
    error_message = "Fallback GPU node group should not be created for pure ON_DEMAND mode"
  }
}

run "multi_gpu_groups_override_legacy_inputs" {
  command = plan

  variables {
    enable_gpu_nodes = false
    gpu_worker_groups = {
      inference = {
        instance_types = ["g4dn.xlarge", "g5.xlarge"]
        min_size       = 0
        desired_size   = 1
        max_size       = 3
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
        taints         = []
      }
    }
  }

  assert {
    condition     = length(aws_eks_node_group.gpu_workers) == 2
    error_message = "Expected two GPU node groups from gpu_worker_groups input"
  }

  assert {
    condition     = aws_eks_node_group.gpu_workers["inference"].capacity_type == "SPOT"
    error_message = "Inference GPU group should keep SPOT capacity type"
  }

  assert {
    condition     = aws_eks_node_group.gpu_workers["training"].capacity_type == "ON_DEMAND"
    error_message = "Training GPU group should keep ON_DEMAND capacity type"
  }

  assert {
    condition     = length(aws_eks_node_group.gpu_workers["training"].taint) == 0
    error_message = "Explicitly empty taints should be respected for gpu_worker_groups entries"
  }
}

run "explicit_on_demand_fallback_key_does_not_set_legacy_fallback_output" {
  command = plan

  variables {
    enable_gpu_nodes = false
    gpu_worker_groups = {
      "on-demand-fallback" = {
        instance_types = ["g4dn.xlarge"]
        min_size       = 0
        desired_size   = 0
        max_size       = 1
        capacity_type  = "SPOT"
      }
    }
  }

  assert {
    condition     = output.gpu_fallback_node_group_id == null
    error_message = "Legacy fallback outputs should not be inferred from key names in explicit gpu_worker_groups mode."
  }
}
