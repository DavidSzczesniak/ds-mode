# Skill mechanics

The skill-specific branch of [`writing-for-agents`](SKILL.md): what changes when the document is a skill — frontmatter, the invocation choice, and router skills. Everything else about writing it is the universal reference in `SKILL.md`.

## Invocation

Two choices, trading the two loads:

- A **model-invoked** skill can fire autonomously. Its `description` is the skill's top-level context pointer, forced to stay loaded at all times — permanent context load in exchange for discoverability. You can still type its name. Mechanics: keep `policy.allow_implicit_invocation` enabled or omit the policy from `agents/openai.yaml`, and write a model-facing description carrying the trigger branches (the pointer-writing rules in `SKILL.md` apply in full).
- A **user-invoked** skill fires only when the human names it. This spends cognitive load — you are the index that must remember it exists. Mechanics: set `policy.allow_implicit_invocation: false` in `agents/openai.yaml`; keep the `description` as a concise human-facing summary without autonomous trigger language.

Pick model-invocation only when autonomous discovery is worth the permanent pointer. If the skill fires only by hand, make it user-invoked.

Shared reference that two user-invoked skills both need should live in a plain file outside the skill system that either skill can reference directly.

## Splitting by invocation

The invocation cut of splitting (the sequence cut lives in `SKILL.md`): split off a model-invoked skill when you have a distinct leading word that should trigger it on its own — a trigger word you actually use in your prompts. You pay context load for the new always-loaded description, so that independent reach has to be worth it.

## Router skills

When user-invoked skills multiply past what you can remember, that piled-up cognitive load is cured by a **router skill**: one user-invoked skill that names the others and when to reach for each, so the human has one skill to remember instead of many. It can only direct the agent to their files; it cannot make them implicitly invocable.
