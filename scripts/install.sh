#!/bin/sh

set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
skills_root=${DS_MODE_SKILLS_DIR:-"$HOME/.agents/skills"}
claude_skills_root=${DS_MODE_CLAUDE_SKILLS_DIR:-"$HOME/.claude/skills"}

mkdir -p "$skills_root" "$claude_skills_root"
skills_root=$(CDPATH= cd -- "$skills_root" && pwd -P)
claude_skills_root=$(CDPATH= cd -- "$claude_skills_root" && pwd -P)

check_target() {
  if [ -L "$2" ]; then
    current=$(readlink "$2")
    case "$current" in
      /*) current_path=$current ;;
      *) current_path="${2%/*}/$current" ;;
    esac
    current_parent=$(CDPATH= cd -- "${current_path%/*}" 2>/dev/null && pwd -P) || current_parent=
    if [ "$current_parent/${current_path##*/}" != "$1" ]; then
      echo "refusing to replace unrelated link: $2 -> $current" >&2
      exit 1
    fi
  elif [ -e "$2" ]; then
    echo "refusing to overwrite real path: $2" >&2
    exit 1
  fi
}

link_skill() {
  if [ ! -L "$2" ]; then
    ln -s "$1" "$2"
    echo "linked $2"
  fi
}

for source in "$repo_root"/skills/*; do
  [ -d "$source" ] || continue
  name=${source##*/}

  check_target "$source" "$skills_root/$name"
  check_target "$skills_root/$name" "$claude_skills_root/$name"
done

for source in "$repo_root"/skills/*; do
  [ -d "$source" ] || continue
  name=${source##*/}

  link_skill "$source" "$skills_root/$name"
  link_skill "$skills_root/$name" "$claude_skills_root/$name"
done
