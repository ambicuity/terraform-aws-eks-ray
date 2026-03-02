# ROADMAP.md — Terraform-Driven Ray on Kubernetes Platform

> **Managed jointly by the engineering team and Agent Alpha (Project Lead).**
> Alpha updates milestone completion and version targets after every governance cycle (every 5 merged PRs).

---

## Current Version: v1.0.0

---

## Milestone 1 — Production-Ready Core ✅ 100%

| Feature | Status |
|---|---|
| EKS cluster Terraform module | ✅ Done |
| KubeRay HelmRelease with battle-hardened config | ✅ Done |
| GPU node groups (SPOT) with prefix delegation | ✅ Done |
| Velero backup integration | ✅ Done |
| OPA Rego cost-governance policies | ✅ Done |
| HA Head Node preStop + readinessProbe | ✅ Done |
| wait-gcs-ready init container rewrite | ✅ Done |
| Grafana dashboards | ✅ Done |

---

## Milestone 2 — CI / Quality Gates ✅ 100%

| Feature | Status |
|---|---|
| Checkov IaC security scanning | ✅ Done |
| TFSec / TFLint | ✅ Done |
| CodeQL SAST | ✅ Done |
| Infracost FinOps gate | ✅ Done |
| Python lint CI | ✅ Done |
| PR lint / stale bot | ✅ Done |
| Drift detection workflow | ✅ Done |
| Diagram drift detection | ✅ Done |
| Contribution guidelines + issue templates | ✅ Done |

---

## Milestone 3 — Autonomous AI Agent Organization 🔄 In Progress

| Feature | Status |
|---|---|
| Agent Gamma (Triager) — `gamma_triage.py` | 🔄 In Progress |
| Agent Delta (Contributor) — `delta_executor.py` | 🔄 In Progress |
| Agent Beta (Maintainer) — `beta_reviewer.py` | 🔄 In Progress |
| Agent Alpha (Governor) — `alpha_governor.py` | 🔄 In Progress |
| Gemini CLI Integration (`setup-gemini-cli`) | ✅ Done |
| GitHub Actions wiring (4 new workflows) | 🔄 In Progress |
| `.ai_metadata/queue.json` state machine | 🔄 In Progress |
| `INTERNAL_LOG.md` bus-factor log | 🔄 In Progress |
| Agent unit tests (`tests/test_gamma.py` etc.) | 🔄 In Progress |

**Target Version:** v1.1.0 (MINOR — new feature set)

---

## Milestone 4 — Multi-Cloud & Advanced MLOps (Backlog)

| Feature | Status |
|---|---|
| GKE support via provider abstraction | ⬜ Planned |
| AKS support | ⬜ Planned |
| Ray Serve integration and Ingress templates | ⬜ Planned |
| Automated canary deploys for Ray workloads | ⬜ Planned |
| Per-job cost attribution tags | ⬜ Planned |

**Target Version:** v2.0.0 (MAJOR — breaking interface changes expected)

---

## Version History

| Version | Date | Type | Summary |
|---|---|---|---|
| v1.0.0 | 2026-02-26 | Initial | Production-ready EKS + KubeRay platform with full CI suite |

---

*Agent Alpha is responsible for updating this file after every governance cycle.*
*Humans retain final veto on Milestone 4+ scope changes per the "No by Default" policy.*
