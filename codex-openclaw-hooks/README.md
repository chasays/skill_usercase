# codex-openclaw-hooks

A small workflow for running **Codex CLI** tasks and sending the result back to **OpenClaw / Telegram** after the task finishes.

This repo is the Codex-oriented replacement for the original Claude Code hook flow:
- no Claude `Stop` / `SessionEnd` hooks
- no Claude settings registration
- task completion is handled explicitly by the dispatch script
- result artifacts and notification flow are kept simple and portable

## What it does

`scripts/dispatch-codex.sh`:
1. writes task metadata
2. launches Codex CLI in a target working directory
3. captures stdout/stderr to `task-output.txt`
4. updates task status / exit code
5. calls `hooks/notify-openclaw.sh`
6. notifier writes JSON artifacts and optionally sends a Telegram message through `openclaw`

## Repository layout

```text
scripts/
  dispatch-codex.sh      # main entrypoint
  codex_run.py           # robust Codex runner
  run-codex.sh           # tiny wrapper that tees output

hooks/
  notify-openclaw.sh     # post-run notifier

codex-config.toml        # example Codex config
```

## Architecture

```text
scripts/dispatch-codex.sh
  │
  ├─ writes task-meta.json
  ├─ runs Codex via scripts/codex_run.py
  ├─ tees output to task-output.txt
  │
  └─ after Codex exits
      └─ calls hooks/notify-openclaw.sh
          ├─ writes latest.json
          ├─ writes pending-wake.json
          └─ optionally sends Telegram via openclaw CLI
```

## Quick start

### 1. Requirements

- `codex` installed and logged in
- `python3`
- `jq`
- optional: `openclaw` CLI if you want Telegram/OpenClaw delivery

### 2. Run a task

```bash
scripts/dispatch-codex.sh \
  -p "Fix the failing tests in this repository" \
  -n "fix-tests" \
  -w "/home/ubuntu/projects/myapp"
```

### 3. Send result to Telegram

```bash
scripts/dispatch-codex.sh \
  -p "Implement a small Python scraper" \
  -n "my-scraper" \
  -g "-5189558203" \
  -w "/home/ubuntu/projects/scraper"
```

### 4. Pick a model

```bash
scripts/dispatch-codex.sh \
  -p "Refactor the auth module" \
  -n "auth-refactor" \
  --model "gpt-5.4" \
  -w "/home/ubuntu/projects/myapp"
```

### 5. Use a different sandbox

```bash
scripts/dispatch-codex.sh \
  -p "Inspect this repo and summarize architecture" \
  -n "repo-audit" \
  --sandbox read-only \
  -w "/home/ubuntu/projects/myapp"
```

Or, if you really want full access:

```bash
scripts/dispatch-codex.sh \
  -p "Perform a broad refactor" \
  -n "big-refactor" \
  --danger-full-access \
  -w "/home/ubuntu/projects/myapp"
```

## CLI reference

### `scripts/dispatch-codex.sh`

```bash
Usage: dispatch-codex.sh [OPTIONS] -p "your prompt"

Options:
  -p, --prompt TEXT           Task prompt (required)
  -n, --name NAME             Task name
  -g, --group ID              Telegram group ID
  -s, --session KEY           Callback session key (stored in metadata)
  -w, --workdir DIR           Working directory for Codex
      --model MODEL           Codex model override
      --sandbox MODE          read-only | workspace-write | danger-full-access
      --danger-full-access    Shortcut for danger-full-access
      --skip-git-repo-check   Allow non-git workdirs
      --codex-bin PATH        Explicit Codex binary path
      --                      Extra args passed to codex exec
```

### `scripts/codex_run.py`

Runs Codex in a PTY-friendly way.

Default behavior:
- uses `codex exec`
- sets sandbox explicitly
- optionally writes the last assistant message to a file
- can run interactive mode with `--interactive`

Examples:

```bash
python3 scripts/codex_run.py \
  --prompt "Review this repository" \
  --cwd /home/ubuntu/projects/myapp \
  --sandbox read-only
```

```bash
python3 scripts/codex_run.py \
  --interactive \
  --cwd /home/ubuntu/projects/myapp
```

### `hooks/notify-openclaw.sh`

Reads the task metadata and captured output, then writes:
- `latest.json`
- `pending-wake.json`
- `notify.log`

If `openclaw` is installed and a Telegram group is provided, it also sends a notification message.

## Result files

Default result directory:

```bash
/home/ubuntu/clawd/data/codex-results
```

Generated files:
- `task-meta.json`
- `task-output.txt`
- `latest.json`
- `pending-wake.json`
- `notify.log`

Example `latest.json`:

```json
{
  "task_name": "fix-tests",
  "status": "done",
  "exit_code": 0,
  "timestamp": "2026-03-13T12:34:56+08:00",
  "workdir": "/home/ubuntu/projects/myapp",
  "telegram_group": "-5189558203",
  "output": "..."
}
```

## Environment variables

```bash
export RESULT_DIR=/home/ubuntu/clawd/data/codex-results
export OPENCLAW_BIN=/home/ubuntu/.npm-global/bin/openclaw
export CODEX_BIN=/opt/homebrew/bin/codex
export OPENCLAW_GATEWAY=http://127.0.0.1:18789
export OPENCLAW_GATEWAY_TOKEN=...
```

## Migration from the Claude version

If you came from the original Claude repo, the mapping is:

- `dispatch-claude-code.sh` → `dispatch-codex.sh`
- `claude_code_run.py` → `codex_run.py`
- `notify-agi.sh` / hook callback → `notify-openclaw.sh`
- Claude settings hook registration → not needed

The key design difference is simple:

- **Claude version**: completion came from lifecycle hooks
- **Codex version**: completion is handled directly by the dispatch script after Codex exits

## Validation

Recommended smoke checks:

```bash
python3 scripts/codex_run.py --help
bash scripts/dispatch-codex.sh --help
bash hooks/notify-openclaw.sh --help
```

## Suggested rename

If you want to publish this as a dedicated repo, I’d rename it to one of:
- `codex-openclaw-hooks`
- `openclaw-codex-runner`
- `codex-task-callbacks`

My pick: **`codex-openclaw-hooks`**.
