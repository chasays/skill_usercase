---
name: link-to-chiphub-post
description: Turn a shared link into a ChipHub website article and optionally publish it to the chiphub_top GitHub repo. Use when the user sends a WeChat article link, tweet/X post, news page, blog post, or other web URL and wants it rewritten into a personal-commentary网站文章 for chiphub.top. Reuse the existing link-to-wechat-article skill for source fetching only; keep writing rules and website style inside this skill, and do not use chiphub_top repo-side generation logic.
---

# Link to ChipHub Post

Convert a URL into a ChipHub article, save it into `~/source/chiphub_top/src/content/posts/`, and optionally build + commit + push.

## Core rule

Reuse the existing `link-to-wechat-article` skill for the **fetching logic** and the **writing logic**.

Specifically:
- Use `~/.openclaw/workspace/skills/link-to-wechat-article/scripts/fetch-source.sh` for source extraction.
- Read `~/.openclaw/workspace/skills/link-to-wechat-article/references/style-rules.md` before drafting.
- If the source is strongly opinionated/emotional/viral, also read `references/article-teardown.md` from that skill and do a quick internal teardown before rewriting.
- Do **not** call `~/source/chiphub_top` repo-side ingestion/generation scripts for writing the article body.

The repo is only the publication target.

## Workflow

### 1. Fetch the source

Run:

```bash
/Users/admin/.openclaw/workspace/skills/link-to-wechat-article/scripts/fetch-source.sh "<URL>" /tmp/chiphub-source.md
```

Then inspect the fetched file.
If the fetched content is mostly junk, login walls, CAPTCHA, or chrome noise, stop and tell the user extraction failed.

### 2. Rewrite using this skill's website house style

Use this skill's own writing rules and teardown guidance, while keeping the proven high-level approach from the upstream link workflow.

Default output style:
- Chinese-first
- personal commentary, not literal translation
- low AI smell
- no backstage wording like `原文` / `链接里说` / `以下是要点`
- natural paragraphs, short mobile-friendly rhythm
- medium length unless the source is too thin
- standalone article that can be published directly

Reliable structure:
1. 导语
2. 核心事实
3. 影响解读
4. 风险与不确定性
5. 参考链接

Write the body directly. Do not output an analysis note.

### 3. Convert to ChipHub markdown format

Read `references/chiphub-frontmatter.md` and produce a single markdown file with required frontmatter:

- `title`
- `summary`
- `date`
- `tags`
- `category`
- `sourceUrl`
- `sourceName`
- `cover`
- `draft`
- `featured`

Defaults unless user overrides them:
- `cover: /og-default.svg`
- `draft: true`
- `featured: false`
- date = today in Asia/Shanghai

Save to:

```bash
~/source/chiphub_top/src/content/posts/YYYY-MM-DD-<slug>.md
```

Before writing, check whether the same `sourceUrl` already exists in that folder. If it already exists, stop and report the duplicate instead of publishing a second copy.

When reporting completion, include the chosen primary category. If category choice was close, also mention the secondary candidate briefly.

### 4. Publish only when asked

Default behavior: write the markdown file only.

If the user explicitly asks to publish / commit / push, then run:

```bash
/Users/admin/.openclaw/workspace/skills/link-to-chiphub-post/scripts/publish-to-chiphub.sh <markdown-file> "<commit-message>"
```

This script:
- copies the markdown into the repo content directory
- runs `npm run build`
- commits the article
- pushes to GitHub

If build fails, stop and report the failure. Do not push broken content.

## When to ask follow-up questions

Ask only if one of these blocks execution:
- extraction failed
- the source is too thin to support a publishable article
- the desired category/tags/stance are materially unclear
- the user wants immediate publishing but the repo/build/git path is broken

Otherwise, proceed directly.

