# Worker profiles

All roles require fresh contexts for new assignments. Continuation of an existing task uses the same worker conversation, not a fresh review. Use the dispatch contract in [workers.md](workers.md).

## Pi model and reasoning settings

The current Pi-Herdr adapter inherits the spawning agent's selected model for every new worker, including nested workers. It has no per-spawn model or effort parameters. Cold continuation uses the worker's saved model, not the caller's current selection. The lead retains its own thinking setting.

The adapter requests these fixed Pi thinking levels by role. This table is the authoritative role profile:

| Role | Pi thinking level |
|---|---|
| Explore | low |
| Implement | medium |
| Review | medium |
| Judgment | high |

Pi must support the selected model, and the child must have the provider configuration and authentication it needs. Adapter launch support is not evidence that a model can execute every ds-mode phase well. These thinking labels are Pi settings, not portable promises about provider reasoning budgets. Verify the selected model's supported settings and record any effective difference rather than claiming identical effort across providers. Selecting a role at spawn selects its fixed setting. A brief cannot override the tool schema.

## Review disclosure

Fresh Review and Judgment workers provide independent context. Record the actual provider, model, and known family for the lead, candidates, and reviewers. Use runtime identity and native message evidence, not an assumed default. Mark unknown family or effective reasoning settings as unknown.

Label a review `same-family independent review` only when the recorded composition supports it. Same-model and same-family runs are not model-family diversity. Different provider names and higher thinking effort do not establish different underlying model families. If the run actually includes different families, name them and the workers using each. Fresh-context independence remains mandatory in either case; multiple providers are not required.
