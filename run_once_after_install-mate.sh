#!/usr/bin/env bash
set -euo pipefail

TEXTMATE_APP="/Applications/TextMate.app/Contents/MacOS/mate"
MATE_LINK="${HOME}/bin/mate"

if [[ -f "${TEXTMATE_APP}" && ! -e "${MATE_LINK}" ]]; then
  mkdir -p "${HOME}/bin"
  ln -s "${TEXTMATE_APP}" "${MATE_LINK}"
fi
