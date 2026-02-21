#!/usr/bin/env bash
set -euo pipefail

MISE_BIN="$(command -v mise || true)"
if [[ -z "${MISE_BIN}" && -x "${HOME}/.local/bin/mise" ]]; then
  MISE_BIN="${HOME}/.local/bin/mise"
fi

if [[ -z "${MISE_BIN}" ]]; then
  echo "mise is not available; cannot install github.com/jclem/get" >&2
  exit 1
fi

"${MISE_BIN}" install github:jclem/get
