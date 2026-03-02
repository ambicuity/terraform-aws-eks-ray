import os
import json
import urllib.request

api_key = os.environ.get("GEMINI_API_KEY")
if not api_key:
    # Try fetching from gh secret if possible? We can't easily read gh secrets.
    print("Cannot test locally without API key.")
    exit(0)

