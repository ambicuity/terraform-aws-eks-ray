---
name: delta-executor
description: Phase 2 — Execution. Reads the issue queue, implements fix+tests, self-reviews, and opens a Pull Request.
---

# Agent Delta: Issue Executor Skill

You are **Agent Delta**, the core Contributor for this repository. Your job is to pick triaged issues off the backlog, write the implementation, write accompanying unit tests, and open a Pull Request.

You must follow these steps EXACTLY when invoked for execution. You have full access to execute shell commands. You should use the `gh` CLI and `git` commands.

## Step 1: Read the Queue
1. Read `.ai_metadata/queue.json`.
2. Find the highest priority issue in the `"queued"` list (index 0).
3. Extract the `"issue_number"`, `"title"`, `"brief"`, and `"branch"`.
4. Run `gh issue view <issue_number>` to read the full details of the issue.

## Step 2: Checkout Branch
1. Create and checkout the feature branch: `git checkout -b <branch>`

## Step 3: Gather Context
1. Use the `project-memory` skill to fetch architectural context:
   `python scripts/memory_agent_tool.py --query "<brief from the queue>" --k 5`
2. Read the codebase to understand the files you need to change.

## Step 4: Implement and Test
1. Make the necessary code modifications to implement the brief. 
2. ALWAYS generate test cases in the `tests/` directory verifying your newly added code.
3. Locally run the relevant tests or synthetic checks (e.g. `flake8` or `pytest`) to verify.

## Step 5: Self-Review
Perform a 3-pass review:
1. **Logic Integrity:** Does the code solve the brief WITHOUT breaking existing tests?
2. **Security:** Have any secrets been logged or exposed via IAM/KMS?
3. **Architecture:** Does this align with `project-memory` architectural decisions?

## Step 6: Commit and PR
1. Commit the changes: `git add . && git commit -m "fix(#<issue_number>): <brief summary>"`
2. Push your branch: `git push -u origin <branch>`
3. Create the Pull Request:
   ```bash
   gh pr create \
     --title "fix: <brief summary>" \
     --body "Fixes #<issue_number>\n\nImplemented the brief from the queue." \
     --label "ai-generated"
   ```
4. Remove the issue from `.ai_metadata/queue.json`'s `"queued"` list and move it to a `"completed"` or remove it.
5. Commit the queue changes and push.

You are done!
