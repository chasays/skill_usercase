# Usage guide

## Simplest workflow

Run a Codex task in a project:

```bash
scripts/dispatch-codex.sh \
  -p "Fix lint errors and summarize changes" \
  -n "lint-fix" \
  -w "/path/to/project"
```

What happens:
1. metadata is written
2. Codex runs in that directory
3. output is captured
4. notifier writes result JSON
5. optional Telegram/OpenClaw notification is sent

## Common commands

### Read-only analysis

```bash
scripts/dispatch-codex.sh \
  -p "Inspect this repo and explain the architecture" \
  -n "audit" \
  --sandbox read-only \
  -w "/path/to/project"
```

### Normal coding task

```bash
scripts/dispatch-codex.sh \
  -p "Implement user login and run tests" \
  -n "login-feature" \
  -w "/path/to/project"
```

### Send result back to Telegram

```bash
scripts/dispatch-codex.sh \
  -p "Fix CI failures" \
  -n "fix-ci" \
  -g "-5189558203" \
  -w "/path/to/project"
```

### Use a specific Codex binary

```bash
scripts/dispatch-codex.sh \
  -p "Refactor auth middleware" \
  -n "auth-refactor" \
  --codex-bin /opt/homebrew/bin/codex \
  -w "/path/to/project"
```

## Files to inspect after a run

Result directory defaults to:

```bash
/home/ubuntu/clawd/data/codex-results
```

Useful files:
- `task-meta.json` — prompt, workdir, start/end time, sandbox, model
- `task-output.txt` — raw CLI output
- `latest.json` — summarized final artifact
- `pending-wake.json` — wake-up signal for OpenClaw heartbeat workflows
- `notify.log` — notifier log

## Troubleshooting

### `codex binary not found`

Fix one of these:

```bash
which codex
export CODEX_BIN=/opt/homebrew/bin/codex
```

Or pass:

```bash
--codex-bin /path/to/codex
```

### Telegram message was not sent

Check:
- `openclaw` is installed
- `OPENCLAW_BIN` points to the correct binary
- the Telegram group ID is correct
- OpenClaw is logged in / configured properly

### Running outside a git repo

Add:

```bash
--skip-git-repo-check
```

## Good default prompt style

Codex behaves better when prompts are concrete. For example:

```text
Inspect this repository first. Make a short plan. Then implement the fix, run the relevant tests, and summarize changed files.
```

That tends to work better than vague prompts like “fix stuff”.
