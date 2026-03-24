# Launch Template for CPU Workers
resource "aws_launch_template" "cpu_workers" {
  name_prefix            = "${var.cluster_name}-cpu-"
  description            = "Launch template for CPU worker nodes"
  update_default_version = true
  vpc_security_group_ids = local.worker_security_group_ids

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 100
      volume_type           = "gp3"
      iops                  = 3000
      throughput            = 125
      delete_on_termination = true
      encrypted             = true
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name      = "${var.cluster_name}-cpu-worker"
      NodeGroup = "cpu-workers"
      ManagedBy = "Terraform"
    }
  }

  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    cluster_name     = var.cluster_name
    cluster_endpoint = aws_eks_cluster.main.endpoint
    cluster_ca       = aws_eks_cluster.main.certificate_authority[0].data
    node_group_name  = "cpu-workers"
  }))
}

# CPU Worker Node Group
resource "aws_eks_node_group" "cpu_workers" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-cpu-workers"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.worker_node_subnet_ids
  instance_types  = var.cpu_node_instance_types
  ami_type        = "AL2023_ARM_64_STANDARD"

  launch_template {
    id      = aws_launch_template.cpu_workers.id
    version = aws_launch_template.cpu_workers.latest_version
  }

  scaling_config {
    desired_size = var.cpu_node_desired_size
    max_size     = var.cpu_node_max_size
    min_size     = var.cpu_node_min_size
  }

  capacity_type = var.cpu_capacity_type

  update_config {
    max_unavailable = 1
  }

  labels = {
    role                   = "cpu-worker"
    workload-type          = "general"
    "ray.io/node-type"     = "worker"
    "ray.io/resource-type" = "cpu"
    managed-by             = "terraform"
  }

  tags = {
    Name                                            = "${var.cluster_name}-cpu-workers"
    ManagedBy                                       = "Terraform"
    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
    "k8s.io/cluster-autoscaler/enabled"             = var.enable_cluster_autoscaler ? "true" : "false"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config[0].desired_size]
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
  ]
}

# Launch Template for GPU Workers
resource "aws_launch_template" "gpu_workers" {
  count                  = length(local.effective_gpu_worker_groups) > 0 ? 1 : 0
  name_prefix            = "${var.cluster_name}-gpu-"
  description            = "Launch template for GPU worker nodes"
  update_default_version = true
  vpc_security_group_ids = local.worker_security_group_ids

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 200
      volume_type           = "gp3"
      iops                  = 3000
      throughput            = 125
      delete_on_termination = true
      encrypted             = true
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name       = "${var.cluster_name}-gpu-worker"
      NodeGroup  = "gpu-workers"
      ManagedBy  = "Terraform"
      GPUEnabled = "true"
    }
  }

  user_data = base64encode(templatefile("${path.module}/user-data-gpu.sh", {
    cluster_name     = var.cluster_name
    cluster_endpoint = aws_eks_cluster.main.endpoint
    cluster_ca       = aws_eks_cluster.main.certificate_authority[0].data
    node_group_name  = "gpu-workers"
  }))
}

# Multi-GPU worker node groups (new gpu_worker_groups or legacy compatibility map)
resource "aws_eks_node_group" "gpu_workers" {
  for_each = local.effective_gpu_worker_groups

  cluster_name    = aws_eks_cluster.main.name
  node_group_name = each.value.node_group_name
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.worker_node_subnet_ids
  instance_types  = each.value.instance_types
  ami_type        = "AL2_x86_64_GPU"

  launch_template {
    id      = aws_launch_template.gpu_workers[0].id
    version = aws_launch_template.gpu_workers[0].latest_version
  }

  scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
    min_size     = each.value.min_size
  }

  capacity_type = each.value.capacity_type

  update_config {
    max_unavailable = 1
  }

  labels = merge(
    {
      role                   = "gpu-worker"
      workload-type          = "gpu-intensive"
      "ray.io/node-type"     = "worker"
      "ray.io/resource-type" = "gpu"
      "nvidia.com/gpu"       = "true"
      "capacity-class"       = lower(each.value.capacity_type)
      "gpu-group"            = each.key
      managed-by             = "terraform"
    },
    each.value.labels
  )

  dynamic "taint" {
    for_each = each.value.taints
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  tags = {
    Name                                            = each.value.node_group_name
    ManagedBy                                       = "Terraform"
    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
    "k8s.io/cluster-autoscaler/enabled"             = var.enable_cluster_autoscaler ? "true" : "false"
    "ray.io/gpu-worker-group"                       = each.key
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config[0].desired_size]
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
  ]
}

# Cluster Autoscaler IAM Policy
# checkov:skip=CKV_AWS_355: The Cluster Autoscaler requires wildcard scope for AWS Describe APIs; mutating autoscaling actions are constrained by resource tags below.
resource "aws_iam_policy" "cluster_autoscaler" {
  count       = var.enable_cluster_autoscaler ? 1 : 0
  name_prefix = "${var.cluster_name}-autoscaler-"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeScalingActivities",
          "autoscaling:DescribeTags",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplateVersions"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeImages",
          "ec2:GetInstanceTypesFromInstanceRequirements",
          "eks:DescribeNodegroup"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM Role for Cluster Autoscaler (IRSA)
resource "aws_iam_role" "cluster_autoscaler" {
  count       = var.enable_cluster_autoscaler ? 1 : 0
  name_prefix = "${var.cluster_name}-autoscaler-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = local.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(local.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:kube-system:cluster-autoscaler"
          "${replace(local.oidc_provider_url, "https://", "")}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  count      = var.enable_cluster_autoscaler ? 1 : 0
  policy_arn = aws_iam_policy.cluster_autoscaler[0].arn
  role       = aws_iam_role.cluster_autoscaler[0].name
}
