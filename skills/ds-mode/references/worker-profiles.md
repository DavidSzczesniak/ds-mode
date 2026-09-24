# Worker profiles

Use [workers.md](workers.md) for briefs and task control.

## Role, model, and thinking

Pass these values on every `spawn_agent` call. Set `model.provider` to `openai-codex`.

| `role` | `model.id` | `thinking` |
|---|---|---|
| `explore` | `gpt-6-sol` | `medium` |
| `implement` | by tier, below | by tier, below |
| `review` | `gpt-6-astra` | `medium` |
| `judgment` | `gpt-6-astra` | `high` |

Implement work tiers by difficulty; the role stays `implement`. The hardest changes (cross-cutting design, gnarly concurrency, subtle algorithms) go to the judgment tier when the task needs judgment or the intent is vague, and to the instruction-following tier when the work is a precisely specified sequence of steps to execute to the letter. Trivial mechanical edits go to the fast tier. Name the tier in the brief.

| Implement tier | `model.id` | `thinking` |
|---|---|---|
| Judgment: vague intent or cross-cutting design | `gpt-6-astra` | `high` |
| Instruction-following: precisely specified steps (default) | `gpt-6-sol` | `high` |
| Fast: trivial mechanical edits | `gpt-6-sol` | `medium` |

These tables are configuration. Retune a role or tier by changing its line.

Worker settings are independent of the lead's. The adapter requires an explicit thinking level and rejects unsupported values before launch.

Follow-ups, reloads, and cold continuation retain the worker's settings, including changes made through Pi. `followup_task` has no model or thinking arguments.

## Independent review

Record the models and thinking levels used by the lead, candidates, and reviewers. A receipt's `selection` records task-start settings. Consult native session entries if settings changed during the task.

Label reviews within one known model family `same-family independent review`. For different families, name the families and their workers. If the family is unknown, say so. Different providers or thinking levels alone do not establish model-family diversity.

Independent review requires a fresh worker. A follow-up in the original conversation is not a fresh review.
