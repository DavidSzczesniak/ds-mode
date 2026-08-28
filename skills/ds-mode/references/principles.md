# Principle index

`Status: ready for dogfooding`

The principle bodies were copied unchanged from dforge. The active agent selects from the active index after investigation, when the real task shape is known. The reviewer makes its own selection from the same index. Read a selected leaf in full. Do not load every leaf.

## Active principles

| Principle                                            | Read when                                                                   |
| ---------------------------------------------------- | --------------------------------------------------------------------------- |
| [`principle-boundary-discipline`](../../principle-boundary-discipline/SKILL.md)                                           | Wiring validation, error handling, or external adapters.                    |
| [`principle-build-the-lever`](../../principle-build-the-lever/SKILL.md)                                                   | Considering a reusable tool or deterministic verifier for non-trivial work. |
| [`principle-encode-lessons-in-structure`](../../principle-encode-lessons-in-structure/SKILL.md)                           | A correction appears to recur and may belong in code or tooling.            |
| [`principle-exhaust-the-design-space`](../../principle-exhaust-the-design-space/SKILL.md)                                 | A novel interaction or architecture choice has no useful precedent.         |
| [`principle-experience-first`](../../principle-experience-first/SKILL.md)                                                 | Product quality and implementation convenience conflict.                    |
| [`principle-fix-root-causes`](../../principle-fix-root-causes/SKILL.md)                                                   | Diagnosing a defect or performance regression.                              |
| [`principle-foundational-thinking`](../../principle-foundational-thinking/SKILL.md)                                      | Choosing core types, data structures, or shared state.                      |
| [`principle-laziness-protocol`](../../principle-laziness-protocol/SKILL.md)                                               | Shaping a change or considering additional machinery.                       |
| [`principle-make-operations-idempotent`](../../principle-make-operations-idempotent/SKILL.md)                             | Work must remain safe across retries or partial completion.                 |
| [`principle-migrate-callers-then-delete-legacy-apis`](../../principle-migrate-callers-then-delete-legacy-apis/SKILL.md)    | Replacing an internal API without external compatibility requirements.      |
| [`principle-minimize-reader-load`](../../principle-minimize-reader-load/SKILL.md)                                         | Code is difficult to trace or holds excessive hidden state.                 |
| [`principle-model-the-domain`](../../principle-model-the-domain/SKILL.md)                                                 | Stateful logic or repeated branching suggests a missing structure.          |
| [`principle-outcome-oriented-execution`](../../principle-outcome-oriented-execution/SKILL.md)                             | A planned rewrite or migration has explicit phase boundaries.               |
| [`principle-prove-it-works`](../../principle-prove-it-works/SKILL.md)                                                     | Selecting proof or deciding whether work is complete.                       |
| [`principle-redesign-from-first-principles`](../../principle-redesign-from-first-principles/SKILL.md)                     | A new requirement challenges the existing design.                           |
| [`principle-separate-before-serializing-shared-state`](../../principle-separate-before-serializing-shared-state/SKILL.md) | Concurrent actors may write the same state.                                 |
| [`principle-subtract-before-you-add`](../../principle-subtract-before-you-add/SKILL.md)                                   | An addition or rewrite may benefit from removing dead weight first.         |
| [`principle-type-system-discipline`](../../principle-type-system-discipline/SKILL.md)                                     | Designing types or signatures in a statically typed language.               |

## Held from v0

Do not select these leaves through ds-mode. Keep them available for explicit use and reconsider them only when dogfooding or a broader agent model supplies evidence.

| Principle                             | Reason held                                                                                |
| ------------------------------------- | ------------------------------------------------------------------------------------------ |
| `principle-guard-the-context-window`  | Its main response delegates bulk work, while v0 uses one active agent and one reviewer.    |
| `principle-never-block-on-the-human`  | Its review-after-the-fact posture conflicts with initial plan approval and held decisions. |
| `principle-sequence-verifiable-units` | Its per-edit sequencing can split coherent refactors and includes an unconditional rebase. |
