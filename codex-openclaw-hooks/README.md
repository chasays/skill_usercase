# codex-openclaw-hooks

Run Codex CLI tasks through a reusable dispatch workflow, capture result artifacts, and optionally notify OpenClaw / Telegram when the task finishes.

## Included files

- `SKILL.md` — skill definition and trigger description
- `scripts/dispatch-codex.sh` — main task dispatcher
- `scripts/codex_run.py` — Codex runner
- `scripts/run-codex.sh` — lightweight wrapper
- `hooks/notify-openclaw.sh` — post-run notifier
- `codex-config.toml` — example Codex config

## Typical use

```bash
export CODEX_BIN="$(command -v codex)"
export RESULT_DIR="$PWD/results"

bash scripts/dispatch-codex.sh \
  -p "Inspect this repo first, make a short plan, then implement the fix and summarize changed files" \
  -n "task-name" \
  -w "/path/to/project"
```

## Result files

The workflow writes these files under `RESULT_DIR`:

- `task-meta.json`
- `task-output.txt`
- `latest.json`
- `pending-wake.json`
- `notify.log`

## Notes

- Prefer `read-only` or `workspace-write` sandbox unless broader access is explicitly needed.
- Telegram delivery requires a working `openclaw` CLI setup.
- This repo is MIT-0 licensed.
