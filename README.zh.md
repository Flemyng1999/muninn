# Muninn

[English](README.md) · [中文](README.zh.md)

> *"Muninn（古诺斯语"记忆"）——北欧神话中 Odin 的两只乌鸦之一，每天飞遍世界带回消息。另一只叫 Huginn（思维）。"*

**一套"AI 时代的个人知识管理制度"** —— Obsidian vault 骨架 + 宪法 + 8 套 AI 协作工作流。

## 为什么叫 Muninn

乌鸦（Corvidae）是鸟类 IQ 之王：
- **极高智商**：能识别抽象符号 / 解决多步工具问题
- **惊人长期记忆**：能记住人脸数年
- **工具使用者**：不仅用工具，还会**制作和保留工具** —— 精准对应本仓库的 `_Skills/` 工作流
- **能和人协作**：日本奈良的乌鸦和人类协同觅食，分享信息

这四点，正是 AI 时代个人知识系统该有的样子：**聪明、记得住、会用工具、会和人协作**。

## 这是什么

一个公开的模板仓库，帮你 5 分钟起一个符合以下原则的 Obsidian 知识库：

1. **SSOT（Single Source of Truth）**：核心概念只在一处有权威定义
2. **Arbiter-Executor 边界**：你是决策者，AI 是执行者，有明确制度防 AI 瞎改
3. **生命周期管理**：卡片有 seedling / live / superseded / deprecated / retracted / archived 状态流转
4. **健康度仪表盘**：周度脚本扫描孤儿率 / 断链率 / frontmatter 覆盖等 8 项指标

## 三档 Profile

| Profile | 状态 | 适合谁 |
|---|---|---|
| **research** | ✅ 稳定 | 博士生 / 研究员 / 学术工作者 |
| **product** | 🟡 WIP | 产品经理 / 设计师 / 创业者 |
| **engineering** | 🟡 WIP | 软件工程师 / 架构师 / SRE |

详见 [docs/profile-comparison.md](docs/profile-comparison.md)。

## 快速开始（5 分钟）

```bash
# 1. clone
git clone https://github.com/<yourname>/muninn.git
cd muninn

# 2. 生成你的 vault（选一个 profile）
bash scripts/bootstrap.sh --profile research --out ~/my-vault

# 3. 打开 Obsidian → Open folder as vault → 选 ~/my-vault

# 4. 读 ~/my-vault/README.md 按指引上手
```

完整新手指南见 [QUICKSTART.md](QUICKSTART.md)。

## 仓库结构

```
muninn/
├── core/                         # 80% 通用骨架
│   ├── _Governance/              # 宪法 + rules + schemas
│   ├── _Skills/                  # 7 套通用工作流（早间/晚间/流水/会议/卡片/AI接入/交接）
│   ├── scripts/                  # kms_health.sh + backfill_yaml.py
│   └── _Concepts / 00-Journal / 02-Projects / 03-Zettelkasten / .obsidian
├── profiles/
│   ├── research/                 # 研究者 profile（完整）
│   ├── product/                  # 产品人 profile（WIP，欢迎 PR）
│   └── engineering/              # 工程师 profile（WIP，欢迎 PR）
├── docs/
│   ├── philosophy.md             # 为什么这样设计
│   ├── profile-comparison.md     # profile 对比
│   ├── repo-vault-interface.md   # repo ↔ vault 接口契约模板
│   ├── working-control-panel.md  # WORKING.md 运行态控制面板规则
│   ├── agent-onboarding.md       # 项目入口文件实践（11 项内容契约）
│   └── known-issues.md           # 已知问题与技术债务清单
├── examples/                     # 示例（3 套）
│   ├── research-full/            # 完整研究示例：城市乌鸦工具使用演化
│   ├── product-teaser/           # 产品 teaser：决策卡 + 用户画像
│   └── engineering-teaser/       # 工程 teaser：ADR + 故障复盘
└── scripts/
    └── bootstrap.sh              # core + profile overlay 工具
```

## 核心特性

### 1. 宪法 + R01–R08 八条硬规则

- **R01 SSOT**：核心概念只在主卡定义
- **R02 Frontmatter 覆盖率** ≥ 95%
- **R03 Memory 瘦身**：AI memory 不囤 project_* 原件
- **R04 Narrative spine**：项目 MOC 是叙事骨架
- **R05 孤儿率** = 0
- **R06 断链率** < 10%
- **R07 升级队列**：seedling → live 有流程
- **R08 生命周期 + 编辑深度矩阵**：🟢 / 🟡 / 🔴 三档，🔴 要 Q3 三要素授权

### 2. R08 §8.7 编辑深度矩阵 + §8.8 内容卫生

AI 改卡时按动词判档：

| 档 | 触发动词 | AI 行为 |
|---|---|---|
| 🟢 content_patch | 补 / 修 / 加 / 审 | 直接改，报 diff |
| 🟡 structure_refactor | 拆 / 合 / 升级 / 改名 / 移 | Arbiter 口头批，执行 + grep 入链报告 |
| 🔴 definition_governance | 改定义 / 翻 / 废 / 撤 / 改规则 | **只起草**，等 Q3 三要素书面批准 |

Q3 三要素：(a) Arbiter 审阅 (b) grep 入链评估 (c) 书面明确判断。

R08 §8.8 约束长期卡片的内容卫生：临时路线名要改写成长期机制表达，任务状态留在 Journal / WORKING / GAPS / 任务区，重要结论尽量说明证据强度，除非讨论对象就是 agent/tool，否则正文不写 agent 过程语。

### 3. 8 套 AI 工作流（开箱即用）

| 工作流 | 场景 |
|---|---|
| 工作流-早间启动-条件Git | 开工启动 + 昨日承接 |
| 工作流-晚间结项-Git闭环 | 日结 + AI 挑沉淀点 |
| 工作流-流水记录-分流沉淀 | Inbox 分流 |
| 工作流-会议沉淀-规范落库 | 开完会落卡 |
| 工作流-KMS-卡片起草与维护 | 起 seedling / 修断链 |
| 工作流-AI接入KMS | 把外部 AI（非 Claude Code）拉进 KMS |
| 工作流-KMS交接他人 | 把系统传给下一个人 |
| 工作流-文献沉淀-规范落库 | （research profile）读完论文落卡 |

每套都是成对的：**说明页**（.md）+ **正式提示词**（-正式提示词.md，直接粘给 AI）。

### 4. 健康度仪表盘

```bash
bash scripts/kms_health.sh            # 输出 markdown 报告
bash scripts/kms_health.sh --save     # 保存到 out/kms_health/YYYY-MM-DD.md
```

周度跑一次，看 R02/R05/R06 等 8 项绿不绿。

## 谁应该（不）用

### 适合你 ✅

- 做研究 / 产品 / 工程，每周有 ≥ 5 次值得沉淀的信息点
- 想用 AI 协作但吃过 AI 乱改笔记的亏
- 愿意花 1 小时读宪法换未来 3 年的结构化沉淀

### 别用 ❌

- 你的工作不需要跨月度沉淀
- 你还没养成定期写日记/周报的习惯 → 先用 Notion 养 3 个月
- 你不打算和 AI 协作 → Muninn 的一半价值消失
- 你只想做玩具知识图谱 → Logseq / Roam 更适合

## 设计哲学

详见 [docs/philosophy.md](docs/philosophy.md)。三个核心原则：

1. **SSOT** —— 核心定义只在一处
2. **Arbiter-Executor 角色边界** —— AI 有明确制度限制
3. **三层分离** —— 宪法 / 工作流 / 数据各自独立演化

## 关键文档

| 文档 | 用途 |
|---|---|
| [docs/philosophy.md](docs/philosophy.md) | 设计哲学 / 为什么这样做 |
| [docs/profile-comparison.md](docs/profile-comparison.md) | research / product / engineering profile 对比 |
| [docs/repo-vault-interface.md](docs/repo-vault-interface.md) | 项目仓库 ↔ vault 接口契约模板 |
| [docs/agent-onboarding.md](docs/agent-onboarding.md) | 入口文件（CLAUDE.md / AGENTS.md / ...）必含字段契约 |
| [docs/known-issues.md](docs/known-issues.md) | 已知问题与技术债务清单 |
| [QUICKSTART.md](QUICKSTART.md) | 5 分钟起步 |
| [CONTRIBUTING.md](CONTRIBUTING.md) | 贡献新 profile / 工作流 / schema 扩展 |

## 贡献

- **新 profile**：`profiles/<name>/`，参考 `profiles/research/` 结构，PR welcome
- **新工作流**：`core/_Skills/02-Workflows/<工作流-场景-目标>.md` + 配对的 `-正式提示词.md`
- **宪法改进**：`core/_Governance/proposals/` 起 proposal，不直接改 `@宪法.md` / `rules.yaml`

详见 [CONTRIBUTING.md](CONTRIBUTING.md)。

## 许可

MIT。宪法文本、工作流、脚本、schema 均可自由修改、商用、再发布。

## 致谢

- 北欧神话给了这个项目的名字
- Obsidian 给了这个项目的载体
- 研究工作中无数次被 AI 乱改笔记的崩溃给了这个项目的动机

## 联系

Issue / PR 欢迎。商业咨询、定制 profile、团队版请 open issue 联系。
