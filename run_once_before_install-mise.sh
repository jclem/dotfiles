#!/usr/bin/env bash
set -euo pipefail

if ! command -v mise >/dev/null 2>&1; then
  curl https://mise.run | sh
fi

MISE_BIN="$(command -v mise || true)"
if [[ -z "${MISE_BIN}" && -x "${HOME}/.local/bin/mise" ]]; then
  MISE_BIN="${HOME}/.local/bin/mise"
fi

if [[ -z "${MISE_BIN}" ]]; then
  echo "mise installation succeeded, but no mise binary was found on PATH" >&2
  exit 1
fi

"${MISE_BIN}" install go@latest
