### Pause safely

**You own a clean stop. Leave a checkpoint a cold-start agent can resume from.** Use on an explicit pause or imminent context compaction.

1. Stop at a safe boundary. Finish the current atomic step or back it out. Start nothing new. For each active background worker, read its PID file, verify the process command and checkout with `ps`, send `TERM` to that PID, and confirm exit. Keep the Pi session ID for later recovery. A session ID is not a process handle.
2. Do not cross an irreversible line to pause. Push or open a PR only when the user already requested it.
3. Make work durable. Commit a clear `wip:` commit only when repository instructions allow commits. Otherwise leave the exact diff and checkout path intact.
4. Write a resume note outside the conversation. Capture intent, progress, verified evidence, current state, next steps, key files, gotchas, worker names, Pi session IDs, PID paths and final process state, brief paths, result JSONL paths, and checkouts. Point to an existing Show Me Your Work trail instead of duplicating it.

**Reply:** the current unit, what is on disk, commits if any, checkout paths, persisted Pi session IDs, and the first action on resume. This is a pause, not a final report.
