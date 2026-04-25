# Product Profile（WIP — 邀请贡献）

**状态**：骨架存在，核心工作流 / schema 尚未实现。欢迎 PR。

**适合谁**：产品经理 / 设计师 / 创业者 / 增长负责人。

## 为什么产品人也需要 KMS

产品工作的日常正是 KMS 的典型场景：
- 每周做 5 个用户访谈 → 3 个月后全忘了谁说过啥
- 一年做了几十个大小决策 → 新人来问"当时为什么选 A 不选 B" → 答不上来
- 每个季度定 OKR → 关键结果和后续决策之间链接断裂
- 做竞品调研 → 调研文档散在 Google Docs / Notion，不同人重复做

**核心共性**：都需要 SSOT（用户画像 / 关键决策 / OKR 只在一处权威定义）+ AI 协作（让 AI 从访谈录音起草卡片、从会议记录提炼决策）。

## 计划中的差异化

### 工作流（TODO）

| 工作流 | 触发 | AI 产出 |
|---|---|---|
| 用户访谈沉淀 | 做完一次访谈 | `01-Interviews/` 下一张卡 + 提炼 2–3 条 seedling 洞察 |
| 决策记录 ADR 式 | 做了重大产品决策 | `01-Decisions/` 下 Options / Tradeoffs / Decision / Consequences |
| 竞品调研 | 看完一个竞品 | `01-Competitors/` 下一张卡 + 差异矩阵更新 |

### schema 扩展（TODO）

- `decision.yaml` —— 决策卡字段（options, tradeoffs, decision, review_date, consequences）
- `persona.yaml` —— 用户画像卡字段（quote, pain_points, jobs_to_be_done, segments）
- `okr.yaml` —— OKR 卡字段（quarter, objective, key_results, status, weekly_log_links）

### 数据目录（TODO）

```
01-Interviews/    用户访谈原始 + 提炼
01-Decisions/     重大决策 ADR 卡
01-Competitors/   竞品卡
_Concepts/        产品核心概念（如 "MVP", "PMF", "North Star Metric"）
02-Projects/      产品线 MOC
03-Zettelkasten/  散想法 / 洞察 seedling
```

## 如何贡献

- 想主导这个 profile 的实现 → open issue 说"我来"，成为 profile maintainer
- 想贡献一个工作流 → 参考 `core/_Skills/02-Workflows/工作流-会议沉淀-规范落库.md` 的结构（说明页 + 正式提示词配对）
- 想贡献一个 schema 扩展 → 参考 `profiles/research/schemas/extensions/gate.yaml`

目前可以先用 `core/` 裸骨架 + 自己写产品 workflow。成熟后欢迎回贡。
