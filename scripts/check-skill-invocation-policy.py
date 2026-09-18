#!/usr/bin/env python3
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

REQUIRED_EXPLICIT = {"how", "why"}
REQUIRED_IMPLICIT = {"technical-writing", "typescript-best-practices", "unslop"}


def frontmatter(path: Path) -> str:
    parts = path.read_text().split("---", 2)
    if len(parts) != 3:
        raise ValueError("missing YAML frontmatter")
    return parts[1]


def boolean_field(text: str, key: str, path: Path, errors: list[str]) -> bool:
    matches = re.findall(rf"(?m)^\s*{re.escape(key)}:\s*([^#\s]+)\s*(?:#.*)?$", text)
    if len(matches) > 1:
        errors.append(f"{path}: duplicate {key}")
        return False
    if not matches:
        return False
    if matches[0] not in {"true", "false"}:
        errors.append(f"{path}: {key} must be a YAML boolean")
        return False
    return matches[0] == "true"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("root", nargs="?", type=Path, default=Path(__file__).resolve().parents[1] / "skills")
    root = parser.parse_args().root.resolve()
    errors: list[str] = []
    checked = 0
    for skill in sorted(path.parent for path in root.glob("*/SKILL.md")):
        skill_file = skill / "SKILL.md"
        codex_file = skill / "agents/openai.yaml"
        try:
            pi_explicit = boolean_field(
                frontmatter(skill_file), "disable-model-invocation", skill_file.relative_to(root.parent), errors
            )
        except ValueError as error:
            errors.append(f"{skill_file.relative_to(root.parent)}: {error}")
            continue
        codex_explicit = False
        if codex_file.is_file():
            codex_explicit = not boolean_field(
                codex_file.read_text(), "allow_implicit_invocation", codex_file.relative_to(root.parent), errors
            ) if re.search(r"(?m)^\s*allow_implicit_invocation:", codex_file.read_text()) else False
        if pi_explicit != codex_explicit:
            errors.append(
                f"{skill.name}: Pi/Cursor explicit-only={pi_explicit}, Codex explicit-only={codex_explicit}"
            )
        if skill.name in REQUIRED_EXPLICIT and not (pi_explicit and codex_explicit):
            errors.append(f"{skill.name}: required explicit-only policy is absent")
        if skill.name in REQUIRED_IMPLICIT and (pi_explicit or codex_explicit):
            errors.append(f"{skill.name}: automatic invocation must be enabled")
        checked += 1
    if errors:
        print("\n".join(errors), file=sys.stderr)
        return 1
    print(f"skill invocation policy aligned: {checked} skills")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
