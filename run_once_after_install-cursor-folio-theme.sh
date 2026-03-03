#!/usr/bin/env bash
set -euo pipefail

source_dir="$HOME/Library/Application Support/Cursor/User/folio-theme"
target_dir="$HOME/.cursor/extensions"
target_link="$target_dir/jclem.folio-1.0.0"

if [[ -e "$target_link" ]]; then
  exit 0
fi

if [[ ! -d "$source_dir" ]]; then
  echo "Folio theme source not found at $source_dir; run chezmoi apply first" >&2
  exit 1
fi

mkdir -p "$target_dir"
ln -sf "$source_dir" "$target_link"
