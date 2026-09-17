# ds-mode

ds-mode is a user-invoked, pstack-derived engineering workflow. A Codex lead owns design, the visible plan, worker briefs, diff review, and final proof. Fresh native Codex children handle exploration, implementation, review, and judgment.

The active workflow covers local investigation, implementation, verification, and requested GitHub PR work. Cloud agents, Graphite, polling, automatic merging, and fleet orchestration remain available only in the pinned source snapshot.

## Repository contents

- `skills/ds-mode/` contains the direct workflow, active playbooks, and the native Codex worker contract.
- `skills/principle-*/` contains all 21 pstack principle bodies, copied unchanged from the pin.
- `skills/tdd/` contains pstack TDD.
- `skills/pull-request/` prepares and creates GitHub PRs across projects, or repairs an existing title and body when requested. Use `$pull-request` independently of `$ds-mode`; it follows each repository's contribution rules and issue tracker.
- `skills/control-ui/`, `skills/control-cli/`, and `skills/deslop/` contain the pinned Cursor Team Kit control skills.
- `skills/architect/`, `skills/arena/`, `skills/how/`, `skills/why/`, and the other pstack supporting skills back the active routes.
- `skills/create-verification-skill/`, `skills/maintain-verification-skill/`, and `skills/reflect/` remain explicit invocations.
- Existing Matt Pocock-derived skills remain installed but are not routed from ds-mode.
- `upstream/` contains the complete pinned pstack tree and the selected Cursor Team Kit sources.
- `docs/upstream-deviations.tsv` records active substitutions and inactive routes.
- `scripts/check-lineage.sh` verifies source hashes, verbatim active copies, and manifest coverage.

## Install

Run:

```sh
./scripts/install.sh
```

The installer links every directory under `skills/` into `DS_MODE_SKILLS_DIR`, or `~/.agents/skills` when that variable is unset. It refuses to overwrite real paths or unrelated links. It remains skills-only. It does not configure Pi, models, hooks, or global instructions.

## Lineage

The source pin is Cursor plugins commit `b9ddc83c32972210b8a94d389130713e8eed346e`. `upstream/SOURCES.tsv` records repository URLs, tree hashes, import date, and licenses. `upstream/SHA256SUMS` records every imported file.

Run:

```sh
./scripts/check-lineage.sh
```

The full pstack snapshot retains inactive cloud, Graphite, shipping, orchestration, autopilot, and polling code for inspection. Active ds-mode replaces Babysit with one-shot PR Check and Triage.

## Credits

Pstack and its principle skills are by Lauren Tan. The imported Cursor Team Kit skills are by Cursor. Existing Matt Pocock-derived skills include `diagnosing-bugs`, `grilling`, `research`, and `writing-for-agents`. All three sources use the MIT License. See [LICENSE](./LICENSE) and the license files under `upstream/`.

`Last reviewed: 2026-09`
