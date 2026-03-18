# ROADMAP.md — terraform-aws-eks-ray

## Current Version: v1.0.0

## Milestone 1 — Production Core

| Feature | Status |
|---|---|
| EKS cluster Terraform module | Done |
| KubeRay Helm deployment | Done |
| GPU node groups with Spot and prefix delegation | Done |
| Velero backup integration | Done |
| OPA guardrails | Done |
| Ray HA and GCS stability fixes | Done |
| Grafana dashboards | In Progress |

## Milestone 2 — Repository Automation Hardening

| Feature | Status |
|---|---|
| Path-scoped required CI router | Done |
| Low-noise deterministic workflow set | Done |
| CodeRabbit integration | Done |
| Gemini Code Assist on GitHub integration | Done |
| Ruleset-managed required checks | Done |
| Workflow linting in CI | Done |
| Terraform source pinning to `v1.0.0` in docs | Done |
| Removal of repo-owned AI workflow layer | Done |

## Milestone 3 — Production Readiness Follow-Through

| Feature | Status |
|---|---|
| Further separation of infra and workload delivery concerns | In Progress |
| Branch protection and required-check cleanup | Done |
| Release automation aligned to pinned tags | Done |
| Additional workload validation depth | Planned |
| Karpenter alternative autoscaler support | Planned |

## Milestone 4 — Multi-Cloud and Advanced MLOps

| Feature | Status |
|---|---|
| Karpenter as first-class autoscaler option | Planned |
| GKE support via provider abstraction | Planned |
| AKS support | Planned |
| Ray Serve integration and ingress templates | Planned |
| Automated canary deploys for Ray workloads | Planned |
| Per-job cost attribution tags | Planned |

## Version History

| Version | Date | Summary |
|---|---|---|
| v1.0.0 | 2026-02-26 | Production-ready EKS and KubeRay platform baseline |
