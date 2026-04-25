# 示例：城市乌鸦工具使用演化研究（research-full）

一个**虚构但可信**的完整研究项目 vault，用于展示 Muninn research profile 的全貌。

## 项目设定

**研究问题**：城市化压力下，乌鸦（Corvidae）的工具使用行为如何演化？是个体创新还是文化传播主导？

**为什么选这个主题**：
1. 真实研究领域（Taylor / Rutz / Hunt 等人在 New Caledonian crow / Urban carrion crow 有实证工作）
2. 和 Muninn 项目主题呼应（乌鸦 = 智慧 + 工具使用 + 记忆）
3. 概念清晰、能展示完整的 Gate 判据结构
4. 不过于接近任何真实实验室的项目，避免误导

## 本示例覆盖了哪些 Muninn 特性

| 特性 | 在哪里看 |
|---|---|
| **R01 SSOT** | 所有 `_Concepts/概念-*.md` 是唯一定义，其他地方只 `[[link]]` |
| **R02 Frontmatter 覆盖** | 每张卡顶部完整 YAML |
| **R04 Narrative spine** | `02-Projects/城市乌鸦工具使用演化研究.md` |
| **R05 无孤儿** | 每张卡至少挂一个 MOC |
| **R08 生命周期** | `概念-社会学习指标.md` 展示 seedling → superseded 链 |
| **R08 §8.7 🔴 档** | `_Governance/CHANGELOG.md` 记录了一次走 Q3 三要素的规则改动 |
| **Schema 扩展 experiment** | `03-Zettelkasten/实验-E1-野外工具识别率.md` |
| **Schema 扩展 gate** | `_Concepts/概念-Gateα-工具识别准确率.md`（`authoritative: true`，含 pass_condition） |
| **主卡 vs seedling 区分** | `_Concepts/` 下全部 `authoritative: true` live；`03-Zettelkasten/` 下全部 seedling |
| **Journal 时间戳** | `00-Journal/2026-04-*.md` 每条 `[HH:MM]` |
| **核心概念双链** | 看任何一份 Journal / 洞察卡，引用概念都是 `[[概念-xxx]]` |
| **文献卡规范** | `01-Literature/Taylor2007-crow-cognition.md` |
| **踩坑 / 洞察 / 思考分类** | `03-Zettelkasten/` 下三种前缀 |

## 如何读这个示例

**5 分钟速览**：
1. `02-Projects/城市乌鸦工具使用演化研究.md`（项目叙事骨架）
2. `_Concepts/@索引-乌鸦工具使用.md`（领域 MOC）

**30 分钟深读**：
3. 看 `_Concepts/` 里每张主卡的结构（定义 / 数学形式 / 边界 / 关联 4 节 ≤ 上限）
4. 看 `_Concepts/概念-社会学习指标.md` 的 `superseded_by` 字段（生命周期示例）
5. 看 `00-Journal/2026-04-22.md` 感受"AI 协作 + [HH:MM]"的日常节奏
6. 看 `_Governance/CHANGELOG.md` 的 Q3 三要素实例

## 如何复用这个示例

**不要直接 bootstrap 到这个 vault**（它已是填满的示例）。先 bootstrap 一个空 vault：

```bash
bash scripts/bootstrap.sh --profile research --out ~/my-vault
```

然后挑本示例里的几张卡当模板，改成你的内容。

## 与你自己项目的对照法

- 我的项目有 5 张核心概念？→ 仿 `_Concepts/概念-工具使用定义.md`（L1 通用类型）
- 我的项目有 Gate 判据？→ 仿 `_Concepts/概念-Gateα-工具识别准确率.md`（authoritative + pass_condition）
- 我今天做了实验？→ 仿 `03-Zettelkasten/实验-E1-野外工具识别率.md`
- 我读了一篇论文？→ 仿 `01-Literature/Taylor2007-crow-cognition.md`
- 我踩了个坑？→ 仿 `03-Zettelkasten/踩坑-视频标注一致性.md`
