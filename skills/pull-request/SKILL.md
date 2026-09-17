---
name: pull-request
description: Use when the user wants to prepare or create a GitHub pull request. Use for an existing pull request only when the user explicitly asks to repair its title or body.
---

## 1. Establish the change

Read the applicable `AGENTS.md` files. Resolve the repository, default branch, requested base, head branch, and remote state. Check whether the head branch already has an open PR so you don't create a duplicate. If one exists, report it and stop unless the user explicitly asked to repair its title or body. Changing an existing PR's base requires explicit user direction.

Fetch the target branch. Inspect the base-to-head diff, commits, changed files, worktree state, and available validation evidence. Identify issue tracker tickets associated with the work, such as Jira cards, GitHub issues, or Linear issues. Fetch each relevant ticket and confirm that it describes the change. A change can have tickets in more than one tracker; retain all relevant references.

Finish when the base and head are fixed, and you have inspected the diff, commits, changed files, worktree state, issue tracker tickets when present, and applicable validation results.

## 2. Write the title

Write the title for someone scanning a PR list. Name the affected product or module and why the change exists. Choose the type and subject from the problem it solves or the capability it adds, not from the shape or size of the implementation. New endpoints, configuration, or supporting code can still form a `fix` when they exist to correct faulty behavior.

Use a Conventional Commit title that can become the squash subject unchanged:

```text
<type>(<scope>): <specific outcome> [<issue reference>]
```

Use the narrowest accurate type:

- `feat` adds a user-facing capability.
- `fix` corrects faulty user or maintainer behavior.
- `docs` changes documentation only.
- `style` changes formatting without changing runtime behavior.
- `refactor` changes code structure without an intended behavior change.
- `test` changes tests only.
- `perf` improves performance.
- `build` changes dependencies, the build system, or the toolchain.
- `chore` covers repository maintenance that does not fit another type.

Use a short noun for the scope, such as the product, app, service, or shared module. Describe the problem fixed or the user or maintainer outcome, not an implementation detail. Add a verified issue reference when the work has one, using the repository's title convention. Omit it for untracked maintenance.

Examples:

```text
feat(editor): add preview before publishing [PROJ-123]
fix(search): preserve selected filters after refresh [PROJ-123]
docs(agents): explain PR validation evidence
refactor(ui): centralise favourite-list routing
perf(reports): reduce database reads
build(tooling): update shared lint configuration
chore(agents): simplify pull-request guidance
```

Finish when the title identifies the area and outcome accurately on its own.

## 3. Write the body

Choose the smallest profile that fits the evidence. The profile name never appears in the PR body.

Describe only the final base-to-head change. Remove attempted approaches, reverted work, and stale details from earlier revisions.

| Profile   | Use when                                                                                             | Body                                                          |
| --------- | ---------------------------------------------------------------------------------------------------- | ------------------------------------------------------------- |
| Minimal   | A small documentation or maintenance change fits completely in `Why`                                 | `Why`, `Validation`, `Squash commit message`                  |
| Standard  | Most defects, features, and refactors                                                                | `Why`, `Scope`, `Validation`, `Squash commit message`         |
| High risk | The change affects migration, security, schema, tenants, deployment, compatibility, or safe reversal | Standard plus the supported risk, review, or rollout sections |

Add an `Issues` section to any profile when the work has verified issue tracker tickets.

Use this standard shape:

````markdown
## Why

<Explain the problem, its effect, and why the change is needed.>

## Scope

- <State the net behavior or contract change.>
- <Name a meaningful boundary or affected consumer.>

## Issues

- [<issue reference>](<verified issue URL>)

## Validation

- `<targeted check>` - passed; <what it proves>

## Squash commit message

```text
<Commit body only. Explain the need or root cause, resulting behavior, and any lasting constraint in two or three lines.>
```
````

Write each section for one purpose:

- `Why` is the human summary. Lead with the problem and its effect. State a root cause only when the evidence supports it.
- `Scope` describes resulting behavior, decisions, affected consumers, and useful boundaries. Let the diff show files and commits. Add a `Related:` line when an issue, design discussion, or prior PR helps the reviewer.
- `Issues` links every relevant verified ticket, including tickets from different trackers. Include it whenever the work has a linked ticket, even if the title does not carry its reference. Omit it for untracked maintenance.
- `Validation` records checks of the change and their observed outcomes. Include only results that apply to the current head. Add results from the current session only for checks completed against the change. Include meaningful gaps. Compress routine automation so it does not crowd out checks that exercise the changed behavior.
- `Squash commit message` is the body only. Use the PR title as the intended squash subject. Write durable rationale and behavior for `git log`, without validation results or reviewer instructions.

Add optional sections only when they contain useful information:

- `Review focus` asks a concrete question, identifies a decision, or gives a useful review order.
- `Risks and trade-offs` names a material cost, compatibility concern, or residual risk and its mitigation.
- `Rollout and rollback` explains special deployment steps, safe reversal, and any data consequence.

Keep each reviewer-facing fact in one section. The body uses one human summary and one evidence section, so it has no separate `Summary`, `Verification`, or `Blast Radius`. The squash body may share facts with the PR body, but it uses fresh prose for a future reader.

Keep the body project-owned. Omit file inventories, generic boilerplate, generated-by footers, and authoring-tool attribution.

Finish when every claim is supported and every visible section earns its place.

## 4. Prepare or create

When the user asks only for a proposed title and body, return or save them. Remote reads are allowed. Stop before pushing, creating a PR, or editing GitHub.

For a new PR, ensure the branch exists remotely, then create one PR with the verified base, head, title, and body. A normal push is part of creation when needed. Rewriting an existing remote branch requires explicit user authorization.

Finish when the requested title and body exist or GitHub reports one PR for the branch with the intended metadata.

## 5. Verify remote changes

After a GitHub mutation, read the PR back. Check its rendered title, body, base, head, draft state, and URL. Correct any mismatch before reporting completion.

Finish only when the remote PR matches the actual change and repository policy.

## Repair an existing pull request

Use this only when the user explicitly asks to repair an existing PR's title or body. Read its current title, body, base, head, and draft state. Preserve its draft state, useful human content such as images or reviewer notes, issue context, and validation results that still apply to the current head. Update the existing PR instead of replacing it, then complete step 5.
