---
type: AI工作流
date: 2026-04-24
tags: [AI, Workflow, KMS, Onboarding, Governance]
linked_role: [[_Skills/01-Roles/角色-KMS执行人]]
required_blocks:
  - [[_Skills/03-Blocks/组件-KMS角色边界-非Arbiter]]
optional_blocks: []
related_templates: []
entry_prompt: [[_Skills/02-Workflows/工作流-AI接入KMS-正式提示词]]
target_folders:
  - _Skills
scope_paths:
  - _Governance
  - _Concepts
  - _Skills
  - 02-Projects
---

# 工作流-AI接入KMS

正式投喂入口：[[_Skills/02-Workflows/工作流-AI接入KMS-正式提示词]]

> [!abstract]- 适用场景
> 把 Claude Code 以外的 AI（ChatGPT / Gemini / Claude.ai Web / Codex / Copilot Chat / 本地 LLM）在 5 分钟内拉进本项目的 KMS，让它按宪法 v0.1.3 行事。
>
> **不适用**：Claude Code 在本仓库内跑（auto-memory + `CLAUDE.md` 自动生效，不需要这套流程）。

## 两类 AI，两种投喂法

| AI 类型 | 举例 | 文件访问 | 投喂方式 |
|---|---|---|---|
| IDE 内嵌 | Codex CLI / Copilot Chat / Cursor / Windsurf | 有仓库文件系统 | 粘贴[[_Skills/02-Workflows/工作流-AI接入KMS-正式提示词\|正式提示词]]首条消息，AI 自己 Read |
| Web 对话 | ChatGPT / Gemini / Claude.ai / Grok | 无 | 粘贴提示词 + 手动贴 5 份核心文件正文 |

需要手动贴的 **5 份核心文件**（Web 端用）：
1. `_Governance/@宪法.md`
2. `_Governance/rules.yaml`
3. `_Governance/project_<YOUR_PROJECT>.yaml`
4. `_Concepts/@索引-冠层路径分解.md`
5. `02-Projects/冠层反射率分布照明角度归一化.md`

## 执行步骤

1. **开新 AI 会话**。
2. 复制 `工作流-AI接入KMS-正式提示词.md` 全文作为首条消息。
3. Web 端补贴 5 份核心文件正文（按 1–5 顺序）。
4. 等 AI 按"验收清单"逐条答。
5. **5 项全中 → 接入成功**；漏一条 → 重新投喂并指出漏项。

## 验收清单（AI 必须全中）

1. 当前 Gate 状态：Gate 0 / α / β / γ + Phase 6 L3 全 PASS
2. R08 §8.7 三档：`content_patch` 🟢 / `structure_refactor` 🟡 / `definition_governance` 🔴
3. 不能直接改 `_Concepts/概念-*.md`（SSOT 主卡）、`_Governance/`、`_Skills/`
4. 改 `rules.yaml` = 🔴 + Q3 三要素（a 审阅 / b 入链评估 / c 书面判断）
5. 新知识第一落点：`00-Journal/<YOUR_PROJECT>/YYYY-MM-DD.md` 或 `03-Zettelkasten/`（seedling）

## 能力降级预期

接入成功的外部 AI 仍**不具备**以下能力（都归 Claude Code + Arbiter）：

1. 跨会话 auto-memory（每次都要重贴提示词）
2. 自动同步 5 锚点（WORKING / PROJECT / GAPS / CONTEXT_BUNDLE / 数学推导记录）
3. 仓库侧写文件（Web 端无文件系统）
4. `git commit`（任何 AI 都不跑，Arbiter 执行）

外部 AI 可以做：起草 seedling / 做推导 / 跑实验讨论 / 分析数据 / 写草稿。不可以做：建主卡 / 改 `_Governance/` / flip status / 断言"已改 xxx 文件"。

## 失败排查

| 现象 | 原因 | 处置 |
|---|---|---|
| AI 答不出 Gate 状态 | 没读 `project_<name>.yaml` 的 `gate_status` | 重贴该文件 |
| AI 提议直接改 `_Concepts/概念-X.md` | 没读 `组件-KMS角色边界-非Arbiter` | 把 block 内容贴过去 |
| AI 把新概念写进 log 正文 | 不懂 R01 SSOT | 重申"一律 `[[link]]`，定义只在主卡" |
| AI 自称已完成 git commit | 幻觉 | 立即打断，要求改为建议命令行 |

## 维护

- 每次宪法升版（v0.1.x → v0.1.y）：更新正式提示词的"当前版本"字段 + 验收清单第 2 条。
- 每次 `project_<name>.yaml` 新增核心概念：提示词的"读文件"列表无需改（已用 glob/index），验收清单无需改。
- 新增一个项目（非 <YOUR_PROJECT>）：复制一份提示词，把 `project_<name>.yaml` 名称替换。

## 禁止事项

1. 不把外部 AI 的输出直接落进 `_Concepts/` 或 `_Governance/`（Arbiter 亲手过一遍）。
2. 不让外部 AI 跑 `git commit`（哪怕它自信满满说能跑）。
3. 不在提示词里夹带项目机密（数据路径 OK，密钥 / 未公开数据 NOT OK）。
