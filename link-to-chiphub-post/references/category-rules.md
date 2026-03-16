# Category Rules

Use this file to assign a ChipHub category after the article is written.

## Goal

For each article, decide:
1. **Primary category** — the single category written into frontmatter
2. **Secondary candidate** — one backup category that also fits, kept only as an internal decision note or mentioned in the completion report if useful

Frontmatter still accepts only one `category` value.

## Category selection rule

Always choose **1 primary category**.
If two categories both fit, pick the stronger one for frontmatter and keep the other as a backup in your reasoning/process, not in the article body.

## Default ChipHub categories

Prefer these stable buckets unless the user explicitly asks for a different taxonomy:

- `Agent 与接口`
  - AI agents, MCP, WebMCP, browser automation, tools, protocols, app-agent interaction
- `AI算力`
  - GPU clusters, inference cost, training cost, data centers, compute supply, deployment economics
- `GPU硬件`
  - NVIDIA, AMD, accelerators, interconnect, HBM, servers, hardware launches
- `半导体制造`
  - foundry, packaging, CoWoS, process nodes, TSMC, Samsung, supply chain manufacturing
- `大模型生态`
  - model vendors, open/closed model competition, model releases, ecosystem shifts, platform strategy
- `AI产品策略`
  - product rollout, pricing, developer platforms, adoption, enterprise positioning, application-layer moves
- `行业观察`
  - broader market commentary that spans multiple layers and does not fit tightly into one technical bucket

## How to choose

### Choose `Agent 与接口` when:
- the core change is how agents call tools, browse, interact with websites, or use protocols
- the article is mainly about interface design, agent execution, browser standards, or tool invocation

### Choose `AI算力` when:
- the main point is compute economics, inference/training cost, cluster deployment, or supply constraints

### Choose `GPU硬件` when:
- the article centers on chips, GPU products, hardware specs, memory, networking, or server platforms

### Choose `半导体制造` when:
- the main signal is fab capacity, packaging, foundry process, yield, manufacturing bottlenecks, or upstream supply chain

### Choose `大模型生态` when:
- the focus is model vendors, model launches, ecosystem dynamics, open-vs-closed, or foundation-model platform competition

### Choose `AI产品策略` when:
- the article is more about product packaging, customer segmentation, business rollout, developer offerings, or commercial strategy

### Choose `行业观察` when:
- the article is mostly macro commentary across multiple layers
- no single technical/product bucket clearly dominates

## Tie-break rule

If torn between two categories:
1. Choose the one that best matches the article's **main tension**
2. Not the noisiest noun frequency
3. Not the source's own framing

Ask: what is this article *really about* once stripped of examples?

## Output rule

- Write exactly one category into frontmatter
- Keep category names short and stable
- Do not invent a new category unless the user explicitly asks
