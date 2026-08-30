# Review a completed change

Start one fresh reviewer agent after a completed code change. Start it without inherited conversation history (`fork_turns: "none"`) and provide only the brief below. The reviewer inspects the implementation without prior exposure to the active agent's reasoning.

## Build the brief

Provide:

- The requested outcome and completed slice, when the task has slices.
- Accepted decisions and held boundaries.
- Relevant repository instructions and authoritative specifications.
- The exact current changes and the base they should be compared with.
- Verification already completed and any known verification gap.
- Permission to inspect surrounding code and run focused, non-destructive checks.

Do not provide the implementer's rationale, self-assessment, suspected findings, or earlier review discussion before the independent review.

## Reviewer instructions

Review the complete change for correctness, required behavior, structure, test strength, and repository rules. Inspect surrounding architecture where needed to judge ownership, state, boundaries, and acceptance paths.

If you cannot confidently trace the affected ownership, boundaries, or runtime flow, read [`how`](../../how/SKILL.md) and use its Explain flow before judging the architecture.

Read the principle index, independently select the principles that match the task and diff, then read those leaves in full. Do not load every principle.

For each material finding, report:

- Severity and a concise title.
- File and line evidence.
- The failure mechanism and concrete consequence.
- Whether the issue was introduced by the change.
- Whether it blocks completion.

Also report focused verification performed, principles applied, and a final `ready` or `not ready` verdict. No findings is a valid result. Omit speculative observations and exhaustive cleared-category prose.

Do not edit code.

## Process the review

The active agent classifies findings as local or systemic before editing. A finding is systemic when it challenges the chosen boundary, state model, acceptance path, or task scope.

Re-ground before fixing when any of these occurs:

- The chosen seam bypasses the behavior the task exists to prove.
- Two findings share an underlying state or ownership problem.
- Static checks pass but the real user, deployment, migration, or operator journey remains unproved.
- A correction materially changes the plan or introduces another abstraction.
- A second full review discovers a new material issue.
- The active agent cannot explain the current architecture and acceptance proof briefly.

After local fixes, ask the same reviewer to verify its original findings. Run a new full review only after material redesign. If another material problem remains, re-plan or split the work.
