# Principle index

`Status: ready for dogfooding`

The principle bodies were copied unchanged from dforge. The active agent selects from the active index after investigation, when the real task shape is known. The reviewer makes its own selection from the same index. Read a selected leaf in full. Do not load every leaf.

## Active principles

| Principle                                            | Read when                                                                   |
| ---------------------------------------------------- | --------------------------------------------------------------------------- |
| `principle-boundary-discipline`                      | Wiring validation, error handling, or external adapters.                    |
| `principle-build-the-lever`                          | Considering a reusable tool or deterministic verifier for non-trivial work. |
| `principle-encode-lessons-in-structure`              | A correction appears to recur and may belong in code or tooling.            |
| `principle-exhaust-the-design-space`                 | A novel interaction or architecture choice has no useful precedent.         |
| `principle-experience-first`                         | Product quality and implementation convenience conflict.                    |
| `principle-fix-root-causes`                          | Diagnosing a defect or performance regression.                              |
| `principle-foundational-thinking`                    | Choosing core types, data structures, or shared state.                      |
| `principle-laziness-protocol`                        | Shaping a change or considering additional machinery.                       |
| `principle-make-operations-idempotent`               | Work must remain safe across retries or partial completion.                 |
| `principle-migrate-callers-then-delete-legacy-apis`  | Replacing an internal API without external compatibility requirements.      |
| `principle-minimize-reader-load`                     | Code is difficult to trace or holds excessive hidden state.                 |
| `principle-model-the-domain`                         | Stateful logic or repeated branching suggests a missing structure.          |
| `principle-outcome-oriented-execution`               | A planned rewrite or migration has explicit phase boundaries.               |
| `principle-prove-it-works`                           | Selecting proof or deciding whether work is complete.                       |
| `principle-redesign-from-first-principles`           | A new requirement challenges the existing design.                           |
| `principle-separate-before-serializing-shared-state` | Concurrent actors may write the same state.                                 |
| `principle-subtract-before-you-add`                  | An addition or rewrite may benefit from removing dead weight first.         |
| `principle-type-system-discipline`                   | Designing types or signatures in a statically typed language.               |

## Held from v0

Do not select these leaves through ds-mode. Keep them available for explicit use and reconsider them only when dogfooding or a broader agent model supplies evidence.

| Principle                             | Reason held                                                                                |
| ------------------------------------- | ------------------------------------------------------------------------------------------ |
| `principle-guard-the-context-window`  | Its main response delegates bulk work, while v0 uses one active agent and one reviewer.    |
| `principle-never-block-on-the-human`  | Its review-after-the-fact posture conflicts with initial plan approval and held decisions. |
| `principle-sequence-verifiable-units` | Its per-edit sequencing can split coherent refactors and includes an unconditional rebase. |
