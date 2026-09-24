# ds-mode

ds-mode is a user-invoked, pstack-derived engineering workflow. The lead owns design, the visible plan, worker briefs, diff review, and final proof. Fresh workers handle exploration, implementation, review, and judgment.

The active workflow covers local investigation, implementation, verification, and GitHub PRs: Opening a PR ends every code-changing playbook unless the session is local only. Cloud agents, Graphite, polling, automatic merging, and fleet orchestration remain available only in the pinned source snapshot.

## Repository contents

- `skills/ds-mode/` contains the direct workflow, active playbooks, and the worker contract. Its [Opening a PR playbook](skills/ds-mode/playbooks/opening-a-pr.md) ends every code-changing playbook, and also proposes a PR or repairs its title or body when asked.
- `skills/principle-*/` contains all 21 pstack principle bodies, copied unchanged from the pin.
- `skills/tdd/` contains pstack TDD.
- `skills/control-ui/`, `skills/control-cli/`, and `skills/deslop/` contain the pinned Cursor Team Kit control skills.
- `skills/architect/`, `skills/arena/`, `skills/how/`, `skills/why/`, and the other pstack supporting skills back the active routes.
- `skills/create-verification-skill/`, `skills/maintain-verification-skill/`, and `skills/reflect/` remain explicit invocations.
- Existing Matt Pocock-derived skills remain installed. ds-mode routes only `writing-for-agents`, which replaces Cursor's built-in `create-skill` for agent-facing prose and the Authoring a Skill playbook.
- `upstream/` contains the complete pinned pstack tree and the selected Cursor Team Kit sources.
- `docs/upstream-deviations.tsv` records active substitutions and inactive routes.
- `scripts/check-lineage.sh` verifies source hashes, verbatim active copies, and manifest coverage.

## Runtime scope

The workflow uses generic lead and worker roles. The concrete [worker binding](skills/ds-mode/references/workers.md) documents `pi-herdr-agents` for Pi 0.87.0 in Herdr. The [profiles](skills/ds-mode/references/worker-profiles.md) document the configured GPT models and thinking levels for each role, and actual model-family disclosure. Other runtimes need verified equivalent controls; generic wording alone does not make them compatible.

After accepting results, the lead explicitly retires workers it no longer needs. Retirement closes their processes and tabs while preserving conversations for later follow-up. See the [worker closeout instructions](skills/ds-mode/references/workers.md#retire-idle-workers).

Pi support for a selected model does not prove that model can execute every workflow phase well. This wording port addresses a known host mismatch, not the skipped workflow steps observed in an earlier Pi journey. No model-comparison or behavioral success is claimed for this branch. Use the [dogfooding guide](docs/dogfooding.md) to record those results.

## Install

Only when changing the active installation, run:

```sh
./scripts/install.sh
```

The installer links every directory under `skills/` into `~/.agents/skills`, then links each entry into `~/.claude/skills`. Existing relative Claude links remain valid. It checks both destinations before adding links and refuses to overwrite real paths or unrelated links. It remains skills-only. It does not configure Pi, models, hooks, or global instructions.

Links follow the checkout used for installation. Editing skills or switching branches in that checkout changes the active skills without rerunning the installer.

Set `DS_MODE_SKILLS_DIR` and `DS_MODE_CLAUDE_SKILLS_DIR` to override the respective destinations. Set both variables when testing against temporary directories. Run `python3 scripts/check-install.py` to check installation, repeat runs, and conflict handling in isolated directories.

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
