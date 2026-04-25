# 示例：产品决策 + 用户画像（product-teaser）

> ⚠️ **这是一个 teaser**（约 3 张卡），展示 `profiles/product/` 将来成熟后会长什么样。不是完整 vault。`profiles/product/` 仍是 WIP，欢迎贡献 PR 把它补完。

## 项目设定

**虚构产品**：`mobile-health-app` —— 健康追踪手机应用，团队 8 人，正处第二年迭代。

**本 teaser 展示**：产品人典型的两种沉淀对象：
1. **决策卡（Decision / ADR-style）** —— 做了一个重大决策，留下 context / options / tradeoffs / 最终选择 + 预期后果
2. **用户画像卡（Persona）** —— 用户群代表

## 包含的卡

| 文件 | 展示什么 |
|---|---|
| `01-Decisions/决策-DEC-0042-弃用Apple Health直接集成.md` | 决策卡（ADR 风格）：options / tradeoffs / decision / consequences / review_date 完整结构 |
| `_Concepts/画像-通勤健身族.md` | 用户画像（persona）卡：quotes / pain_points / jobs-to-be-done / segments |
| `_Concepts/概念-North Star指标定义.md` | 核心指标定义（主卡，authoritative 的产品概念） |

## 展示了哪些 Muninn 特性

| 特性 | 在哪里 |
|---|---|
| R01 SSOT | 画像卡 + North Star 主卡，其他地方 [[link]] 不重复 |
| R08 生命周期 | 决策卡含 `review_date`（6 个月后必须复查）+ `superseded_by` 字段（若被后续决策推翻） |
| Schema 扩展预览 | frontmatter 里的 `decision_status` / `options` / `tradeoffs`（等 `profiles/product/` 成熟会移到 schemas/extensions/decision.yaml） |
| AI 协作痕迹 | 决策卡底部附"AI 起草 + Arbiter 审阅"留痕（未来 `工作流-决策记录-ADR式` 会自动生成这段） |

## 如果你是产品人

读完这 3 张卡，你会看到两件事：
1. **决策卡长什么样**（vs Notion 里那种无结构的"会议纪要"）
2. **画像怎么 SSOT 化**（一处权威定义，整个项目引用它而不是各团队各写一版）

受启发 → 开 issue 或 PR 认领 `profiles/product/`，按 [CONTRIBUTING.md](../../CONTRIBUTING.md) 贡献。
