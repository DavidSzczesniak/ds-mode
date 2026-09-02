# Issue 202 dogfooding remediation plan

Status: Units 1 through 5 complete. Units 6 through 10 pending. Unit 5 approved native Codex children as the only ordinary worker path.

## Goal

Make worker delegation reliable, measurable, and cheap enough that ds-mode can depend on it. Repair the decision trail and blind-test boundaries exposed by the issue #202 planning run. Choose Pi workers, native Codex subagents, or a narrow combination from comparative evidence rather than preference.

Do not start issue #202 implementation dogfooding until the exit gate in this plan passes.

## Evidence from the planning run

Use these artifacts as the baseline:

- Codex lead session `01a05f2d-b3e7-7571-9d89-f649f379a309`.
- Final plan at `/home/david/code/work/talisman-development-kit/.scratch/plans/issue-202-clean-cut-development-environment.md`.
- Decision trail at `/home/david/code/work/talisman-development-kit/.scratch/audit/issue-202-plan.tsv`.
- Worker briefs under `/home/david/code/work/talisman-development-kit/.scratch/plans/issue-202/`.
- Worker streams under `/home/david/code/work/talisman-development-kit/.scratch/findings/issue-202/`.
- Persisted Pi sessions under `/home/david/.pi/agent/sessions/--home-david-code-work-talisman-development-kit--/`.

The run established these facts:

- A Pi WebSocket emitted no events for 300 seconds. Pi then fell back to SSE and began work. The lead killed it about ten seconds later.
- The failed worker exposed session ID `01a05f32-6705-7734-a8f6-db709a57a7d3`, but Pi did not persist that session. Exact resume fails.
- The generic shell-background launch pattern did not survive Codex `exec_command`. Codex-managed foreground processes did survive.
- The lead made 178 execution calls and 63 wait calls. Its final turn used 238,454 of 258,400 context tokens.
- The three accepted Explore workers produced their first model-driven tool result in about 8.4 seconds and completed in 211 to 242 seconds.
- The lead read an issue #200 comment that embedded the withdrawn decomposition. Fresh workers could not restore blindness to the lead.
- The decision trail was useful but not append-only. It omitted launcher and transport failures, and its reviewer did not receive the Codex lead transcript.
- The last reviewer returned `not ready`. The lead fixed its finding but did not obtain a final independent pass.
- FirstMate commit `f42a6291d4335cc7e169660bd7114239c3830a08` confirms the proposed topology. Its coordinator launches Pi or Codex workers into Herdr-owned endpoints and keeps deterministic endpoint records. FirstMate still labels Herdr experimental and carries queues, watchers, mandatory worker worktrees, and delivery automation that ds-mode does not need.
- Herdr 0.8.0 officially supports one agent creating work for other agents, waiting on lifecycle state, and restoring Pi and Codex conversations from integration-reported session identities. A normal detach keeps processes alive. A Herdr server restart kills processes and relies on native conversation restore.

Treat the completed plan as useful design input. Do not call it a blind result.

## Constraints

- Keep all experiments local.
- Do not change the active global installation until the user asks.
- Do not inspect withdrawn issues #203 through #208, PR #209, or their commits during a new blind run.
- Preserve every current issue #202 artifact. New runs use unique paths and names.
- Use GPT-5.6 Sol with Explore and Implement at `medium` and Review and Judgment at `high`. Run outer Codex coordinators at `high`; they are process leads. Units 1 through 5 capped every Codex process at `high`.
- Disclose same-family review.
- Keep cloud agents, Graphite, ds-mode queues, ds-mode watchers, automatic retries, automatic worktrees, and remote mutations out of scope. Herdr's existing server may own terminal processes.
- Prefer scripts and fixtures over more prose instructions.

## Unit 1. Freeze and score the baseline

1. Copy no artifacts. Record the existing absolute paths and hashes in a local manifest.
2. Add a local analysis script that extracts the lead timeline, tool counts, wait counts, final context use, Pi session IDs, worker timing, diagnostics, and terminal states.
3. Make the script detect a JSON session header without a persisted Pi session file.
4. Make the script detect `provider_transport_failure`, fallback transport, and first model output.
5. Make the script report whether every review correction received a later independent pass.
6. Mark this run `blind=false` because the lead saw the withdrawn decomposition through issue #200 comments.

Completion criterion: one command reproduces the metrics and failures listed in the evidence section without reading unrelated sessions.

## Unit 2. Prototype Codex-owned Pi dispatch paths

Run each Codex lead in a named Herdr pane. The Codex lead owns every worker dispatch so the experiment measures the ds-mode topology. Keep both Pi adapters outside the active ds-mode skill until the comparison accepts one.

First update the official Herdr Pi integration and verify it through `herdr integration status`. The integration supplies Pi lifecycle and session identity. It does not remove Pi's provider transport behavior.

Test two paths:

1. **Codex process path.** The Codex lead launches Pi as the foreground command owned by `exec_command`. It retains the returned Codex process-session ID and waits in multi-minute intervals.
2. **Herdr agent path.** The Codex lead creates a sibling pane, starts a uniquely named Pi agent through `herdr agent start`, submits the brief through `herdr agent prompt --wait`, and reads the bounded report artifact after Herdr reports a settled state.

Apply the same lifecycle contract to both paths:

1. Create a unique run directory for each task and incarnation. Refuse existing result, stderr, PID, and metadata paths.
2. Record the Herdr lead name, Codex thread ID, checkout, brief, worker name, model, thinking level, edit mode, worker endpoint, Pi session ID, result path, and persisted Pi session path. Record the OS PID and Codex process-session ID where that path exposes them.
3. Verify that Pi created the matching persisted session file. Report `starting`, not `recoverable`, until both the endpoint and the conversation exist.
4. Surface provider diagnostics and transport fallback. Herdr lifecycle state does not prove that the provider has started streaming.
5. Verify exact endpoint identity before sending input, interrupting, or closing a pane.
6. Preserve failed output. A retry receives a new incarnation and new files.
7. Require the worker to write its bounded result to a unique file. Terminal capture is diagnostic evidence, not the result contract.
8. Prove status, wait, stop, and resume behavior.
9. After the durable result exists, the Codex lead closes each exact worker pane it created and verifies that the endpoint no longer resolves. Preserve an ambiguous endpoint for inspection instead of guessing.
10. After the lead finishes, the outer coordinator closes the exact lead tab it created and verifies that the tab no longer resolves.

Keep Pi at `transport=auto`. The normal path starts on WebSocket and may fall back to SSE only through Pi's built-in recovery. If a WebSocket stalls or fails, pause topology testing and diagnose that transport failure before continuing. An explicit SSE run may isolate the fault, but it cannot become the default or the quality-comparison route without a separate decision.

Completion criterion: both Codex-owned paths have deterministic results for normal WebSocket completion, transport failure and fallback, interruption, missing conversation persistence, resume, stale endpoint identity, and late output from an old incarnation.

## Unit 3. Prototype Codex-owned Codex dispatch paths

Start each fresh Codex lead in Herdr. Update the official Herdr Codex integration and verify it through `herdr integration status`. Herdr 0.8.0 uses the Codex integration for session identity and screen detection for lifecycle state.

Test two paths:

1. **Native path.** The lead uses the collaboration API exposed by the installed Codex build. Codex 0.152.1 exposes `spawn_agent`, `wait_agent`, `followup_task`, and `interrupt_agent`. A completed child remains addressable by its canonical target. Resume the exact outer lead session, then use `followup_task` to prove that the child remains available.
2. **Herdr agent path.** The lead creates a sibling pane, starts a uniquely named Codex agent through `herdr agent start`, submits the same complete brief, waits through Herdr, and reads the bounded result artifact.

For both paths:

1. Launch GPT-5.6 Sol Explore at `medium` with no inherited lead history.
2. Launch Review at `high` the same way.
3. Record the Herdr lead name, lead thread ID, child thread or session ID, model, effort, start time, first useful result, completion time, and resume result.
4. Use one multi-minute wait at the layer that owns the worker. Do not busy-poll either layer.
5. Resume the exact outer lead session and continue the same child through its canonical target.
6. Confirm that the child receives only the brief and intended repository context.
7. Require a bounded result artifact so alternate-screen history cannot truncate the result.
8. After the durable result exists, the lead closes each exact Herdr worker pane it created and verifies that the endpoint no longer resolves. Native children have no external pane or process to close. The outer coordinator closes the exact lead tab in both paths.

Completion criterion: both Codex-owned paths preserve the Explore and Review effort profiles used by Unit 4, complete a bounded task, and continue from their recorded identities after the outer lead resumes.

## Unit 3.5. Recheck Pi control against FirstMate

Read the current FirstMate control implementation before another Herdr Pi attempt. Pin the inspected commit in the result.

1. Extract Pi's interrupt key, repeat count, exit command, and accepted postconditions from FirstMate's harness table.
2. Compare those controls with the failed Unit 2 interruption. Do not generalize from the wrong key.
3. Repeat only the failed Herdr interruption with FirstMate's verified Pi controls. Preserve exact pane, agent, and session identity before acting.
4. Verify that the interrupt settles the turn, the exit command returns the pane to its shell, and exact cleanup removes only the created pane.
5. Keep FirstMate's queue, watcher, worktree pool, and delivery machinery out of ds-mode.

Completion criterion: either the corrected Herdr control path passes, or a remaining failure has evidence below the key-mapping layer.

## Unit 4. Compare Pi and native Codex on frozen work

Create one frozen Explore brief and one frozen Review brief. Use the same checkout snapshot, evidence pack, scope, exclusions, report limit, and skill policy for every route. Keep skill discovery enabled. Heavy routed workflows remain explicit-only through both `disable-model-invocation` and Codex `allow_implicit_invocation: false`; do not pass `--no-skills` in an engineering trial.

For every trial, start a fresh named Codex lead in a Herdr pane. Give the lead a frozen coordinator brief that requires exactly one worker dispatch through the assigned route. The current Pi coordinator starts and observes the Codex lead. It never launches the benchmark worker directly.

Herdr has two roles in this experiment. It keeps every outer Codex lead alive. In the Herdr agent routes, the Codex lead also uses Herdr as the worker process and lifecycle owner. Keep those measurements separate.

Screen these routes once with a small frozen task:

1. The Codex lead launches Pi with `transport=auto` through `exec_command`.
2. The Codex lead launches Pi with `transport=auto` through a Herdr agent pane.
3. The Codex lead launches a native Codex worker through `spawn_agent`.
4. The Codex lead launches a Codex worker through a Herdr agent pane.

Both Pi routes must complete through WebSocket often enough to measure. If either route reaches Pi's SSE fallback, record it as a WebSocket failure and finish root-cause diagnosis before quality comparison. Reject a screened route only when it fails the required effort, isolation, result, lifecycle, or resume contract.

Run each surviving route and each frozen brief three times. Extend a route and brief pair to five runs when it fails or its completion time varies by more than 20 percent. Preserve trials from superseded skill policies as rejected evidence; do not mix them into the topology table.

Measure:

- Dispatch to first model event.
- Dispatch to first tool call.
- Completion time.
- Successful completion rate.
- Transport and process failures.
- Session persistence and exact resume.
- Lead execution calls and wait calls.
- Lead context growth.
- Worker input, output, and cache tokens when available.
- Report length.
- Required file-pointer coverage.
- Unsupported claims.
- Exclusion violations.
- Findings accepted by a blind same-family judge.

Randomize report order before judging quality. Do not tell the judge which route produced a report.

Completion criterion: the result table supports a topology decision on reliability, speed, recovery, lead overhead, and report quality.

## Unit 5. Choose the worker topology

Apply these rules to the comparison:

- Prefer native Codex when it matches Pi result quality and materially reduces failures, lead turns, or context use.
- Prefer Pi when independent persistence or report quality earns its process cost.
- Keep both only when each owns a distinct role supported by results. Do not keep two interchangeable paths.
- Reject either Pi path if WebSocket transport or fallback still needs manual lifecycle judgment during normal work.
- Reject either Codex path if effort selection, recovery, isolation, or report quality fails the frozen tests.
- Prefer Herdr-owned workers only when process keepalive, lifecycle state, or recovery improves enough to pay for pane and integration management.

Record the decision, rejected alternative, evidence table, and reconsideration trigger in the deviation manifest.

Completion criterion: one default worker path exists for each active role. Every retained second path has a measured reason.

## Unit 6. Reduce worker and lead context cost

1. Set a report contract with a strict size limit. Require result, evidence pointers, changed paths, checks, and open risks. Store bulk findings outside the report.
2. Keep raw streams and full worker sessions out of the lead context. Import only the bounded report and targeted evidence excerpts.
3. Stop duplicate exploration. The lead inspects only shared blockers and the evidence needed to verify worker claims.
4. Replace repeated source dumps with scripts that extract symbols, paths, imports, diagnostics, and final messages.
5. Keep `update_plan` visible but avoid repeatedly sending unchanged oversized explanations.
6. Add lead-budget measurements to the dogfooding record.

Completion criterion: a repeated planning run uses no busy polling, no truncated source dumps, and less than half the baseline lead context without losing review findings.

## Unit 7. Repair Show Me Your Work

1. Require `show-me-your-work/scripts/log.sh` for every row. Do not patch existing TSV rows.
2. Start with real timestamps. A correction appends a superseding row.
3. Log failed launches, rejected evidence, transport fallback, unrecoverable sessions, retries, reviewer failures, and final acceptance.
4. Store exact Codex session IDs, canonical child targets, and artifact paths. Do not use broad globs as process evidence.
5. Add the exact Codex lead rollout to the review brief alongside worker sessions and the TSV.
6. Add a checker for six fields, ISO timestamps, monotonic row order, resolvable local evidence paths, and placeholder timestamps.
7. Continue review after every correction. Handoff requires a fresh reviewer to return `ready` or `PASS` on the exact final artifacts.
8. Include reviewer session IDs and canonical child targets in the plan and final reply.

Completion criterion: the checker passes, every material lead pivot appears in the TSV, and the final row follows an independent pass.

## Unit 8. Build a blind evidence pack

1. Create an allowlisted pack for issue #202 from approved issue bodies, ADR 0007, `CONTEXT.md`, current repository files, and accepted prototype evidence that does not embed the withdrawn decomposition.
2. Record every included source and hash.
3. Give the lead and workers the pack. Disable or prohibit direct tracker lookup for the blind run.
4. Add a scan that fails if the lead transcript, worker transcripts, briefs, or plan contain `#203` through `#208`, `PR #209`, `pull/209`, archived branch names, or known withdrawn commit IDs.
5. Treat a scan failure as a failed blind run. Do not try to cleanse the same lead context and continue.

Completion criterion: the evidence pack is complete enough to plan #202, and the exclusion scan passes across every run artifact.

## Unit 9. Repeat the issue #202 planning dogfood

Run the same short prompt in a fresh Codex session. Use the accepted worker topology and the blind evidence pack.

Preserve:

- The lead rollout.
- The visible `update_plan` history.
- Canonical child targets and exact persisted Codex sessions.
- Worker briefs and bounded reports.
- The append-only TSV.
- The final plan.
- Validator output.
- The final independent review.
- The metrics from Unit 6.

Evaluate the run before revealing or comparing the withdrawn baseline.

Completion criterion: the run remains blind, the final reviewer passes the exact plan and trail, worker lifecycle is deterministic, and the lead stays within the agreed context budget.

## Unit 10. Pressure-test the implementation units

Before starting issue #202 implementation, inspect whether each plan unit fits one worker and one verification boundary.

Start with X1 because it currently spans bootstrap, installation, CLI dispatch, schemas, logging, approval, inventory ownership, data callers, runtime callers, tests, dependency changes, and qualification.

For each unit:

1. Write the proposed Implement brief.
2. Count writable files, ownership seams, and verification commands.
3. Split the unit when the brief cannot stay bounded or when an intermediate private capability can be verified before public exposure.
4. Do not use fewer units or commits as a proxy for simpler work.
5. Ask a fresh reviewer whether each resulting unit is independently executable and reviewable.

Completion criterion: every unit has one clear owner, a bounded writable set, one direct pass predicate, and a brief that fits the worker report contract.

## Exit gate for implementation dogfooding

Begin issue #202 implementation only when all conditions hold:

- The worker topology comparison has an accepted result.
- The selected launcher or native path passes completion, failure, and resume tests.
- Pi transport is out of the ordinary worker path.
- Worker reports and lead context meet their budgets.
- Show Me Your Work is append-only and includes the Codex lead rollout.
- The blind evidence pack and exclusion scan pass.
- A fresh issue #202 plan receives a final independent pass.
- X1 and every other implementation unit pass the bounded-brief review.
- The user explicitly approves implementation.

## Verification and review

For each completed workflow change:

1. Run the smallest check that proves its contract.
2. Inspect the real artifact rather than a worker summary.
3. Validate every changed skill with the Codex skill validator against a temporary copy that strips host-only frontmatter, then verify the Cursor/Pi and Codex invocation policies separately.
4. Run lineage and active-link checks when active skills change.
5. Test installer changes against an isolated destination.
6. Give one fresh reviewer the task contract, repository rules, exact diff, and verification output.
7. Install globally only when the user asks.
