# ds-mode

ds-mode is a user-invoked engineering workflow for planning, implementing, proving, and reviewing a coding change. The active agent owns the change. One fresh reviewer agent checks completed code.

The initial repository is intentionally small. Its principle bodies remain unchanged from their source. Eighteen are active for dogfooding, and three incompatible with the v0 workflow remain held. Their explicit-only invocation metadata has been ported to Codex.

## Repository contents

- `skills/ds-mode/` contains the workflow and its planning, principle, and review references.
- `skills/how/` explains subsystem architecture, ownership, layering, and runtime flow.
- `skills/why/` investigates the motivation, history, and constraints behind code decisions.
- `skills/diagnosing-bugs/` runs a tight reproduction and hypothesis-testing loop for hard defects and performance regressions.
- `skills/principle-*/` contains the unchanged principle leaves. The ds-mode index owns active and held routing.
- `skills/grilling/` resolves material planning decisions when evidence cannot settle them.
- `skills/read-the-damn-docs/` grounds external and version-sensitive contracts in authoritative documentation.
- `skills/research/` investigates design patterns, industry standards, and material decisions against primary sources.
- `skills/unslop/` and `skills/writing-for-agents/` contain supporting writing guidance.
- `docs/dogfooding.md` guides transcript-based workflow reviews.
- `scripts/install.sh` links the reviewed skills into `~/.agents/skills`.

## Install

To install the dogfooding version, run:

```sh
./scripts/install.sh
```

The installer links this repository's skill directories into `~/.agents/skills`. It refuses to overwrite real files, real directories, or unrelated links. It does not configure another agent runtime, model selection, hooks, or global instructions.

## Credits

The `how` and `why` skills, principle leaves, and `unslop` derive from [pstack](https://github.com/cursor/plugins/tree/main/pstack) by Lauren Tan. `diagnosing-bugs`, `grilling`, `research`, and `writing-for-agents` come from [Matt Pocock's engineering skills](https://github.com/mattpocock/skills/tree/main/skills/engineering). Both projects use the MIT License. The retained license notices are in [LICENSE](./LICENSE).

`Last reviewed: 2026-08`
