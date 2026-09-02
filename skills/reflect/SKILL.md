---
name: reflect
description: "Review the active session through three lenses, surface durable lessons, and route approved edits to an existing skill. Explicit invocation only."
disable-model-invocation: true
---

# Reflect

Mine the current conversation for durable lessons, then route them into skill edits. Use only when the user invokes `reflect`.

## Process

### 1. Locate the active transcript

Use the current transcript when the host exposes its exact path. Otherwise write a tight session digest and pass that instead. Do not search unrelated sessions.

### 2. Launch three reviewers

Launch three fresh native Codex children in parallel. Give them no edit permission and follow `../ds-mode/references/workers.md`.

| Lens | Profile | Prompt |
|---|---|---|
| Judgment | Judgment | `references/judgment-reviewer.md` |
| Tooling | Review | `references/tooling-reviewer.md` |
| Divergent | Judgment | `references/divergent-reviewer.md` |

Pass each template verbatim with the transcript path or digest. All configured profiles use one GPT model family. Label the result `same-family independent review`.

### 3. Synthesize

Launch one fresh native Codex Judgment child with `references/synthesizer.md` and the three full outputs. Give it no edit permission. It returns Accepted, Rejected, and Backlog lists.

### 4. Check structural enforcement

Move any lesson that belongs in a lint, script, metadata flag, or runtime check from Accepted to Backlog. See the **encode-lessons-in-structure** principle skill.

### 5. Ask before applying

Present the full Accepted, Rejected, and Backlog output. Wait for explicit approval before editing skills.

For each approved item:

- Apply a trivial existing-skill edit directly.
- For a substantive edit, read `writing-for-agents` and follow its draft and validation process.
- For a description change or new skill, use `writing-for-agents` rather than inventing the shape.
- Run the Codex skill validator on every touched skill.

File Backlog items only when the user requests an external tracker action.

### 6. Summarize

Report applied paths, new skills, backlog actions, rejected findings, checks, and the same-family disclosure.
