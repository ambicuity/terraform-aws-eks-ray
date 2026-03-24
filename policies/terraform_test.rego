package terraform

import rego.v1

launch_template(encrypted, http_tokens) := {
  "address": "aws_launch_template.gpu_workers",
  "type": "aws_launch_template",
  "change": {
    "after": {
      "metadata_options": [{"http_tokens": http_tokens}],
      "block_device_mappings": [{"ebs": [{"encrypted": encrypted}]}]
    }
  }
}

gpu_node_group(address, instance_types, max_size) := {
  "address": address,
  "type": "aws_eks_node_group",
  "change": {
    "after": {
      "labels": {
        "ray.io/resource-type": "gpu"
      },
      "instance_types": instance_types,
      "scaling_config": [{"desired_size": 0, "min_size": 0, "max_size": max_size}]
    }
  }
}

test_launch_templates_require_imdsv2 if {
  mock_input := {"resource_changes": [launch_template(true, "optional")]}
  d := deny with input as mock_input
  some msg in d
  contains(msg, "must require IMDSv2")
}

test_launch_templates_require_encryption if {
  mock_input := {"resource_changes": [launch_template(false, "required")]}
  d := deny with input as mock_input
  some msg in d
  contains(msg, "must encrypt its root volume")
}

test_public_endpoint_requires_private_access if {
  mock_input := {
    "resource_changes": [{
      "address": "aws_eks_cluster.main",
      "type": "aws_eks_cluster",
      "change": {
        "after": {
          "vpc_config": [{
            "endpoint_public_access": true,
            "endpoint_private_access": false
          }]
        }
      }
    }]
  }
  d := deny with input as mock_input
  some msg in d
  contains(msg, "private endpoint access enabled")
}

test_group_gpu_cap_denied if {
  mock_input := {
    "variables": {
      "gpu_policy_max_per_group": {"value": 8},
      "gpu_policy_max_total": {"value": 24}
    },
    "resource_changes": [
      launch_template(true, "required"),
      gpu_node_group("aws_eks_node_group.gpu_workers[\"training\"]", ["p4d.24xlarge"], 2)
    ]
  }
  d := deny with input as mock_input
  some msg in d
  contains(msg, "exceeds per-group cap")
}

test_total_gpu_cap_denied if {
  mock_input := {
    "variables": {
      "gpu_policy_max_per_group": {"value": 16},
      "gpu_policy_max_total": {"value": 8}
    },
    "resource_changes": [
      launch_template(true, "required"),
      gpu_node_group("aws_eks_node_group.gpu_workers[\"inference\"]", ["g5.2xlarge"], 4),
      gpu_node_group("aws_eks_node_group.gpu_workers[\"training\"]", ["p4d.24xlarge"], 1)
    ]
  }
  d := deny with input as mock_input
  some msg in d
  contains(msg, "Total potential GPUs")
}

test_multi_group_within_caps_allowed if {
  mock_input := {
    "variables": {
      "gpu_policy_max_per_group": {"value": 8},
      "gpu_policy_max_total": {"value": 12}
    },
    "resource_changes": [
      launch_template(true, "required"),
      gpu_node_group("aws_eks_node_group.gpu_workers[\"inference\"]", ["g4dn.xlarge", "g5.xlarge"], 3),
      gpu_node_group("aws_eks_node_group.gpu_workers[\"training\"]", ["g4dn.2xlarge"], 2)
    ]
  }
  d := deny with input as mock_input
  count(d) == 0
}

test_unknown_gpu_instance_type_denied if {
  mock_input := {
    "variables": {
      "gpu_policy_max_per_group": {"value": 16},
      "gpu_policy_max_total": {"value": 32}
    },
    "resource_changes": [
      launch_template(true, "required"),
      gpu_node_group("aws_eks_node_group.gpu_workers[\"experimental\"]", ["g6.4xlarge"], 1)
    ]
  }
  d := deny with input as mock_input
  some msg in d
  contains(msg, "unknown GPU instance type")
}
