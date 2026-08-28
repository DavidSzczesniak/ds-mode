---
name: ds-mode
description: Work through a coding change with planning when needed, direct implementation, proportionate proof, and one fresh reviewer agent.
---

# ds-mode

Apply this mode to the current task until the user starts another task or opts out.

## Establish the task contract

Read the repository instructions and inspect the relevant code before choosing an approach. Keep a compact contract in the conversation:

- Requested outcome.
- Accepted decisions.
- Relevant constraints.
- Intended proof.

After investigation, read [references/principles.md](references/principles.md). Follow its review status and routing instructions.

## Ground the approach

Use repository code and documentation first for local behavior.

Read [`read-the-damn-docs`](../read-the-damn-docs/SKILL.md) before choosing or revising an approach that depends on an external, version-sensitive, unfamiliar, or possibly drifting contract. Follow its docs-first workflow in full.

Read [`research`](../research/SKILL.md) during investigation or planning when a larger change or material decision could benefit from established design patterns, industry standards, comparison of credible approaches, or reconciliation of several primary sources. Give the research agent the decision it must inform, the relevant local constraints, and any unacceptable consequence or invariant. Research may also re-ground later work when new evidence invalidates the current model.

## Decide whether to plan

Read [references/planning.md](references/planning.md) when the user requests a plan or the work contains a meaningful product decision, architecture choice, ownership-boundary change, or several dependent feature slices.

When a written plan is warranted, present it for approval once. After approval, continue without another approval between slices unless evidence changes an accepted decision, creates a held decision, materially changes the outcome, or reaches an irreversible action.

For work that does not warrant a written plan, briefly explain what will change, how it will work, and how you will prove it. Then proceed.

## Implement directly

The active agent owns investigation, planning, implementation, and proof. Do not delegate implementation.

For large feature work, plan tracer-bullet slices. Each slice delivers a narrow working capability with its own proof. Complete the implementation and review loop for one slice before starting the next, then check whether the remaining plan still holds.

Treat a refactor as one coherent change unless the actual code provides a natural reason to divide it. Preserve its behavior contract and prove that behavior after the structural change.

When unrelated cleanup or another defect appears, leave it unchanged unless it blocks the accepted outcome or makes the work unsafe. Report it with its practical benefit and likely size so the user can choose whether to include it.

Before adding an abstraction, compatibility path, workflow rule, agent role, persistent state, or special process, ask:

1. Is this fixing a repeated problem or one observation?
2. Does an existing mechanism already own it?
3. Can the need be represented directly where it applies?

Remove the proposed machinery when a direct change solves the task.

## Prove and review the change

Verify the completed code against the task's real behavior, artifact, value, or journey. Match the cost of proof to the scope and risk. A build or typecheck is supporting evidence when it does not exercise the accepted outcome.

After each completed code change, read [references/review-brief.md](references/review-brief.md) and start one fresh reviewer agent. The reviewer may run focused, non-destructive checks but does not edit code.

Classify each material finding before editing:

- **Local.** The design remains sound and the correction is contained.
- **Systemic.** The finding challenges the boundary, state model, acceptance path, or task scope.

For a systemic finding, stop editing and re-ground the change. State the missed invariant or acceptance criterion, identify its owner, reassess the design, choose whether to correct, revert, or split the work, and name the proof for the revised result. Return to the user when this changes an accepted product decision, architecture boundary, or outcome.

After fixes, ask the same reviewer to verify only its original findings. Start a second full review only after a material redesign. If that review finds another material issue, re-plan or split the work instead of starting another automatic review.

## Finish

The active agent decides whether the task is complete. Finish only when the task contract is satisfied, the real artifact has been checked, blocking findings are resolved, the final diff remains within the accepted work, and known gaps are reported.
