### Multi-phase or multi-PR plan

**You own the plan, not the code. The plan is a checklist an owner runs box by box and the operator audits from the evidence.** The plan is the deliverable. Do not implement.

1. When the change is one or two files with an obvious approach, skip the plan. Say so and stop.
2. Settle open questions by prototype before you write. Run [Prototype](prototype.md) for each. Keep the branch, the SHA, and the screenshots for Appendix A. Ask the operator only about a product or preference call that no run can settle. Give options (the [**never-block-on-the-human**](../../principle-never-block-on-the-human/SKILL.md) principle skill).
3. Explore in fresh Explore workers per **Workers** in `../SKILL.md` (the [**guard-the-context-window**](../../principle-guard-the-context-window/SKILL.md) principle skill). Each returns file pointers, conventions, test commands, and entry points. No inlined dumps.
4. Copy the skeleton below into the plan file and fill every placeholder. Keep every heading and every sub-block in the order shown. One section per PR. One PR is one change with its own evidence (the [**sequence-verifiable-units**](../../principle-sequence-verifiable-units/SKILL.md) principle skill). Name the execution playbook in **How to read this**. `playbooks/autonomous-run.md` drives the units to the done predicate, each PR through its build playbook, and `playbooks/shipping.md` lands them.
5. Write under [**technical-writing**](../../technical-writing/SKILL.md) in full, then [**unslop**](../../unslop/SKILL.md). The body is one Diátaxis mode, how-to. Appendices hold explanation and reference. Each heading states the task or the finding. No long dashes. No mid-sentence colons.
6. Run `node <this skill's directory>/scripts/check-plan.mjs <plan.md>` and fix every line it prints (the [**encode-lessons-in-structure**](../../principle-encode-lessons-in-structure/SKILL.md) principle skill).
7. Hand back. Post the plan path and the script's output, then stop. Execution starts on the operator's explicit go, under the execution playbook the plan names.

**Verification.** Tests alone are not sufficient verification. A PR is verified only when its unit, live, and perf boxes are all checked (the [**prove-it-works**](../../principle-prove-it-works/SKILL.md) principle skill). That sentence is the verification rule. Every verification block opens with it. The live block is mandatory. At least three lanes at the PR head drive the real surface through its control skill, per the [**swarm**](../../swarm/SKILL.md) skill; the plan sets the count for each PR. Each lane is a fresh Review worker. Each lane is one box with a concrete scenario, the screenshot it saves, and its pass predicate. One lane is the **Regression lane against trunk.** It runs the same load-bearing scenario on trunk and head. If trunk does not have the feature, the lane records that fact and gates the behavior the diff adds plus the end state the user waits for instead of inventing a trunk result. The perf gate is dual-sided. Trunk and head must both produce the named metric. If trunk lacks the feature, also isolate the work the diff adds and set an absolute budget for that work plus the end-to-end state the user waits for. Do not claim a ratio between unlike scenarios. The perf block names the metric, the interleaved probe, the trunk baseline measured first, and the rule with the number that fails. A PR that changes an interaction is review-gated. The operator reviews it with screenshots and a video, attached to the PR and posted in chat, before merge. A PR that changes no interaction writes `**Review gate.** None. <PR id> is not review-gated.` and no boxes under it.

**Control skill.** Pick it by surface. Browser, Electron, and web UIs use [control-ui](../../control-ui/SKILL.md). CLIs and TUIs use [control-cli](../../control-cli/SKILL.md). Native mobile uses whatever simulator-driving skill the repo has. A PR that touches two surfaces gets lanes on both. A surface with no control skill is a risk in Appendix C, and its live block still names how each lane drives it.

````markdown
# <Program> plan

<Under ten lines. What changes, for whom, the rule the program enforces, and the PR ids in order.>

## How to read this

One box is one unit of work. Every box names the evidence that checks it. A nested box is a sub-step of the box above it. Check a box only when its evidence exists, a file, a log line, a screenshot, a test run, or a SHA. The body is a how-to. The appendices explain and record.

The program runs `playbooks/autonomous-run.md` over the PRs, each through its build playbook, and `playbooks/shipping.md` for landing. The swarm verdict below is each PR's independent verdict. <Who merges, and which PR ids are the operator's items that stop at merge-ready.>

Tests alone are not sufficient verification. A PR is verified only when its unit, live, and perf boxes are all checked.

## Program checklist

### Arm the program

- [ ] State the protocol and this plan to the operator, then stop. Start execution only on the operator's explicit go.
- [ ] On the go, state the done predicate in `update_plan`. "<The plan path, the PR ids in order, the verification rule, who merges, and the done condition.>"
- [ ] At every PR boundary, post a short status message to the operator in chat naming each tracked change that no earlier status message reported, such as a PR opened, a round launched or closed, a verdict, a merge, a stuck agent and the action taken, a blocker added or cleared, or a decision only the operator can make. Name every such change and nothing else. Do not repeat a table, the merged list, or an unchanged blocker.
- [ ] On the operator's hold or stand-down, send every owner a zero-writes order at once. Interrupt each by its canonical child target.

### Spawn owners

- [ ] Spawn one Implement worker per PR as its owner, per **Workers** in `../SKILL.md`, with the full lifecycle of its build playbook.
- [ ] Follow this dependency graph. Start dependent work only after its parent merges, or base it on the parent branch.
  - [ ] <PR id> and <PR id> are independent and first. Both branch from `main`.
  - [ ] <PR id> after <PR id>.
- [ ] Hold the file boundaries. <PR id or class> touches only `<glob>`.
- [ ] Hold the review gate. <PR ids> change an interaction. They wait for the operator's review of screenshots and a video before merge.

### PR mechanics, for every PR

- [ ] Open the PR ready, never draft, per [Opening a PR](opening-a-pr.md).
- [ ] Run the repo's lint and typecheck once before the PR-facing push. Push with hooks on.
- [ ] Run [deslop](../../deslop/SKILL.md) before each commit and [no-comments](../../no-comments/SKILL.md) before review.
- [ ] Triage every Bugbot and security-reviewer comment per `../references/bugbot-triage.md`.
- [ ] Rebase onto current trunk before opening the PR. Keep that merge base in fix rounds. Rebase again only at merge prep, on a `git merge-tree` conflict with trunk, or on a CI failure that comes from a change on trunk.

### Verdict and merge, for every PR

- [ ] At the head SHA the PR opens with and at each later push that changes the patch, run the swarm per [swarm](../../swarm/SKILL.md). One gates lane. The live lanes from the PR's **Verify, live** block. The perf lane from its **Verify, perf** block. Two or more audit lanes, each with its own focus, that read the diff and the verification evidence and distrust the PR body. The lead audits the verification evidence in the owner's report before the verdict.
- [ ] Clean only when every lane is `PASS`. Post the verdict on the PR with its screenshots. Findings go back to the owner, including a defect that a lane filed as a note. A new head gets a fresh swarm and a fresh verdict, except for results that stay valid under the patch-id rule in [Shipping](shipping.md).
- [ ] Land per [Shipping](shipping.md), with its patch-id rule. Merge only on the operator's merge request.

### Boot recipe, for every live lane

Each live lane runs as a fresh Review worker at the PR head and drives the surface through its own control-skill session. Drive through [control-ui](../../control-ui/SKILL.md) or [control-cli](../../control-cli/SKILL.md).

- [ ] The lead, once. `git fetch origin <head-branch>` and create one worktree at `<head SHA>` for every lane.
- [ ] The lead, once. <Start the backend and the surface. Wait for ready. A CLI or TUI lane starts its own process through its control skill instead.>
- [ ] The lead, once. Create a second worktree at the trunk SHA and start a second backend and surface there on their own ports for the regression lane.
- [ ] Each lane. <Deliver input only through the control skill's commands, in its own session and with its own test data. Name the read-only diagnostics.>
- [ ] Each lane. Save every screenshot to `/tmp/swarm-<pr-id>/worker-<n>/<slug>.png` and return the paths with the report.

## <Task as a verb phrase> (<PR id>)

**Depends on.** <PR id, or None.>

**Files.**

- [ ] Edit `<path>`.
- [ ] Create `<path>`.
- [ ] Delete `<path>`.

**Build.**

- [ ] <One change. Name the symbol and the file.>

**You see.**

- [ ] <One observable result, with the exact log line or screen state.>

**Verify, unit.** Tests alone are not sufficient verification. A PR is verified only when its unit, live, and perf boxes are all checked.

- [ ] <Test file and the case it gains.> Run `<command>`.

**Verify, live.** Tests alone are not sufficient verification. A PR is verified only when its unit, live, and perf boxes are all checked. <Count> lanes at the PR head, per the boot recipe.

- [ ] Lane 1. Regression lane against trunk. Run <the same load-bearing scenario> at trunk and head. If trunk lacks the feature, record that and gate <the behavior the diff adds plus the end state the user waits for>. Save `<slug>.png`. Pass when <predicate>.
- [ ] Lane 2. <Scenario.> Save `<slug>.png`. Pass when <predicate>.
- [ ] Lane 3. <Scenario.> Save `<slug>.png`. Pass when <predicate>.

**Verify, perf.** Tests alone are not sufficient verification. A PR is verified only when its unit, live, and perf boxes are all checked.

- [ ] Metric. <What is measured at both trunk and head. If trunk lacks the feature, also name the diff-added work and the end-to-end state the user waits for.>
- [ ] Probe. <The command or procedure, run at trunk and at the head, interleaved. Both sides must produce the metric.>
- [ ] Baseline. Record the trunk <value> first.
- [ ] Rule. <Head against trunk, with the number that fails. If the scenarios differ, add absolute budgets for the diff-added work and the user-visible end state instead of an invalid ratio.>

**Review gate.** The operator reviews before merge.

- [ ] Copy lane <n> screenshots into `<media path>/<pr-id>-review-<slug>.png`.
- [ ] Record a 30 to 60 second video of the change in a lane. Save it as `<media path>/<pr-id>-review.mp4`.
- [ ] Attach the screenshots and the video to the PR (`gh pr comment --attach`) and post them in chat. Stop at merge-ready. Wait for the operator's click.

**Merge.**

- [ ] The lead's clean verdict at the exact head SHA.
- [ ] Bugbot triage done.
- [ ] Rebased onto current trunk after the verdict, patch-id unchanged.
- [ ] <The operator merges, or the lead merges per Shipping on the operator's merge request.>

## Close the program

- [ ] Every box above is checked with its evidence.
- [ ] Reply to the operator with the report the execution playbook names.

## Appendix A. Prototype evidence

<Each open question a prototype answered, with the branch, the SHA, and the artifact links. Each question that stays unproven.>

## Appendix B. Alternatives rejected

<Each approach weighed and why it lost.>

## Appendix C. Risks

<Each risk with the PR it lands in and what the owner watches.>

## Appendix D. Links and reading list

<Docs to read before editing. Which PRs get the `how` and `interrogate` skills. The trail per the `show-me-your-work` skill.>
````

**Reply:** the plan path, the PR ids with their dependencies and the review-gated set, what the prototypes proved and what stays unproven, and the check script's output.
