# terraform-aws-eks-ray

[![CI](https://github.com/ambicuity/terraform-aws-eks-ray/actions/workflows/ci.yml/badge.svg)](https://github.com/ambicuity/terraform-aws-eks-ray/actions/workflows/ci.yml)
[![CodeQL](https://github.com/ambicuity/terraform-aws-eks-ray/actions/workflows/codeql.yml/badge.svg)](https://github.com/ambicuity/terraform-aws-eks-ray/actions/workflows/codeql.yml)
[![Gitleaks](https://github.com/ambicuity/terraform-aws-eks-ray/actions/workflows/gitleaks.yml/badge.svg)](https://github.com/ambicuity/terraform-aws-eks-ray/actions/workflows/gitleaks.yml)

Production-grade Terraform module for AWS EKS clusters optimized for Ray ML workloads. Supports multi-GPU worker groups with mixed instance types, IRSA-based service accounts, and KubeRay operator deployments.

## Notable Features

- **Multi-GPU worker groups** — define heterogeneous GPU pools (for example inference + training) with per-group autoscaling and capacity type.
- **Infra-only module** — The root module provisions the EKS platform only. Workload deployment (KubeRay, Ray charts, Velero) is composed separately in `examples/complete/`.
- **Evidence-based validation** — all security and scaling claims are backed by a committed proof bundle under `tests/evidence/`, auditable via `make evidence`.
- **OPA cost governance** — Rego policies block expensive GPU instance families and cap total node scale.

## Quick Start

### Infrastructure Only

```hcl
module "ray_eks_cluster" {
  source = "git::https://github.com/ambicuity/terraform-aws-eks-ray.git//terraform?ref=v1.0.0"

  cluster_name = "production-ray-cluster"
  region       = "us-east-1"

  vpc_id     = "vpc-0abcd1234efgh5678"
  control_plane_subnet_ids = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
  worker_node_subnet_ids   = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]

  cpu_node_min_size     = 2
  cpu_node_max_size     = 10
  cpu_node_desired_size = 3

  gpu_worker_groups = {
    inference = {
      instance_types = ["g4dn.xlarge", "g5.xlarge"]
      min_size       = 0
      desired_size   = 1
      max_size       = 4
      capacity_type  = "SPOT"
    }
    training = {
      instance_types = ["p4d.24xlarge"]
      min_size       = 0
      desired_size   = 0
      max_size       = 2
      capacity_type  = "ON_DEMAND"
    }
  }

  gpu_policy_max_per_group = 8
  gpu_policy_max_total     = 16
}
```

### Full Platform (with addons)

Use [`examples/complete/`](examples/complete/) to compose the infrastructure module with Cluster Autoscaler, KubeRay operator, the Ray Helm chart, and optional Velero backups.

## Local Validation

Terraform `>= 1.6.0` is required. The repo also bundles `.tmp-tools/bin/terraform-1.9.8` for local use.

```bash
make evidence    # Full evidence bundle: lint, test, claim audit, local cluster validation
make lint        # Deterministic static checks only
make test        # Terraform and Python tests only
```

## Documentation

| Document | Description |
|----------|-------------|
| [Architecture](docs/architecture.md) | Diagram and dataflow for how Ray and EKS interact |
| [Terraform Module Reference](docs/terraform-module.md) | Inputs, outputs, and behavior notes for the root module |
| [Autoscaling](docs/autoscaling.md) | Platform and workload scaling layers, Spot GPU reliability guidance |
| [Operations Guide](docs/operations-guide.md) | Day-1 deploy and day-2 troubleshooting |
| [Security](docs/security.md) | IAM roles, IRSA, KMS, and RBAC hardening |
| [CI/CD Pipelines](docs/ci-cd-pipelines.md) | Path-scoped CI, required checks, advisory AI surfaces |
| [Deployment Guide](DEPLOYMENT.md) | Step-by-step from `terraform apply` to running Ray workloads |
| [Contributing](docs/contributing.md) | How to contribute, code style, PR expectations |
| [Terraform Registry](docs/terraform-registry.md) | How to publish this module to the Terraform Registry |

| [Validation Runbook](validation/README.md) | Live-cluster validation scripts |
| [Claim Matrix](tests/evidence/claim-matrix.md) | Auditable claims with cross-references to proof paths |
| [Latest Evidence Summary](tests/evidence/SUMMARY.md) | Status of the latest local evidence run |
| [Changelog](CHANGELOG.md) | Version history and notable changes |
| [Roadmap](ROADMAP.md) | Current milestones and planned features |

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | >= 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_eks_addon.addons](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_cluster.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) | resource |
| [aws_eks_node_group.cpu_workers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |
| [aws_eks_node_group.gpu_workers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |
| [aws_iam_openid_connect_provider.cluster_managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_openid_connect_provider.cluster_unmanaged](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_policy.cluster_autoscaler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.cluster_autoscaler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cluster_AmazonEKSVPCResourceController](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cluster_autoscaler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.node_ebs_csi](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_alias.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_launch_template.cpu_workers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_launch_template.gpu_workers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_security_group.node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.node_ingress_self](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [tls_certificate.cluster](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_endpoint_public_access"></a> [cluster\_endpoint\_public\_access](#input\_cluster\_endpoint\_public\_access) | Enable public access to cluster endpoint | `bool` | `false` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster | `string` | `"ray-ml-cluster"` | no |
| <a name="input_commit_sha"></a> [commit\_sha](#input\_commit\_sha) | Git commit SHA for resource tagging | `string` | `"unknown"` | no |
| <a name="input_control_plane_subnet_ids"></a> [control\_plane\_subnet\_ids](#input\_control\_plane\_subnet\_ids) | List of subnet IDs for the EKS Control Plane ENIs (preferably isolated private subnets) | `list(string)` | n/a | yes |
| <a name="input_cpu_capacity_type"></a> [cpu\_capacity\_type](#input\_cpu\_capacity\_type) | Capacity type for CPU worker nodes (ON\_DEMAND or SPOT) | `string` | `"ON_DEMAND"` | no |
| <a name="input_cpu_node_desired_size"></a> [cpu\_node\_desired\_size](#input\_cpu\_node\_desired\_size) | Desired number of CPU worker nodes | `number` | `3` | no |
| <a name="input_cpu_node_instance_types"></a> [cpu\_node\_instance\_types](#input\_cpu\_node\_instance\_types) | Instance types for CPU worker nodes | `list(string)` | <pre>[<br/>  "m5.xlarge",<br/>  "m5.2xlarge"<br/>]</pre> | no |
| <a name="input_cpu_node_max_size"></a> [cpu\_node\_max\_size](#input\_cpu\_node\_max\_size) | Maximum number of CPU worker nodes | `number` | `10` | no |
| <a name="input_cpu_node_min_size"></a> [cpu\_node\_min\_size](#input\_cpu\_node\_min\_size) | Minimum number of CPU worker nodes | `number` | `2` | no |
| <a name="input_eks_addons"></a> [eks\_addons](#input\_eks\_addons) | Map of EKS addons to enable | `map(any)` | <pre>{<br/>  "coredns": {<br/>    "configuration_values": "{\"replicaCount\":4,\"resources\":{\"limits\":{\"cpu\":\"200m\",\"memory\":\"256Mi\"},\"requests\":{\"cpu\":\"100m\",\"memory\":\"128Mi\"}}}",<br/>    "resolve_conflicts_on_create": "OVERWRITE",<br/>    "resolve_conflicts_on_update": "OVERWRITE"<br/>  },<br/>  "kube-proxy": {<br/>    "resolve_conflicts_on_create": "OVERWRITE",<br/>    "resolve_conflicts_on_update": "OVERWRITE"<br/>  },<br/>  "vpc-cni": {<br/>    "configuration_values": "{\"env\":{\"ENABLE_PREFIX_DELEGATION\":\"true\"}}",<br/>    "resolve_conflicts_on_create": "OVERWRITE",<br/>    "resolve_conflicts_on_update": "OVERWRITE"<br/>  }<br/>}</pre> | no |
| <a name="input_enable_cloudwatch_logs"></a> [enable\_cloudwatch\_logs](#input\_enable\_cloudwatch\_logs) | Enable CloudWatch logs for control plane | `bool` | `true` | no |
| <a name="input_enable_cluster_autoscaler"></a> [enable\_cluster\_autoscaler](#input\_enable\_cluster\_autoscaler) | Enable Kubernetes cluster autoscaler | `bool` | `true` | no |
| <a name="input_enable_ebs_csi_driver"></a> [enable\_ebs\_csi\_driver](#input\_enable\_ebs\_csi\_driver) | Enable EBS CSI driver for persistent volumes | `bool` | `true` | no |
| <a name="input_enable_gpu_nodes"></a> [enable\_gpu\_nodes](#input\_enable\_gpu\_nodes) | DEPRECATED: Enable the legacy single GPU worker node pool when gpu\_worker\_groups is not set. | `bool` | `true` | no |
| <a name="input_enable_gpu_ondemand_fallback"></a> [enable\_gpu\_ondemand\_fallback](#input\_enable\_gpu\_ondemand\_fallback) | DEPRECATED: Create a legacy On-Demand fallback GPU node group when legacy primary GPU uses SPOT. | `bool` | `true` | no |
| <a name="input_enable_oidc_thumbprint_management"></a> [enable\_oidc\_thumbprint\_management](#input\_enable\_oidc\_thumbprint\_management) | Whether Terraform should manage the OIDC thumbprint. Set to false to prevent perpetual drift where AWS populates the thumbprint natively. | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (dev, staging, production) | `string` | `"production"` | no |
| <a name="input_gpu_capacity_type"></a> [gpu\_capacity\_type](#input\_gpu\_capacity\_type) | DEPRECATED: Capacity type for the legacy single GPU worker node pool (ON\_DEMAND or SPOT). | `string` | `"SPOT"` | no |
| <a name="input_gpu_node_desired_size"></a> [gpu\_node\_desired\_size](#input\_gpu\_node\_desired\_size) | DEPRECATED: Desired number of nodes for the legacy single GPU worker node pool. | `number` | `0` | no |
| <a name="input_gpu_node_instance_types"></a> [gpu\_node\_instance\_types](#input\_gpu\_node\_instance\_types) | DEPRECATED: Instance types for the legacy single GPU worker node pool. | `list(string)` | <pre>[<br/>  "g4dn.xlarge",<br/>  "g4dn.2xlarge"<br/>]</pre> | no |
| <a name="input_gpu_node_max_size"></a> [gpu\_node\_max\_size](#input\_gpu\_node\_max\_size) | DEPRECATED: Maximum number of nodes for the legacy single GPU worker node pool. | `number` | `5` | no |
| <a name="input_gpu_node_min_size"></a> [gpu\_node\_min\_size](#input\_gpu\_node\_min\_size) | DEPRECATED: Minimum number of nodes for the legacy single GPU worker node pool. | `number` | `0` | no |
| <a name="input_gpu_ondemand_fallback_desired_size"></a> [gpu\_ondemand\_fallback\_desired\_size](#input\_gpu\_ondemand\_fallback\_desired\_size) | DEPRECATED: Desired number of nodes in the legacy On-Demand fallback GPU worker pool. | `number` | `0` | no |
| <a name="input_gpu_ondemand_fallback_instance_types"></a> [gpu\_ondemand\_fallback\_instance\_types](#input\_gpu\_ondemand\_fallback\_instance\_types) | DEPRECATED: Instance types for the legacy On-Demand fallback GPU worker pool. | `list(string)` | <pre>[<br/>  "g4dn.xlarge"<br/>]</pre> | no |
| <a name="input_gpu_ondemand_fallback_max_size"></a> [gpu\_ondemand\_fallback\_max\_size](#input\_gpu\_ondemand\_fallback\_max\_size) | DEPRECATED: Maximum number of nodes in the legacy On-Demand fallback GPU worker pool. | `number` | `1` | no |
| <a name="input_gpu_ondemand_fallback_min_size"></a> [gpu\_ondemand\_fallback\_min\_size](#input\_gpu\_ondemand\_fallback\_min\_size) | DEPRECATED: Minimum number of nodes in the legacy On-Demand fallback GPU worker pool. | `number` | `0` | no |
| <a name="input_gpu_policy_max_per_group"></a> [gpu\_policy\_max\_per\_group](#input\_gpu\_policy\_max\_per\_group) | Maximum allowed potential GPUs for any single GPU worker group. | `number` | `8` | no |
| <a name="input_gpu_policy_max_total"></a> [gpu\_policy\_max\_total](#input\_gpu\_policy\_max\_total) | Maximum allowed total potential GPUs across all GPU worker groups. | `number` | `24` | no |
| <a name="input_gpu_worker_groups"></a> [gpu\_worker\_groups](#input\_gpu\_worker\_groups) | Preferred multi-GPU worker group configuration. When set, this overrides legacy gpu\_node\_* variables. | <pre>map(object({<br/>    instance_types = list(string)<br/>    min_size       = number<br/>    max_size       = number<br/>    desired_size   = number<br/>    capacity_type  = optional(string, "SPOT")<br/>    labels         = optional(map(string), {})<br/>    taints = optional(list(object({<br/>      key    = string<br/>      value  = string<br/>      effect = string<br/>    })))<br/>  }))</pre> | `{}` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | The Amazon Resource Name (ARN) of the KMS key to use for envelope encryption of Kubernetes secrets. If not provided, a new key will be created. | `string` | `""` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Kubernetes version for EKS | `string` | `"1.31"` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | CloudWatch log retention in days | `number` | `365` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region for infrastructure deployment | `string` | `"us-east-1"` | no |
| <a name="input_repo_name"></a> [repo\_name](#input\_repo\_name) | GitHub repository name for resource tagging | `string` | `"unknown"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags for all resources | `map(string)` | <pre>{<br/>  "Environment": "production",<br/>  "ManagedBy": "Terraform",<br/>  "Repository": "terraform-aws-eks-ray",<br/>  "Service": "Ray-ML-Platform"<br/>}</pre> | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the existing VPC to deploy the EKS cluster into | `string` | n/a | yes |
| <a name="input_worker_node_subnet_ids"></a> [worker\_node\_subnet\_ids](#input\_worker\_node\_subnet\_ids) | List of subnet IDs for the EKS Worker Nodes (preferably isolated private subnets) | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_instructions"></a> [access\_instructions](#output\_access\_instructions) | Instructions to access the cluster |
| <a name="output_cloudwatch_log_group"></a> [cloudwatch\_log\_group](#output\_cloudwatch\_log\_group) | CloudWatch log group name |
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | EKS cluster ARN |
| <a name="output_cluster_autoscaler_iam_role_arn"></a> [cluster\_autoscaler\_iam\_role\_arn](#output\_cluster\_autoscaler\_iam\_role\_arn) | IAM Role ARN for the Cluster Autoscaler (IRSA) |
| <a name="output_cluster_certificate_authority"></a> [cluster\_certificate\_authority](#output\_cluster\_certificate\_authority) | Cluster CA certificate |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | EKS cluster endpoint URL |
| <a name="output_cluster_iam_role_arn"></a> [cluster\_iam\_role\_arn](#output\_cluster\_iam\_role\_arn) | Cluster IAM role ARN |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | EKS cluster ID |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | EKS cluster name |
| <a name="output_cluster_oidc_issuer_url"></a> [cluster\_oidc\_issuer\_url](#output\_cluster\_oidc\_issuer\_url) | OIDC issuer URL for the cluster |
| <a name="output_cluster_security_group_id"></a> [cluster\_security\_group\_id](#output\_cluster\_security\_group\_id) | Cluster security group ID |
| <a name="output_cluster_version"></a> [cluster\_version](#output\_cluster\_version) | Kubernetes version |
| <a name="output_cpu_node_group_id"></a> [cpu\_node\_group\_id](#output\_cpu\_node\_group\_id) | CPU node group ID |
| <a name="output_cpu_node_group_status"></a> [cpu\_node\_group\_status](#output\_cpu\_node\_group\_status) | CPU node group status |
| <a name="output_estimated_monthly_cost"></a> [estimated\_monthly\_cost](#output\_estimated\_monthly\_cost) | Rough monthly cost estimate (USD) |
| <a name="output_gpu_fallback_node_group_id"></a> [gpu\_fallback\_node\_group\_id](#output\_gpu\_fallback\_node\_group\_id) | On-Demand fallback GPU node group ID |
| <a name="output_gpu_fallback_node_group_status"></a> [gpu\_fallback\_node\_group\_status](#output\_gpu\_fallback\_node\_group\_status) | On-Demand fallback GPU node group status |
| <a name="output_gpu_node_group_id"></a> [gpu\_node\_group\_id](#output\_gpu\_node\_group\_id) | DEPRECATED: Primary GPU node group ID. Use gpu\_node\_group\_ids. |
| <a name="output_gpu_node_group_ids"></a> [gpu\_node\_group\_ids](#output\_gpu\_node\_group\_ids) | GPU worker node group IDs keyed by gpu\_worker\_groups key. |
| <a name="output_gpu_node_group_status"></a> [gpu\_node\_group\_status](#output\_gpu\_node\_group\_status) | DEPRECATED: Primary GPU node group status. Use gpu\_node\_group\_statuses. |
| <a name="output_gpu_node_group_statuses"></a> [gpu\_node\_group\_statuses](#output\_gpu\_node\_group\_statuses) | GPU worker node group statuses keyed by gpu\_worker\_groups key. |
| <a name="output_gpu_primary_node_group_id"></a> [gpu\_primary\_node\_group\_id](#output\_gpu\_primary\_node\_group\_id) | Primary GPU node group ID |
| <a name="output_gpu_primary_node_group_status"></a> [gpu\_primary\_node\_group\_status](#output\_gpu\_primary\_node\_group\_status) | Primary GPU node group status |
| <a name="output_kubeconfig_command"></a> [kubeconfig\_command](#output\_kubeconfig\_command) | Command to configure kubectl |
| <a name="output_kubeconfig_path"></a> [kubeconfig\_path](#output\_kubeconfig\_path) | Suggested kubeconfig file path |
| <a name="output_node_iam_role_arn"></a> [node\_iam\_role\_arn](#output\_node\_iam\_role\_arn) | Node IAM role ARN |
| <a name="output_node_security_group_id"></a> [node\_security\_group\_id](#output\_node\_security\_group\_id) | Node security group ID |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | ARN of the OIDC provider used for IRSA (IAM Roles for Service Accounts) |
| <a name="output_region"></a> [region](#output\_region) | AWS region |
| <a name="output_resource_tags"></a> [resource\_tags](#output\_resource\_tags) | Tags applied to all resources |
<!-- END_TF_DOCS -->