# Worker profiles

Use [workers.md](workers.md) for briefs, fresh contexts, and task control.

## Model and effort

New workers use the spawning agent's selected model, including when a worker launches another worker. Restarting a dead worker restores its saved model, not the caller's current model.

The Pi-Herdr adapter sets thinking effort by role:

| Role | Pi thinking level |
|---|---|
| Explore | low |
| Implement | medium |
| Review | medium |
| Judgment | high |

The lead keeps its own thinking setting. `spawn_agent` has no model or effort override. These settings come from adapter code; editing this file or naming an override in a brief does not change them.

The child needs Pi support, provider configuration, and authentication for its model. Pi's thinking levels do not imply equal reasoning budgets across providers. Verify the model's supported thinking settings and record any effective difference. Mark unavailable effective settings as unknown.

## Review disclosure

Record the provider, model, known family, and effective thinking setting for the lead, candidates, and reviewers. Use runtime records and native messages. Mark unknown values as unknown.

Use `same-family independent review` when the records support that label. If different families took part, name them and their workers. Different provider names or effort levels alone do not prove family diversity.

Fresh contexts are required for independent review; multiple providers are not. A follow-up in the original worker conversation is not a fresh review.
