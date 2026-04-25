# Engineering Profile（WIP — 邀请贡献）

**状态**：骨架存在，核心工作流 / schema 尚未实现。欢迎 PR。

**适合谁**：软件工程师 / 架构师 / SRE / 技术负责人。

## 为什么工程师也需要 KMS

工程师的日常沉淀痛点：
- ADR（架构决策记录）写在 repo 里但缺乏跨 repo 索引
- 故障复盘写在 Notion / Confluence，3 个月后搜不到
- 反复遇到的代码模式 / 坑 / 性能 tip 没地方沉淀
- 技术选型对比（Kafka vs Pulsar, Postgres vs MySQL）散在各种会议记录里

**核心共性**：都需要 SSOT（ADR / 模式 / 事故复盘只在一处权威定义）+ AI 协作（让 AI 从 Slack 讨论提炼决策、从日志分析根因）。

## 相比现有工具（ADR tools, Notion, Obsidian）多了什么

- **角色边界**：AI 不能擅自改你的 ADR（当前主流 AI 工具没这约束）
- **生命周期**：ADR 有 seedling / live / superseded 完整链路（R08）
- **健康度仪表盘**：周度扫描哪些 ADR 孤立了、哪些链接坏了、哪些过期未复查

## 计划中的差异化

### 工作流（TODO）

| 工作流 | 触发 | AI 产出 |
|---|---|---|
| ADR 起草 | 做了技术决策 | `01-ADRs/ADR-0042-<topic>.md`（context / decision / consequences） |
| 故障复盘 Postmortem | 出了生产事故 | `01-Incidents/YYYY-MM-DD-<topic>.md`（timeline / root cause / remediation） |
| 代码片段沉淀 | 反复写过一段难忘的代码 | `01-Snippets/模式-<name>.md`（problem / solution / tradeoffs） |

### schema 扩展（TODO）

- `adr.yaml` —— ADR 字段（number, status, context, decision, consequences, superseded_by）
- `incident.yaml` —— 事故字段（severity, duration, services_affected, root_cause, action_items）
- `pattern.yaml` —— 模式字段（problem, solution, tradeoffs, examples, counter_patterns）

### 数据目录（TODO）

```
01-ADRs/          架构决策记录（编号 + topic）
01-Incidents/     故障复盘
01-Snippets/      代码模式 / 性能 tip
_Concepts/        工程核心概念（如 CAP 定理、CQRS、eventual consistency）
02-Projects/      服务 / 项目 MOC
03-Zettelkasten/  散想法 / 学习笔记
```

## 如何贡献

- 想主导这个 profile 的实现 → open issue 说"我来"
- 有成熟的 ADR / Incident 模板 → PR 到 `_Skills/02-Workflows/`
- 有已跑通的工程 KMS 实践 → 贡献 `examples/engineering-*/`

参考：MADR / Google SRE Postmortem Template / Michael Nygard ADR 格式都是业界成熟模板，可直接吸收进本 profile。
