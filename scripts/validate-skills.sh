#!/bin/sh

set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
validator=${CODEX_SKILL_VALIDATOR:-$HOME/.codex/skills/.system/skill-creator/scripts/quick_validate.py}
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT INT TERM

cp -R "$repo_root/skills" "$tmp/skills"
python3 - "$tmp/skills" <<'PY'
import sys
from pathlib import Path

for path in Path(sys.argv[1]).glob("*/SKILL.md"):
    lines = path.read_text().splitlines(keepends=True)
    path.write_text("".join(line for line in lines if not line.startswith("disable-model-invocation:")))
PY

for skill in "$tmp"/skills/*/SKILL.md; do
    python3 "$validator" "$(dirname "$skill")" >/dev/null
done

"$repo_root/scripts/check-skill-invocation-policy.py"
printf 'Codex validation passed: %s skills\n' "$(find "$tmp/skills" -mindepth 2 -maxdepth 2 -name SKILL.md | wc -l | tr -d ' ')"
