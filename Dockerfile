# ---------------------------------------------------------------------------
# Dockerfile — Local Development & CI Test Runner
#
# Purpose:
#   Provides a reproducible environment for running the full Python test suite
#   (pytest) and linters (flake8, pylint, mypy) without requiring local tool
#   installation.
#
# What is NOT included:
#   - ray, kubernetes — these are cluster-workload dependencies (requirements.txt)
#     installed directly on the EKS nodes and in the minikube CI job, not here.
#     Including them would bloat this image from ~300MB to ~3GB.
#
# Usage:
#   docker build -t ray-k8s-dev .
#   docker run --rm ray-k8s-dev                          # runs pytest (default)
#   docker run --rm ray-k8s-dev make lint                # runs linters
#   docker compose up test-runner                        # via docker-compose.yml
# ---------------------------------------------------------------------------

FROM python:3.11-slim AS base

LABEL maintainer="ambicuity"
LABEL description="Test runner and lint environment for terraform-aws-eks-ray"
LABEL org.opencontainers.image.source="https://github.com/ambicuity/terraform-aws-eks-ray"

# Security: run as a non-root user
RUN groupadd --gid 1001 appgroup && \
    useradd --uid 1001 --gid appgroup --shell /bin/bash --create-home appuser

WORKDIR /app

# Install system dependencies required for some stdlib modules
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    make \
    curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ── Test/lint toolchain ───────────────────────────────────────────────────────
# Pin exact versions to guarantee reproducible CI results.
# These are intentionally separate from requirements.txt (which is for the
# cluster workloads, not the dev/test toolchain).
COPY requirements-dev.txt ./
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements-dev.txt

# ── Source code ───────────────────────────────────────────────────────────────
# Copy only what is needed for the test suite — not .git, .terraform, .venv, etc.
COPY scripts/ ./scripts/
COPY tests/ ./tests/
COPY workloads/ ./workloads/
COPY validation/ ./validation/
COPY Makefile ./

# Hand off ownership to non-root user
RUN chown -R appuser:appgroup /app
USER appuser

# Default command: run the full test suite with coverage
CMD ["pytest", "tests/", "-v", "--tb=short", "--cov=scripts", "--cov-report=term-missing"]
