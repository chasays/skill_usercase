# skill_usercase

一个公开的 OpenClaw / Agent Skills 与相关工作流示例仓库。

## 已收录内容

| 名称 | 类型 | 说明 |
|---|---|---|
| `link-to-wechat-article` | skill | 将分享链接改写成带个人评论风格的微信公众号草稿文章。 |
| `link-to-chiphub-post` | skill | 将分享链接改写成 ChipHub 网站文章，并可按需发布到基于 GitHub 的 ChipHub 站点仓库。 |
| `codex-openclaw-hooks` | 工作流 / 辅助包 | 提供可复用的 Codex 运行器、hooks，以及回调式 OpenClaw 通知流程。 |
| `chrome_tampermonkey` | 杂项示例 | 存放和 Tampermonkey 使用相关的浏览器侧笔记与脚本示例。 |

## 仓库结构

```text
skill_usercase/
  README.md
  README_CN.md
  link-to-wechat-article/
    SKILL.md
    LICENSE
    references/
    scripts/
  link-to-chiphub-post/
    SKILL.md
    LICENSE
    references/
    scripts/
  codex-openclaw-hooks/
    SKILL.md
    LICENSE
    README.md
    USAGE.md
    codex-config.toml
    hooks/
    scripts/
  chrome_tampermonkey/
    list.md
```

## 约定

- 每个可复用 skill 放在自己的一级目录里。
- skill 目录至少应包含 `SKILL.md`。
- 如有需要，skill 也可以包含 `references/`、`scripts/`、`assets/`、示例文件或辅助配置文件。
- 部分一级目录也可能存放工作流示例、辅助包或说明笔记，而不一定是独立 skill。
- 后续可以继续在这个仓库下增加更多内容。

## 使用方式

- 如果是 skill：先读该目录下的 `SKILL.md`。
- 如果是辅助包或工作流示例：读该目录自己的 `README.md`、`USAGE.md` 或说明文件。

## 英文版

英文版仓库说明请查看 [`README.md`](./README.md)。

## 计划

- 收录更多可复用的发布与自动化 skill
- 补充更清晰的安装 / 引入示例
- 为非 skill 的辅助目录补充轻量说明
- 如有需要，为各项内容增加截图或 demo 流程
