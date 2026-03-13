---
name: codex-openclaw-hooks
description: Run Codex CLI tasks with a reusable dispatch workflow that captures output and notifies OpenClaw/Telegram after completion. Use when the user wants Codex to run as a background or scriptable task with result artifacts, callback-style notifications, Telegram delivery, or a reusable Codex runner/dispatcher instead of an ad-hoc one-off exec.
---

# Codex OpenClaw Hooks

Use this skill when the user wants a reusable Codex task runner with post-run notification behavior.

## What this skill provides

- `scripts/dispatch-codex.sh`: main entrypoint
- `scripts/codex_run.py`: robust Codex runner
- `scripts/run-codex.sh`: simple tee wrapper
- `hooks/notify-openclaw.sh`: post-run notifier
- `codex-config.toml`: optional example config

## Default workflow

1. Set a result directory.
2. Run `scripts/dispatch-codex.sh` with a prompt and workdir.
3. Let the script launch Codex, capture output, update metadata, and call the notifier.
4. Read `latest.json`, `task-output.txt`, or `notify.log` from the result directory.

## Recommended environment

Prefer:

```bash
export CODEX_BIN="$(command -v codex)"
export RESULT_DIR="$PWD/results"
```

If Telegram/OpenClaw delivery is desired, also ensure `openclaw` CLI is installed and authenticated. `OPENCLAW_BIN` can be set explicitly if needed.

## Common command

```bash
bash scripts/dispatch-codex.sh \
  -p "Inspect this repo first, make a short plan, then implement the fix and summarize changed files" \
  -n "task-name" \
  -w "/path/to/project"
```

Add Telegram delivery with:

```bash
-g "<telegram-group-id>"
```

## Result files

The workflow writes these artifacts under `RESULT_DIR`:

- `task-meta.json`
- `task-output.txt`
- `latest.json`
- `pending-wake.json`
- `notify.log`

## Guardrails

- Prefer `workspace-write` or `read-only` unless the user explicitly wants broader access.
- Keep prompts concrete: inspect first, plan briefly, then execute.
- Do not assume Telegram delivery works unless `openclaw` is configured.
- Use this skill for reusable/background Codex task orchestration; for simple one-off coding in chat, normal Codex usage may be simpler.
