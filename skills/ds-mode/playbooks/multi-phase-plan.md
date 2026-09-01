### Multi-phase or multi-PR plan

**You own the plan, not the code. The plan is a checklist an owner runs box by box and the operator audits from the evidence.** The plan is the deliverable. Do not implement.

1. When the change is one or two files with an obvious approach, skip the plan. Say so and stop.
2. Settle observable open questions by prototype before writing. Ask the operator only about a product or preference call that no run can settle.
3. Explore with named persistent Pi Explore workers per [`../references/pi-workers.md`](../references/pi-workers.md). Each returns file pointers, conventions, test commands, and entry points. No inlined dumps.
4. Copy the skeleton below into the plan file and fill every placeholder. Keep every heading in order. One section is one task-shaped, verifiable unit. A unit may become a PR only when the user requests PR delivery.
5. Write under `technical-writing`, then `unslop`.
6. Run `node skills/ds-mode/scripts/check-plan.mjs <plan.md>` and fix every line it prints.
7. Hand back the plan path and script output, then stop. Execution starts on the operator's explicit go.

The Codex lead owns the visible `update_plan`. Copy each matched playbook step into it verbatim. Keep skipped steps as `skip: <reason>`. Workers report results and session IDs. They do not share or mutate the checklist.

````markdown
# <Program> plan

<What changes, for whom, the rule the program enforces, and the units in order.>

## How to read this

One box is one unit of work. Check a box only when its named evidence exists. The Codex lead owns this checklist.

## Program checklist

- [ ] State the done predicate.
- [ ] Record dependencies between units.
- [ ] Record writable paths and the writer for each unit.
- [ ] Record each Pi role, profile, and session ID when delegated.
- [ ] Record the checkout or worktree decision.
- [ ] Run each unit's exact verification before the next dependent unit.
- [ ] Perform PR actions only when the user requested them.

## <Task as a verb phrase> (<unit id>)

**Depends on.** <Unit id, or None.>

**Owner.** <Codex lead or named Pi role and profile.>

**Writable paths.**

- [ ] `<path>`.

**Checkout.** <Active checkout or dedicated worktree, with the reason.>

**Build.**

- [ ] <One change. Name the symbol and file.>

**You see.**

- [ ] <One observable result.>

**Verify.**

- [ ] <Exact command or control-skill procedure and pass predicate.>
- [ ] <Real artifact to inspect.>

**Delivery.**

- [ ] <Local verified commit when allowed, or no commit with reason.>
- [ ] <Requested PR action, or `skip: no PR requested`.>

## Close the program

- [ ] Every unit is checked with its evidence.
- [ ] Inspect the final diff and the real artifact against the done predicate.
- [ ] Report open risks and persisted Pi session IDs.

## Appendix A. Prototype evidence

<Questions a prototype answered, with artifact paths.>

## Appendix B. Alternatives rejected

<Approaches weighed and why they lost.>

## Appendix C. Risks

<Risks, affected units, and checks.>
````

**Reply:** the plan path, units and dependencies, prototype results, unresolved decisions, and the check script output.
