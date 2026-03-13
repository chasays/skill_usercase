---
name: link-to-wechat-article
description: Turn a shared link into a WeChat Official Account draft article. Use when the user sends a WeChat article link, tweet/X post, news page, blog post, or other web URL and wants it rewritten into a personal-commentary公众号文章, then saved as a WeChat draft through baoyu-post-to-wechat using the API path by default.
---

# Link to WeChat Article

Convert a URL into a公众号 draft article in the user's preferred voice: personal commentary, medium length, low AI smell, no backstage wording, and API-first draft publishing.

## Default output contract

Apply these defaults unless the user overrides them:

- Sources: WeChat articles, tweets/X posts, news sites, blogs, and normal web pages
- Article type: commentary rewrite, not literal translation and not outline summary
- Voice: personal观点号, natural human tone, low AI smell
- Formatting: avoid bullet-point summaries; do not break after commas; prefer paragraph breaks after full stops/sentence completion instead of mid-sentence wrapping
- Length: medium (`900–1500` Chinese characters unless the source is too thin)
- Ending: light closing sentence
- Publishing: save as draft first, do not directly publish
- Preferred publish path: `baoyu-post-to-wechat` API mode, not Chrome mode

Read `references/style-rules.md` before drafting.

If the source is a观点型爆款、强情绪帖子、个人立场很重的文章， also read `references/article-teardown.md` and do a quick internal teardown before rewriting.

## Direct execution workflow

When the user sends a link and wants a公众号 draft, do this sequence directly.

### 1. Fetch source content

Use the bundled fetch script:

```bash
/Users/admin/.openclaw/workspace/skills/link-to-wechat-article/scripts/fetch-source.sh "<URL>" /tmp/link-source.md
```

Behavior:
- WeChat article URL → tries the local Camoufox-based WeChat reader
- Normal web page URL → fetches readable text via `r.jina.ai`

Then inspect the fetched file and extract:
- title
- source / author if visible
- publish time if visible
- main argument
- important facts, examples, and quotes

If the fetched content is mostly CAPTCHA/junk, stop and tell the user extraction failed.

### 2. Rewrite into the house style

Write like a human operator with opinions.

For strong-opinion / viral / emotional source material, do a quick internal teardown first using `references/article-teardown.md`. Extract the argument structure, emotional triggers, signature lines, and sentence patterns that create emotional value or pain points. Use that analysis as scaffolding, but never paste the teardown into the final article.

Do:
- open from an angle, judgment, or tension point
- compress the source into a smooth narrative
- add light interpretation and stance
- keep transitions natural
- use short paragraphs
- make the article read as a standalone published piece
- remove backstage wording like `原文`, `链接`, `这篇文章里提到`

Do not:
- write `下面是几个要点`
- dump bullet lists unless the user explicitly asks
- sound like a model doing a content summary
- over-praise, over-balance, or over-disclaim
- copy the source structure mechanically

Reliable structure:
1. Hook with reaction or framing
2. Explain what happened
3. State why it matters
4. Add your judgment, reservation, or broader view
5. End with a light closing line

### 3. Save markdown draft locally

Save the rewritten article as markdown with frontmatter:

```yaml
---
title: <rewritten title>
summary: <short digest>
author: 小叉
---
```

Suggested location:

```bash
mkdir -p /Users/admin/.openclaw/workspace/post-to-wechat/$(date +%F)
```

Use a descriptive file name such as:

```text
/Users/admin/.openclaw/workspace/post-to-wechat/YYYY-MM-DD/<slug>.md
```

Title rules:
- do not copy the source headline mechanically
- lead with the user's angle

Summary rules:
- 1–2 sentences
- natural, not robotic
- safe for WeChat digest field

### 4. Auto-select a cover image

Before API publish, resolve a cover automatically:

```bash
/Users/admin/.openclaw/workspace/skills/link-to-wechat-article/scripts/choose-cover.py <markdown-file> [source-file]
```

Selection order:
1. frontmatter `coverImage` / `featureImage` / `cover` / `image`
2. first real content image in the markdown body
3. first plausible image URL found in the fetched source file
4. local `imgs/cover.png` beside the article
5. workspace fallback cover

The chooser should reject obvious junk images such as logos, icons, avatars, placeholders, and generic WeChat chrome assets.

### 5. Publish with `baoyu-post-to-wechat` API

Prefer API publishing. Do not use Chrome unless the user explicitly asks.

Run:

```bash
COVER=$( /Users/admin/.openclaw/workspace/skills/link-to-wechat-article/scripts/choose-cover.py <markdown-file> [source-file] )
node /Users/admin/.openclaw/workspace/skills/baoyu-post-to-wechat/scripts/wechat-api.ts <markdown-file> --theme default --color blue --cover "$COVER"
```

Notes:
- API draft publishing normally needs a cover image.
- Prefer a real source/content image over a generic fallback.
- If the chooser falls back to a generic workspace cover, mention that in the completion report.
- The workspace currently has project-level WeChat API config and project-level baoyu-post-to-wechat preferences.

### 6. Report completion

After publish, report:
- final title
- whether API draft publish succeeded
- `media_id` if returned
- any cover-image fallback used

## Quality bar

Before publishing, check:
- Would this read like a real person wrote it?
- Does it avoid backstage wording?
- Are paragraphs short enough for mobile reading?
- Did you avoid generic AI-summary phrasing?
- Is the closing light rather than preachy or salesy?

If not, revise once before publishing.

## When to ask follow-up questions

Ask only if one of these blocks execution:
- the source cannot be read reliably
- the source is too thin to support a medium-length commentary
- a required cover image is missing and no fallback is acceptable
- the user wants a tone or stance different from the defaults

Otherwise, proceed directly.
