#!/bin/bash
# Lightweight wrapper to run Codex CLI and tee output to /tmp/codex-output.txt

set -euo pipefail

CODEX_BIN="${CODEX_BIN:-$(command -v codex || true)}"
OUTPUT_FILE="${CODEX_OUTPUT_FILE:-/tmp/codex-output.txt}"

if [[ -z "$CODEX_BIN" ]]; then
  echo "codex binary not found. Set CODEX_BIN or install codex." >&2
  exit 2
fi

: > "$OUTPUT_FILE"
"$CODEX_BIN" "$@" 2>&1 | tee "$OUTPUT_FILE"
