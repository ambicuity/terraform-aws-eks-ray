# Using Gemini CLI as an Agent in GitHub Actions

The [`@google/gemini-cli`](https://geminicli.com/docs/) is now natively integrated into our GitHub Actions pipeline alongside our Custom Python Agents (Alpha, Beta, Gamma, Delta). This allows developers to construct lightweight, Shell-based AI agents directly within workflows.

## How to use it

To enable the `gemini` command in any new or existing workflow, simply add the setup step and provide the `GEMINI_API_KEY` to the environment block of your step:

```yaml
jobs:
  example-agent:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      # 1. Install Node.js & the Gemini CLI globally
      - name: Set up Gemini CLI
        uses: ./.github/actions/setup-gemini-cli

      # 2. Use the CLI organically in your bash scripts
      - name: Run lightweight Bash Agent
        env:
          GEMINI_API_KEY: ${{ secrets.GEMINI_API_KEY }}
        run: |
          # Piping context to the CLI
          git diff | gemini "Write a brief summary of these changes for the PR description"
          
          # Headless data extraction
          gemini --output-format json "Return a structured summary of the changes" > summary.json
```

## When to use Gemini CLI vs. Custom Python Agents
- **Gemini CLI:** Best for rapid prototyping, bash scripting, file summaries, log analysis, and simpler tasks where building a dedicated Python script is overkill.
- **Python Agents (Alpha/Beta...):** Best for workflows that require complex GitHub API interactions (like reading state, creating tags, committing files incrementally) where the `github` API library and complex state management are necessary.
