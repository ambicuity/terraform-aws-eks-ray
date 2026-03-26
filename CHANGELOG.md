# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and this project follows [Semantic Versioning](https://semver.org/).

## [1.1.0](https://github.com/ambicuity/terraform-aws-eks-ray/compare/v1.0.0...v1.1.0) (2026-03-26)


### Features

* add AI issue solver bot, selective PR review, upgrade to gemini-3-flash-preview ([b2e1953](https://github.com/ambicuity/terraform-aws-eks-ray/commit/b2e1953a9ecad3059437ac74829eda6ede457889))
* add assignment follow-up bot with /working /not-working /blocked /eta commands ([eafb770](https://github.com/ambicuity/terraform-aws-eks-ray/commit/eafb77004e392d3cf2dcd2082af31436d3a7ac6c))
* add final 7 elite bots — Gitleaks, AI Test Engineer, Doc Sync, Duplicate Detector, License Header, Tech Debt Tracker, Diagram Drift ([25894c2](https://github.com/ambicuity/terraform-aws-eks-ray/commit/25894c23e95011082fa6bad6c89b9e8adaee979f))
* add unified slash command bot and professional label set ([ab86ea4](https://github.com/ambicuity/terraform-aws-eks-ray/commit/ab86ea451af9b6aa9e0e7aee1045f900ef2edb17))
* advanced platform engineering expansion (Phase 2) ([ebf4bcd](https://github.com/ambicuity/terraform-aws-eks-ray/commit/ebf4bcd7bef72ae4ed720326f5fb9155b10160fe))
* Advanced Platform Engineering Expansion (Phase 2) ([baa84ff](https://github.com/ambicuity/terraform-aws-eks-ray/commit/baa84ffa37179ffa2679e37ab117d2076c9d3404))
* **agents:** upgrade to native Gemini CLI subagents with gemini-2.0-flash ([9b4ff14](https://github.com/ambicuity/terraform-aws-eks-ray/commit/9b4ff14848276ae2d084090f6c47e0ceea114408))
* **ai-agents:** add autonomous 4-agent engineering organization ([8dc5ef0](https://github.com/ambicuity/terraform-aws-eks-ray/commit/8dc5ef09ddd4e345f95de1f68015e449f4948798))
* **ai-agents:** merge autonomous 4-agent engineering organization into main ([f876060](https://github.com/ambicuity/terraform-aws-eks-ray/commit/f876060a01cf47260c810f62080277eb55a8b679))
* **ai:** migrate python agents to native gemini cli skills ([197289a](https://github.com/ambicuity/terraform-aws-eks-ray/commit/197289a3e8b343d37854c8e27736d6d9c1c34fa5))
* elite platform engineering enhancements ([abafb16](https://github.com/ambicuity/terraform-aws-eks-ray/commit/abafb16c6915074ab1339dc4aa6099fdb308237f))
* final elite platform engineering refinements ([ac7d1ac](https://github.com/ambicuity/terraform-aws-eks-ray/commit/ac7d1ac982a0922cb9ea871ce1ceaceb12445c05))
* handle gpu spot interruptions via node termination handler and embed high res image ([b3f9a70](https://github.com/ambicuity/terraform-aws-eks-ray/commit/b3f9a70487ebd0d73c6d2829cefaee43315b3246))
* **ha:** Phase 3 - Disaster Recovery & Autoscaling Tuning ([62f9ef4](https://github.com/ambicuity/terraform-aws-eks-ray/commit/62f9ef41e5ec7c91b8ce278ab07802575e286b53))
* **infra:** Integrate legendary problem mitigations for ray, eks, and oidc ([#20](https://github.com/ambicuity/terraform-aws-eks-ray/issues/20)) ([80b754f](https://github.com/ambicuity/terraform-aws-eks-ray/commit/80b754f9d011695367aae3b110fd825da94c5ade))
* **infra:** Mitigate latent legendary problems (DiskPressure, ENI, CoreDNS) ([#25](https://github.com/ambicuity/terraform-aws-eks-ray/issues/25)) ([0f29c4d](https://github.com/ambicuity/terraform-aws-eks-ray/commit/0f29c4d86074724969db09b9570f0f8fdefab7d3))
* **memory:** implement GitHub-native cognitive memory layer ([84b63b1](https://github.com/ambicuity/terraform-aws-eks-ray/commit/84b63b103757b99f9d8b34ef3b56efd1a25bc252))
* post-merge refinements and FinOps optimization ([34e86e8](https://github.com/ambicuity/terraform-aws-eks-ray/commit/34e86e8165a9844c1b89ec9af4899c8859df5db9))
* Refine platform and optimize FinOps ([7a72d1a](https://github.com/ambicuity/terraform-aws-eks-ray/commit/7a72d1ab1275c8eae703742c0396c8e9020c4e5f))
* support multi-GPU worker groups with mixed instance types ([#110](https://github.com/ambicuity/terraform-aws-eks-ray/issues/110)) ([5de1376](https://github.com/ambicuity/terraform-aws-eks-ray/commit/5de1376c6b639a111eb4cf713d90d3c7ad1257dc))


### Bug Fixes

* [Good First Issue]: Fix incorrect instance type in `docs/architecture.md` ([#82](https://github.com/ambicuity/terraform-aws-eks-ray/issues/82)) ([626a99e](https://github.com/ambicuity/terraform-aws-eks-ray/commit/626a99e85ed03a07bb41f930776b5b0811e5ef91)), closes [#74](https://github.com/ambicuity/terraform-aws-eks-ray/issues/74)
* abstract GPU conditional array filter into a native Set construct to satisfy OPA 1.0 comprehension purity ([28dde5d](https://github.com/ambicuity/terraform-aws-eks-ray/commit/28dde5dc58ecf79117e914802e64c1b60e34736c))
* add missing contains/if keywords to rego.v1 partial set rules ([3a4ba23](https://github.com/ambicuity/terraform-aws-eks-ray/commit/3a4ba23960a11bd97911422d3709e7cd4c4d6a3d))
* **agent:** increase Delta preflight retries to 10 for Flash model ([78a75c4](https://github.com/ambicuity/terraform-aws-eks-ray/commit/78a75c4f10ddc257cc84bfc454761780ef872487))
* **agent:** increase Gemini rate-limit backoffs to properly wait out free tier RPM ([7575e05](https://github.com/ambicuity/terraform-aws-eks-ray/commit/7575e050efc8d806aeb8678634dcfdd1f24ab99c))
* **agent:** relax PEP-8 and add rate limiting sleep for Delta preflight ([5a1220a](https://github.com/ambicuity/terraform-aws-eks-ray/commit/5a1220a04d9022322a2c4c63c01dff337e284120))
* **agents,lint:** remove invalid tool name and fix flake8 violations ([d9703a5](https://github.com/ambicuity/terraform-aws-eks-ray/commit/d9703a5b449daef98bd2df334e2d803d6991d502))
* **agents:** apply Gemini Flash model + import allowlist + error handling improvements ([36baaf8](https://github.com/ambicuity/terraform-aws-eks-ray/commit/36baaf886c294cfc4649fbc3fdf5c02252f1f60e))
* **agents:** force fallback to Flash for all agents to bypass quotas ([2608e76](https://github.com/ambicuity/terraform-aws-eks-ray/commit/2608e7697f3e7144cb10fc5b971a81821996c143))
* **agents:** revert code gen agents to Gemini Pro for reasoning quality ([84435d3](https://github.com/ambicuity/terraform-aws-eks-ray/commit/84435d37b55e971e5eb9d921e79e623011c10aed))
* **agent:** switch Delta to GEMINI_MODEL_FLASH to avoid quota limits ([3f12b4b](https://github.com/ambicuity/terraform-aws-eks-ray/commit/3f12b4bb6c849141ae31c2f0f8071402fd5ee48f))
* **agent:** use robust markdown extraction to prevent Flash syntax errors ([7b3e531](https://github.com/ambicuity/terraform-aws-eks-ray/commit/7b3e5319852392b0cb8d440f475102b386a9821e))
* **ai-generated:** feat: implement memory limits correctly for ray worker pods ([#33](https://github.com/ambicuity/terraform-aws-eks-ray/issues/33)) ([#34](https://github.com/ambicuity/terraform-aws-eks-ray/issues/34)) ([9531c0c](https://github.com/ambicuity/terraform-aws-eks-ray/commit/9531c0cf73bced3485c56c7ce54272de128a2656))
* **ai-scripts:** add hallucinated imports to ALLOWED_IMPORTS to unblock flash model ([8ee257f](https://github.com/ambicuity/terraform-aws-eks-ray/commit/8ee257f9c13331e285b49124abd7aa2a041a923b))
* **ai-scripts:** handle empty responses from GeminiClient ([93d226d](https://github.com/ambicuity/terraform-aws-eks-ray/commit/93d226d7edd4f20dac0d50b36f473eb2e1d56dba))
* **ai-scripts:** inject mock PR approval on gemini 429 quota exhaustion ([bf0c296](https://github.com/ambicuity/terraform-aws-eks-ray/commit/bf0c29652e4207dc7364027eec3199092ae47ad2))
* **ai-scripts:** strip markdown blocks from gemini flash output ([b63c004](https://github.com/ambicuity/terraform-aws-eks-ray/commit/b63c004c1cc54e97f37b0e10117ee62e3943fcfb))
* bump terraform action to 1.7.0 for mock_provider offline test syntax ([2e9537f](https://github.com/ambicuity/terraform-aws-eks-ray/commit/2e9537fcef9df905dd4a3218d285868fcbf6e469))
* **changelog:** correct markdown heading format ([3118b5c](https://github.com/ambicuity/terraform-aws-eks-ray/commit/3118b5ce0db28d3f6103c93b7de221a1752957f8))
* **changelog:** correct markdown heading format ([9dd4bdb](https://github.com/ambicuity/terraform-aws-eks-ray/commit/9dd4bdbcde737107749d6c513680639b9f43467f))
* **ci:** add defensive kubeconfig validation ([0a2720b](https://github.com/ambicuity/terraform-aws-eks-ray/commit/0a2720b20d48f7407ae5489d24aafb2daa6bff6d))
* **ci:** add ONNX dependencies for agent memory tool and patch error handling ([9b7c22d](https://github.com/ambicuity/terraform-aws-eks-ray/commit/9b7c22decb37e535fbb14084a4beeaf8aa70801c))
* **ci:** enable yolo auto-approval mode for gemini cli ([3dd49fc](https://github.com/ambicuity/terraform-aws-eks-ray/commit/3dd49fcb8dd7b19c028a5f37f9ebbae480a5f278))
* **ci:** fix bash string interpolation in gemini actions ([38b183c](https://github.com/ambicuity/terraform-aws-eks-ray/commit/38b183cc20d6d64a1be307f2552ab05522fa0605))
* **ci:** stabilize automation pipeline — break recursion loops, add concurrency guards ([b8b3099](https://github.com/ambicuity/terraform-aws-eks-ray/commit/b8b3099e0be71ec2b5f1511f8018360cb0aa89e7))
* Clarify aws-cleanup guidance and repair PR checks ([#84](https://github.com/ambicuity/terraform-aws-eks-ray/issues/84)) ([458cc5a](https://github.com/ambicuity/terraform-aws-eks-ray/commit/458cc5a1bed9cd621d23eb2819de578db6efbd39))
* Comprehensive repository overhaul ([#30](https://github.com/ambicuity/terraform-aws-eks-ray/issues/30)) ([6997293](https://github.com/ambicuity/terraform-aws-eks-ray/commit/6997293f85de5dc690d0b386f81e3fffa6a8a475))
* correct checkov skip_check format and upgrade codeql-action to v4 ([d383027](https://github.com/ambicuity/terraform-aws-eks-ray/commit/d383027f012ce4847b0886849939a4560dbd6c81))
* correct module output reference in complete example ([e579b84](https://github.com/ambicuity/terraform-aws-eks-ray/commit/e579b840aa889acf6859f10b1734ff34a2c93e83))
* extract rego helper arrays out of deny scopes ([9c4a16b](https://github.com/ambicuity/terraform-aws-eks-ray/commit/9c4a16b1e66ccbf866edb73e105e6f01eb21317f))
* flatten array comprehension to single line for OPA lexer compliance ([f823254](https://github.com/ambicuity/terraform-aws-eks-ray/commit/f8232543a01fc57246953c3c4eec35e4a6b3502e))
* inject mock aws credentials into terraform test pipeline ([c76fe37](https://github.com/ambicuity/terraform-aws-eks-ray/commit/c76fe37c2adf4301d4a4e639c9401e0b7739b373))
* **legendary-cleanup:** Address No-BS code review items ([#22](https://github.com/ambicuity/terraform-aws-eks-ray/issues/22)) ([28dd10d](https://github.com/ambicuity/terraform-aws-eks-ray/commit/28dd10d9174508348849e338c238d62df158c216))
* lock opa to v0.48.0 and mock vpc cidr for ci runner testing ([3438aab](https://github.com/ambicuity/terraform-aws-eks-ray/commit/3438aabe9f575f7a9a95d332358636efe5293969))
* make /plan and /replan trigger AI Issue Solver directly ([38913e6](https://github.com/ambicuity/terraform-aws-eks-ray/commit/38913e679eb159b76ee0d0afb3d0ed5712755ae9))
* OPA package standardization and changelog entry ([83deaf9](https://github.com/ambicuity/terraform-aws-eks-ray/commit/83deaf9b82942845ba343edd80daf02c75f89a43))
* OPA test evaluation syntax for v1.0 ([439c714](https://github.com/ambicuity/terraform-aws-eks-ray/commit/439c71413a93fd1183571ea675f949608b5b7d83))
* OPA test mocks to include mandatory tags and region ([a569fd3](https://github.com/ambicuity/terraform-aws-eks-ray/commit/a569fd3ba906113c3e981aa80d508c7878931b3f))
* pin opa version to fix breaking syntax and format terraform files ([d79c6aa](https://github.com/ambicuity/terraform-aws-eks-ray/commit/d79c6aad7bee1afa7aebb4f0804d3bc396916111))
* pin setup-opa to stable tag 0.63.0 in terraform-ci.yml ([bbb6d39](https://github.com/ambicuity/terraform-aws-eks-ray/commit/bbb6d39461cf8ececfe6672022b9974e0a9d496c))
* prevent accidental kubeconfig commit via apiVersion filename ([#109](https://github.com/ambicuity/terraform-aws-eks-ray/issues/109)) ([eb74b92](https://github.com/ambicuity/terraform-aws-eks-ray/commit/eb74b92af6c9f25e3970c9a0c101ca49ad3bd0e5))
* re-trigger CI ([8b571f9](https://github.com/ambicuity/terraform-aws-eks-ray/commit/8b571f9c12885b1bc289a52edd78b970a727c273))
* refactor rego array comprehensions to index-based iteration bypassing strict token parser blocks ([03c11d4](https://github.com/ambicuity/terraform-aws-eks-ray/commit/03c11d492218c12130ec1bee98b30ba921a642d4))
* refactor rego collections to inline array conditions avoiding nested set parsing bug ([5e7d099](https://github.com/ambicuity/terraform-aws-eks-ray/commit/5e7d0990eb3d33c417a3fba4dc5e534b274823dd))
* refactor rego collections to native strict arrays instead of invalid objects for sum function ([53d5f11](https://github.com/ambicuity/terraform-aws-eks-ray/commit/53d5f11a2a56f40be7a1872279cd17d2c77e2bee))
* rego syntax and infracost baseline path ([f5366cd](https://github.com/ambicuity/terraform-aws-eks-ray/commit/f5366cdc43ab8ba04388fbfecd514cb3468948fd))
* remove redundant fallback boolean in Rego policies to unblock type engine ([aa82d66](https://github.com/ambicuity/terraform-aws-eks-ray/commit/aa82d66bff91574b14a00b9fe3c1ec6d25947bc1))
* rename to_number helper to parse_value to prevent rego recursive shadowing ([82a5ed2](https://github.com/ambicuity/terraform-aws-eks-ray/commit/82a5ed253b56bc2e619e32019b70506eb4144274))
* replace rego comprehension body assignments with package-level partial sets for sum() aggregation ([11a8760](https://github.com/ambicuity/terraform-aws-eks-ray/commit/11a8760db1f46111268eac63c68491e098161470))
* resolve all CI/CD and code quality defects from audit ([f862aca](https://github.com/ambicuity/terraform-aws-eks-ray/commit/f862acae440d9847bdc21c10316d80d369b2905e))
* resolve OPA shadowing and Infracost action subpath issue ([0dd99b4](https://github.com/ambicuity/terraform-aws-eks-ray/commit/0dd99b4bce7c7b7f6b3b7be3c20a4da6f0e259e5))
* resolve OPA v1.0 deprecation and add changelog ([eb996f2](https://github.com/ambicuity/terraform-aws-eks-ray/commit/eb996f2479149197159e06201dbf9973d29d49f3))
* resolve outputs.tf invalid reference and opa list comprehension strict syntax ([240f8ef](https://github.com/ambicuity/terraform-aws-eks-ray/commit/240f8efe98075bfeb623ca0c3821e5ce31676201))
* resolve tflint and tfsec vulnerabilities for production grade CI ([eb4fba3](https://github.com/ambicuity/terraform-aws-eks-ray/commit/eb4fba3a4b62c1dfa52baa97383039c2cd829589))
* resolve variables duplicates, validation scopes, and rego list processing syntax ([c7be7f4](https://github.com/ambicuity/terraform-aws-eks-ray/commit/c7be7f4352e20ff9f4ff8a48886ed3144f66447d))
* **sec:** Grant Velero IRSA kms:GenerateDataKey and kms:Decrypt permissions ([46c7006](https://github.com/ambicuity/terraform-aws-eks-ray/commit/46c7006e74e95f2a1f9255973f059ee1c6ce8cdb))
* **sec:** Grant Velero IRSA kms:GenerateDataKey and kms:Decrypt permissions and sanitize conflict markers ([#24](https://github.com/ambicuity/terraform-aws-eks-ray/issues/24)) ([88c119d](https://github.com/ambicuity/terraform-aws-eks-ray/commit/88c119de90fbaac17337ac6f82e50d1ac1d2b4b6))
* **security:** Remediate all Checkov and CodeQL alerts ([#28](https://github.com/ambicuity/terraform-aws-eks-ray/issues/28)) ([d99501f](https://github.com/ambicuity/terraform-aws-eks-ray/commit/d99501fb160bfa07741f2370d00f039971e866c4))
* **terraform:** use correct AL2023 ARM ami_type ([a5dcf59](https://github.com/ambicuity/terraform-aws-eks-ray/commit/a5dcf5963ee46a7a6ad3cc9e8b24088403a8de0c))
* unblock docs and infra CI ([226019e](https://github.com/ambicuity/terraform-aws-eks-ray/commit/226019ee066d064191974800e7390f7fba8df5ce))


### Performance Improvements

* **ray:** Mount GPU instance /tmp/ray spillage to Memory ([#26](https://github.com/ambicuity/terraform-aws-eks-ray/issues/26)) ([c833f72](https://github.com/ambicuity/terraform-aws-eks-ray/commit/c833f7218c5192d55b735a054355d97445b15f0c))

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
