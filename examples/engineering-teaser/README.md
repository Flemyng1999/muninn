# 示例：ADR + 故障复盘（engineering-teaser）

> ⚠️ **这是一个 teaser**（约 3 张卡），展示 `profiles/engineering/` 将来成熟后会长什么样。不是完整 vault。`profiles/engineering/` 仍是 WIP，欢迎贡献 PR 把它补完。

## 项目设定

**虚构系统**：`payment-service` —— B 端支付服务，Java/Kotlin 微服务，每秒 5k 峰值 TPS，团队 6 人。

## 包含的卡

| 文件 | 展示什么 |
|---|---|
| `01-ADRs/ADR-0017-从Kafka迁至Pulsar.md` | 架构决策记录（ADR）：context / decision / consequences / status 完整 Michael Nygard 格式 |
| `01-Incidents/2026-03-12-支付延迟突增事故.md` | 故障复盘（Postmortem）：timeline / root cause / remediation / lessons |
| `_Concepts/概念-最终一致性边界.md` | 工程核心概念主卡（何处可接受 eventual consistency，何处必须 strong） |

## 展示了哪些 Muninn 特性

| 特性 | 在哪里 |
|---|---|
| R01 SSOT | `概念-最终一致性边界` 主卡，ADR 和 Postmortem 都 `[[link]]` 引用，不重复定义 |
| R08 生命周期 | ADR 有 `status: accepted / superseded / deprecated`；postmortem 有 `action_items` 完成跟踪 |
| Schema 扩展预览 | frontmatter 的 `adr_number` / `severity` / `root_cause_category`（等 `profiles/engineering/` 成熟会移到 schemas/extensions/） |
| AI 协作痕迹 | Postmortem 底部附 "AI 从 PagerDuty / Slack / Grafana 归并时间线 + Arbiter 补因果判断" |

## 对标业界模板

- **ADR**：Michael Nygard 2011 格式 + MADR 扩展
- **Postmortem**：Google SRE book + Atlassian Incident Response Handbook
- **SSOT 概念**：本项目原创（业界通常散落在 Confluence / RFC doc）

## 如果你是工程师

读完这 3 张卡，你会看到：
1. **ADR 不止是 "decided X on date Y"**，而是 context + options + tradeoffs + consequences 的完整决策链
2. **Postmortem 不止是 blameless 故事**，而是可搜索 / 可度量 / 可关联工程规范的工程制品
3. **跨 ADR / Postmortem 的核心概念可以 SSOT 化** —— 下次讨论"最终一致性"时直接 `[[link]]`，不用再开一次会

受启发 → 开 issue 或 PR 认领 `profiles/engineering/`，按 [CONTRIBUTING.md](../../CONTRIBUTING.md) 贡献。
