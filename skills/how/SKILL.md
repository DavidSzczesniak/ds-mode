---
name: how
description: "Use for \"how does X work\", code walkthroughs before changing something, and placement / ownership / layering questions (\"where should this live\", \"which package owns this\", \"is this the right layer\"). Explains subsystem architecture, runtime flow, and onboarding mental models. Can critique architecture."
---

# How

Explore the codebase to answer "how does X work?" questions. Produce clear architectural explanations at the level of a senior engineer onboarding onto a subsystem. Enough to build a working mental model, not annotated source code.

Two modes:

1. **Explain** (default). Explore the codebase and produce a clear explanation
2. **Critique.** Explain first, then use one fresh critic agent to identify architectural issues

## Explain Mode

### Step 1. Understand the Question and Assess Complexity

Parse what the user is asking about:

- "How does the rate limiter work?", a subsystem
- "How do we handle billing for on-demand usage?", a feature flow
- "How is the auth service structured?", an architectural overview
- "Walk me through what happens when a user submits a form", a runtime trace

Identify the scope. If ambiguous, state your best-guess interpretation before exploring. Don't ask. Let the user redirect if you're off.

**Assess complexity to decide the approach:**

- **Simple** (a single module, a small utility, a narrow question like "how does function X work"): explore and explain in a single pass. Go to Step 2b.
- **Complex** (a subsystem spanning multiple files/services, a cross-cutting feature, a full architectural overview): use one read-only explorer agent for the code tracing, then verify and synthesize its findings. Go to Step 2a.

When in doubt, lean simple. Use the explorer only when the question cannot be traced reliably in one focused pass.

### Step 2a. Explore (complex questions only)

Define one exploration brief that covers the code paths needed to answer the question. For "how does the rate limiter work?", the brief might include:

- Data model and state management
- Request path and enforcement
- Configuration and metrics infrastructure

The brief should name the subsystem boundary and the main path to trace. Keep incidental questions out of it.

Start one fresh explorer agent without inherited conversation history (`fork_turns: "none"`). Give it a read-only investigation task with no implementation work.

Build its prompt from `references/explorer-prompt.md` and add the exploration brief. The explorer should:
- Start broad: Glob for relevant directories, Grep for key types/interfaces/class names
- Follow the thread: from an entry point, trace the call chain (callers, callees, data flow, type definitions)
- Read the actual code, don't guess from file names
- Stop when it can describe the full path from input to output (or trigger to effect) without hand-waving any step
- Note things that are surprising, non-obvious, or that a newcomer would get wrong

The explorer returns structured findings: components found, flow traced, files read, and anything non-obvious.

Then proceed to Step 3.

### Step 2b. Direct Explain (simple questions)

Explore and explain directly. Read `references/explanation.md` for the communication style and output format. Use the same structure without explorer findings as input.

Proceed to Step 4.

### Step 3. Synthesize (complex questions only)

Once the explorer returns, verify its material claims against the code. Resolve gaps or contradictions directly, then synthesize the findings into one coherent explanation. Read `references/explanation.md` for the communication style and output format.

### Step 4. Present

Present the explanation to the user. Add relevant context from the conversation, but keep the traced code as the source of truth.

### Output Format

Follow this structure, adapted to the question. Not every section is needed for every question.

**Overview.** 1-2 paragraphs. What it is, what it does, why it exists. Enough to decide whether to keep reading.

**Key Concepts.** The important types, services, or abstractions. Brief definition of each. Not exhaustive, just the ones needed to understand the rest.

**How It Works.** The core of the explanation. Walk through the flow: what triggers it, what happens step by step, where data goes, the decision points. Prose, not pseudocode. Reference specific files and functions so the reader can go look, but don't dump code blocks unless a snippet is genuinely necessary.

**Where Things Live.** A brief map of the relevant files/directories. Not every file, just the ones needed to start working in this area.

**Gotchas.** Non-obvious or surprising things that would trip someone up. Historical context that explains why something looks weird. Known sharp edges.

## Critique Mode

Triggered when the user asks for architectural issues, problems, or improvements, not just understanding.

### Step 1. Explain First

Run the full explain flow above (Steps 1-4). You must understand the architecture before critiquing it.

### Step 2. Start a critic

After the explanation is complete, start one fresh architectural critic agent without inherited conversation history (`fork_turns: "none"`). Give it a read-only critique task with no implementation work.

Read `references/critic-prompt.md` for the prompt template. The critic gets:
1. The explanation from Step 1 (so they don't re-explore)
2. The relevant file paths (so they can read the actual code)
3. The architectural critique rubric from `references/critique-rubric.md`

### Step 3. Lead Judgment

Act as the pragmatic lead, not an aggregator. Judge each finding against the code, the subsystem's actual needs, and the likely cost and benefit of acting on it.

Categorize findings:
- **Act on.** Architectural problems worth fixing now
- **Consider.** Real concerns, but the cost/benefit is unclear
- **Noted.** Valid observations, low priority
- **Dismissed.** Wrong, missing context, or style preference

Present the explanation first (from Step 1), then the critique verdict below it. The explanation should stand on its own; someone who just wants to understand the system shouldn't wade through critique.
