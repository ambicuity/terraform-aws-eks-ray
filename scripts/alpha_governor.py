#!/usr/bin/env python3
# MIT License
# Copyright (c) 2026 ambicuity
"""Small governance helpers used by the Agent Alpha test suite."""

from __future__ import annotations

import re


def determine_bump(merged_prs: list[dict]) -> str:
    """Return ``minor`` when any merged PR signals a feature, else ``patch``."""
    for pr in merged_prs:
        title = str(pr.get("title", "")).lower()
        label_names = {
            str(label.get("name", "")).lower()
            for label in pr.get("labels", [])
            if isinstance(label, dict)
        }
        if "feat" in title or "enhancement" in label_names or "feature" in label_names:
            return "minor"
    return "patch"


def bump_version(current_version: str, bump: str) -> str:
    """Bump a semantic version string, defaulting safely when parsing fails."""
    match = re.search(r"^(v)?(\d+)\.(\d+)\.(\d+)$", current_version.strip())
    if match:
        prefix = match.group(1) or ""
        major = int(match.group(2))
        minor = int(match.group(3))
        patch = int(match.group(4))
    else:
        prefix = "v"
        major, minor, patch = 1, 0, 0

    if bump == "minor":
        minor += 1
        patch = 0
    else:
        patch += 1
    return f"{prefix}{major}.{minor}.{patch}"


def extract_version(changelog_text: str) -> str:
    """Extract the first changelog version and normalize it to a ``v`` prefix."""
    match = re.search(r"^## \[(v?\d+\.\d+\.\d+)\]", changelog_text, re.MULTILINE)
    if not match:
        return "v1.0.0"
    version = match.group(1)
    return version if version.startswith("v") else f"v{version}"
