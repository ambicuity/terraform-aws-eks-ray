#!/usr/bin/env python3
# MIT License
# Copyright (c) 2026 ambicuity
"""Minimal Agent Delta implementation used by the repository test suite."""

from __future__ import annotations

import ast
import re
import sys

from gh_utils import ALLOWED_IMPORTS, GEMINI_MODEL_PRO, GeminiClient, GithubClient, compile_check, require_env

_FENCED_CODE_RE = re.compile(r"^```(?:python)?\n(?P<code>.*)\n```$", re.DOTALL)


def extract_code(response_text: str) -> str:
    """Strip markdown fences from model output while preserving raw code."""
    text = response_text.strip()
    match = _FENCED_CODE_RE.match(text)
    return match.group("code") if match else text


def extract_imports(code: str) -> set[str]:
    """Return top-level imported module names from a Python source string."""
    if not code.strip():
        return set()
    try:
        tree = ast.parse(code)
    except SyntaxError:
        return set()

    imports: set[str] = set()
    for node in ast.walk(tree):
        if isinstance(node, ast.Import):
            imports.update(alias.name.split(".")[0] for alias in node.names)
        elif isinstance(node, ast.ImportFrom) and node.module:
            imports.add(node.module.split(".")[0])
    return imports


def select_issue(queue: dict, requested_issue: str) -> dict | None:
    """Pick the requested queued issue or fall back to the first queued item."""
    queued = queue.get("queued", [])
    if not queued:
        return None
    for item in queued:
        if str(item.get("issue_number")) == str(requested_issue):
            return item
    return queued[0]


def preflight(code: str, gemini: GeminiClient) -> tuple[bool, str]:
    """Run import allowlisting, compilation, and a lightweight Gemini review."""
    imports = extract_imports(code)
    disallowed = sorted(imports - set(ALLOWED_IMPORTS))
    if disallowed:
        return False, f"Hallucinated imports detected: {', '.join(disallowed)}"

    compiled, compile_feedback = compile_check(code)
    if not compiled:
        return False, f"Compile error: {compile_feedback}"

    prompt = (
        "Review this generated Python patch. Respond with APPROVED or REJECTED.\n\n"
        f"{code[:4000]}"
    )
    review = gemini.generate(prompt)
    if review.startswith("APPROVED"):
        return True, review
    if not review:
        return False, "Gemini returned an empty review."
    return False, review


def _build_memory_context(gh: GithubClient) -> str:
    """Return a compact repository context string for prompt construction."""
    return gh.get_repo_tree()


def main() -> None:
    """Claim an issue, generate a fix, and open a PR."""
    env = require_env("GEMINI_API_KEY", "GITHUB_TOKEN", "ISSUE_NUMBER", "GITHUB_REPOSITORY")
    issue_number = int(env["ISSUE_NUMBER"])
    gh = GithubClient(env["GITHUB_TOKEN"], env["GITHUB_REPOSITORY"])

    if not gh.claim_issue(issue_number):
        sys.exit(0)

    gemini = GeminiClient(env["GEMINI_API_KEY"], model=GEMINI_MODEL_PRO)
    queue = gh.read_queue()
    selected = select_issue(queue, str(issue_number))
    issue = gh.get_issue(issue_number)
    repo_tree = _build_memory_context(gh)

    prompt = (
        f"Issue #{issue_number}: {issue.get('title', '')}\n"
        f"Body:\n{issue.get('body', '')}\n\n"
        f"Repo tree:\n{repo_tree}\n\n"
        f"Queued item:\n{selected or {}}"
    )
    generated_code = extract_code(gemini.generate(prompt))
    passed, feedback = preflight(generated_code, gemini)
    if not passed:
        gh.post_comment(issue_number, feedback)
        return

    test_code = extract_code(
        gemini.generate(
            f"Write a focused unittest for issue #{issue_number}.\n\nCode:\n{generated_code[:4000]}"
        )
    )

    branch_name = f"ai-fix/{issue_number}"
    main_sha = gh.get_main_sha()
    if main_sha:
        gh.create_branch(branch_name, main_sha)

    gh.write_file(
        f"scripts/fix_issue_{issue_number}.py",
        generated_code,
        "",
        f"fix(ai): implement issue #{issue_number}",
        branch=branch_name,
    )
    gh.write_file(
        f"tests/test_issue_{issue_number}.py",
        test_code,
        "",
        f"test(ai): cover issue #{issue_number}",
        branch=branch_name,
    )

    pr = gh.create_pr(
        branch_name,
        f"fix(ai-generated): resolve issue #{issue_number}",
        f"Closes #{issue_number}",
    )
    queue["in_progress"] = {
        "issue_number": issue_number,
        "pr_number": pr.get("number"),
        "brief": issue.get("title", ""),
    }
    gh.write_queue(queue)
    gh.append_log("Delta", f"Issue #{issue_number}", "Opened PR", "in_progress", branch_name)
