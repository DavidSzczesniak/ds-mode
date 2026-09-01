# Review a ds-mode dogfooding session

`Last reviewed: 2026-09`

Use this guide after a completed ds-mode session. Record observations, not success stories. Cite the transcript, Pi session JSONL, diff, command output, or artifact behind each claim.

## Inspect the session

1. Read the lead transcript, named worker briefs, persisted Pi session JSONL, and reviewer output.
2. Compare the lead's `update_plan` with the matched playbook. Record verbatim steps, explicit skips, and dropped steps.
3. Inspect the target repository before blaming ds-mode for a repeated failure.
4. Check the real artifacts behind every proof claim.
5. Classify friction as a target-project problem, a ds-mode problem, or unresolved.
6. Recommend the smallest change supported by repeated evidence.

Keep deliberate exclusions out of this review. Cloud agents, Graphite, Shipping, Orchestrate, Autopilot, polling, and automatic merging are inactive design decisions. They are not failed dogfooding experiments.

## Questions to test

1. Are named Pi sessions enough for occasional manual recovery?
2. Would a persistent-worker launcher add more complexity than value?
3. Do mandatory How, Architect consideration, and delegated implementation improve results enough to justify their cost?
4. Do conditional worktrees prevent collisions without leaving too many stale trees?
5. Does Show Me Your Work produce a truthful, useful trail with its complete contract?
6. Does a fresh same-family reviewer find useful issues despite the missing model-family diversity?
7. Does Codex `update_plan` preserve verbatim playbook steps and visible skips?
8. Do Control UI and Control CLI produce better proof than ad hoc verification instructions?
9. Does one-shot PR Check and Triage retain the useful part of Babysit?
10. Are the four role profiles sufficient without pstack's larger model matrix?

## Record an observation

For each question, record:

- The task and repository.
- The lead session and Pi session IDs.
- The exact behavior observed.
- Evidence paths or command output.
- Cost or friction.
- Whether the observation repeated.
- The smallest proposed response, if any.

Do not weaken a retained pstack contract from one observation. Link the evidence in `docs/upstream-deviations.tsv` when it supports a change.
