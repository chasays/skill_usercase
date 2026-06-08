---
name: claude-plan-review
description: Use when the user asks for a multi-round implementation-plan review before coding, wants terminal Claude Code to review a plan, or mentions a v1/v2/v3 plan-review flow.
---

# Claude Plan Review

Use this skill to turn a feature request into a reviewed implementation plan before any code changes. The current agent remains the implementer; terminal Claude Code is an external plan reviewer.

## Core Rule

Do not edit production files or start implementation until `plan v3` is ready. Reading files, running read-only discovery commands, and drafting plans are allowed.

## Claude Reviewer Settings

Use terminal Claude Code as the external reviewer with Opus 4.8 when available. If Opus 4.8 is unavailable, use Opus 4.7. Set Claude Code effort to `xhigh` before review.

Prefer this noninteractive invocation when available:

```bash
claude --print --model opus --effort xhigh --permission-mode plan --output-format json '<review prompt>'
```

Do not add `--bare` for normal review calls; bare mode can skip OAuth/keychain auth and may make an otherwise logged-in setup look unauthenticated unless API-key auth is separately configured.

If the current Claude Code session cannot be switched to the requested model/effort, state the mismatch and ask the user to set Claude Code to Opus 4.8 or 4.7 with `xhigh` effort before continuing the review loop.

## Artifact Storage

Save review artifacts to disk instead of relying on chat history or terminal scrollback.

For repository work, use the repository's plan directory:

```text
docs/superpowers/plans/YYYY-MM-DD-<feature>.md
docs/superpowers/plans/YYYY-MM-DD-<feature>-reviews/
  plan-v1.md
  claude-review-1.md
  plan-v2.md
  claude-review-2.md
  plan-v3.md
```

The top-level `YYYY-MM-DD-<feature>.md` is the canonical execution plan and should match `plan-v3.md` after the review loop completes. Keep the review subdirectory for traceability.

If the work is not tied to a repository, use:

```text
~/.codex/plan-reviews/YYYY-MM-DD-<feature>/
```

## Workflow

1. Gather the user's requirements and enough code context to draft a plan.
2. Write `plan v1` with concrete files, steps, tests, risks, and open assumptions, then save it to the review artifact directory.
3. Send `plan v1` to terminal Claude Code for review.
4. Read Claude Code's review output, save the raw review, then separate valid findings from questionable advice.
5. Revise the plan into `plan v2`, explicitly resolving or rejecting each important review point, then save it.
6. Send `plan v2` to Claude Code for a second review.
7. Read and save the second review, then revise into `plan v3`.
8. Copy or rewrite `plan v3` into the canonical top-level plan file.
9. Start implementation from `plan v3` only after the two review rounds are complete, unless the user explicitly says to stop at planning or skip a round.

## Review Prompt Template

Use a prompt like this for Claude Code:

```text
Please review this implementation plan before coding.

Focus on:
- missing requirements or unstated assumptions
- incorrect file boundaries or likely integration gaps
- missing tests or verification commands
- risky sequencing, migration, deployment, or rollback issues
- unnecessary complexity

Return findings ordered by severity. Be specific and actionable. Do not rewrite the whole plan unless needed.

Plan:
[paste plan vN here]
```

## Applying Review Feedback

For each review round:

- Fix critical or clearly valid important issues in the next plan version.
- Push back on wrong or overbroad feedback with a short technical reason.
- Keep minor suggestions only when they improve correctness or reduce risk.
- Preserve the user's scope. A reviewer cannot expand scope unless the user approves.

## Implementation Handoff

When `plan v3` is ready, summarize the review outcome briefly, then implement normally using the appropriate implementation workflow and repository conventions. If the user asked only for a reviewed plan, stop after delivering `plan v3`.
