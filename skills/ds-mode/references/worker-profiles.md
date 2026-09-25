# Worker profiles

Use [workers.md](workers.md) for briefs and task control.

## Role, runtime, model, and thinking

Pass `role`, `runtime`, `model`, and `thinking` from these tables on every `spawn_agent` call. The family column is for disclosure only.

| `role` | `runtime` | Family | `model` | `thinking` |
|---|---|---|---|---|
| `explore` | `pi` | OpenAI | `openai-codex` / `gpt-6-sol` | `medium` |
| `implement` | `pi` | OpenAI | by tier, below | by tier, below |
| `review` | `pi` | OpenAI | `openai-codex` / `gpt-6-astra` | `medium` |
| `judgment` | `pi` | OpenAI | `openai-codex` / `gpt-6-astra` | `high` |

A model is written `provider` / `id` and passed as `model: {provider, id}`.

Implement work tiers by difficulty; the role stays `implement`. The hardest changes (cross-cutting design, gnarly concurrency, subtle algorithms) go to the judgment tier, whether the task needs judgment on vague intent or is a precisely specified sequence of steps to execute to the letter. Trivial mechanical edits go to the fast tier. Name the tier in the brief.

| Implement tier | `runtime` | `model` | `thinking` |
|---|---|---|---|
| Judgment: the hardest changes | `pi` | `openai-codex` / `gpt-6-astra` | `high` |
| Instruction-following: everything else (default) | `pi` | `openai-codex` / `gpt-6-sol` | `high` |
| Fast: trivial mechanical edits | `pi` | `openai-codex` / `gpt-6-sol` | `medium` |

These tables are configuration. Retune a role or tier by changing its line.

Worker settings are independent of the lead's. The adapter requires an explicit thinking level and rejects unsupported values before launch. Levels are per model. A `pi` worker takes the Pi levels its model's catalogue entry supports. A `claude` worker takes Claude's effort levels: `low`, `medium`, `high`, `xhigh`, or `max`.

### Claude workers

`runtime: "claude"` starts Claude Code under the user's Claude subscription instead of a Pi child. `model.id` names the Claude model, and the adapter ignores `model.provider`. Claude workers are one-shot leaf workers. They cannot spawn workers or take follow-ups, so give new work to a fresh worker. If Claude is unavailable or out of quota, the step that needs it blocks. Report the blocker. Never substitute a worker from another family.

Follow-ups, reloads, and cold continuation retain the worker's settings, including changes made through Pi. `followup_task` has no model or thinking arguments.

## Independent review

Record the models and thinking levels used by the lead, candidates, and reviewers. A receipt's `selection` records task-start settings. Consult native session entries if settings changed during the task.

Label reviews within one known model family `same-family independent review`. For different families, name the families and their workers. If the family is unknown, say so. Different providers or thinking levels alone do not establish model-family diversity.

Independent review requires a fresh worker. A follow-up in the original conversation is not a fresh review.

Where pstack asks for a different model family, use one once it is configured here. Until then, a second opinion is the same prompt against the other configured model (`gpt-6-sol` or `gpt-6-astra`), labelled `same-family independent review`.
