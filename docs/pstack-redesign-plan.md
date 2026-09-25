# Pstack-based ds-mode redesign

Status: implemented on 2026-09-01. Revised on 2026-09-24 to restore pstack's development loop: Pi leads with pi-herdr-agents workers, reversible external actions proceed without asking (team chat asks first), and Opening a PR ends every code-changing playbook unless a "local only" session override applies. Re-pinned to pstack `fadd237` on 2026-09-25. `docs/upstream-deviations.tsv` records each difference from pstack.

## Goal

Make pstack the base methodology for ds-mode. Preserve a complete pinned upstream tree, adapt the active workflow for a Codex lead and local Pi workers, and keep every departure from upstream visible.

The initial workflow covers local investigation, implementation, verification, and explicit GitHub PR work. It does not recreate pstack's cloud-agent, Graphite, fleet, polling, or automatic landing system.

## Source pins

Import and record these sources without modifying them:

- Pstack at commit `fadd23794c0075468eb8964b0fd93e06e09486ad`.
- Cursor Team Kit's `control-ui`, `control-cli`, and `deslop` skills at commit `fadd23794c0075468eb8964b0fd93e06e09486ad`.
- FirstMate at commit `355f46fe5528ccc9790481171bf9da48dee2e90d` remains research evidence only. It is not a dependency or methodology layer.

For each import, record the repository URL, commit, import date, license, and hashes. Keep the complete pstack tree under `upstream/pstack/`. Keep the selected Cursor Team Kit sources in a separate pinned location.

## Implementation sequence

### 1. Import the upstream sources

1. Copy the complete pinned pstack tree into `upstream/pstack/`.
2. Copy the three approved Cursor Team Kit skills into their own pinned source tree.
3. Add source metadata and license notices.
4. Add a small lineage check. It must detect edits to verbatim sources and active adaptations missing from the deviation manifest.

Completion criterion: the committed snapshots match their recorded hashes, and the lineage check reports no unexplained differences.

### 2. Build the active ds-mode adaptation

1. Replace `skills/ds-mode/` with a directly adapted copy of pstack's `poteto-mode`.
2. Keep the active name `ds-mode`. Do not expose a second `poteto-mode` entry point.
3. Preserve pstack prose unless an approved host substitution or route decision requires a change.
4. Activate all 21 pstack principles with their upstream bodies unchanged.
5. Copy and adapt the approved playbooks and supporting skills.
6. Remove the old mandatory tracer-bullet slicing rules and the unconditional fresh-review-after-every-slice rule.
7. Use pstack's task-shaped, verifiable execution units and risk-scaled review behavior.

Completion criterion: ds-mode reads as one direct workflow. It does not require an override layer to cancel Cursor, cloud, or Graphite instructions.

### 3. Add the Codex-to-Pi adapter

Codex is the initial lead. Pi supplies workers.

- The Codex lead owns design, the visible `update_plan` checklist, worker briefs, diff review, and final proof.
- Cursor-style shared worker todos are not assumed. Pstack only needs the lead's checklist.
- Use one generic Pi worker profile. Each dispatch states the role, task contract, scope, writable paths, verification requirement, model profile, edit permission, and report shape.
- Launch background workers as named, persisted Pi sessions. Do not use `--no-session`.
- Display or return the Pi session ID at launch. Use Pi's session picker or exact session ID for manual recovery.
- The lead may inspect and plan while a writer runs, but it must not mutate the writer's checkout.

Use this default profile:

| Role | Model | Thinking |
|---|---|---:|
| Explore | GPT-5.6 Sol | `medium` |
| Implement | GPT-5.6 Sol | `medium` |
| Review | GPT-5.6 Sol | `high` |
| Judgment | GPT-5.6 Sol | `xhigh` |

A dispatch may override the model or thinking level. Keep these defaults in one small ds-mode reference file. Do not add a global configuration file or setup command initially.

Completion criterion: a Codex lead can launch, identify, inspect, and manually resume one Pi worker through documented Pi commands.

### 4. Adapt supporting skills

- Install pstack's `tdd` as the only active `tdd` skill. Matt Pocock's local TDD skill has been removed and is not retained in this repository.
- Preserve pstack's Authoring a Skill playbook. Replace Cursor's unavailable `create-skill` target with `writing-for-agents`, retain pstack's validation steps, and run the Codex skill validator.
- Install Create Verification Skill, Maintain Verification Skill, and Reflect for explicit invocation. Do not route normal completed work through them.
- Preserve Show Me Your Work's triggers, append-only TSV, helper, evidence pointers, transcript reconciliation, fresh review, `Attention` handback, and local-by-default policy.
- Review a Show Me Your Work trail in a fresh judgment-profile session. Label the result `same-family independent review` while only GPT models are configured. Do not claim that a higher thinking level supplies model-family diversity.
- Keep the decision trail separate from process state. Agent prose records reasoning. Deterministic tools own process identity and lifecycle state.
- Import pinned `control-ui`, `control-cli`, and `deslop` as active dependencies.
- Retain the other Matt-derived skills in the repository without routing to them from ds-mode, except for the approved Authoring a Skill substitution.

Completion criterion: every retained pstack dependency resolves to an installed skill or an explicit, documented host substitution.

### 5. Adapt playbook routing

Keep these local playbooks active:

- Investigation
- Bug Fix
- Perf Issue
- Hillclimb
- Runtime Forensics
- Trace Forensics
- Feature
- Refactoring
- Prototype
- Visual Parity
- Authoring a Skill
- Eval
- Autonomous Run
- Multi-phase Plan
- Session Pickup
- Pause Safely
- Worktree Cleanup
- Opening a PR
- PR Check and Triage
- Shipping, without Graphite: it re-checks the verdicts Opening a PR posts and merges only on a merge request

Replace Babysit with one-shot PR Check and Triage. It may inspect CI, review comments, conflicts, and current PR state when requested. It does not poll, retry indefinitely, merge, or keep a queue alive.

Keep these routes in the pinned upstream tree but remove them from active routing:

- Babysit
- Orchestrate
- Autopilot Full
- Autopilot Stack

Do not add cloud agents, Graphite stacks, multi-day queues, scheduled polling, automatic PR responses, automatic merging, or cloud-environment reproduction.

Completion criterion: every upstream playbook has an active, replaced, or inactive status in the deviation manifest.

### 6. Apply the Git and worktree contract

- One writer may use a clean or dedicated active checkout. The lead must not mutate it concurrently.
- Parallel writers, competing experiments, and tracked-file conflicts require separate worktrees with disjoint ownership.
- Untracked files alone do not make a checkout dirty. Never delete, overwrite, or adopt them incidentally.
- Stage and commit verified local units by default after the repository instructions have been updated.
- Push and open a PR at the end of code-changing playbooks, as pstack does, unless the session is local only. Create a remote or merge only when requested. (Revised 2026-09-24; originally push and PR only on request.)
- Remove the two conflicting Git and worktree restrictions from `AGENTS.md`. Do not replace them with new repository-level wording in that edit.

Completion criterion: representative one-writer and parallel-writer scenarios select the expected checkout arrangement without risking tracked or untracked work.

### 7. Update documentation

- Add a section-specific deviation manifest.
- Rewrite `docs/dogfooding.md` around the approved hypotheses below.
- Update `README.md` only where installation, lineage, routing, or supported behavior changes.
- Retain the research reports under `docs/research/` as design evidence.
- Keep removed capabilities separate from dogfooding hypotheses. Removed routes are deliberate workflow exclusions, not failed experiments.

Each deviation entry records:

- upstream path and commit;
- exact section or step;
- status as `verbatim`, `host substitution`, `inactive`, or `prototype pending`;
- original dependency;
- local treatment;
- reason;
- reconsideration trigger;
- dogfooding evidence when available.

Completion criterion: a reviewer can locate every active departure from upstream without reconstructing it from prose or Git history.

### 8. Verify the implementation

Run the smallest checks that prove each changed contract:

1. Validate every changed skill with the Codex skill validator.
2. Check all active cross-skill and playbook references.
3. Verify pinned snapshots against their recorded hashes.
4. Run the installer against an isolated temporary destination.
5. Exercise representative Feature and Bug Fix flows, including pstack TDD.
6. Re-run the issue 203 planning case against the new task-shaped planning contract.
7. Exercise parallel read-only investigation and one background writer.
8. Exercise a conditional parallel-writer worktree case.
9. Produce and audit a Show Me Your Work trail with same-family independent review.
10. Verify Control UI and Control CLI against real artifacts.
11. Exercise one-shot PR Check and Triage.
12. Exercise Pause Safely and Session Pickup with a persisted Pi session.
13. Inspect the real diff and runtime artifacts rather than treating compilation as proof.

After the implementation and checks, give one fresh reviewer agent the task contract, repository rules, exact diff, and completed verification. Withhold the implementer's rationale until that review finishes.

Do not change the active global installation during these checks. Run `scripts/install.sh` against `~/.agents/skills` only when the user requests it.

## Lineage and conflict map

| Concern | Authority | Previous conflict | Resolution |
|---|---|---|---|
| Base methodology | Pstack | Pstack, tracer bullets, and bootstrap rules had equal weight | Pstack is authoritative |
| Work decomposition | Pstack playbooks | Mandatory tracer-bullet slices | Use task-shaped verifiable units |
| Principles | Pstack's 21 leaves | Eighteen active and three held | Activate all 21 unchanged |
| Planning state | Pstack checklist contract | Assumed shared worker todos | Codex lead owns `update_plan`; workers report results |
| Delegation | Pstack ownership with local adapter | Cursor Task and cloud-agent assumptions | Codex launches named Pi sessions |
| Model selection | Local host adapter | Large multi-model matrix | GPT-5.6 Sol with four effort profiles |
| Trail review | Show Me Your Work | Another model family is unavailable | Use a fresh same-family judgment session and disclose the deviation |
| Long-run evidence | Show Me Your Work | Proposed trimming before evidence existed | Preserve the complete upstream contract and dogfood it |
| Runtime state | Pi and the external launcher experiment | Agent prose could become lifecycle truth | Keep deterministic process state separate from decision trails |
| Worktrees | Pstack shared-state principles | Blanket branch and worktree prohibition | Isolate according to writers and actual conflicts |
| Untracked files | Local safety rule | Untracked files could be treated as disposable dirt | Protect them from deletion, overwrite, and incidental adoption |
| Git delivery | Pstack sequencing with local policy | Commits required explicit approval | Commit verified local units; request approval for remote actions |
| PR operation | Local GitHub adapter | Graphite, polling, and automatic landing | Use explicit GitHub actions and one-shot Check and Triage |
| UI and CLI proof | Cursor Team Kit | Control tooling was assumed unavailable | Import pinned Control UI and Control CLI |
| Code cleanup | Cursor Team Kit | Pstack's `/deslop` dependency was missing | Import pinned Deslop |
| TDD | Pstack | Matt and pstack used the same installed name | Keep pstack TDD and remove Matt TDD |
| Skill authoring | Pstack plus repository rules | Cursor's built-in `create-skill` is unavailable | Use `writing-for-agents` and the Codex validator |
| Retrospectives | Explicit supporting skills | Reflection risked becoming mandatory | Keep Reflect user-invoked |
| Cloud orchestration | Inactive upstream routes | Unsupported cloud and fleet assumptions | Preserve lineage and reconsider only after the workflow changes |
| FirstMate | Research evidence | Its fleet system exceeds the local need | Borrow ideas only for an external launcher experiment |
| Existing ds-mode rules | Dogfooding evidence | Bootstrap hypotheses had become policy | Return them to explicit hypotheses |

## Dogfooding questions

Test these claims after the rewrite:

1. Named Pi sessions are enough for occasional manual recovery.
2. A persistent-worker launcher would add more complexity than value.
3. Mandatory How, Architect consideration, and delegated implementation improve results enough to justify their cost.
4. Conditional worktrees prevent collisions without accumulating too many stale trees.
5. Show Me Your Work produces a truthful and useful trail when used with its complete contract.
6. A same-family fresh reviewer still finds useful issues despite the missing model-family diversity.
7. Codex `update_plan` preserves verbatim playbook steps and visible skips.
8. Control UI and Control CLI produce better proof than ad hoc verification instructions.
9. One-shot PR Check and Triage retain the useful part of Babysit.
10. The four-role effort profile is sufficient without pstack's larger model matrix.

Record observations rather than success stories. Cite dogfooding evidence before weakening a retained pstack contract.

## External launcher experiment

Keep this experiment outside ds-mode until it earns adoption.

Compare direct Codex launch of a named Pi session with a thin wrapper that adds only:

- atomic task metadata;
- task and incarnation IDs;
- durable brief and result paths;
- PID, Pi session ID, checkout, and read or write mode;
- exact status, resume, stop, and safe cleanup operations.

Test normal completion, launcher interruption, killed Pi, stale PID reuse, fresh-shell recovery, and late output from an old incarnation.

Do not add queues, inboxes, watchers, automatic retries, daemons, backend abstractions, PR automation, or automatic worktree management. Adopt the wrapper only if it improves recovery enough to pay for its code and operating cost.
