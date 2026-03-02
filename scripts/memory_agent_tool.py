#!/usr/bin/env python3
# MIT License
# Copyright (c) 2026 ambicuity
"""
memory_agent_tool.py — CLI bridge for Gemini CLI to query project semantic memory.

The Gemini CLI uses this as a text/shell tool. It wraps `memory_retriever` and
`query_embedder` so the Agent can retrieve historical context, architectural decisions,
and semantic duplicates without writing Python.

Usage:
  python scripts/memory_agent_tool.py --query "how are GPUs scaled?" --k 5
  python scripts/memory_agent_tool.py --decisions-only
"""

import argparse
import json
import logging
import sys

from memory_retriever import MemoryRetriever
from query_embedder import embed_query

logger = logging.getLogger(__name__)

def main() -> None:
    parser = argparse.ArgumentParser(description="Query project semantic memory.")
    parser.add_argument("--query", type=str, required=False, help="Semantic search query")
    parser.add_argument("--k", type=int, default=5, help="Number of results to return")
    parser.add_argument("--decisions-only", action="store_true", help="Only return architectural decisions")
    parser.add_argument("--file-type", type=str, default=None, help="Filter by extension (e.g. python, terraform, markdown)")
    
    args = parser.parse_args()

    # If asking for decisions only
    if args.decisions_only:
        retriever = MemoryRetriever()
        decisions = retriever.search_decisions(query_embedding=[], k=args.k)
        print(json.dumps({"decisions": decisions}, indent=2))
        sys.exit(0)

    if not args.query:
        print("Error: --query is required unless --decisions-only is specified.", file=sys.stderr)
        sys.exit(1)

    # 1. Embed Query
    # This may return None if onnxruntime is missing, which is handled gracefully by MemoryRetriever
    query_vec = embed_query(args.query)

    # 2. Retrieve top-k blocks
    retriever = MemoryRetriever()
    results = retriever.top_k(
        query_embedding=query_vec,
        k=args.k,
        file_type=args.file_type,
        use_weighted_scoring=True
    )

    # 3. Output raw JSON for Gemini CLI to parse
    output = {
        "query": args.query,
        "results": [r.to_dict() for r in results]
    }
    print(json.dumps(output, indent=2))

if __name__ == "__main__":
    main()
