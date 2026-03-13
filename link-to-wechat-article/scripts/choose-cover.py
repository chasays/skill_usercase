#!/usr/bin/env python3
import re
import sys
from pathlib import Path

IMAGE_EXTS = {'.png', '.jpg', '.jpeg', '.webp', '.gif'}
BAD_HINTS = ['wxlogo', 'icon', 'avatar', 'logo', 'placeholder', 'emoji', 'res.wx.qq.com']
FALLBACKS = [
    Path('/Users/admin/.openclaw/workspace/post-to-wechat/daily-ai-news-cover-2026-03-10.png'),
    Path('/Users/admin/.openclaw/workspace/post-to-wechat/cover-2026-03-10.png'),
]


def parse_frontmatter(text: str):
    if not text.startswith('---\n'):
        return {}, text
    m = re.match(r'^---\n([\s\S]*?)\n---\n([\s\S]*)$', text)
    if not m:
        return {}, text
    fm_text, body = m.group(1), m.group(2)
    fm = {}
    for line in fm_text.splitlines():
        if ':' in line:
            k, v = line.split(':', 1)
            fm[k.strip()] = v.strip().strip('"\'')
    return fm, body


def first_markdown_image(body: str):
    for pat in [r'!\[[^\]]*\]\(([^)]+)\)', r'<img[^>]+src=["\']([^"\']+)["\']']:
        m = re.search(pat, body, re.I)
        if m:
            return m.group(1).strip()
    return None


def looks_bad(ref: str) -> bool:
    low = ref.lower()
    return any(h in low for h in BAD_HINTS)


def resolve_image(ref: str, base: Path):
    if looks_bad(ref):
        return None
    if ref.startswith('http://') or ref.startswith('https://'):
        return ref
    p = (base / ref).resolve() if not Path(ref).is_absolute() else Path(ref)
    if p.exists() and p.suffix.lower() in IMAGE_EXTS:
        return str(p)
    return None


def source_image_candidates(source_text: str):
    patterns = [
        r'https?://[^\s"\')>]+\.(?:png|jpg|jpeg|webp|gif)(?:\?[^\s"\')>]*)?',
        r'https?://mmbiz\.qpic\.cn[^\s"\')>]+',
        r'mmbiz\.qpic\.cn[^\s"\')>]+',
    ]
    seen = set()
    for pat in patterns:
        for m in re.finditer(pat, source_text, re.I):
            url = m.group(0)
            if url.startswith('mmbiz.qpic.cn'):
                url = 'https://' + url
            if url in seen or looks_bad(url):
                continue
            seen.add(url)
            yield url


def main():
    if len(sys.argv) < 2:
        print('Usage: choose-cover.py <markdown-file> [source-file]', file=sys.stderr)
        sys.exit(1)

    md_path = Path(sys.argv[1]).resolve()
    source_path = Path(sys.argv[2]).resolve() if len(sys.argv) > 2 else None
    text = md_path.read_text(encoding='utf-8')
    fm, body = parse_frontmatter(text)

    for key in ['coverImage', 'featureImage', 'cover', 'image']:
        if key in fm and fm[key]:
            resolved = resolve_image(fm[key], md_path.parent)
            if resolved:
                print(resolved)
                return

    img = first_markdown_image(body)
    if img:
        resolved = resolve_image(img, md_path.parent)
        if resolved:
            print(resolved)
            return

    if source_path and source_path.exists():
        source_text = source_path.read_text(encoding='utf-8', errors='ignore')
        for url in source_image_candidates(source_text):
            print(url)
            return

    default_cover = md_path.parent / 'imgs' / 'cover.png'
    if default_cover.exists():
        print(str(default_cover))
        return

    for p in FALLBACKS:
        if p.exists():
            print(str(p))
            return

    sys.exit(2)


if __name__ == '__main__':
    main()
