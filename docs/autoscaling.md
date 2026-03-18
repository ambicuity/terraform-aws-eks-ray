# Autoscaling

The repository now treats autoscaling as two separate layers:

1. Platform scaling in Terraform (the root module)
2. Ray workload scaling in the Helm chart and the complete example

## Platform Layer

The Terraform module defines the available capacity envelopes:

- CPU node group
- primary GPU node group
- optional On-Demand GPU fallback node group

Cluster Autoscaler is not installed by the root module. The IRSA role is exported so a downstream stack can deploy it safely.

## Workload Layer

The workload layer is managed by:

- `helm/ray/` for the `RayCluster`
- `examples/complete/helm.tf` for composing KubeRay, Cluster Autoscaler, and the Ray chart

The chart enables Ray in-tree autoscaling by default and defines separate CPU and GPU worker groups.

## Spot GPU Reliability

The previous repo story implied Spot-only GPU capacity was enough by itself. That is no longer the documented position.

Current guidance:

- Use `gpu_capacity_type = "SPOT"` for the primary GPU pool when you want the FinOps benefit
- Keep `enable_gpu_ondemand_fallback = true` unless you have consciously accepted Spot-only risk
- Keep fallback min and desired sizes at `0` if you want cost control while still preserving emergency capacity

Why:

- Ray can recover tasks and objects
- AWS can still reclaim an entire Spot pool at once
- without an On-Demand fallback node group, the autoscaler has nowhere reliable to place replacement GPU pods

## Local Validation

The local harness does not simulate AWS Spot reclamation. Instead, the repo validates the fallback design structurally:

- Terraform tests assert that Spot GPU mode creates an On-Demand fallback group by default
- OPA policy denies Spot GPU node groups without an On-Demand fallback
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

