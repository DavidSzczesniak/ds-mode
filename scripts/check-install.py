#!/usr/bin/env python3

import os
from pathlib import Path
import subprocess
import tempfile


repo_root = Path(__file__).resolve().parents[1]
sources = sorted(path for path in (repo_root / "skills").iterdir() if path.is_dir())


def install(skills_root, claude_root):
    return subprocess.run(
        ["sh", str(repo_root / "scripts/install.sh")],
        env={
            **os.environ,
            "DS_MODE_SKILLS_DIR": str(skills_root),
            "DS_MODE_CLAUDE_SKILLS_DIR": str(claude_root),
        },
        capture_output=True,
        text=True,
    )


with tempfile.TemporaryDirectory(prefix="ds-mode-install-") as temporary:
    root = Path(temporary).resolve()
    skills_root = root / "shared skills"
    claude_root = root / "claude skills"
    skills_root.mkdir()
    claude_root.mkdir()
    existing = claude_root / sources[0].name
    existing.symlink_to(os.path.relpath(skills_root / existing.name, claude_root))
    original_link = os.readlink(existing)
    unrelated = claude_root / "unrelated-skill"
    unrelated.mkdir()

    result = install(skills_root, claude_root)
    assert result.returncode == 0, result.stderr
    for source in sources:
        shared = skills_root / source.name
        claude = claude_root / source.name
        assert shared.is_symlink() and shared.resolve() == source
        assert claude.is_symlink() and claude.resolve() == source
        link_target = claude.parent / os.readlink(claude)
        assert link_target.parent.resolve() / link_target.name == shared
    assert os.readlink(existing) == original_link
    assert unrelated.is_dir()

    links = [directory / source.name for directory in (skills_root, claude_root) for source in sources]
    before = [(link.lstat().st_ino, link.lstat().st_mtime_ns) for link in links]
    result = install(skills_root, claude_root)
    assert result.returncode == 0, result.stderr
    assert result.stdout == "", result.stdout
    assert [(link.lstat().st_ino, link.lstat().st_mtime_ns) for link in links] == before

def stable(path):
    # Access time is excluded: Linux updates it when the installer reads the symlink.
    status = path.lstat()
    return status.st_ino, status.st_mode, status.st_size, status.st_mtime_ns


for destination in ("shared", "claude"):
    for conflict in ("file", "directory", "symlink"):
        with tempfile.TemporaryDirectory(prefix="ds-mode-conflict-") as temporary:
            root = Path(temporary).resolve()
            skills_root = root / "shared"
            claude_root = root / "claude"
            skills_root.mkdir()
            claude_root.mkdir()
            target = root / destination / sources[-1].name
            if conflict == "file":
                target.write_text("keep me")
            elif conflict == "directory":
                target.mkdir()
                (target / "keep-me").write_text("keep me")
            else:
                target.symlink_to(root / "missing-unrelated-skill")
            before = stable(target)

            result = install(skills_root, claude_root)
            assert result.returncode != 0, (destination, conflict)
            assert "refusing to" in result.stderr, result.stderr
            assert stable(target) == before
            assert set(skills_root.iterdir()) | set(claude_root.iterdir()) == {target}

print(f"installer ok: {len(sources)} skills, existing relative links, repeat run, six conflicts")
