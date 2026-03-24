# Autoscaling

The repository now treats autoscaling as two separate layers:

1. Platform scaling in Terraform (the root module)
2. Ray workload scaling in the Helm chart and the complete example

## Platform Layer

The Terraform module defines the available capacity envelopes:

- CPU node group
- one or more GPU worker groups via `gpu_worker_groups`

Cluster Autoscaler is not installed by the root module. The IRSA role is exported so a downstream stack can deploy it safely.

## Workload Layer

The workload layer is managed by:

- `helm/ray/` for the `RayCluster`
- `examples/complete/helm.tf` for composing KubeRay, Cluster Autoscaler, and the Ray chart

The chart enables Ray in-tree autoscaling by default and defines separate CPU and GPU worker groups.

## Spot GPU Reliability

Current guidance:

- Use per-group `capacity_type` in `gpu_worker_groups` to split FinOps-sensitive inference pools (Spot) from reliability-sensitive training pools (On-Demand)
- Keep low `desired_size` with higher `max_size` for burst-capable pools
- Tune OPA limits (`gpu_policy_max_per_group`, `gpu_policy_max_total`) to enforce budget boundaries

Why:

- Ray can recover tasks and objects
- mixed GPU groups reduce blast radius when one pool is reclaimed or saturated
- policy caps prevent runaway group scaling from overwhelming quota/budget

## Local Validation

The local harness does not simulate AWS Spot reclamation. Instead, the repo validates the multi-group design structurally:

- Terraform tests assert legacy compatibility and multi-group behavior
- OPA policy enforces per-group and total GPU cap constraints
- `local_test.sh` focuses on the chart-backed CPU/HA path in minikube

## Karpenter Alternative

[Karpenter](https://karpenter.sh/) is the newer AWS-native node provisioner that is increasingly replacing Cluster Autoscaler on EKS.

| Aspect | Cluster Autoscaler | Karpenter |
|--------|-------------------|-----------|
| **Node group model** | Managed Node Groups with ASGs | Provisioners create nodes directly via EC2 Fleet |
| **Scale speed** | Bound to ASG reconciliation loops (~2–3 min) | Launches nodes directly (~30–60s) |
| **Instance selection** | Fixed list per node group | Dynamic selection from a flexible set |
| **Spot handling** | One capacity type per node group | Can mix Spot and On-Demand per provisioner |
| **Maturity** | Battle-tested, wide adoption | Stable on EKS; not portable to other clouds |

### Why this repo uses Cluster Autoscaler

1. Cluster Autoscaler works with EKS Managed Node Groups, which provide a simpler operational model for teams that don't need sub-minute scaling.
2. The IRSA pattern for Cluster Autoscaler is well-understood and auditable.
3. The OPA policies and evidence bundle assume the ASG-based model.

### When to consider Karpenter

- If your Ray workloads require sub-minute node scaling (e.g., bursty inference).
- If you need dynamic instance type selection across a wide family range.
- If you want to consolidate GPU Spot and On-Demand into a single provisioner rather than separate node groups.

Adding Karpenter support is tracked in the [Roadmap](../ROADMAP.md) under Milestone 4.
