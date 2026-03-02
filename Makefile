# Developer Entry Point
#
# Usage:
#   make help          — Show this help message
#   make lint          — Run all linters locally (tflint, checkov, flake8, pylint, mypy)
#   make fmt           — Format all files (terraform, python)
#   make test          — Run all tests locally (terraform test, pytest)
#   make validate      — Validate terraform configuration
#   make docker-test   — Run full pytest suite inside Docker (no local tool install required)
#   make docker-lint   — Run all Python linters inside Docker
#   make clean         — Clean up temporary files

.PHONY: help lint fmt test validate docker-test docker-lint clean

help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

lint: ## Run all linters (tflint, checkov, flake8, pylint, mypy)
	@echo "--- Running TFLint ---"
	@cd terraform && tflint --init && tflint
	@echo "--- Running Checkov ---"
	@checkov -d terraform
	@echo "--- Running Flake8 ---"
	@flake8 scripts/ workloads/ validation/ tests/ \
		--max-line-length=120 \
		--extend-ignore=E203,W503 \
		--statistics \
		--count
	@echo "--- Running Pylint ---"
	@pylint scripts/ workloads/ \
		--disable=C0114,C0115,C0116,R0903 \
		--max-line-length=120 \
		--fail-under=7.0
	@echo "--- Running Mypy ---"
	@mypy scripts/ workloads/ \
		--ignore-missing-imports \
		--no-strict-optional \
		--allow-untyped-defs

fmt: ## Format all files (terraform, python)
	@echo "--- Formatting Terraform ---"
	@terraform fmt -recursive terraform/
	@echo "--- Formatting Python ---"
	@black scripts/ workloads/

test: ## Run all tests locally (terraform test, pytest)
	@echo "--- Running Terraform Tests ---"
	@cd terraform && terraform init -backend=false && terraform test
	@echo "--- Running Python Tests ---"
	@pytest tests/ -v --tb=short --cov=scripts --cov-report=term-missing

validate: ## Validate terraform configuration
	@echo "--- Validating Terraform ---"
	@cd terraform && terraform init -backend=false && terraform validate

# ─────────────────────────────────────────────────────────────────────────────
# Docker targets — Use these if you do not have the local toolchain installed.
# Requires Docker Desktop or Docker Engine.
# ─────────────────────────────────────────────────────────────────────────────

docker-test: ## Run full pytest suite inside Docker (single-command, no local installs required)
	@echo "--- Building Docker test image ---"
	@docker build -t ray-k8s-dev:local .
	@echo "--- Running tests inside Docker ---"
	@docker run --rm ray-k8s-dev:local

docker-lint: ## Run all Python linters inside Docker
	@echo "--- Building Docker test image ---"
	@docker build -t ray-k8s-dev:local .
	@echo "--- Running linters inside Docker ---"
	@docker compose run --rm lint

clean: ## Clean up temporary files
	@find . -type d -name ".terraform" -exec rm -rf {} +
	@find . -type f -name "*.tfstate*" -delete
	@find . -type d -name "__pycache__" -exec rm -rf {} +
	@rm -rf reports/
	@rm -f coverage.xml test-results.xml
