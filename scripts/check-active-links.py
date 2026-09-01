#!/usr/bin/env python3

import re
from pathlib import Path

root = Path(__file__).resolve().parents[1]
skills = root / "skills"
installed = {path.name for path in skills.iterdir() if path.is_dir()}
errors = []
active_markdown = [root / "AGENTS.md", root / "README.md", root / "docs/dogfooding.md", root / "docs/pstack-redesign-plan.md"]
active_markdown.extend(skills.rglob("*.md"))

for path in sorted(active_markdown):
    text = path.read_text()
    for target in re.findall(r"\[[^\]]+\]\(([^)]+)\)", text):
        target = target.split("#", 1)[0]
        if not target or target == "url" or "://" in target or target.startswith("mailto:") or "<" in target:
            continue
        resolved = (path.parent / target).resolve()
        if not resolved.exists():
            errors.append(f"{path.relative_to(root)}: missing Markdown link {target}")

    if skills not in path.parents:
        continue
    skill_root = path
    while skill_root.parent != skills and skill_root != skills:
        skill_root = skill_root.parent
    for target in re.findall(r"`((?:playbooks|references)/[^` ]+\.md)`", text):
        if "<" in target:
            continue
        matches = list(skill_root.glob(target)) if "*" in target else [skill_root / target]
        if not matches or any(not match.exists() for match in matches):
            errors.append(f"{path.relative_to(root)}: missing active reference {target}")

    for name in re.findall(r"\*\*([a-z][a-z0-9-]+)\*\* skill", text):
        if name not in installed and name not in {"model-invoked", "user-invoked"}:
            errors.append(f"{path.relative_to(root)}: missing installed skill {name}")

if errors:
    raise SystemExit("\n".join(errors))
print(f"active links ok: {len(active_markdown)} Markdown files, {len(installed)} installed skill roots")
