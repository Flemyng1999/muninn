---
type: AI工作流
date: 2026-04-24
tags: [AI, Workflow, KMS, Handoff, Onboarding]
linked_role: [[_Skills/01-Roles/角色-KMS执行人]]
required_blocks:
  - [[_Skills/03-Blocks/组件-KMS角色边界-非Arbiter]]
optional_blocks: []
related_templates: []
entry_prompt: [[_Skills/02-Workflows/工作流-KMS交接他人-正式提示词]]
target_folders:
  - _Skills
scope_paths:
  - _Governance
  - _Concepts
  - _Skills
---

# 工作流-KMS交接他人

正式投喂入口（给被交接者的 AI 用）：[[_Skills/02-Workflows/工作流-KMS交接他人-正式提示词]]

> [!abstract]- 适用场景
> 把这套 KMS（宪法 v0.1.3 + 骨架 + AI 工作流）交给另一个人（同事 / 学生 / 合作者）使用。他得到一份**脱敏模板仓库**，按两周节奏表独立上手。
>
> **不适用**：(1) 接入外部 AI（用[[_Skills/02-Workflows/工作流-AI接入KMS]]）(2) vault 内的 Wave 迁移

## Arbiter 交付清单（4 件）

1. **脱敏模板仓库**（git repo）
   - 生成命令：`bash <项目仓库>/scripts/make_kms_template.sh --apply`
   - 默认输出：`~/kms-template/`
   - 推送：`cd ~/kms-template && gh repo create kms-template --private --source=. --remote=origin --push`
   - 给被交接者：`gh repo --add-collaborator` 或直接发仓库链接
2. **两周节奏表**（本页下方，复制给他）
3. **入口 AI 提示词**：告诉他用[[_Skills/02-Workflows/工作流-KMS交接他人-正式提示词]]喂给他的 AI
4. **验收线**：两周后跑 `kms_health.sh` R02 ≥ 95% + R05 = 0 + R06 < 10%

## 两周节奏表（Arbiter 给被交接者复制）

| 日 | 任务 | 产出 | 验收 |
|---|---|---|---|
| Day 1 | 读 `_Governance/@宪法.md` + `rules.yaml` | 理解 R01/R02/R08 | 能回答"什么操作需要 Q3 三要素" |
| Day 2 | 复制 `project_TEMPLATE.yaml` → `project_<你>.yaml`，填 meta + 5–10 个 core_concepts | 一份项目 yaml | Arbiter（原作者）review yaml |
| Day 3 | `_Concepts/` 建前 3 张主卡（带 frontmatter + `## 定义`） | 3 张 concept 主卡 | 跑 `kms_health.sh` R02 字段完整 |
| Day 5 | 复制 `kms_health.sh` 到自己项目，改路径常量跑通 | 一份体检报告 | R02 ≥ 90% |
| Day 7 | 写第一篇 Journal `[HH:MM]` 时间戳 + 1 张 seedling | Journal + seedling | 时间戳规范 |
| Day 10 | 接入一个外部 AI（ChatGPT / Gemini），跑一次 Author 任务 | 1 张 AI 起草的 seedling | AI 通过验收清单 5 条 |
| Day 12 | 处理孤儿 / 断链，跑 Curator 流程 | before/after 对比表 | R05 = 0 |
| Day 14 | 总体评估 | 体检报告截图 | R02 ≥ 95% + R05 = 0 + R06 < 10% |

**不过线处置**：回 Day 3 重建 `_Concepts/` 骨架。90% 的失败都是主卡建太多或建太少（推荐区间 5–10 张）。

## 交接前的一次性准备（Arbiter 做）

1. **跑 dry-run** 看清单：`bash scripts/make_kms_template.sh`
2. **apply**：`bash scripts/make_kms_template.sh --apply`
3. **人工检查输出**：
   - `_Governance/` 里**无** `project_*.yaml`（除了 `project_TEMPLATE.yaml`）
   - `_Concepts/` 只有 `README.md`，**无**个人主卡
   - `_Skills/` 的字面量已从 `<YOUR_PROJECT>` 替换为 `<YOUR_PROJECT>`
   - 顶层 `README.md` 存在
4. **敏感信息扫描**：
   ```bash
   grep -r "<ARBITER>" ~/kms-template/ --include="*.md" --include="*.yaml"
   grep -r "/Volumes/\|/scratch/" ~/kms-template/
   ```
   命中任何个人路径 / 用户名 → 手动改掉
5. **推远程**：`gh repo create kms-template --private --source=. --remote=origin --push`
6. **写给被交接者的邮件 / 消息**：
   ```
   仓库：<repo URL>
   入口文档：README.md
   首次 AI 会话：复制 _Skills/02-Workflows/工作流-KMS交接他人-正式提示词.md 的提示词部分
   两周节奏：见 _Skills/02-Workflows/工作流-KMS交接他人.md 的节奏表
   验收：Day 14 跑 kms_health.sh R02≥95% R05=0 R06<10% → 过
   ```

## 定制化分层（告诉被交接者哪里可以改）

| 层级 | 目录 | 被交接者可改性 | 改动约束 |
|---|---|---|---|
| 宪法层 | `_Governance/@宪法.md` / `rules.yaml` / `schemas/` | ❌ 不要改 | 改 = fork 新版本，走 Q3 三要素 |
| 工作流层 | `_Skills/` | 🟡 可添加自己的，不要删原有 | 删原有破坏 AI 提示词链 |
| 项目层 | `_Governance/project_<你>.yaml` / `_Concepts/` / `02-Projects/` | ✅ 全部自己填 | 按 schema 填字段名 |
| 数据层 | `00-Journal/` / `01-Literature/` / `03-Zettelkasten/` | ✅ 自由 | 命名规范遵守 |

## 失败模式（Arbiter 监控）

| 现象 | 诊断 | 处置 |
|---|---|---|
| Day 5 没跑体检 | 没嵌入周节奏 | 设日历提醒 |
| Day 7 主卡数 > 15 | 非核心概念升主卡 | 只保留"跨 3 篇以上被引用"的 |
| Day 10 AI 自称改了 `_Governance/` | AI 幻觉 | 对齐[[_Skills/02-Workflows/工作流-AI接入KMS]] |
| Day 14 R05 > 0 但拒绝挂接 | 没理解 MOC | 一对一演示一次挂接 |

## 多代传递（传给"传给的人"）

你交接给的人两周后再想传给第三人 → 他重跑 `make_kms_template.sh` 在他自己的 vault 上，产出他的脱敏版。宪法 v0.1.3 保持不变（这是 L0 层）。

## 禁止事项

1. 不要把 `project_<YOUR_PROJECT>.yaml` 或任何 `_Concepts/概念-*.md`（含主卡内容）发给被交接者——他只拿骨架
2. 不要承诺帮他维护宪法升版同步——他拿到的是 snapshot，未来分叉是他的事
3. 不要跳过 Day 14 验收线——不过线就是不过，别放水
4. 不要在模板 README 里留你的联系方式之外的个人信息
