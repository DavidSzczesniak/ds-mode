# Worker profiles

Use [workers.md](workers.md) for briefs and task control.

## Role, model, and thinking

Pass these values on every `spawn_agent` call. Set `model.provider` to `openai-codex`.

| `role` | `model.id` | `thinking` |
|---|---|---|
| `explore` | `gpt-6-sol` | `medium` |
| `implement` | `gpt-6-sol` | `high` |
| `review` | `gpt-6-astra` | `medium` |
| `judgment` | `gpt-6-astra` | `high` |

Worker settings are independent of the lead's. The adapter requires an explicit thinking level and rejects unsupported values before launch.

Follow-ups, reloads, and cold continuation retain the worker's settings, including changes made through Pi. `followup_task` has no model or thinking arguments.

## Independent review

Record the models and thinking levels used by the lead, candidates, and reviewers. A receipt's `selection` records task-start settings. Consult native session entries if settings changed during the task.

Label reviews within one known model family `same-family independent review`. For different families, name the families and their workers. If the family is unknown, say so. Different providers or thinking levels alone do not establish model-family diversity.

Independent review requires a fresh worker. A follow-up in the original conversation is not a fresh review.
