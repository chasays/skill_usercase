# skill_usercase

A public collection of reusable OpenClaw / Agent skills and related workflow examples.

## Included items

| Name | Type | Description |
|---|---|---|
| `link-to-wechat-article` | skill | Turn a shared link into a WeChat Official Account draft article, rewritten in a personal-commentary style. |
| `link-to-chiphub-post` | skill | Turn a shared link into a ChipHub website article and optionally publish it to a GitHub-backed ChipHub site repo. |
| `codex-openclaw-hooks` | workflow / helper package | Reusable Codex runner, hooks, and callback-style OpenClaw notification workflow. |
| `chrome_tampermonkey` | misc examples | Browser-side notes and scripts related to Tampermonkey usage. |

## Repository structure

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

## Conventions

- Each reusable skill lives in its own top-level directory.
- Skill directories should include `SKILL.md` at minimum.
- Skills may also include `references/`, `scripts/`, `assets/`, examples, or helper config files when needed.
- Some top-level directories may store workflow examples, helper packages, or notes instead of a standalone skill.
- More items can be added over time under this same repository.

## How to use

- For a skill: read the `SKILL.md` inside that directory first.
- For helper packages or workflow examples: read their local docs such as `README.md`, `USAGE.md`, or note files.

## Chinese version

For the Chinese version of this repository overview, see [`README_CN.md`](./README_CN.md).

## Roadmap

- Add more reusable publishing and automation skills
- Add clearer install / import examples
- Add lightweight examples for non-skill helper directories
- Add per-item screenshots or demo flows if needed
