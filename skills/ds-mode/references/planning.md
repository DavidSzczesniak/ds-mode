# Plan a change

Use a written plan when the user requests one or the work contains a meaningful product decision, architecture choice, ownership-boundary change, or several dependent feature slices.

Investigate before writing the plan. Resolve facts from the repository, tracker, runtime, or authoritative external source instead of asking the user. Ask the user only for product choices, preferences, irreversible actions, and decisions the evidence cannot settle.

When those decisions form a meaningful tree, read [`grilling`](../../grilling/SKILL.md) and resolve that tree before writing the plan. Keep routine implementation choices out of the interview. Skip grilling when evidence settles the approach or no material decision remains.

Apply `unslop` before presenting the plan.

## Plan format

### Current state

Explain what exists now, how it behaves, and why it needs to change. Distinguish verified behavior from inference.

### Proposed change

Explain the result in plain language. Lead with what changes for the user in product work and what changes for the maintainer in structural work.

### Approach

Explain how the change will work. Name the existing owner, affected state, important boundaries, and any unchanged behavior that prevents a real misunderstanding. Check whether a direct change or deletion avoids new machinery.

### Execution

List the ordered implementation steps. Use tracer-bullet slices only for large feature work. Each slice must deliver a narrow working capability, state how it will be observed, and name the proof it enables. Record blocking edges only when the order is not already obvious.

For later slices, fix the architecture, boundaries, order, and done condition. Leave implementation detail until the preceding slice supplies evidence.

Treat a refactor as one coherent change unless the code provides a natural reason to divide it.

### Proof

Name the real behavior, artifact, value, or journey that will demonstrate the result. Include focused static checks as supporting evidence when relevant.

### Held decisions

List only choices that require the user. Omit this section when none remain.

## Approval

Present the explainer and plan together, then pause once for approval. After approval, execute the plan without asking between slices unless evidence creates a new held decision or materially changes the accepted outcome.
