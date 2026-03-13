#!/bin/bash
# Post-run notifier for Codex CLI tasks.

set -euo pipefail

RESULT_DIR="${RESULT_DIR:-/home/ubuntu/clawd/data/codex-results}"
EXIT_CODE=""
LOG_FILE=""
OPENCLAW_BIN_DEFAULT="${OPENCLAW_BIN:-$(command -v openclaw || true)}"

usage() {
  cat <<'EOF'
Usage: notify-openclaw.sh [--result-dir DIR] [--exit-code N] [--help]
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --result-dir) RESULT_DIR="$2"; shift 2 ;;
    --exit-code) EXIT_CODE="$2"; shift 2 ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
done

META_FILE="${RESULT_DIR}/task-meta.json"
TASK_OUTPUT="${RESULT_DIR}/task-output.txt"
LATEST_JSON="${RESULT_DIR}/latest.json"
WAKE_FILE="${RESULT_DIR}/pending-wake.json"
LOG_FILE="${RESULT_DIR}/notify.log"

mkdir -p "$RESULT_DIR"
log() { echo "[$(date -Iseconds)] $*" >> "$LOG_FILE"; }

log "=== notifier start ==="

TASK_NAME="unknown"
TELEGRAM_GROUP=""
CALLBACK_SESSION=""
WORKDIR=""
PROMPT=""
MODEL=""
SANDBOX=""
STARTED_AT=""

if [[ -f "$META_FILE" ]]; then
  TASK_NAME=$(jq -r '.task_name // "unknown"' "$META_FILE" 2>/dev/null || echo "unknown")
  TELEGRAM_GROUP=$(jq -r '.telegram_group // ""' "$META_FILE" 2>/dev/null || echo "")
  CALLBACK_SESSION=$(jq -r '.callback_session // ""' "$META_FILE" 2>/dev/null || echo "")
  WORKDIR=$(jq -r '.workdir // ""' "$META_FILE" 2>/dev/null || echo "")
  PROMPT=$(jq -r '.prompt // ""' "$META_FILE" 2>/dev/null || echo "")
  MODEL=$(jq -r '.model // ""' "$META_FILE" 2>/dev/null || echo "")
  SANDBOX=$(jq -r '.sandbox // ""' "$META_FILE" 2>/dev/null || echo "")
  STARTED_AT=$(jq -r '.started_at // ""' "$META_FILE" 2>/dev/null || echo "")
fi

if [[ -z "$EXIT_CODE" && -f "$META_FILE" ]]; then
  EXIT_CODE=$(jq -r '.exit_code // empty' "$META_FILE" 2>/dev/null || true)
fi
EXIT_CODE="${EXIT_CODE:-1}"

OUTPUT=""
if [[ -s "$TASK_OUTPUT" ]]; then
  OUTPUT=$(tail -c 12000 "$TASK_OUTPUT")
fi

STATUS="failed"
if [[ "$EXIT_CODE" = "0" ]]; then
  STATUS="done"
fi

jq -n \
  --arg task_name "$TASK_NAME" \
  --arg timestamp "$(date -Iseconds)" \
  --arg started_at "$STARTED_AT" \
  --arg workdir "$WORKDIR" \
  --arg telegram_group "$TELEGRAM_GROUP" \
  --arg callback_session "$CALLBACK_SESSION" \
  --arg prompt "$PROMPT" \
  --arg model "$MODEL" \
  --arg sandbox "$SANDBOX" \
  --arg output "$OUTPUT" \
  --arg status "$STATUS" \
  --argjson exit_code "$EXIT_CODE" \
  '{task_name: $task_name, timestamp: $timestamp, started_at: $started_at, workdir: $workdir, telegram_group: $telegram_group, callback_session: $callback_session, prompt: $prompt, model: $model, sandbox: $sandbox, output: $output, status: $status, exit_code: $exit_code}' \
  > "$LATEST_JSON"

SUMMARY=$(printf '%s' "$OUTPUT" | tail -c 1000 | tr '\n' ' ' | sed 's/  */ /g')

jq -n \
  --arg task "$TASK_NAME" \
  --arg group "$TELEGRAM_GROUP" \
  --arg session "$CALLBACK_SESSION" \
  --arg ts "$(date -Iseconds)" \
  --arg status "$STATUS" \
  --arg summary "$SUMMARY" \
  '{task_name: $task, telegram_group: $group, callback_session: $session, timestamp: $ts, status: $status, summary: $summary, processed: false}' \
  > "$WAKE_FILE"

log "wrote latest.json and pending-wake.json"

OPENCLAW_BIN="$OPENCLAW_BIN_DEFAULT"
if [[ -n "$TELEGRAM_GROUP" && -n "$OPENCLAW_BIN" && -x "$OPENCLAW_BIN" ]]; then
  MSG="🤖 Codex 任务完成
📋 任务: ${TASK_NAME}
📁 目录: ${WORKDIR}
📌 状态: ${STATUS} (exit=${EXIT_CODE})
📝 摘要:
${SUMMARY:0:800}"
  if "$OPENCLAW_BIN" message send --channel telegram --target "$TELEGRAM_GROUP" --message "$MSG" >/dev/null 2>&1; then
    log "telegram sent to $TELEGRAM_GROUP"
  else
    log "telegram send failed"
  fi
fi

log "=== notifier done ==="
