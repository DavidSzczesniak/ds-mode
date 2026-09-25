#!/bin/sh

set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo_root"

printf '%s  %s\n' \
  '0f9384b3c70320851f8a50ce80f000bd1ad1a17ba5dbb93755ccae7c5b1a7ee6' 'upstream/SHA256SUMS' \
  '48c6dc70fb86fa728620383f2366e702cc0ec07a4f254f767ada98eace92ea01' 'upstream/SOURCES.tsv' |
  sha256sum -c - >/dev/null

(
  cd upstream
  [ "$(wc -l < SHA256SUMS | tr -d ' ')" = 162 ]
  sha256sum -c SHA256SUMS >/dev/null
)

python3 - "$repo_root" <<'PY'
import csv
import sys
from pathlib import Path

root = Path(sys.argv[1])
manifest_path = root / "docs/upstream-deviations.tsv"
allowed = {"verbatim", "host substitution", "inactive", "prototype pending"}
with manifest_path.open(newline="") as f:
    rows = list(csv.DictReader(f, delimiter="\t"))

errors = []
required = {
    "upstream_path", "commit", "section_or_step", "status",
    "original_dependency", "local_root", "local_path", "local_treatment", "reason",
    "reconsideration_trigger", "dogfooding_evidence",
}
if not rows:
    errors.append("deviation manifest is empty")
elif set(rows[0]) != required:
    errors.append("deviation manifest columns do not match the lineage contract")

represented = {row["local_root"] for row in rows}
for row in rows:
    if row["status"] not in allowed:
        errors.append(f"invalid status for {row['upstream_path']}: {row['status']}")
    if any(not row[column].strip() for column in required):
        errors.append(f"empty manifest field for {row['upstream_path']}")
    if row["commit"] == "fadd23794c0075468eb8964b0fd93e06e09486ad" and not (root / "upstream" / row["upstream_path"]).exists():
        errors.append(f"manifest upstream path does not exist: {row['upstream_path']}")

for marker in sorted((root / "skills").glob("*/.upstream-source")):
    local_root_path = marker.parent
    local_root = local_root_path.relative_to(root).as_posix()
    if local_root not in represented:
        errors.append(f"active adapted root missing from manifest: {local_root}")
    declarations = [line.split("@", 1)[0] for line in marker.read_text().splitlines()]
    for source in declarations:
        if not (root / "upstream" / source).exists():
            errors.append(f"marker source does not exist: {marker.relative_to(root)} -> {source}")
        if not any(row["local_root"] == local_root and (row["upstream_path"] == source or row["upstream_path"].startswith(source.rstrip("/") + "/")) for row in rows):
            errors.append(f"declared adaptation missing from manifest: {local_root} <- {source}")

    primary = root / "upstream" / declarations[0]
    for local in sorted(local_root_path.rglob("*")):
        if not local.is_file() or local.name == ".upstream-source":
            continue
        relative = local.relative_to(local_root_path).as_posix()
        if relative == "references/comment-sicko.md" and "pstack/agents/comment-sicko.md" in declarations:
            source = root / "upstream/pstack/agents/comment-sicko.md"
        else:
            source = primary / relative
        if source.exists() and source.read_bytes() == local.read_bytes():
            continue
        local_path = local.relative_to(root).as_posix()
        if not any(row["local_root"] == local_root and row["local_path"] == local_path for row in rows):
            errors.append(f"adapted file missing from manifest: {local_path}")

def body(path):
    data = path.read_bytes()
    parts = data.split(b"---\n", 2)
    return parts[2] if len(parts) == 3 else data

for row in rows:
    if not row["upstream_path"].endswith("/SKILL.md"):
        continue
    source = root / "upstream" / row["upstream_path"]
    target = root / row["local_root"] / "SKILL.md"
    if row["status"] == "verbatim":
        if not source.exists() or not target.exists():
            errors.append(f"verbatim path missing: {row['upstream_path']}")
        elif source.read_bytes() != target.read_bytes():
            errors.append(f"verbatim active copy changed: {target.relative_to(root)}")
    if ("/principle-" in row["upstream_path"] or row["local_root"] in {"skills/tdd", "skills/technical-writing", "skills/unslop"}):
        if not source.exists() or not target.exists() or body(source) != body(target):
            errors.append(f"pinned body changed: {target.relative_to(root)}")

if errors:
    print("\n".join(errors), file=sys.stderr)
    raise SystemExit(1)
print(f"lineage ok: 162 snapshot files, {len(rows)} deviation rows")
PY
