### Pause safely

**You own a clean stop. Leave a checkpoint a cold-start agent can resume from.** Use on an explicit pause or imminent context compaction.

1. Stop at a safe boundary. Finish the current atomic step or back it out. Start nothing new. Interrupt each active native child by its exact canonical target and record the target for later continuation.
2. Do not cross an irreversible line to pause. Push or open a PR only when the user already requested it.
3. Make work durable. Commit a clear `wip:` commit only when repository instructions allow commits. Otherwise leave the exact diff and checkout path intact.
4. Write a resume note outside the conversation. Capture intent, progress, verified evidence, current state, next steps, key files, gotchas, worker roles, canonical child targets and final states, brief paths, result paths, and checkouts. Point to an existing Show Me Your Work trail instead of duplicating it.

**Reply:** the current unit, what is on disk, commits if any, checkout paths, canonical child targets, and the first action on resume. This is a pause, not a final report.
