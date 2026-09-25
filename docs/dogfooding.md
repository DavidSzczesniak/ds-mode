# Review a ds-mode dogfooding session

`Last reviewed: 2026-09`

Use this guide after a completed ds-mode session. Record observations, not success stories. Cite the lead and child transcripts, diff, command output, or artifact behind each claim.

## Inspect the session

1. Read the lead transcript, worker briefs, child transcripts, and reviewer output. Resolve exact runtime records per [workers.md](../skills/ds-mode/references/workers.md). Use a parser only after checking that it understands that host's transcript format.
2. Compare the lead's `update_plan` with the matched playbook. Record verbatim steps, explicit skips, and dropped steps.
3. Inspect the target repository before blaming ds-mode for a repeated failure.
4. Check the real artifacts behind every proof claim.
5. Classify friction as a target-project problem, a ds-mode problem, or unresolved.
6. Recommend the smallest change supported by repeated evidence.

Keep deliberate exclusions out of this review. Cloud agents, Graphite, Orchestrate, Autopilot, polling, and automatic merging are inactive design decisions, not failed dogfooding experiments. Each PR gets an independent verdict when it opens. Shipping is active without Graphite: it re-checks verdicts and merges only on a merge request.

## Questions to test

1. Does the configured worker binding cover every ordinary role with fresh contexts and exact task identity?
2. Does continuation preserve enough context for bounded follow-up work without replaying the old task?
3. Do mandatory How, Architect consideration, and delegated implementation improve results enough to justify their cost?
4. Do conditional worktrees prevent collisions without leaving too many stale trees?
5. Does Show Me Your Work produce a truthful, useful trail with its complete contract?
6. Does a fresh reviewer find useful issues? Record the actual model-family composition, including same-family limits when applicable.
7. Does the lead's `update_plan` preserve verbatim playbook steps and visible skips while workers keep separate task plans?
8. Do Control UI and Control CLI produce better proof than ad hoc verification instructions?
9. Does one-shot PR Check and Triage retain the useful part of Babysit?
10. Are the four role profiles sufficient without pstack's larger model matrix?
11. Does each worker report give file pointers instead of raw source or command dumps?
12. Does the lead use multi-minute waits without progress checks, duplicated exploration, or truncated output?
13. Does the final lead context stay within the task's recorded budget after a fresh review passes?

## Record an observation

For each question, record:

- The task and repository.
- The runtime and adapter versions, lead session, and exact worker and task identities.
- The actual models, known families, and requested and effective reasoning settings per [worker-profiles.md](../skills/ds-mode/references/worker-profiles.md). Mark unknown settings as unknown.
- The exact behavior observed.
- Evidence paths or command output.
- Cost or friction, including final lead context, report sizes, waits, and truncations.
- Whether the observation repeated.
- The smallest proposed response, if any.

Pi's ability to launch a selected model is not proof of phase competence. Static wording and lineage checks do not show that earlier skipped workflow steps are fixed. Behavioral or model-comparison claims need observed runs with their model and runtime scope recorded.

Do not weaken a retained pstack contract from one observation. Link the evidence in `docs/upstream-deviations.tsv` when it supports a change.
