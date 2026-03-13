#!/usr/bin/env python3
"""Run Codex CLI reliably.

Default mode is non-interactive via `codex exec`.
Interactive mode launches `codex` directly in a PTY-like wrapper using `script(1)` when available.
"""

from __future__ import annotations

import argparse
import os
import shlex
import subprocess
import sys
from pathlib import Path

DEFAULT_CODEX = os.environ.get("CODEX_BIN") or "codex"


def which(name: str) -> str | None:
    for p in os.environ.get("PATH", "").split(":"):
        cand = Path(p) / name
        try:
            if cand.is_file() and os.access(cand, os.X_OK):
                return str(cand)
        except OSError:
            pass
    return None


def resolve_codex(explicit: str | None) -> str:
    candidates = [
        explicit,
        os.environ.get("CODEX_BIN"),
        which("codex"),
        "/Applications/Codex.app/Contents/Resources/codex",
        os.path.expanduser("~/Applications/Codex.app/Contents/Resources/codex"),
    ]
    for cand in candidates:
        if cand and Path(cand).exists():
            return cand
    print("codex binary not found. Set --codex-bin or CODEX_BIN.", file=sys.stderr)
    raise SystemExit(2)


def run_with_pty(cmd: list[str], cwd: str | None) -> int:
    script_bin = which("script")
    if script_bin:
        cmd_str = " ".join(shlex.quote(c) for c in cmd)
        proc = subprocess.run([script_bin, "-q", "-c", cmd_str, "/dev/null"], cwd=cwd, text=True)
        return proc.returncode
    proc = subprocess.run(cmd, cwd=cwd, text=True)
    return proc.returncode


def build_exec_cmd(args: argparse.Namespace, codex_bin: str) -> list[str]:
    cmd = [codex_bin, "exec", "--sandbox", args.sandbox]
    if args.model:
        cmd += ["--model", args.model]
    if args.skip_git_repo_check:
        cmd.append("--skip-git-repo-check")
    if args.output_last_message:
        cmd += ["--output-last-message", args.output_last_message]
    if args.extra:
        cmd += args.extra
    if args.prompt is not None:
        cmd.append(args.prompt)
    return cmd


def build_interactive_cmd(args: argparse.Namespace, codex_bin: str) -> list[str]:
    cmd = [codex_bin]
    if args.model:
        cmd += ["--model", args.model]
    if args.sandbox:
        cmd += ["--sandbox", args.sandbox]
    if args.prompt:
        cmd.append(args.prompt)
    if args.extra:
        cmd += args.extra
    return cmd


def main() -> int:
    ap = argparse.ArgumentParser(description="Run Codex CLI reliably")
    ap.add_argument("--prompt", "-p", help="Prompt text")
    ap.add_argument("--cwd", help="Working directory")
    ap.add_argument("--codex-bin", help="Path to codex binary")
    ap.add_argument("--model", help="Model override")
    ap.add_argument("--sandbox", default="workspace-write", choices=["read-only", "workspace-write", "danger-full-access"], help="Sandbox mode")
    ap.add_argument("--skip-git-repo-check", action="store_true", help="Allow running outside git repos")
    ap.add_argument("--output-last-message", help="Write last assistant message to file")
    ap.add_argument("--interactive", action="store_true", help="Launch interactive codex instead of `codex exec`")
    ap.add_argument("extra", nargs=argparse.REMAINDER, help="Extra args after --")
    args = ap.parse_args()

    extra = args.extra
    if extra and extra[0] == "--":
        extra = extra[1:]
    args.extra = extra

    codex_bin = resolve_codex(args.codex_bin)
    cmd = build_interactive_cmd(args, codex_bin) if args.interactive else build_exec_cmd(args, codex_bin)
    return run_with_pty(cmd, cwd=args.cwd or os.getcwd())


if __name__ == "__main__":
    raise SystemExit(main())
