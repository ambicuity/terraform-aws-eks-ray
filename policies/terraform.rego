package terraform

import rego.v1

default allow = false

gpu_per_instance := {
  "g4dn.xlarge": 1,
  "g4dn.2xlarge": 1,
  "g4dn.4xlarge": 1,
  "g4dn.8xlarge": 1,
  "g4dn.12xlarge": 4,
  "g4dn.16xlarge": 1,
  "g5.xlarge": 1,
  "g5.2xlarge": 1,
  "g5.4xlarge": 1,
  "g5.8xlarge": 1,
  "g5.12xlarge": 4,
  "g5.16xlarge": 1,
  "g5.24xlarge": 4,
  "g5.48xlarge": 8,
  "p3.2xlarge": 1,
  "p3.8xlarge": 4,
  "p3.16xlarge": 8,
  "p4d.24xlarge": 8,
  "p5.48xlarge": 8
}

gpu_per_group_limit := object.get(object.get(input, "variables", {}), "gpu_policy_max_per_group", {"value": 8}).value
gpu_total_limit := object.get(object.get(input, "variables", {}), "gpu_policy_max_total", {"value": 24}).value

deny contains msg if {
  some i
  resource := input.resource_changes[i]
  resource.type == "aws_launch_template"
  metadata := resource.change.after.metadata_options[0]
  metadata.http_tokens != "required"
  msg := sprintf("Launch template '%s' must require IMDSv2 (http_tokens = required)", [resource.address])
}

deny contains msg if {
  some i
  resource := input.resource_changes[i]
  resource.type == "aws_launch_template"
  device := resource.change.after.block_device_mappings[_]
  not device.ebs[0].encrypted
  msg := sprintf("Launch template '%s' must encrypt its root volume", [resource.address])
}

deny contains msg if {
  some i
  resource := input.resource_changes[i]
  resource.type == "aws_eks_cluster"
  vpc_config := resource.change.after.vpc_config[0]
  vpc_config.endpoint_public_access
  not vpc_config.endpoint_private_access
  msg := "EKS clusters must keep private endpoint access enabled whenever public endpoint access is enabled"
}

deny contains msg if {
  node_group := gpu_node_groups[_]
  potential := potential_gpus(node_group)
  potential > gpu_per_group_limit
  msg := sprintf(
    "GPU worker group '%s' potential GPUs (%d) exceeds per-group cap (%d).",
    [node_group.address, potential, gpu_per_group_limit]
  )
}

deny contains msg if {
  total := sum([potential_gpus(node_group) | node_group := gpu_node_groups[_]])
  total > gpu_total_limit
  msg := sprintf("Total potential GPUs across all worker groups (%d) exceeds cluster cap (%d).", [total, gpu_total_limit])
}

gpu_node_groups contains node_group if {
  some i
  resource := input.resource_changes[i]
  resource.type == "aws_eks_node_group"
  labels := object.get(resource.change.after, "labels", {})
  labels["ray.io/resource-type"] == "gpu"
  node_group := resource
}

instance_gpu_count(instance_type) := object.get(gpu_per_instance, instance_type, 1)

max_instance_gpu(instance_types) := max([instance_gpu_count(instance_type) | instance_type := instance_types[_]])

potential_gpus(node_group) := max_instance_gpu(object.get(node_group.change.after, "instance_types", [])) * object.get(node_group.change.after.scaling_config[0], "max_size", 0)

deny contains msg if {
  node_group := gpu_node_groups[_]
  count(object.get(node_group.change.after, "instance_types", [])) == 0
  msg := sprintf("GPU worker group '%s' must define at least one instance type.", [node_group.address])
}

allow if {
  count(deny) == 0
}
