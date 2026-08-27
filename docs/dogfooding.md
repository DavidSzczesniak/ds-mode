# Review a ds-mode dogfooding session

`Last reviewed: 2026-08`

Use this guide when a completed ds-mode session needs retrospective analysis. The goal is to identify the source of friction before changing the workflow.

## Inspect the session

1. Read the relevant transcript, including user corrections and any reviewer output.
2. Identify where the agent lost direction, added ceremony, accepted weak proof, or entered a review-fix loop.
3. Record what worked and should remain unchanged.
4. Inspect the target codebase, tests, tooling, and repository instructions behind each repeated failure.
5. Classify each issue as a project problem, a ds-mode problem, or unresolved.
6. Recommend the smallest response and explain what evidence supports it.

Pay particular attention to:

- User interventions that restored progress.
- Reviews that found architectural problems rather than contained defects.
- Passing checks that did not prove the accepted outcome.
- Local code patterns that taught the agent the wrong design.
- Tooling or repository boundaries that forced repeated rediscovery.
- Process that cost more than the task warranted.

Discuss the findings with the user before changing ds-mode. One observation is evidence to inspect, not an automatic new rule.

## Bootstrap inspection point

The unchanged principle leaves use a `user-invocable` frontmatter key that the current Codex skill validator rejects. Decide how to represent non-user-invocable leaves as each principle is reviewed. Do not bulk-rewrite them before that review.
