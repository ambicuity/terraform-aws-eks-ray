#!/usr/bin/env python3
# MIT License
# Copyright (c) 2026 ambicuity
"""Minimal Agent Gamma helpers used by the repository test suite."""

from __future__ import annotations

import json

_MARKER_HINTS = {
    "environment": ("environment", "os:", "terraform", "kubernetes", "eks", "kuberay"),
    "steps_to_reproduce": ("steps to reproduce", "reproduce", "terraform apply", "kubectl"),
    "expected_vs_actual": ("expected", "actual", "expected vs actual"),
}

_HIGH_PRIORITY_TERMS = ("crash", "security", "vulnerability", "outage", "production", "oom")
_LOW_PRIORITY_TERMS = ("typo", "readme", "documentation", "docs", "spelling")


def detect_duplicates_semantic(new_issue: dict, closed_issues: list[dict], gemini) -> list[dict]:
    """Ask Gemini for duplicate issue numbers and map them back to candidate issues."""
    candidates = [
        issue for issue in closed_issues
        if issue.get("number") != new_issue.get("number")
    ]
    if not candidates:
        return []

    prompt = json.dumps(
        {
            "new_issue": {
                "number": new_issue.get("number"),
                "title": new_issue.get("title", ""),
                "body": new_issue.get("body", ""),
            },
            "candidates": [
                {
                    "number": issue.get("number"),
                    "title": issue.get("title", ""),
                    "body": issue.get("body", ""),
                }
                for issue in candidates
            ],
        }
    )
    response = gemini.generate(prompt)
    try:
        matches = json.loads(response)
    except (TypeError, json.JSONDecodeError):
        return []
    if not isinstance(matches, list):
        return []

    match_numbers = {number for number in matches if isinstance(number, int)}
    return [issue for issue in candidates if issue.get("number") in match_numbers]


def validate_markers(body: str | None) -> list[str]:
    """Return missing issue-template markers using lightweight keyword heuristics."""
    text = (body or "").strip().lower()
    missing: list[str] = []
    for marker, hints in _MARKER_HINTS.items():
        if not any(hint in text for hint in hints):
            missing.append(marker)
    return missing


def assign_priority(issue: dict) -> str:
    """Assign a coarse priority label based on issue title/body keywords."""
    text = " ".join(filter(None, [issue.get("title", ""), issue.get("body") or ""])).lower()
    if any(term in text for term in _HIGH_PRIORITY_TERMS):
        return "priority:high"
    if any(term in text for term in _LOW_PRIORITY_TERMS):
        return "priority:low"
    return "priority:medium"
