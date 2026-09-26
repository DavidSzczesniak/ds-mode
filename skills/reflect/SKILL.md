---
name: reflect
description: Launch three parallel review workers over the active session, surface learnings, and route each to a concrete edit on an existing skill. Use when the user says reflect.
disable-model-invocation: true
---

# Reflect

Mine the current conversation for durable learnings, then route them into skill edits.

## When to invoke

Invoke when the user says "reflect" or "/skill:reflect". Skip when the conversation is trivial, off-topic, or already covered by an existing skill the parent followed correctly. One-offs are not learnings.

## Process

### 1. Locate the active transcript

The parent reads its own session file at `$PI_SESSION_FILE` before fanning out. Do not search other sessions. That crosses workspace boundaries and reads private chats from unrelated projects. If it is unset, write a tight digest of the session and pass that instead.

### 2. Launch three reviewers in parallel

Three fresh workers in parallel per `../ds-mode/references/workers.md`, each with the profile below and normal tools. Reviewers need tool access for context lookups (tickets, chat threads, observability traces referenced in the transcript).

| Lens | Profile | Prompt template |
|---|---|---|
| Judgment | Judgment | `references/judgment-reviewer.md` |
| Tooling | Review role on `openai-codex` / `gpt-6-sol`, `high` thinking, `runtime: "pi"` | `references/tooling-reviewer.md` |
| Divergent | Judgment | `references/divergent-reviewer.md` |

Pass each template verbatim, substituting the session file path or digest where marked. Reviewers return findings in their task result. The Tooling lens runs on the OpenAI family while Judgment runs on Anthropic, so the lenses span two families, as upstream's did. Disclose the review composition per `../ds-mode/references/worker-profiles.md`.

Claude workers have no MCP servers. After each template, tell a Claude worker to make lookups through CLIs and to mark every citation it cannot reach. Verify marked citations yourself before accepting their findings.

### 3. Synthesize

One fresh Judgment worker with normal tools. The synthesizer's quality check includes spot-verifying citations, which can require tool access. Use `references/synthesizer.md` verbatim, with each reviewer's full output inlined where marked. The synthesizer returns a structured Accepted / Rejected / Backlog list.

### 4. Structural enforcement check

Sanity-check the synthesizer's Accepted list. For any item that would be enforced more reliably by a lint rule, script, metadata flag, or runtime check, move it from Accepted to Backlog. See the [**encode-lessons-in-structure**](../principle-encode-lessons-in-structure/SKILL.md) principle skill.

### 5. Apply

Before applying any Accepted edit, present the synthesizer's full Accepted/Rejected/Backlog output to the user and wait for explicit approval. The user picks which subset to apply and may redirect routings. Skill changes affect every future agent in the org. Do not auto-apply.

Backlog items file to whatever devex / backlog tracker your team uses automatically. Only the Accepted list waits for approval.

For each approved Accepted item, follow the Routing field exactly:

- Trivial existing-skill edit (a one-line bullet, a tightened sentence, a stale fact corrected): parent does directly.
- Substantive existing-skill edit (a new section, a new pattern table, more than ~10 lines): hand to the [**writing-for-agents**](../writing-for-agents/SKILL.md) skill, draft against its rules, and run the repository's skill validator.
- `tune description: <skill path>` (the skill exists but didn't trigger when it should have): hand to `writing-for-agents` and rewrite the description with its context-pointer rules.
- `new skill via writing-for-agents: <kebab-name>`: hand creation to `writing-for-agents`. Do not invent the shape ad hoc.

If your environment ships a SKILL.md validator, run it on every touched skill before declaring done. Skip this step if it doesn't.

### 6. Summarize for the user

Short list, no preamble:

- Edits applied: `<skill path>`. What changed, one line each.
- New skills created: `<skill path>`. One line each (rare).
- Backlog filed to the devex tracker: `<issue title>` (`<tags>`). One line each.
- Dropped: one line per rejected finding + reason from the synthesizer.
