# ds-mode

`Status: bootstrap, not installed`

ds-mode is a user-invoked engineering workflow for planning, implementing, proving, and reviewing a coding change. The active agent owns the change. One fresh reviewer agent checks completed code.

The initial repository is intentionally small. Its principles are copied unchanged and will be reviewed one at a time before ds-mode is installed for live work. The current Codex validator rejects their existing `user-invocable` frontmatter key; resolve that compatibility issue during the individual reviews.

## Repository contents

- `skills/ds-mode/` contains the workflow and its planning, principle, and review references.
- `skills/principle-*/` contains the unchanged principle leaves awaiting review.
- `skills/unslop/` and `skills/writing-for-agents/` contain supporting writing guidance.
- `docs/dogfooding.md` guides transcript-based workflow reviews.
- `scripts/install.sh` links the reviewed skills into `~/.agents/skills`.

## Install

Do not install the bootstrap version. After the principle review and routing are complete, run:

```sh
./scripts/install.sh
```

The installer links this repository's skill directories into `~/.agents/skills`. It replaces links to the old dforge checkout, but refuses to overwrite real files, real directories, or unrelated links. It does not configure another agent runtime, model selection, hooks, or global instructions.

## Credits

The principle leaves and `unslop` derive from [pstack](https://github.com/cursor/plugins/tree/main/pstack) by Lauren Tan. `writing-for-agents` comes from [Matt Pocock's engineering skills](https://github.com/mattpocock/skills/tree/main/skills/engineering). Both projects use the MIT License. The retained license notices are in [LICENSE](./LICENSE).

`Last reviewed: 2026-08`
