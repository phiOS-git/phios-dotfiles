#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOST="$(< /etc/hostname)"
MANIFEST="$REPO/hosts/$HOST.txt"

[[ -f "$MANIFEST" ]] || { echo "Manca hosts/$HOST.txt" >&2; exit 1; }

while read -r module; do
  [[ -z "$module" ]] && continue
  MOD="$REPO/modules/$module"
  [[ -d "$MOD" ]] || { echo "Modulo sconosciuto: $module" >&2; exit 1; }

  if [[ -f "$MOD/packages.txt" ]]; then
    sudo pacman -S --needed $(cat "$MOD/packages.txt")
  fi

  find "$MOD" -type f ! -name packages.txt | while read -r f; do
    rel="${f#$MOD/}"
    target="$HOME/$rel"
    mkdir -p "$(dirname "$target")"
    ln -sf "$f" "$target"
  done
done < "$MANIFEST"
