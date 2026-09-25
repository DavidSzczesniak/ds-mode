# Worker profiles

Pass `role`, `runtime`, `model`, and `thinking` from this table on every `spawn_agent` call. A model is written `provider` / `id`.

| Role | Runtime | Model | Thinking |
|---|---|---|---|
| `explore` | `pi` | `openai-codex` / `gpt-6-sol` | `medium` |
| `implement`, hardest changes | `pi` | `openai-codex` / `gpt-6-astra` | `high` |
| `implement`, default | `pi` | `openai-codex` / `gpt-6-sol` | `high` |
| `implement`, trivial mechanical edits | `pi` | `openai-codex` / `gpt-6-sol` | `medium` |
| `review` | `claude` | `anthropic` / `claude-opus-5-5` | `high` |
| `judgment` | `claude` | `anthropic` / `claude-opus-5-5` | `high` |
| Swarm gates, live, and perf lane (`review` role) | `pi` | `openai-codex` / `gpt-6-sol` | `high` |
| Second opinion on Anthropic work | `pi` | `openai-codex` / `gpt-6-astra` | `high` |
| Second opinion on OpenAI work | `claude` | `anthropic` / `claude-opus-5-5` | `high` |

`pi` workers are the OpenAI family. `claude` workers are the Anthropic family. The hardest changes are cross-cutting design, gnarly concurrency, and subtle algorithms. Name the implement tier in the brief.

A second opinion reruns the same prompt and role on the second-opinion row for the family that did the work. Swarm lanes that drive the product or run gates stay on the code model, as upstream's swarm workers do. Audit lanes use the `review` row.

Disclose review composition by family and worker, for example `cross-family review: writer OpenAI gpt-6-sol, reviewer Anthropic claude-opus-5-5`. Label a review within one family `same-family independent review`.
