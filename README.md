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
