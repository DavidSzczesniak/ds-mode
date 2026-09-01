### Session pickup

**You own the resume point. Read the prior trail, don't redo it.** Use for a Pi session ID, resume note, result JSONL, or pushed branch.

1. Locate the prior trail. Resume an exact Pi session with `pi --session <session-id>`, or use `pi -r` to select it. The durable brief and result JSONL identify the task. Inside a worker, `PI_SESSION_ID` and `PI_SESSION_FILE` identify the active session.
2. Read the metadata and last messages first, then scan back for decision points. Give a long JSONL file to a named Pi Explore worker and keep the reduced timeline in the lead context.
3. Reconstruct operational state. Record the branch and checkout, `git log`, the diff against the base, open `update_plan` items, decisions, and verification already completed.
4. Compare done with pending. Name the resume point and preserve completed work. Re-run evidence only when it is missing, stale, or required by the final accepted outcome.
5. Route the remaining work to the matching playbook. Verify inherited claims against the original goal on the real artifact.

The decision trail records reasoning. Pi session metadata records process identity. Neither claims that a worker is still alive.

**Reply:** the session ID, where the prior worker stopped, what you inherited or redid, the resume point, and the outcome.
