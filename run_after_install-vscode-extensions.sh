#!/usr/bin/env bash
set -euo pipefail

manifest_path="${VSCODE_EXTENSIONS_MANIFEST:-$HOME/Library/Application Support/Code/User/extensions.txt}"
folio_source_dir="${VSCODE_FOLIO_SOURCE_DIR:-$HOME/Library/Application Support/Code/User/folio-theme}"
extensions_dir="${VSCODE_EXTENSIONS_DIR:-$HOME/.vscode/extensions}"
code_bin="${VSCODE_BIN:-code}"

trim() {
  local value="$1"

  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"

  printf '%s' "$value"
}

extension_id() {
  printf '%s\n' "${1%@*}"
}

if [[ ! -f "$manifest_path" ]]; then
  echo "VS Code extensions manifest not found at $manifest_path" >&2
  exit 1
fi

manifest_specs=()
folio_spec=""

while IFS= read -r raw_line || [[ -n "$raw_line" ]]; do
  line=$(trim "${raw_line%%#*}")

  if [[ -z "$line" ]]; then
    continue
  fi

  manifest_specs+=("$line")

  if [[ "$line" == "jclem.folio" ]]; then
    echo "Local Folio extension entries must pin a version in $manifest_path" >&2
    exit 1
  fi

  if [[ "$line" == jclem.folio@* ]]; then
    folio_spec="$line"
  fi
done < "$manifest_path"

if [[ -n "$folio_spec" ]]; then
  if [[ ! -d "$folio_source_dir" ]]; then
    echo "Folio theme source not found at $folio_source_dir; run chezmoi apply first" >&2
    exit 1
  fi

  folio_version="${folio_spec#jclem.folio@}"
  folio_target_link="$extensions_dir/jclem.folio-$folio_version"

  mkdir -p "$extensions_dir"
  find "$extensions_dir" -maxdepth 1 -type l -name 'jclem.folio-*' ! -path "$folio_target_link" -exec rm -f {} +
  ln -snf "$folio_source_dir" "$folio_target_link"
fi

if ! command -v "$code_bin" >/dev/null 2>&1; then
  exit 0
fi

current_specs="$("$code_bin" --list-extensions --show-versions)"
desired_ids_file="$(mktemp)"
trap 'rm -f "$desired_ids_file"' EXIT

for spec in "${manifest_specs[@]}"; do
  printf '%s\n' "$(extension_id "$spec")" >> "$desired_ids_file"
done

sort -u -o "$desired_ids_file" "$desired_ids_file"

for spec in "${manifest_specs[@]}"; do
  id="$(extension_id "$spec")"

  if [[ "$id" == "jclem.folio" ]]; then
    continue
  fi

  current_spec=""

  while IFS= read -r line; do
    if [[ "$(extension_id "$line")" == "$id" ]]; then
      current_spec="$line"
      break
    fi
  done <<< "$current_specs"

  if [[ -n "$current_spec" ]]; then
    if [[ "$spec" == *"@"* && "$current_spec" == "$spec" ]]; then
      continue
    fi

    if [[ "$spec" != *"@"* ]]; then
      continue
    fi
  fi

  "$code_bin" --install-extension "$spec"
done

while IFS= read -r current_spec; do
  id="$(extension_id "$current_spec")"

  if grep -Fxq "$id" "$desired_ids_file"; then
    continue
  fi

  "$code_bin" --uninstall-extension "$id"
done <<< "$current_specs"
