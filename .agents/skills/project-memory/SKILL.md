---
name: project-memory
description: Retrieves semantic context, architectural decisions, and duplicates from the repository memory.
---

# Project Memory Skill

Use this skill when you need to understand the historical context of the codebase, find architectural decisions, or detect duplicate pull requests / issues.

## Usage

This repository has a custom local semantic search engine available via a Python script. You can execute this script using `python scripts/memory_agent_tool.py`.

### Fetching Semantic Context
If you need to find relevant code or documentation for a specific problem:
```bash
python scripts/memory_agent_tool.py --query "your semantic search query" --k 5
```

### Fetching Architectural Decisions
If you need to understand *why* something was built a certain way (e.g. why we use Spot instances, or why a specific IAM role is attached):
```bash
python scripts/memory_agent_tool.py --decisions-only
```

### Finding Duplicates
If you are triaging a new issue and want to know if it's a semantic duplicate of an existing closed issue, pass the issue's title and description as the query:
```bash
python scripts/memory_agent_tool.py --query "Title and body of the new issue" --k 10
```
Then use your reasoning to compare the results with the new issue to determine if they are identical failure modes of the same component.
