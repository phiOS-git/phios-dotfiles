#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOST="$(< /etc/hostname)"
MANIFEST="$REPO/hosts/$HOST.txt"

[[ -f "$MANIFEST" ]] || { echo "Manca hosts/$HOST.txt" >&2; exit 1; }

while read -r module <&3; do
  [[ -z "$module" ]] && continue
  MOD="$REPO/modules/$module"
  [[ -d "$MOD" ]] || { echo "Modulo sconosciuto: $module" >&2; exit 1; }

  if [[ -f "$MOD/packages.txt" ]]; then
    sudo pacman -S --needed $(cat "$MOD/packages.txt")
  fi

  find "$MOD" -type f ! -name packages.txt ! -name '*.tmpl' | while read -r f; do
    rel="${f#$MOD/}"
    target="$HOME/$rel"
    mkdir -p "$(dirname "$target")"
    ln -sfr "$f" "$target"
  done

  find "$MOD" -type f -name '*.tmpl' | while read -r f; do
    rel="${f#$MOD/}"; rel="${rel%.tmpl}"
    target="$HOME/$rel"
    mkdir -p "$(dirname "$target")"
    ( set -a; source "$REPO/theme.sh"; set +a
      envsubst < "$f" > "$target" )
  done
done 3< "$MANIFEST"
