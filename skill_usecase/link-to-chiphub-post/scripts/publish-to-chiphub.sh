#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <markdown-file> [commit-message]" >&2
  exit 1
fi

MD_FILE="$1"
COMMIT_MSG="${2:-feat: publish new chiphub article}"
REPO="$HOME/source/chiphub_top"
TARGET_DIR="$REPO/src/content/posts"

if [[ ! -f "$MD_FILE" ]]; then
  echo "Error: markdown file not found: $MD_FILE" >&2
  exit 1
fi

if [[ ! -d "$REPO/.git" ]]; then
  echo "Error: chiphub repo not found at $REPO" >&2
  exit 1
fi

mkdir -p "$TARGET_DIR"
cp "$MD_FILE" "$TARGET_DIR/"

cd "$REPO"
npm run build

git add "$TARGET_DIR/$(basename "$MD_FILE")"
git add dist >/dev/null 2>&1 || true

if git diff --cached --quiet; then
  echo "No changes to commit."
  exit 0
fi

git commit -m "$COMMIT_MSG"
git push

echo "Published $(basename "$MD_FILE") to $REPO"
