# Terraform-Driven Ray on Kubernetes Platform — Gemini CLI Project Context

## Stack and Architecture
- **Infrastructure**: AWS EKS via Terraform (modules in `terraform/`)
- **Workloads**: Ray on Kubernetes using KubeRay (`helm/ray-cluster/`)
- **CI/CD**: GitHub Actions (`.github/workflows/`) — 4-phase autonomous agent loop (Gamma → Delta → Beta → Alpha)
- **Agent Skills**: `.gemini/agents/*.md` — each skill is a Gemini CLI subagent
- **Semantic Memory**: `.memory/` — ONNX embeddings via `scripts/memory_retriever.py`
- **Issue Queue**: `.ai_metadata/queue.json` — managed by Gamma, consumed by Delta

## Code Style Rules
- **Python**: PEP8, max line length 88 (Black-compatible). All new scripts in `scripts/`. Tests in `tests/`. No wildcard imports.
- **Terraform**: Pin all module versions. Use `checkov:skip` with justification comments above the resource block. Use IAM conditions to scope write access.
- **Git commits**: Conventional commits format — `type(scope): message`. Agent commits use `[skip ci]` where appropriate.
- **No hardcoded secrets**: All credentials via environment variables or GitHub secrets.

## Agent Workflow Conventions
When working on GitHub issues as an agent:
1. Always read `.ai_metadata/queue.json` first to understand the current queue state.
2. Respect priority ordering: `high` → `medium` → `low`.
3. All code changes require corresponding tests in `tests/`.
4. Use `python scripts/memory_agent_tool.py --query "<topic>" --k 5` to fetch repo context before implementing.
5. Use `gh` CLI for all GitHub API operations (labels, comments, PRs).

## Key File Locations
| Purpose | Path |
|---------|------|
| Issue queue | `.ai_metadata/queue.json` |
| Semantic memory store | `.memory/` |
| Memory retrieval CLI | `scripts/memory_agent_tool.py` |
| EKS cluster config | `terraform/main.tf` |
| Node pool config | `terraform/node_pools.tf` |
| Velero backup config | `terraform/velero.tf` |
| Ray workload manifests | `helm/ray-cluster/` |
| CI audit trail | `INTERNAL_LOG.md` |
