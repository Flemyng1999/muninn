# Profile 对比

三档 profile 如何选：

## 一张表选 profile

| 维度 | research | product | engineering |
|---|---|---|---|
| **状态** | ✅ 稳定 | 🟡 WIP | 🟡 WIP |
| **典型用户** | 博士生 / 研究员 | 产品经理 / 设计师 / 创业者 | 软件工程师 / 架构师 / SRE |
| **沉淀对象** | 论文 / 实验 / 推导 / Gate 判据 | 用户访谈 / 决策 / 竞品 / OKR | ADR / 故障复盘 / 代码模式 |
| **节奏** | 月级（实验周期） | 周级（sprint / 迭代） | 事件驱动（决策 + 故障） |
| **时间跨度** | 3–5 年（PhD / 课题） | 1–3 年（产品生命周期） | 开放（跨 job / 跨 repo） |
| **主要 AI 场景** | 论文理解 + 起草 | 访谈分析 + 决策归档 | 架构讨论 + 根因分析 |
| **核心指标** | Gate PASS 率 / 主卡数 | OKR 达成 / 决策复查率 | ADR 活跃度 / 事故响应时长 |
| **扩展 schema** | experiment / gate | decision / persona / okr | adr / incident / pattern |

## 共用的 core/（80%）

所有 profile 共享：

- `_Governance/` 宪法 + rules + schemas
- `_Skills/` 7 套通用工作流：
  - 早间启动 / 晚间结项
  - 流水记录分流
  - 会议沉淀
  - KMS 卡片起草与维护
  - AI 接入 KMS
  - KMS 交接他人
- `scripts/` 健康度 + YAML 回填
- `_Concepts/` + `03-Zettelkasten/` + `00-Journal/` + `02-Projects/` 骨架

## profile-specific 的 20%

### research 加了什么
- `工作流-文献沉淀-规范落库`
- `01-Literature/` 数据目录
- schema 扩展：`experiment.yaml` / `gate.yaml`

### product 计划加（WIP）
- `工作流-用户访谈沉淀` / `工作流-决策记录-ADR式` / `工作流-竞品调研`
- `01-Interviews/` / `01-Decisions/` / `01-Competitors/`
- schema 扩展：`decision.yaml` / `persona.yaml` / `okr.yaml`

### engineering 计划加（WIP）
- `工作流-ADR起草` / `工作流-故障复盘-Postmortem` / `工作流-代码片段沉淀`
- `01-ADRs/` / `01-Incidents/` / `01-Snippets/`
- schema 扩展：`adr.yaml` / `incident.yaml` / `pattern.yaml`

## 选不准时

默认选 **core-only**（不选 profile），跑 2 周看看自己的沉淀对象是啥，再决定。

```bash
bash scripts/bootstrap.sh --profile none --out ~/my-vault
```

两周后你会知道自己最频繁沉淀的是论文 / 会议 / ADR / 访谈。按那个选 profile。

## 多 profile 混用

**可以**。bootstrap.sh 支持 `--profile research,engineering`（逗号分隔）。

典型场景：
- 研究员兼做工程（开源项目维护） → `research,engineering`
- 产品技术负责人 → `product,engineering`
- 全栈创业者 → 三个都上，但**强烈不建议**（KMS 过载）

## 自建 profile

按 `profiles/<name>/profile.yaml` 结构建。参考 `profiles/research/` 作为成熟 reference。建完提 PR 回贡，让别人也能用。
