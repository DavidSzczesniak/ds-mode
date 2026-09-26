### Opening a PR

Invoked at the end of every other playbook. A request for only a title and body returns them without pushing. A repair request edits an existing PR's title or body in place and keeps its human content.

**Checkout.** Use the current checkout when it is clean or dedicated to this task, otherwise a git worktree off the base branch that carries only this task's changes. Untracked files do not make a checkout dirty, and nobody deletes, overwrites, or adopts them. On the default branch, create a topic branch first. Never push the default branch.

**Commits.** Commit liberally. Rebase into small, ordered commits before opening PRs. Each commit is a future PR: landable, ordered to tell the story. Amend when the fix belongs in a just-made commit. New commit when separable. Rewrite your own PR branch freely and push it with `--force-with-lease`. A branch someone else has pushed to or reviewed is shared.

**PRs.** Run [deslop](../../deslop/SKILL.md) over the diff before commit. Run [no-comments](../../no-comments/SKILL.md) before review. Run [interrogate](../../interrogate/SKILL.md) first when the design was contested and the task has not run it. Write every PR title, PR description, and commit body with [technical-writing](../../technical-writing/SKILL.md), then apply [unslop](../../unslop/SKILL.md). Whoever opens the PR, lead or worker, runs these.

**Titles.** Use `type(scope): outcome` for every commit except Pause safely's `wip:` commit, and for the PR and the squash commit. The types are `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `perf`, `build`, and `chore`. Use a short product or module name as the scope. Keep the outcome short and imperative, with no trailing period, and the whole title within 72 characters. Append `(#123)` or `(ABC-123)` when the change resolves that ticket. Give each commit two or three lines of why. Before every push, run `<this skill's directory>/scripts/check-commit-titles.sh <base-branch>` from the checkout being pushed. Reword every commit it prints, and push only when it exits 0.

**Descriptions.** The PR body is a briefing, not the lab notebook. A reviewer who has the diff should learn why the change exists, what is out of scope, and how you proved the change works. Keep the body under about 40 lines.

Use these sections in order. Drop a section when it has nothing to say.

- `## Why`. State the intent and approach in one or two short paragraphs. Do not list SHAs or rebase genealogy. Do not add a "based on main" preamble.
- `## Scope`. Use bullets to list real symbols and paths. Name both sides of a rename or retarget. State what is in and out only when the boundary matters. Do not write a file-by-file essay.
- `## Tradeoffs`. Name only rejected alternatives that a reviewer would otherwise ask about. Skip this section when there was no real choice.
- `## Blast Radius`. In one to three sentences, name who or what the change touches and why the change is safe or risky. State the continuing cost if main stays red without the fix.
- `## Verification`. Name each real run path and its outcome. For a performance change, report one primary number with its unit in `before → after` form. Link the arena or swarm directory for the remaining evidence. Do not include sample-size methodology, swarm recitals, or metric tables.
- `## Open decisions`. Each call the ticket left open, the default you applied, and the one word that reverses it.
- `## Squash commit message`. A fenced `text` block with the commit body only, two or three lines on the need or root cause and the resulting behavior.

After these sections, attach videos or screenshots when they prove a claim. Do not paste full SHAs, swarm or arena lane recitals, lever-correction essays, file-by-file checklists, or "CLEAN" verdicts. Put these details in a linked artifact. Do not use `## Summary` or `## Test plan` boilerplate. A commit body does not restate its subject.

**Size and stacks.** Prefer five narrow PRs to one large PR. A stack is a base-branch chain. The root PR targets the default branch. Each child branch rebases onto its parent's exact tip, and its PR targets the parent branch (`gh pr create --base <parent-branch>`). Branch from the default branch only for independent work. Rebase on it before substantial stack work.

**Publish.** If the branch already has an open PR, push and update its body to describe the final change. Otherwise push and run `gh pr create`. Open every PR ready, never as a draft. Read it back with `gh pr view` before you refer to its status, and fix any mismatch.

**Verdict.** After creating the PR or pushing commits that change its patch, get an independent verdict for the head. Skip it inside a multi-phase plan, whose swarm verdict replaces it, when a verdict with a matching `git patch-id` already covers the head, or when the PR changes only docs or comments and says so.

- Launch one fresh Review worker with the PR URL, the head SHA, and the checkout path. Leave that checkout unchanged until the verdict returns.
- The worker first re-runs the repository's documented gates at the head SHA. A test or check that fails at head but passes at the merge base is a `FAIL`. It runs the merge base in a separate worktree, only for checks that fail at head. When the base cannot run or the check is new, a failure at head is a `FAIL`.
- It then exercises the real surface ([control-ui](../../control-ui/SKILL.md) or [control-cli](../../control-cli/SKILL.md) as the change demands) against base versus head. It posts `PASS`, `PASS+NOTES`, or `FAIL` on the PR with the head SHA and the screenshots that prove it (`gh pr comment <number> --body-file <file> --attach <path>`). An interaction change also gets a 30 to 60 second video.
- On `FAIL`, fix the findings, push, and get a new verdict from a fresh worker.
- The verdict comes from an agent that did not write the code. CI green is not a verdict, and an approving bot review is not a verdict.

**No PR Check.** Opening a PR does not start PR Check and Triage. Post the URL and the verdict, and keep building. A later status request routes to `playbooks/pr-check-and-triage.md`.
