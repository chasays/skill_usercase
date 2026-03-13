#!/bin/bash
# Dispatch a task to Codex CLI and notify OpenClaw/Telegram after completion.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RESULT_DIR="${RESULT_DIR:-/home/ubuntu/clawd/data/codex-results}"
META_FILE="${RESULT_DIR}/task-meta.json"
TASK_OUTPUT="${RESULT_DIR}/task-output.txt"
RUNNER="${SCRIPT_DIR}/codex_run.py"
NOTIFIER="${ROOT_DIR}/hooks/notify-openclaw.sh"

PROMPT=""
TASK_NAME="adhoc-$(date +%s)"
TELEGRAM_GROUP=""
CALLBACK_SESSION=""
WORKDIR="$(pwd)"
MODEL=""
SANDBOX="workspace-write"
SKIP_GIT_REPO_CHECK=0
CODEX_BIN="${CODEX_BIN:-}"
EXTRA_ARGS=()

usage() {
  cat <<'EOF'
Usage: dispatch-codex.sh [OPTIONS] -p "your prompt"

Options:
  -p, --prompt TEXT           Task prompt (required)
  -n, --name NAME             Task name (default: adhoc-<timestamp>)
  -g, --group ID              Telegram group ID for result delivery
  -s, --session KEY           Callback session key (stored in metadata)
  -w, --workdir DIR           Working directory for Codex
      --model MODEL           Codex model override
      --sandbox MODE          read-only | workspace-write | danger-full-access
      --danger-full-access    Shortcut for --sandbox danger-full-access
      --skip-git-repo-check   Pass through to codex exec
      --codex-bin PATH        Explicit Codex binary path
      --help                  Show help
      --                      Remaining args passed to codex exec
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -p|--prompt) PROMPT="$2"; shift 2 ;;
    -n|--name) TASK_NAME="$2"; shift 2 ;;
    -g|--group) TELEGRAM_GROUP="$2"; shift 2 ;;
    -s|--session) CALLBACK_SESSION="$2"; shift 2 ;;
    -w|--workdir|--cwd) WORKDIR="$2"; shift 2 ;;
    --model) MODEL="$2"; shift 2 ;;
    --sandbox) SANDBOX="$2"; shift 2 ;;
    --danger-full-access) SANDBOX="danger-full-access"; shift ;;
    --skip-git-repo-check) SKIP_GIT_REPO_CHECK=1; shift ;;
    --codex-bin) CODEX_BIN="$2"; shift 2 ;;
    --help|-h) usage; exit 0 ;;
    --) shift; EXTRA_ARGS=("$@"); break ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
done

if [[ -z "$PROMPT" ]]; then
  echo "Error: --prompt is required" >&2
  usage >&2
  exit 1
fi

mkdir -p "$RESULT_DIR"
: > "$TASK_OUTPUT"

jq -n \
  --arg name "$TASK_NAME" \
  --arg group "$TELEGRAM_GROUP" \
  --arg session "$CALLBACK_SESSION" \
  --arg prompt "$PROMPT" \
  --arg workdir "$WORKDIR" \
  --arg ts "$(date -Iseconds)" \
  --arg model "$MODEL" \
  --arg sandbox "$SANDBOX" \
  '{task_name: $name, telegram_group: $group, callback_session: $session, prompt: $prompt, workdir: $workdir, started_at: $ts, model: $model, sandbox: $sandbox, status: "running"}' \
  > "$META_FILE"

echo "📋 Task metadata written: $META_FILE"
echo "   Task: $TASK_NAME"
echo "   Group: ${TELEGRAM_GROUP:-none}"
echo "   Workdir: $WORKDIR"
echo "   Sandbox: $SANDBOX"

CMD=(python3 "$RUNNER" --prompt "$PROMPT" --cwd "$WORKDIR" --sandbox "$SANDBOX")

if [[ -n "$MODEL" ]]; then
  CMD+=(--model "$MODEL")
fi
if [[ -n "$CODEX_BIN" ]]; then
  CMD+=(--codex-bin "$CODEX_BIN")
fi
if [[ "$SKIP_GIT_REPO_CHECK" -eq 1 ]]; then
  CMD+=(--skip-git-repo-check)
fi
if [[ ${#EXTRA_ARGS[@]} -gt 0 ]]; then
  CMD+=(-- "${EXTRA_ARGS[@]}")
fi

echo "🚀 Launching Codex..."
echo "   Command: ${CMD[*]}"
echo ""

set +e
"${CMD[@]}" 2>&1 | tee "$TASK_OUTPUT"
EXIT_CODE=${PIPESTATUS[0]}
set -e

echo ""
echo "✅ Codex exited with code: $EXIT_CODE"

if [[ -f "$META_FILE" ]]; then
  jq --arg code "$EXIT_CODE" --arg ts "$(date -Iseconds)" \
    '. + {exit_code: ($code | tonumber), completed_at: $ts, status: (if ($code | tonumber) == 0 then "done" else "failed" end)}' \
    "$META_FILE" > "${META_FILE}.tmp" && mv "${META_FILE}.tmp" "$META_FILE"
fi

if [[ -x "$NOTIFIER" ]]; then
  "$NOTIFIER" --result-dir "$RESULT_DIR" --exit-code "$EXIT_CODE" || true
else
  echo "Notifier not executable: $NOTIFIER" >&2
fi

exit "$EXIT_CODE"
