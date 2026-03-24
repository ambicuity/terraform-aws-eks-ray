# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and this project follows [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

- `terraform/backend.tf.example` with documented S3 + DynamoDB remote state pattern
- `.github/CODEOWNERS` for review routing
- `docs/terraform-registry.md` — how to publish to the Terraform Registry
- `release-please` workflow and config for automated semver releases
- `terraform-docs` workflow for auto-generated module reference
- Karpenter alternative section in autoscaling documentation
- `gpu_worker_groups` input for multi-GPU worker pools with mixed instance types and per-group autoscaling
- OPA GPU governance controls via `gpu_policy_max_per_group` and `gpu_policy_max_total`
- map-style outputs: `gpu_node_group_ids` and `gpu_node_group_statuses`

### Changed

- refactored `README.md` to value-prop-first structure with annotated docs table
- replaced the custom Gemini CLI agent stack with a smaller automation model centered on deterministic CI plus optional CodeRabbit and Gemini review tools
- collapsed fragmented CI checks into one path-scoped required `CI` workflow
- pinned public Terraform module examples to `v1.0.0`
- updated Cluster Autoscaler Helm chart to v9.43.2 for K8s 1.31 compatibility
- corrected ROADMAP: Grafana dashboards status changed from "Done" to "In Progress"
- refactored GPU node group provisioning from singleton resources to dynamic `for_each` groups with legacy compatibility mapping
- extended Ray chart support for multiple GPU worker groups via `gpuWorkerGroups`

### Removed

- legacy Gemini CLI subagents, setup action, queue files, and memory artifacts
- custom AI workflows (`gamma-triage`, `delta-executor`, `beta-reviewer`, `alpha-governor`, and related helpers)
- redundant standalone CI workflows that duplicated the required router
- assignment follow-up and slash-command automation in favor of a lower-noise maintainer workflow set

### Chore

- removed unused placeholder files `scripts/fix_issue_33.py` and `tests/test_issue_33.py`

### Documentation

- rewrote automation, security, CI/CD, contribution, and roadmap docs to match the current repository model

## [v1.0.0] - 2026-02-26

### Added

- production-ready EKS and KubeRay Terraform platform
- Velero backup integration and KMS-backed security defaults
- OPA guardrails for infrastructure and Ray workloads
- Grafana dashboards and validation tooling

### Changed

- moved Terraform code into `terraform/`
- upgraded the EKS baseline to 1.31
- optimized CPU workers toward Graviton-based instance families

### Security

- defaulted the EKS public endpoint to `false`
- enforced KMS encryption for control-plane logs
- pinned GitHub Actions to stable version references
