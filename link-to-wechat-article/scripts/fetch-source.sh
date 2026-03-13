#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <url> [output-file]" >&2
  exit 1
fi

URL="$1"
OUT="${2:-/tmp/link-to-wechat-source-$(date +%s).md}"
mkdir -p "$(dirname "$OUT")"

if [[ "$URL" == *"mp.weixin.qq.com/"* ]]; then
  TOOL_DIR="$HOME/.agent-reach/tools/wechat-article-for-ai"
  if [[ ! -d "$TOOL_DIR" ]]; then
    echo "Error: WeChat article reader not found at $TOOL_DIR" >&2
    exit 1
  fi

  set +e
  (
    cd "$TOOL_DIR"
    python3 main.py "$URL" >/tmp/link-to-wechat-wechat.log 2>&1
  )
  STATUS=$?
  set -e

  CANDIDATE=$(find "$TOOL_DIR/output" -type f \( -name '*.md' -o -name '*.txt' -o -name '*.html' \) | sort | tail -n 1)
  if [[ -n "${CANDIDATE:-}" ]]; then
    cp "$CANDIDATE" "$OUT"
    echo "$OUT"
    exit 0
  fi

  cat /tmp/link-to-wechat-wechat.log >&2
  exit ${STATUS:-1}
fi

curl -L -s "https://r.jina.ai/http://$(printf '%s' "$URL" | sed 's#^https\{0,1\}://##')" > "$OUT"

echo "$OUT"
