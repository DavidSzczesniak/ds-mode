# Worker profiles

Pass `role`, `runtime`, `model`, and `thinking` from this table on every `spawn_agent` call. A model is written `provider` / `id` and passed as `model: {provider, id}`.

| Role | Runtime | Model | Thinking |
|---|---|---|---|
| `explore` | `pi` | `openai-codex` / `gpt-6-sol` | `medium` |
| `implement`, hardest changes | `pi` | `openai-codex` / `gpt-6-astra` | `high` |
| `implement`, default | `pi` | `openai-codex` / `gpt-6-sol` | `high` |
| `implement`, trivial mechanical edits | `pi` | `openai-codex` / `gpt-6-sol` | `medium` |
| `review` | `claude` | `anthropic` / `claude-opus-5-5` | `high` |
| `judgment` | `claude` | `anthropic` / `claude-opus-5-5` | `high` |

`pi` workers are the OpenAI family. `claude` workers are the Anthropic family, running Claude Code on the user's subscription. The hardest changes are cross-cutting design, gnarly concurrency, and subtle algorithms. Name the implement tier in the brief.

A second opinion is the same prompt on the other family. For Anthropic work, use `openai-codex` / `gpt-6-astra` at `high` on `pi`. For OpenAI work, use the `review` row's Claude model.

Disclose review composition by family and worker, for example `cross-family review: writer OpenAI gpt-6-sol, reviewer Anthropic claude-opus-5-5`. Label a review within one family `same-family independent review`.
