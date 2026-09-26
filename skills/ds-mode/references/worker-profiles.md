# Worker profiles

| Role | Runtime | Model | Thinking |
|---|---|---|---|
| `explore` | `pi` | `openai-codex` / `gpt-6-sol` | `medium` |
| `implement`, hardest changes | `pi` | `openai-codex` / `gpt-6-astra` | `high` |
| `implement`, default | `pi` | `openai-codex` / `gpt-6-sol` | `high` |
| `implement`, trivial mechanical edits | `pi` | `openai-codex` / `gpt-6-sol` | `medium` |
| `review`, `judgment` | `claude` | `anthropic` / `claude-opus-5-5` | `high` |
| Second opinion on Anthropic work | `pi` | `openai-codex` / `gpt-6-astra` | `high` |

`pi` is the OpenAI family and `claude` the Anthropic family. The hardest changes are cross-cutting design, gnarly concurrency, and subtle algorithms. A second opinion on OpenAI work uses the `review` row.

Disclose review composition by family, for example `Cross-family review. The writer used OpenAI gpt-6-sol. The reviewer used Anthropic claude-opus-5-5.` Label a review within one family `same-family independent review`.
