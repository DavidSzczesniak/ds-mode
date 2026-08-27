#!/bin/sh

set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
skills_root=${DS_MODE_SKILLS_DIR:-"$HOME/.agents/skills"}
legacy_skills_root=/Users/david/Documents/workspaces/dforge/skills

mkdir -p "$skills_root"

for source in "$repo_root"/skills/*; do
  [ -d "$source" ] || continue
  name=${source##*/}
  target="$skills_root/$name"

  if [ -L "$target" ]; then
    current=$(readlink "$target")
    case "$current" in
      "$source" | "$legacy_skills_root/$name") ;;
      *)
        echo "refusing to replace unrelated link: $target -> $current" >&2
        exit 1
        ;;
    esac
  elif [ -e "$target" ]; then
    echo "refusing to overwrite real path: $target" >&2
    exit 1
  fi
done

for source in "$repo_root"/skills/*; do
  [ -d "$source" ] || continue
  name=${source##*/}
  target="$skills_root/$name"

  if [ -L "$target" ]; then
    current=$(readlink "$target")
    [ "$current" = "$source" ] && continue
    rm "$target"
  fi

  ln -s "$source" "$target"
  echo "linked $name"
done
