# Tracer bullets and vertical slices

_Research snapshot: 2026-09-01. Matt Pocock source pinned to [`6654f6b`](https://github.com/mattpocock/skills/tree/6654f6b60cd9d5be8b54c6fafe44346dabeb3b76)._

## Short answer

**A vertical slice can be a tracer bullet, but the terms are not universally synonymous.** A vertical slice describes the **shape of an increment**: usable or independently valuable functionality cut across the relevant technical layers rather than one layer at a time ([Agile Alliance](https://agilealliance.org/glossary/incremental-development/)). A tracer bullet describes a **feedback strategy under uncertainty**: put a very thin end-to-end path through real conditions, observe where it lands, and adjust the remaining work ([Hunt and Thomas](https://www.artima.com/articles/tracer-bullets-and-prototypes)). A vertical slice is acting as a tracer bullet when it is deliberately used to test the path and steer what follows.

In Matt Pocock's current skills, however, the practical answer is **yes**: his ticketing material explicitly says "tracer-bullet vertical slices" and "a vertical slice (the tracer bullet)," then gives both the same narrow, complete, cross-layer, independently verifiable shape ([source skill, lines 9 and 25–40](https://github.com/mattpocock/skills/blob/6654f6b60cd9d5be8b54c6fafe44346dabeb3b76/skills/engineering/to-tickets/SKILL.md#L9-L40); [first-party documentation, lines 25–27](https://github.com/mattpocock/skills/blob/6654f6b60cd9d5be8b54c6fafe44346dabeb3b76/docs/engineering/to-tickets.md#L25-L27)). That is a purposeful working equivalence, not proof that the two terms have identical definitions everywhere.

## Definitions and origin

### Tracer bullet

The authoritative software lineage located here is Andrew Hunt and David Thomas's *The Pragmatic Programmer* (1999). The publisher still lists the maxim "Use Tracer Bullets to Find the Target" and explains it as trying things, seeing where they land, and homing in on the target ([official Pragmatic Bookshelf tips, tip 20](https://pragprog.com/tips/)). In a later direct interview, Thomas says the metaphor comes from gunnery: visible tracer rounds are mixed with ordinary rounds so the gunner can see the trajectory and correct the aim under real, changing conditions ([Hunt and Thomas interview, "Tracer Bullets"](https://www.artima.com/articles/tracer-bullets-and-prototypes)).

The software analogue is therefore early feedback instead of exhaustive up-front specification. Hunt describes the starting artifact as a "skeletally thin" line of execution running end to end from UI, through business logic, to a database. The team then adds features or use cases one at a time, checks each path, and corrects course while change is still cheap ([same interview, "Starting with a Skeleton Application"](https://www.artima.com/articles/tracer-bullets-and-prototypes)). A tracer is not merely a throwaway experiment: in the same interview the authors contrast this growing skeleton with a prototype, whose purpose is isolated learning and whose code is intended to be discarded ([same interview, "Building Prototypes"](https://www.artima.com/articles/tracer-bullets-and-prototypes)).

The 1999 book is the earliest authoritative software source located in this research and clearly popularized the metaphor. I found no primary evidence that Hunt and Thomas coined its first software use. Their own account identifies the military metaphor but makes no priority claim ([interview](https://www.artima.com/articles/tracer-bullets-and-prototypes)).

### Vertical slice

Agile Alliance defines an Agile increment as a usable successive product version that adds user-visible functionality. It calls these "vertical" increments, contrasting them with delivery of complete technical components in sequence: schema, then business rules, then UI ([Agile Alliance, "Incremental Development"](https://agilealliance.org/glossary/incremental-development/)). Its story-splitting definition adds an outcome constraint: when one story is split, every smaller story should separately preserve measurable business value ([Agile Alliance, "Story Splitting"](https://agilealliance.org/glossary/story-splitting/)).

For this report, a **vertical slice** therefore means a small, independently usable, observable, or valuable increment crossing the technical boundaries needed for that behavior. "Vertical" is relative to a system pictured in horizontal technical layers; it does not require every conceivable layer when a behavior does not touch one. This report uses the Agile feature-slicing sense; other uses of the term may set different completion standards.

## Relationship

| Axis | Vertical slice | Tracer bullet |
| --- | --- | --- |
| Primary question | "Does this increment deliver a coherent capability across the relevant layers?" ([Agile Alliance](https://agilealliance.org/glossary/incremental-development/)) | "What is the thinnest real path that will show where we are off target?" ([Hunt/Thomas interview](https://www.artima.com/articles/tracer-bullets-and-prototypes)) |
| Defining emphasis | Scope geometry and independent product value/observability ([story splitting](https://agilealliance.org/glossary/story-splitting/)) | Fast feedback, uncertainty reduction, and course correction under real conditions ([official tip](https://pragprog.com/tips/)) |
| Typical shape | One narrow behavior crossing its required layers | A skeletally thin end-to-end execution path, then use cases added through that path ([interview](https://www.artima.com/articles/tracer-bullets-and-prototypes)) |
| Opposite failure | Horizontal/component work that becomes usable only after later layers land ([Agile Alliance](https://agilealliance.org/glossary/incremental-development/)) | Specifying everything first and discovering only at the end whether it hit the target; or confusing durable tracer code with a throwaway prototype ([interview](https://www.artima.com/articles/tracer-bullets-and-prototypes)) |
| Set relationship | Can be routine incremental delivery without a material targeting question ([Agile Alliance](https://agilealliance.org/glossary/incremental-development/)) | Is normally vertical in the layered sense, but its first skeleton may prove integration and feedback without yet carrying independently measurable business value ([Hunt/Thomas](https://www.artima.com/articles/tracer-bullets-and-prototypes)) |

Thus, **"vertical slice" names the shape; "tracer bullet" names the learning role**. The same increment often has both properties. Neither label alone guarantees all of the other's stronger criteria.

## Matt Pocock findings

### Meaning in the current skills

Matt's `to-tickets` source intentionally collapses the distinction for implementation planning. It calls tickets "tracer-bullet vertical slices," requires each to cut a narrow but complete path through schema/API/UI/tests, and requires standalone demonstration or verification ([`to-tickets/SKILL.md`, lines 3–40](https://github.com/mattpocock/skills/blob/6654f6b60cd9d5be8b54c6fafe44346dabeb3b76/skills/engineering/to-tickets/SKILL.md#L3-L40)). Its documentation is even more explicit: every ticket is a tracer bullet, and a "vertical slice (the tracer bullet)" is a thin path through all layers that is verifiable alone ([`docs/engineering/to-tickets.md`, lines 1–27](https://github.com/mattpocock/skills/blob/6654f6b60cd9d5be8b54c6fafe44346dabeb3b76/docs/engineering/to-tickets.md#L1-L27)). Wide mechanical refactors are an explicit exception because no such slice can land green; the skill uses expand–contract instead ([source lines 38–40](https://github.com/mattpocock/skills/blob/6654f6b60cd9d5be8b54c6fafe44346dabeb3b76/skills/engineering/to-tickets/SKILL.md#L38-L40)).

The TDD skill reuses the metaphor at a smaller granularity: one test, one minimal implementation, repeat; each test is called a tracer bullet responding to the previous cycle's learning ([`tdd/SKILL.md`, lines 28–37](https://github.com/mattpocock/skills/blob/6654f6b60cd9d5be8b54c6fafe44346dabeb3b76/skills/engineering/tdd/SKILL.md#L28-L37)). Its documentation narrows that slightly by calling the **first** cycle the tracer that proves one end-to-end path ([`docs/engineering/tdd.md`, line 33](https://github.com/mattpocock/skills/blob/6654f6b60cd9d5be8b54c6fafe44346dabeb3b76/docs/engineering/tdd.md#L33)). Finally, Matt's writing skill explicitly treats "tracer bullets" as a compact **leading word** that recruits a model's existing priors, which helps explain why the operational wording favors a short equivalence over a careful taxonomy ([`writing-for-agents/SKILL.md`, lines 61–65](https://github.com/mattpocock/skills/blob/6654f6b60cd9d5be8b54c6fafe44346dabeb3b76/skills/productivity/writing-for-agents/SKILL.md#L61-L65)).

### Exhaustive mention inventory at the pinned commit

A case-insensitive search of every tracked file for `tracer` or `vertical` found the following relevant lines; ranges include the two semantic mentions written as "slice … vertical" rather than the exact phrase "vertical slice." This is the complete current-source inventory, including source skills, first-party docs, metadata, repository guidance, and changelog entries:

| Area | Pinned file and every matching line |
| --- | --- |
| Behavior-defining skills | [`skills/engineering/to-tickets/SKILL.md`: 3, 9, 25, 27, 29, 31, 36, 40](https://github.com/mattpocock/skills/blob/6654f6b60cd9d5be8b54c6fafe44346dabeb3b76/skills/engineering/to-tickets/SKILL.md#L3-L40); [`skills/engineering/tdd/SKILL.md`: 32](https://github.com/mattpocock/skills/blob/6654f6b60cd9d5be8b54c6fafe44346dabeb3b76/skills/engineering/tdd/SKILL.md#L32); [`skills/engineering/ask-matt/SKILL.md`: 23](https://github.com/mattpocock/skills/blob/6654f6b60cd9d5be8b54c6fafe44346dabeb3b76/skills/engineering/ask-matt/SKILL.md#L23); [`skills/productivity/writing-for-agents/SKILL.md`: 63](https://github.com/mattpocock/skills/blob/6654f6b60cd9d5be8b54c6fafe44346dabeb3b76/skills/productivity/writing-for-agents/SKILL.md#L63); [`skills/in-progress/writing-fragments/SKILL.md`: 36](https://github.com/mattpocock/skills/blob/6654f6b60cd9d5be8b54c6fafe44346dabeb3b76/skills/in-progress/writing-fragments/SKILL.md#L36) |
| Skill metadata/indexes | [`skills/engineering/to-tickets/agents/openai.yaml`: 3](https://github.com/mattpocock/skills/blob/6654f6b60cd9d5be8b54c6fafe44346dabeb3b76/skills/engineering/to-tickets/agents/openai.yaml#L3); [`skills/engineering/README.md`: 15, 27](https://github.com/mattpocock/skills/blob/6654f6b60cd9d5be8b54c6fafe44346dabeb3b76/skills/engineering/README.md#L15-L27); [root `README.md`: 200, 209](https://github.com/mattpocock/skills/blob/6654f6b60cd9d5be8b54c6fafe44346dabeb3b76/README.md#L200-L209) |
| First-party engineering docs | [`docs/engineering/to-tickets.md`: 5, 25, 27, 46, 62, 77](https://github.com/mattpocock/skills/blob/6654f6b60cd9d5be8b54c6fafe44346dabeb3b76/docs/engineering/to-tickets.md#L5-L77); [`docs/engineering/implement.md`: 41, 83](https://github.com/mattpocock/skills/blob/6654f6b60cd9d5be8b54c6fafe44346dabeb3b76/docs/engineering/implement.md#L41-L83); [`docs/engineering/tdd.md`: 33](https://github.com/mattpocock/skills/blob/6654f6b60cd9d5be8b54c6fafe44346dabeb3b76/docs/engineering/tdd.md#L33); [`docs/engineering/to-spec.md`: 81](https://github.com/mattpocock/skills/blob/6654f6b60cd9d5be8b54c6fafe44346dabeb3b76/docs/engineering/to-spec.md#L81); [`docs/engineering/wayfinder.md`: 66](https://github.com/mattpocock/skills/blob/6654f6b60cd9d5be8b54c6fafe44346dabeb3b76/docs/engineering/wayfinder.md#L66) |
| Writing docs/guidance | [`docs/productivity/writing-for-agents.md`: 29](https://github.com/mattpocock/skills/blob/6654f6b60cd9d5be8b54c6fafe44346dabeb3b76/docs/productivity/writing-for-agents.md#L29); [`.agents/writing-docs.md`: 76](https://github.com/mattpocock/skills/blob/6654f6b60cd9d5be8b54c6fafe44346dabeb3b76/.agents/writing-docs.md#L76) |
| Historical record | [`CHANGELOG.md`: 179, 183, 209](https://github.com/mattpocock/skills/blob/6654f6b60cd9d5be8b54c6fafe44346dabeb3b76/CHANGELOG.md#L179-L209) |

## Implications for ds-mode

The current ds-mode wording says: "For large feature work, plan tracer-bullet slices. Each slice delivers a narrow working capability with its own proof," complete one before the next, then re-check the remaining plan ([`SKILL.md`, line 47](https://github.com/DavidSzczesniak/ds-mode/blob/1a3e70ce943c001c82782eb51c96125085d41fd1/skills/ds-mode/SKILL.md#L47)). Planning repeats the large-feature restriction and requires each slice's observation and proof while deliberately deferring later implementation detail until earlier evidence arrives ([`planning.md`, lines 25–31](https://github.com/DavidSzczesniak/ds-mode/blob/1a3e70ce943c001c82782eb51c96125085d41fd1/skills/ds-mode/references/planning.md#L25-L31)).

That wording is substantively sound:

- "Narrow working capability" plus its own proof captures the independently observable increment central to vertical slicing ([Agile Alliance](https://agilealliance.org/glossary/incremental-development/)).
- Completing one slice and reconsidering the rest from its evidence captures the targeting/feedback purpose central to tracer bullets ([Hunt/Thomas](https://www.artima.com/articles/tracer-bullets-and-prototypes)).
- Restricting the mechanism to large feature work avoids forcing horizontally wide refactors into artificial feature slices, consistent with Matt's explicit exception ([Matt source](https://github.com/mattpocock/skills/blob/6654f6b60cd9d5be8b54c6fafe44346dabeb3b76/skills/engineering/to-tickets/SKILL.md#L38-L40)).

The only material ambiguity is that ds-mode never says **end to end**, **across the relevant boundaries/layers**, or **independently demoable/verifiable**. "Working capability" likely implies that result, but could be misread as a working technical component. If dogfooding shows that failure, the smallest clarification would be to call these **vertical tracer-bullet slices** and define each as a narrow end-to-end capability that is independently observable and proven. No broader runtime rule is supported by this research.

## Uncertainties and source limitations

- The detailed 1999 book chapter is not freely available from the publisher. The origin account here therefore combines the publisher's official tip with a 2003 direct interview of both authors. That is strong primary testimony, but it does not establish that no earlier programmer used the phrase.
- Agile Alliance documents "vertical increments" and vertical-versus-horizontal delivery, but does not claim to identify who coined "vertical slice." Its own incremental-development history reaches back before the tracer-bullet book and warns that iterative and incremental terminology is debated ([Agile Alliance](https://agilealliance.org/glossary/incremental-development/)).
- This report uses the Agile feature-slicing sense. It does not try to reconcile unrelated uses of the same phrase; the answer applies to software delivery and planning, especially Matt Pocock's and ds-mode's usage.
- Matt's repository changes quickly. The inventory is exhaustive only for tracked content at the pinned commit, not later commits, deleted history, branches, issue discussions, or his separate websites.

## Source list

### Primary and official conceptual sources

1. Andrew Hunt and David Thomas, [*The Pragmatic Programmer* official page](https://pragprog.com/titles/tpp20/the-pragmatic-programmer-20th-anniversary-edition/) and [official tips](https://pragprog.com/tips/).
2. Andy Hunt and Dave Thomas, direct interview, ["Tracer Bullets and Prototypes"](https://www.artima.com/articles/tracer-bullets-and-prototypes), Artima, 2003.
3. Agile Alliance, ["Incremental Development"](https://agilealliance.org/glossary/incremental-development/).
4. Agile Alliance, ["Story Splitting"](https://agilealliance.org/glossary/story-splitting/).

### Compared source repositories

5. Matt Pocock, [`mattpocock/skills` at `6654f6b`](https://github.com/mattpocock/skills/tree/6654f6b60cd9d5be8b54c6fafe44346dabeb3b76); every relevant file/line is linked in the inventory above.
6. ds-mode, [`SKILL.md` at `1a3e70c`, line 47](https://github.com/DavidSzczesniak/ds-mode/blob/1a3e70ce943c001c82782eb51c96125085d41fd1/skills/ds-mode/SKILL.md#L47) and [`planning.md`, lines 25–31](https://github.com/DavidSzczesniak/ds-mode/blob/1a3e70ce943c001c82782eb51c96125085d41fd1/skills/ds-mode/references/planning.md#L25-L31).
