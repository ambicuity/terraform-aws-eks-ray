#!/usr/bin/env python3
# MIT License
# Copyright (c) 2026 ambicuity
"""Minimal Agent Beta implementation used by the repository test suite."""

from __future__ import annotations

import re

from gh_utils import ALLOWED_IMPORTS, GEMINI_MODEL_PRO, GeminiClient, GithubClient, require_env

_IMPORT_RE = re.compile(r"^(?:import|from)\s+([A-Za-z_][A-Za-z0-9_\.]*)")


def detect_hallucinated_imports(diff_text: str) -> list[str]:
    """Return third-party imports introduced on added diff lines."""
    flagged: list[str] = []
    seen: set[str] = set()
    for line in diff_text.splitlines():
        if not line.startswith("+") or line.startswith("+++"):
            continue
        match = _IMPORT_RE.match(line[1:].strip())
        if not match:
            continue
        module = match.group(1).split(".")[0]
        if module not in ALLOWED_IMPORTS and module not in seen:
            seen.add(module)
            flagged.append(module)
    return flagged


def get_brief(queue: dict, pr_number: int) -> str:
    """Return the technical brief associated with a PR, if one exists."""
    current = queue.get("in_progress") or {}
    if current.get("pr_number") == pr_number:
        return str(current.get("brief", ""))
    for item in queue.get("queued", []):
        if item.get("pr_number") == pr_number:
            return str(item.get("brief", ""))
    return f"No Technical Brief found for PR #{pr_number}."


def main() -> None:
    """Review a PR using a mocked GitHub/Gemini flow in tests."""
    env = require_env("GEMINI_API_KEY", "GITHUB_TOKEN", "PR_NUMBER", "GITHUB_REPOSITORY")
    pr_number = int(env["PR_NUMBER"])
    gh = GithubClient(env["GITHUB_TOKEN"], env["GITHUB_REPOSITORY"])

    diff_text = gh.get_pr_diff(pr_number)
    hallucinated = detect_hallucinated_imports(diff_text)
    if hallucinated:
        joined = ", ".join(hallucinated)
        gh.post_comment(pr_number, f"REJECTED\nHallucinated imports detected: {joined}")
        return

    queue = gh.read_queue()
    brief = get_brief(queue, pr_number)
    pr = gh.get_pr(pr_number)

    gemini = GeminiClient(env["GEMINI_API_KEY"], model=GEMINI_MODEL_PRO)
    prompt = (
        f"Review PR #{pr_number}\n"
        f"Title: {pr.get('title', '')}\n"
        f"Brief: {brief}\n\n"
        f"Diff:\n{diff_text[:4000]}"
    )
    review = gemini.generate(prompt)
    gh.post_comment(pr_number, review or "REJECTED\nGemini review returned no decision.")

    if not review.startswith("APPROVED"):
        return

    gh.merge_pr(pr_number)
    queue["merge_count"] = int(queue.get("merge_count", 0)) + 1
    queue["in_progress"] = None
    gh.write_queue(queue)
    gh.append_log("Beta", f"PR #{pr_number}", "Reviewed and merged", "merged", pr.get("title", ""))

    if queue["merge_count"] - int(queue.get("last_governance_merge", 0)) >= 5:
        gh.trigger_dispatch("governance-cycle")
