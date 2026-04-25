# KMS Template（Obsidian 知识管理宪法 v0.1.3 骨架）

## 一句话
Arbiter 说了算，AI 是 Executor。这是骨架，不是内容。

---

## 三天上手

### Day 1（读宪法）
1. 读 `_Governance/@宪法.md`（30 分钟，只需看懂 R01/R02/R08）
2. 读 `_Governance/rules.yaml`（机读版，速览）
3. 读 `_Skills/02-Workflows/@工作流索引.md`（了解有哪些工作流）

### Day 2（配项目）
1. 复制 `_Governance/project_TEMPLATE.yaml` → `project_<你的项目>.yaml`
2. 至少填两个必填字段：`meta.project_id` 和 `meta.vault_path`
3. 在 `core_concepts` 列 5–10 张主卡名（跨文档被反复引用的核心术语）
4. 完整 schema 见 `_Governance/schemas/project_profile.yaml`

### Day 3（建骨架）
1. 在 `_Concepts/` 建你列的前 3 张主卡（文件名：`概念-<术语>.md`）
2. 按 `_Governance/schemas/concept.yaml` 填 frontmatter
3. 正文不必完美，至少有 `## 定义` + 一条参考文献

### Day 5（第一次体检）
脚本是 profile-driven 的，**不需要改任何路径占位**。设置环境变量后即可：

```bash
export KMS_PROJECT_PROFILE="$(pwd)/_Governance/project_<你的项目>.yaml"
bash scripts/kms_health.sh --verbose
```

或每次显式传：
```bash
bash scripts/kms_health.sh --profile $(pwd)/_Governance/project_<你的项目>.yaml
```

通过：R02 ≥ 95% / R05 = 0 / R06-actionable < 5%

### Day 14（独立）
再跑 `kms_health.sh`，三项达成 → 可独立。不过 → 回 Day 3 重建骨架。

---

## 每周必做

- **周五体检**：`bash scripts/kms_health.sh`
- **Journal 时间戳**：每条前缀 `[HH:MM]`
- **新概念先进主卡**：不在 log / docs / 对话里重写定义

---

## 硬性禁止

- AI 直接改 `_Governance/` 或 `_Concepts/概念-*.md` → 违反 R01/R08
- 跳过 R08 §8.7 的 🟡 / 🔴 授权 → 违反边界
- 核心概念在非主卡位置重写定义 → 违反 SSOT

---

## 可改的三个地方（定制点）

| 目录 | 你改什么 | 不改什么 |
|---|---|---|
| `_Governance/project_<你>.yaml` | 全部（你的项目数据） | 不要改 schema 字段名 |
| `_Concepts/` | 添加你的主卡 | 不要删 `@索引-*.md` 结构约定 |
| `_Skills/02-Workflows/` | 添加你特有工作流 | 不要改"KMS 卡片起草与维护"（这是 AI 核心） |

不要改的：`_Governance/@宪法.md`、`rules.yaml`、`schemas/`、`_Skills/03-Blocks/`。
这些是宪法，改它们 = fork 一个新版本，要走 Arbiter Q3 三要素。

---

## 接入 AI

外部 AI（ChatGPT / Gemini / Claude.ai）首次会话粘贴：
`_Skills/02-Workflows/工作流-AI接入KMS-正式提示词.md` 里 `---PROMPT START---` 到 `---PROMPT END---` 之间全文。

IDE AI（Codex / Copilot）：让它 Read 上面那份提示词文件即可。

---

## 失败模式（看到这些就停下）

| 现象 | 根因 | 处置 |
|---|---|---|
| 一周没跑体检 | 工具流程没嵌入 | 设日历提醒，或合入周五晚间 Git 闭环 |
| `_Concepts/` 主卡数 > 20 | 把非核心概念升主卡了 | 只把"跨 3 篇以上文档被引用"的升主卡 |
| Journal 没时间戳 | 没读宪法 | 回 Day 1 |
| AI 自称"已改 _Governance/" | AI 幻觉 | 立即打断，核对 diff |

---

## 起源

本模板从一个真实项目的宪法 v0.1.3 骨架剥离（2026-04-24）。
你的维护者信息：<ARBITER>
问题反馈：<联系方式>
