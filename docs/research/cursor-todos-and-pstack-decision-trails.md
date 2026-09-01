# Cursor todos and pstack decision trails

Research date: 2026-09-01. pstack snapshot: [`b9ddc83c32972210b8a94d389130713e8eed346e`](https://github.com/cursor/plugins/tree/b9ddc83c32972210b8a94d389130713e8eed346e/pstack). Cursor CLI build examined: `2026.08.31-4057e58`, downloaded from the URL in Cursor's official installer on the research date.

## Conclusions

1. Cursor's public documentation does not document the todo tools. The current official CLI bundle does contain their generated protobuf schemas. The server-facing todo item has `content`, `status`, `id`, and `dependencies`; write calls carry a list plus `merge`. A second CLI-facing schema uses `id`, `content`, an enum status, `created_at`, and `updated_at`.
2. Todo state is part of a persisted conversation state. The same schema stores each subagent under its own nested conversation state, and each nested state has its own `todos` field. This rules out a single workspace-wide or account-wide list in the examined implementation.
3. The official sources do not state whether a child starts with no todos, inherits a copy of the parent's todos, or receives a live shared view. They also do not state a foreground/background difference. Those answers are unknown. The distinct state fields alone do not prove initialization or synchronization behavior.
4. pstack does not use Cursor's todo list as a worker-shared project queue. It uses the parent list as a visible playbook checklist. Durable multi-worker state in Orchestrate lives in files such as `units.tsv`, `ledger.tsv`, `inbox/`, and `decisions.tsv`.
5. `show-me-your-work` is not a normal-task tax. poteto-mode routes to it for long, autonomous, multi-phase, or unattended work. Figure It Out, Autonomous Run, Hillclimb, Orchestrate, and both Autopilot playbooks call it directly. Multi-phase Plan names it in the execution plan's reading list. Reflect does not call it.
6. Its substantive contract is an append-only, evidence-linked decision log written during the run, checked against what actually happened, then reviewed by fresh eyes before handback. The exact Cursor transcript path, `Task` call, model slug, and agent store are host mechanisms. TSV placement and conditional commit behavior are pstack policy, not Cursor requirements.
7. The minimum Pi/Codex adaptation should preserve the whole contract first. Substitute the host's exact session transcript and fresh-agent mechanism. Keep the TSV, triggers, audit, independent review, `Attention` handback, local-by-default placement, and conditional commit policy unchanged until dogfooding supplies evidence for a policy change.

## A. Cursor todo and checklist behavior

### Public documentation

Cursor's current Agent tools page lists search, web, rules, file reads and edits, shell, browser, image generation, and questions. It does not list todo read/write tools. The current subagent page says each child starts with a clean, isolated context and receives relevant information in its prompt, but says nothing about todo state. It distinguishes blocking foreground children from independently running background children without describing todo inheritance or synchronization. [Agent overview](https://cursor.com/docs/agent/overview.md) [Subagents, lines 1-36](https://cursor.com/docs/subagents.md#foreground-vs-background)

This absence matters. Context isolation does not answer checklist ownership. A todo list could be copied, shared outside context, or omitted. The public docs do not choose among those designs.

### First-party schemas in the current CLI bundle

Cursor's official [CLI installation page](https://cursor.com/docs/cli/installation.md) points to `https://cursor.com/install`. On 2026-09-01 that installer selected build `2026.08.31-4057e58` and downloaded:

```text
https://downloads.cursor.com/lab/2026.08.31-4057e58/linux/x64/agent-cli-package.tar.gz
```

The bundle reports the same build from `cursor-agent --version`. Its generated protobuf code exposes two related models.

The `aiserver.v1` model is:

```text
TodoItem
  content: string
  status: string
  id: string
  dependencies: repeated string

TodoReadParams
  read: bool

TodoReadResult
  todos: repeated TodoItem

TodoWriteParams
  todos: repeated TodoItem
  merge: bool

TodoWriteResult
  success: bool
  ready_task_ids: repeated string
  needs_in_progress_todos: bool
  final_todos: repeated TodoItem
  initial_todos: repeated TodoItem
  was_merge: bool
```

These definitions appear in the official bundle's `index.js` at byte offsets 8,256,784 through 8,259,150. The artifact SHA-256 examined was `6e91bd07bfbbcae9e12b65daf73708be3a657b300d70d217d71a04dd9c9d3de6`. [Official build artifact](https://downloads.cursor.com/lab/2026.08.31-4057e58/linux/x64/agent-cli-package.tar.gz)

The CLI's `agent.v1` model is similar but not identical:

```text
TodoStatus
  UNSPECIFIED = 0
  PENDING = 1
  IN_PROGRESS = 2
  COMPLETED = 3
  CANCELLED = 4

TodoItem
  id: string
  content: string
  status: TodoStatus
  created_at: int64
  updated_at: int64

UpdateTodosArgs
  todos: repeated TodoItem
  merge: bool

ReadTodosArgs
  status_filter: repeated TodoStatus
  id_filter: repeated string
```

Update and read results return the todo collection and total count. The CLI extension bridge converts the enum to `pending`, `in_progress`, `completed`, or `cancelled`. These definitions appear in the same official artifact at byte offsets 5,446,040 and 5,459,000, with conversion code in `189.index.js`. [Official build artifact](https://downloads.cursor.com/lab/2026.08.31-4057e58/linux/x64/agent-cli-package.tar.gz)

The two schemas likely sit on different sides of Cursor's client/server protocol, but the artifact does not provide a stable public API contract for plugin authors. This report therefore records both rather than collapsing them into an invented single schema.

### Persistence scope

The generated `agent.v1.ConversationStateStructure` has a repeated `todos` field. It also contains turns, summaries, file state, plans, mode, goal state, and subagent state. Cursor's blob-backed checkpoint code serializes that structure and stores its latest root blob ID in metadata. On reset it reloads that root blob. The same code deserializes each todo blob into the conversation's todo collection. [Official build artifact, `ConversationStateStructure` around byte 5,450,640 and checkpoint code around byte 4,004,100](https://downloads.cursor.com/lab/2026.08.31-4057e58/linux/x64/agent-cli-package.tar.gz)

That establishes conversation persistence in this build. It does not establish account-global or workspace-global persistence. The todo collection is a field of the conversation checkpoint, not a field of account or workspace configuration.

Subagents are persisted separately inside the parent checkpoint:

```text
ConversationStateStructure
  todos: repeated blob reference
  subagent_states: map<string, SubagentPersistedState>

SubagentPersistedState
  conversation_state: ConversationStateStructure
  created_timestamp_ms: int64
  last_used_timestamp_ms: int64
  subagent_type: ...
  model_id: optional string
  environment: ...
```

The recursive shape is explicit in the generated schema at byte offsets 5,448,137 through 5,452,500. The checkpoint loader separately deserializes the root conversation and each child's `conversation_state`, including that child's todo blobs. [Official build artifact](https://downloads.cursor.com/lab/2026.08.31-4057e58/linux/x64/agent-cli-package.tar.gz)

The narrow supported conclusion is:

| Candidate scope | Evidence-backed answer |
| --- | --- |
| Conversation | Yes. Todos are part of persisted conversation state. |
| Parent agent | The parent has its own conversation todos. |
| Child agent | The schema gives each persisted child its own nested conversation state, which has its own todos field. |
| Workspace | No workspace-wide todo collection appears in the examined state schema. |
| Account | No account-wide todo collection appears in the examined state schema. |

### Do parent and child agents share the list?

Unknown.

The first-party schema proves separate storage locations. It does not specify child initialization or later synchronization. The public subagent documentation says children start with clean context and parents pass relevant information in the prompt. It does not mention todos. No examined official source says any of the following:

- a foreground child shares the parent's list;
- a background child shares the parent's list;
- either child receives a copy;
- either child starts empty;
- child updates merge back into the parent.

The same unknown applies to foreground versus background. Cursor documents their scheduling difference, not todo ownership. [Subagents, lines 23-36](https://cursor.com/docs/subagents.md#how-subagents-work)

### How pstack uses todos

poteto-mode treats the todo list as a visible checklist for one active playbook. It requires every multi-step task to open a list whose first item is reading the principles. It then copies the matched playbook's steps verbatim before task-specific items. A skipped step remains visible with `skip: <reason>`. [poteto-mode, lines 13-15 and 108-116](https://github.com/cursor/plugins/blob/b9ddc83c32972210b8a94d389130713e8eed346e/pstack/skills/poteto-mode/SKILL.md#L13-L15) [pstack guide, setup lines 37-47](https://github.com/cursor/plugins/blob/b9ddc83c32972210b8a94d389130713e8eed346e/pstack/docs/guide/01-setup.md#L37-L47)

Other autonomous skills open their own phase checklist for the same reason. Architect says the list shows phase position and prevents phases from silently disappearing. Arena and Swarm say the same. [Architect, lines 9-14](https://github.com/cursor/plugins/blob/b9ddc83c32972210b8a94d389130713e8eed346e/pstack/skills/architect/SKILL.md#L9-L14) [Arena, lines 9-14](https://github.com/cursor/plugins/blob/b9ddc83c32972210b8a94d389130713e8eed346e/pstack/skills/arena/SKILL.md#L9-L14) [Swarm, lines 9-14](https://github.com/cursor/plugins/blob/b9ddc83c32972210b8a94d389130713e8eed346e/pstack/skills/swarm/SKILL.md#L9-L14)

No pstack text asks workers to update the parent's todo list or assumes that a worker's list mutation appears in the parent. Worker coordination uses prompts, Task results, branches, and files.

Orchestrate makes the separation especially clear. The coordinator opens the playbook todo list, while project state lives in a durable store. `units.tsv` tracks units, `ledger.tsv` tracks verification, `inbox/` carries completion pointers, `gates.md` preserves human questions, and `decisions.tsv` records the trail. Cloud workers cannot read the local store, so briefs inline what they need or point at repository paths. [Orchestrate, lines 13-34](https://github.com/cursor/plugins/blob/b9ddc83c32972210b8a94d389130713e8eed346e/pstack/skills/poteto-mode/playbooks/orchestrate.md#L13-L34)

So pstack's checklist contract does not depend on shared todo state across workers. The parent list exposes routing and phase progress. Separate durable artifacts coordinate the fleet.

## B. `show-me-your-work`

### Files and history examined

At the pinned commit the complete skill consists of:

- [`skills/show-me-your-work/SKILL.md`](https://github.com/cursor/plugins/blob/b9ddc83c32972210b8a94d389130713e8eed346e/pstack/skills/show-me-your-work/SKILL.md), 82 lines;
- [`references/decision-log-template.tsv`](https://github.com/cursor/plugins/blob/b9ddc83c32972210b8a94d389130713e8eed346e/pstack/skills/show-me-your-work/references/decision-log-template.tsv), a header row;
- [`scripts/log.sh`](https://github.com/cursor/plugins/blob/b9ddc83c32972210b8a94d389130713e8eed346e/pstack/skills/show-me-your-work/scripts/log.sh), 40 lines.

Repository history before and including the pinned commit has three changes to this directory:

| Commit | What changed | First-party reason or evidence |
| --- | --- | --- |
| [`35f3392`](https://github.com/cursor/plugins/commit/35f33923cde39e9c27d68d95517e4e4e83719c7c) / [PR 78](https://github.com/cursor/plugins/pull/78) | Added Figure It Out, the TSV skill, header template, helper, transcript audit, and routes from poteto-mode, Autonomous Run, and the then-current multi-phase plan reference. | The PR says one canonical trail should replace ad hoc checkpoints and let a reviewer reconstruct decisions after stepping away. |
| [`11ecc12`](https://github.com/cursor/plugins/commit/11ecc12a3ffc037b4ef3b64de2be449668e8afc7) / [PR 79](https://github.com/cursor/plugins/pull/79) | Added parent-directory creation, carriage-return stripping, and spreadsheet formula-prefix protection; shortened descriptions. | A prior babysit run surfaced formula-injection and nested-path failures. The PR records shellcheck and a smoke test. |
| [`47f3df8`](https://github.com/cursor/plugins/commit/47f3df82728f0df2233ed9d773ba0fba74cd79e3) / [PR 89](https://github.com/cursor/plugins/pull/89) | Added mandatory different-family review and the `Attention` handback. | The PR records a three-round, nine-candidate eval and the failures discussed below. |

There are no repository tests for `show-me-your-work` at the pinned snapshot. The only test evidence is PR 79's recorded shellcheck and smoke test, plus PR 89's recorded behavioral eval. A search across every pstack test file found no reference to the skill, its log names, transcript audit, or cross-model review.

### Actual contract

The skill owns one canonical TSV. Each row has an ISO timestamp, phase, decision, reason, evidence pointer, and result. Rows represent forks, completed units, pivots, reverts, blockers, gates, and loop checkpoints rather than every action. The log is append-only. [show-me-your-work, lines 9-22 and 34-52](https://github.com/cursor/plugins/blob/b9ddc83c32972210b8a94d389130713e8eed346e/pstack/skills/show-me-your-work/SKILL.md#L9-L22)

The helper creates a missing parent directory, writes the header on first use, replaces tabs/newlines/carriage returns inside cells, and quote-prefixes spreadsheet formula triggers. It does not validate evidence or enforce append-only history. Those remain agent instructions. [`log.sh`, lines 1-40](https://github.com/cursor/plugins/blob/b9ddc83c32972210b8a94d389130713e8eed346e/pstack/skills/show-me-your-work/scripts/log.sh#L1-L40)

At handback, the working agent reads the run transcript and reconciles the log against actual actions and evidence. It removes invented or padded entries and adds omitted forks or abandoned approaches. Then a different model family reviews the trail and transcript for weak evidence, skipped verification, risky choices, and gaps. The reply ends with `Attention`, names the reviewer model, and points flags to rows or transcript moments. [show-me-your-work, lines 54-78](https://github.com/cursor/plugins/blob/b9ddc83c32972210b8a94d389130713e8eed346e/pstack/skills/show-me-your-work/SKILL.md#L54-L78)

### Role by route

| Route | Actual role at `b9ddc83` |
| --- | --- |
| Normal task | No default trail. poteto-mode routes only long, autonomous, multi-phase, or unattended work to it. A small ordinary task still verifies the real artifact but does not acquire a TSV merely for being multi-step. [poteto-mode, lines 33-35](https://github.com/cursor/plugins/blob/b9ddc83c32972210b8a94d389130713e8eed346e/pstack/skills/poteto-mode/SKILL.md#L33-L35) |
| Autonomous Run | Mandatory row every iteration. The row says what changed and whether the exit predicate moved. [Autonomous Run, lines 5-11](https://github.com/cursor/plugins/blob/b9ddc83c32972210b8a94d389130713e8eed346e/pstack/skills/poteto-mode/playbooks/autonomous-run.md#L5-L11) |
| Figure It Out | Core run artifact. It logs one row per decision and unit while designed steps land, then returns the trail path. The trail is usually important enough to consider committing, but the stated test remains whether confidence has to be shown. [Figure It Out, lines 36-55](https://github.com/cursor/plugins/blob/b9ddc83c32972210b8a94d389130713e8eed346e/pstack/skills/figure-it-out/SKILL.md#L36-L55) |
| Multi-phase Plan | The planning playbook does not run the trail while authoring the plan. Its deliverable is the plan, not code. The skeleton tells the future execution program to name the trail in Appendix D. [Multi-phase Plan, lines 1-8](https://github.com/cursor/plugins/blob/b9ddc83c32972210b8a94d389130713e8eed346e/pstack/skills/poteto-mode/playbooks/multi-phase-plan.md#L1-L8) [Appendix D, lines 148-155](https://github.com/cursor/plugins/blob/b9ddc83c32972210b8a94d389130713e8eed346e/pstack/skills/poteto-mode/playbooks/multi-phase-plan.md#L148-L155) |
| Orchestrate | Mandatory program store artifact. Initialization opens it before spawning; close audits it and runs the cross-model review. It is one record among the store's operational tables, not the queue or verification ledger. [Orchestrate, lines 23-34 and 61-68](https://github.com/cursor/plugins/blob/b9ddc83c32972210b8a94d389130713e8eed346e/pstack/skills/poteto-mode/playbooks/orchestrate.md#L23-L34) |
| Hillclimb | Mandatory experiment memory, but with a specialized `decision.tsv` shape: attempt ID, hypothesis, change, before/after, delta, tests, verdict, note. It stays gitignored so reverts do not erase it. This is a deliberate format specialization despite the base skill's instruction not to restate columns. [Hillclimb, lines 5-13](https://github.com/cursor/plugins/blob/b9ddc83c32972210b8a94d389130713e8eed346e/pstack/skills/poteto-mode/playbooks/hillclimb.md#L5-L13) |
| Autopilot Full / Stack | Every PR owner keeps an uncommitted `decisions.tsv` and returns it in reports. The root collects the trails during audit. [Autopilot Full, lines 5-10](https://github.com/cursor/plugins/blob/b9ddc83c32972210b8a94d389130713e8eed346e/pstack/skills/poteto-mode/playbooks/autopilot-full.md#L5-L10) [Autopilot Stack, lines 5-8](https://github.com/cursor/plugins/blob/b9ddc83c32972210b8a94d389130713e8eed346e/pstack/skills/poteto-mode/playbooks/autopilot-stack.md#L5-L8) |
| Reflect | No call. Reflect mines one completed transcript to propose durable skill edits. It has its own three-reviewer and synthesizer workflow, waits for approval before skill edits, and never mentions `show-me-your-work`. [Reflect](https://github.com/cursor/plugins/blob/b9ddc83c32972210b8a94d389130713e8eed346e/pstack/skills/reflect/SKILL.md) |
| Explicit `/show-me-your-work` | Supported, but the frontmatter has `disable-model-invocation: true`. Cursor documents that flag as slash-only inclusion. The guide presents explicit invocation as a morning audit or a request to keep a trail. [show-me-your-work, lines 1-5](https://github.com/cursor/plugins/blob/b9ddc83c32972210b8a94d389130713e8eed346e/pstack/skills/show-me-your-work/SKILL.md#L1-L5) [Cursor skills, lines 170-173 and 210-212](https://cursor.com/docs/skills.md#disabling-automatic-invocation) |

The explicit-only frontmatter and pstack composition are worth separating. Cursor will not auto-load the leaf skill from its description. poteto-mode and playbooks tell an already-running workflow to use it by name.

### Methodology versus Cursor mechanisms

| Part | Classification | Reason |
| --- | --- | --- |
| One append-only decision/checkpoint trail | Methodology | It defines what evidence the run leaves. Nothing about it requires Cursor. |
| TSV columns and helper sanitation | pstack implementation policy | Portable shell and file format. The formula guard exists because spreadsheets may open the file. |
| `decisions.tsv` in the work directory or `.audit/<slug>.tsv` | pstack placement policy | Portable. Orchestrate's agent-store placement is Cursor-specific because the system prompt supplies that store. |
| Log during the work, not reconstructed only at the end | Methodology | Figure It Out weaves rows through execution; Autonomous Run and Hillclimb write each iteration. |
| Audit against the actual transcript | Methodology plus Cursor adapter | The truth-check is the method. `agent-transcripts/` and its workspace-scoped path are Cursor's storage mechanism. |
| Spawn with `Task` | Cursor mechanism | `Task` is Cursor's child-agent tool. The portable requirement is a fresh reviewer, not this call shape. |
| Different model family | Methodology | The aim is non-self review. Cursor model IDs and pstack's configured role mapping are host details. |
| Name the reviewer model in `Attention` | Methodology forcing function | It makes a missing review visible. It does not require Cursor. |
| Keep local by default; commit only when the reviewer needs the trail in the PR | pstack policy | Git behavior, not Cursor behavior. [show-me-your-work, lines 42-46](https://github.com/cursor/plugins/blob/b9ddc83c32972210b8a94d389130713e8eed346e/pstack/skills/show-me-your-work/SKILL.md#L42-L46) |
| Commit accepted Hillclimb wins or advancing Autonomous Run iterations | Playbook policy | These commits are progress checkpoints. They are separate from whether the trail itself is committed. |

### Why the transcript audit exists

PR 78 says the trail should let a later reviewer reconstruct what was decided, why, and on what evidence without rerunning the work or reading the whole transcript. The transcript audit was added in the same commit to check that the compressed trail is truthful. The skill names the concrete failures it catches: invented or aspirational rows, unresolved evidence, omitted pivots or abandoned approaches, and padding. [PR 78](https://github.com/cursor/plugins/pull/78) [show-me-your-work, lines 54-63](https://github.com/cursor/plugins/blob/b9ddc83c32972210b8a94d389130713e8eed346e/pstack/skills/show-me-your-work/SKILL.md#L54-L63)

That is first-party rationale, not an effectiveness result. PR 78 reports no controlled evaluation of the transcript audit itself. The evidence supports its intended failure classes, not a measured catch rate.

The initial PR also exposed one design failure. Bugbot found that an early template included fictional example rows while the skill required append-only history. The merged version changed the template to header-only, so copied logs would not permanently contain fake evidence. [PR 78 inline review](https://github.com/cursor/plugins/pull/78#discussion_r3295142711)

### Why cross-model review exists

PR 89 separates two questions:

- self-audit asks whether the log tells the truth;
- fresh review asks what the user should still scrutinize even if the log is accurate.

The PR records three eval rounds, with three candidates each, on a sync-to-async migration containing a subtle out-of-scope CLI caller:

| Wording | Recorded behavior |
| --- | --- |
| Soft suggestion | 1 of 3 spawned a reviewer. |
| `must spawn` plus `Attention` | 2 of 3 spawned. One candidate fabricated `Attention: No flags` without a review. |
| Must name reviewer model | 1 of 3 spawned. The PR says the failed candidates dropped the artifact or disclosed failure rather than faking a review. |

The author also reports that reviews which ran found pre-existing races, harness weaknesses, and scope creep. [PR 89](https://github.com/cursor/plugins/pull/89)

The evidence is candid and limited. It supports these claims:

- soft wording often failed to trigger the review;
- an `Attention` heading alone did not prevent fabricated compliance;
- naming the model made some missing reviews visible in this small eval;
- some completed reviews produced findings in that eval.

It does not support a general effectiveness rate. The final tested wording still spawned only 1 of 3 reviewers. No repository test enforces the step.

Bugbot also flagged two unresolved risks in PR 89: the prose did not explicitly require the cross-model pass to wait until self-audit corrections finished, and it did not separately restate the workspace path guard in the child-review paragraph. The pinned file's section order suggests audit then review, but no runtime enforces that order. [Ordering finding](https://github.com/cursor/plugins/pull/89#discussion_r3308303107) [Transcript-scope finding](https://github.com/cursor/plugins/pull/89#discussion_r3308303112)

## Minimum Pi/Codex adaptation

Start with the complete substantive contract. Do not pre-emptively remove parts because Cursor supplied their original mechanism.

### Preserve unchanged

1. Route long, autonomous, multi-phase, and unattended work to a trail. Do not add it to every ordinary task.
2. Keep one append-only TSV and the current six base columns. Preserve Hillclimb's specialized experiment table where that playbook applies.
3. Write rows at decisions and checkpoints while the run proceeds.
4. Keep evidence as resolvable paths, commands, SHAs, PRs, or artifacts.
5. Keep the helper's one-line sanitation and spreadsheet formula protection.
6. Keep logs local by default. Commit only when review of the work requires the trail in version control.
7. At the end, reconcile the trail against the actual host transcript before review.
8. Run a fresh reviewer on a different available model family over the corrected trail and transcript.
9. End the handback with `Attention`, the actual reviewer model, and row or transcript pointers. If no qualifying reviewer ran, say so. Never manufacture `No flags`.

### Unavoidable host substitutions

| Cursor mechanism | Pi substitution | Codex substitution |
| --- | --- | --- |
| Workspace `agent-transcripts/` path | Pass the exact persisted Pi session JSONL path. Resolve it from the active session, not by globbing unrelated projects. | Pass the exact rollout/thread transcript for the active Codex thread. Resolve it by thread ID, not by searching all projects. |
| `Task` reviewer | Start one fresh Pi reviewer process/session with read access to the trail, transcript, diff, and evidence. | Spawn one fresh review agent/thread with the same bounded inputs. |
| Cursor model slug and pstack role rule | Select a configured Pi model from a different provider/model family. Record the actual model. | Select a Codex reviewer role/model from a different provider/model family where available. Record the actual model. |
| Agent-store directory | Use the active work directory for `decisions.tsv`, or a task-scoped `.audit/` path. A project orchestrator may supply its own durable store. | Same. |

The reviewer prompt should name the exact transcript and trail paths. It should ask for weak evidence, unsupported verification, hindsight risk, and omitted gaps. It should not redo implementation. Run it only after the transcript audit has corrected the trail, making the order explicit rather than relying on heading order.

For ds-mode, keep this trail review distinct from the repository's fresh implementation review unless one reviewer can satisfy both contracts without receiving forbidden rationale. A `show-me-your-work` reviewer must read the implementer's transcript. The ds-mode implementation reviewer must receive the task contract, rules, exact diff, and verification while the implementer's rationale is withheld. Those inputs conflict, so combining them would weaken one review.

### Optional policy changes that need dogfooding evidence

Do not make these changes during the first adaptation:

- changing TSV to Markdown or JSON;
- removing transcript reconciliation because the log already has evidence;
- replacing fresh review with self-review;
- allowing the same model family by default;
- dropping the model disclosure line;
- committing every trail or never committing one;
- broadening trails to every multi-step task;
- treating the host todo list as the trail or as a worker queue;
- combining the trail reviewer with ds-mode's rationale-withheld implementation reviewer.

Any of those may eventually prove useful. None is an unavoidable Pi/Codex substitution, and the pinned pstack evidence does not justify it.

## Classification of accompanying skills

Cursor's `disable-model-invocation: true` means a skill enters context only through explicit `/skill-name` invocation. All four skills discussed here set that flag. [Cursor skills, lines 170-173 and 210-212](https://cursor.com/docs/skills.md#disabling-automatic-invocation)

| Skill | Automatic poteto/playbook route | Conditional recommendation | Explicit route and call sites |
| --- | --- | --- | --- |
| `show-me-your-work` | Yes. poteto-mode routes long/autonomous/multi-phase/unattended work. Autonomous Run, Figure It Out, Hillclimb, Orchestrate, Autopilot Full, and Autopilot Stack call it. Multi-phase Plan places it in the future execution reading list. | Commit only when the reviewer needs the trail. Pause Safely points to an existing trail rather than duplicating it. | `/show-me-your-work` is documented in README and the overnight guide. |
| `create-verification-skill` | No poteto-mode or playbook route at the pinned snapshot. | Setup checks for an existing verification skill or harness. If neither exists, it offers generation once and invokes the skill only after the user says yes. The skill itself points to maintenance after generation. [setup-pstack, lines 61-65](https://github.com/cursor/plugins/blob/b9ddc83c32972210b8a94d389130713e8eed346e/pstack/skills/setup-pstack/SKILL.md#L61-L65) | Explicit `/create-verification-skill`, "make a control skill", or a request to create a project verification harness. [Create Verification Skill, lines 1-5](https://github.com/cursor/plugins/blob/b9ddc83c32972210b8a94d389130713e8eed346e/pstack/skills/create-verification-skill/SKILL.md#L1-L5) |
| `maintain-verification-skill` | No. | Create Verification Skill tells the user about it after generation. Maintenance itself redirects to Create only when no target exists. Neither route runs maintenance automatically. [Create Verification Skill, lines 42-44](https://github.com/cursor/plugins/blob/b9ddc83c32972210b8a94d389130713e8eed346e/pstack/skills/create-verification-skill/SKILL.md#L42-L44) [Maintain Verification Skill, lines 23-26](https://github.com/cursor/plugins/blob/b9ddc83c32972210b8a94d389130713e8eed346e/pstack/skills/maintain-verification-skill/SKILL.md#L23-L26) | Explicit `/maintain-verification-skill` or "audit the verify skill". |
| `reflect` | No playbook or poteto trigger calls it. poteto-mode mentions Reflect only in subagent/model-routing mechanics, not as a workflow step. | Its body recommends reflection after a complex clean landing, a generalized dead-end recovery, a user correction, or an uncaptured workflow. Because automatic model invocation is disabled and no caller routes those conditions, these are recommendations once the skill is explicitly loaded, not an automatic route at this snapshot. [Reflect, lines 1-20](https://github.com/cursor/plugins/blob/b9ddc83c32972210b8a94d389130713e8eed346e/pstack/skills/reflect/SKILL.md#L1-L20) | Explicit `reflect` or `/reflect`. README and the guide present it as a post-task command. [Make It Yours, lines 21-29](https://github.com/cursor/plugins/blob/b9ddc83c32972210b8a94d389130713e8eed346e/pstack/docs/guide/09-make-it-yours.md#L21-L29) |

`create-verification-skill`, `maintain-verification-skill`, and `reflect` are therefore accompanying explicit skills, not automatically routed poteto-mode leaves. Create has one setup-time offer. Maintain has a recommendation from Create. Reflect carries conditional advice in its own body but has no automatic caller in the pinned tree.

## Source inventory

Only primary sources were used.

### Cursor

- [Agent overview](https://cursor.com/docs/agent/overview.md), current on 2026-09-01.
- [Subagents](https://cursor.com/docs/subagents.md), current on 2026-09-01.
- [Skills](https://cursor.com/docs/skills.md), especially `disable-model-invocation`.
- [CLI installation](https://cursor.com/docs/cli/installation.md).
- Official installer `https://cursor.com/install`, SHA-256 `5364f95f66879f0e38f3e9ea7a5a44c24bfd8b3baf17964f0de46a065afff13f` when downloaded.
- Official Cursor CLI artifact `2026.08.31-4057e58`, linked above, including generated `todo_tool_pb`, conversation checkpoint, and subagent persistence schemas.

### pstack

- Complete pinned `show-me-your-work` skill, template, and script.
- Every pinned pstack textual call site found for `show-me-your-work`, `decision trail`, `audit trail`, `decisions.tsv`, or `decision.tsv`: poteto-mode, Figure It Out, Autonomous Run, Multi-phase Plan, Orchestrate, Hillclimb, Autopilot Full, Autopilot Stack, Pause Safely, Prove It Works, README, and guides 02 and 07.
- Complete pinned `create-verification-skill`, `maintain-verification-skill`, `reflect`, and `setup-pstack` skills, plus their README and guide call sites.
- All pstack test files searched for the decision-trail terms. No matching test exists.
- Full directory history through the pinned commit: commits `35f3392`, `11ecc12`, and `47f3df8`; PR bodies, reviews, and inline Bugbot findings for PRs 78, 79, and 89.
