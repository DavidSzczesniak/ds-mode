### Autonomous run

**You own the exit condition. Define done, then drive to it without stopping.** For "going to bed", "run until done", or "keep going until X".

1. State the exit condition as a checkable predicate before the first iteration. A vague goal stalls. A predicate lets you stop.
2. Choose a bounded iteration and the evidence worth checking at its end. The Codex lead starts each iteration. It does not install a watcher, poll, or schedule an automatic retry.
3. Each iteration makes the smallest change the evidence justifies, verifies it against the predicate, commits if repository instructions allow and the change advanced, and discards changes that did not help. Sequence the work via the [**sequence-verifiable-units**](../../principle-sequence-verifiable-units/SKILL.md) principle skill.
4. Route local work through ds-mode. Keep the predicate as the main drive and return to it after each side fix. Surface irreversible actions, genuine product choices no experiment can settle, and real dead ends.
5. Checkpoint every iteration via the [**show-me-your-work**](../../show-me-your-work/SKILL.md) skill. Record what changed and whether the predicate moved.
6. Stop when the predicate is met. A plateau calls for a different approach. Surface a genuine dead end rather than spinning, and never relax the predicate to declare victory.

**Reply:** the exit condition, iterations run, what landed, what was discarded, and the final predicate state.
