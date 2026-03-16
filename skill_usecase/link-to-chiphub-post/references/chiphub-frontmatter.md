# ChipHub frontmatter contract

发布到 `~/source/chiphub_top` 的文章必须写入：

```yaml
---
title: <文章标题>
summary: <1-2 句摘要>
date: YYYY-MM-DD
tags:
  - AI
category: <分类名>
sourceUrl: <原始链接>
sourceName: <来源名>
cover: /og-default.svg
draft: true|false
featured: true|false
---
```

## 正文结构

推荐固定结构：

1. 导语
2. 核心事实
3. 影响解读
4. 风险与不确定性
5. 参考链接

允许写成自然段，不要写成机器总结腔。

## 文件路径

- 目录：`~/source/chiphub_top/src/content/posts/`
- 文件名：`YYYY-MM-DD-slug.md`
- slug 推荐小写英文/数字/中划线；如果标题是中文，先人工转一个短英文 slug 更稳。

## 分类要求

- 写完正文后，必须再读一次 `references/category-rules.md`
- 先判断 **1 个主分类** 和 **1 个备选分类**
- frontmatter 里只写主分类
- 如果两个分类都说得通，优先选择更贴近文章主张力的那个，不要按关键词堆叠机械判断

## 发布前检查

- frontmatter 字段齐全
- `sourceUrl` 正确
- `summary` 不要太机器
- `category` 已按 `references/category-rules.md` 选择
- `draft` / `featured` 值符合用户要求
- build 能通过
