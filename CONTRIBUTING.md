# 贡献指南

## 欢迎什么样的贡献

**高价值**：

1. **新 profile**（product / engineering 是官方最想补齐的）
2. **新通用工作流**（如"流水号博客沉淀"、"读代码做学习笔记"）
3. **新 schema 扩展**（用于某个领域的专有卡片字段）
4. **bug 修复**（`scripts/*.sh` / `scripts/*.py`）
5. **示例 vault**（在 `examples/` 下放一个完整脱敏案例）

**不欢迎**：

1. **改宪法正文**（`core/_Governance/@宪法.md` / `rules.yaml` / `schemas/*.yaml`）—— 见下文"宪法级变更"
2. **纯风格改动**（空格 / 标点 / 排版，无实质内容变化）
3. **引入云依赖**（Muninn 是本地优先 + 纯 Markdown，不要引 SaaS）
4. **引入非标 Markdown 扩展**（保持文件可被任何编辑器打开）

## 贡献新 profile

### 目录结构要求

```
profiles/<name>/
├── profile.yaml                  # 必需：profile 元数据
├── README.md                     # 必需：profile 说明（适合谁 / 差异 / 安装）
├── _Skills/02-Workflows/         # 可选：profile 专有工作流（配对 .md + -正式提示词.md）
├── schemas/extensions/           # 可选：schema 扩展 yaml
├── <数据目录>/README.md          # 可选：profile 特有数据目录（如 01-Literature）
└── project_TEMPLATE_<name>.yaml  # 可选：profile 专用项目 yaml 模板
```

### profile.yaml schema

参考 `profiles/research/profile.yaml`：

```yaml
id: <snake_case 短名>
name: <用户可读名>
description: <一句话说明>
status: stable | wip
core_version_required: ">=0.1.4"
maintainer: "@<github handle>"

extras:
  workflows: [...]
  data_dirs: [...]
  schema_extensions: [...]
  project_yaml_template: <文件名>

typical_use_cases: [...]
```

### 成熟度标准（status: stable）

profile 标记为 `stable` 需要满足：
1. 至少 3 个 profile-specific 工作流（含配对的正式提示词）
2. 至少 2 个 schema 扩展
3. 至少 1 个完整示例 vault（放 `examples/<name>-full/`）
4. maintainer 承诺 6 个月内响应 issue

不满足 → 标记为 `wip`，在 profile README 写清楚缺哪几项。

## 贡献新工作流

### 必须配对

每个工作流 **两个文件**：

```
工作流-<场景>-<目标>.md                    # 说明页：适用场景、执行步骤、输出格式
工作流-<场景>-<目标>-正式提示词.md          # 给 AI 的提示词：# Role 到文件末尾
```

### frontmatter 必填

参考 `core/_Skills/02-Workflows/工作流-早间启动-条件Git.md`：

```yaml
---
type: AI工作流
date: YYYY-MM-DD
tags: [AI, Workflow, ...]
linked_role: [[_Skills/01-Roles/角色-KMS执行人]]
required_blocks: [...]
entry_prompt: [[_Skills/02-Workflows/<你的工作流>-正式提示词]]
target_folders: [...]
scope_paths: [...]
---
```

### 提示词格式

正式提示词文件里包含 `---PROMPT START---` 到 `---PROMPT END---` 之间的内容给 AI 粘贴。不强制，但推荐（跨 AI 粘贴友好）。

## 宪法级变更

**改 `core/_Governance/@宪法.md` / `rules.yaml` / `schemas/*.yaml`** 需要走 proposal 流程：

1. 在 `core/_Governance/proposals/<topic>.md` 新建 proposal
2. 描述：动机 / 影响面（grep 入链评估）/ 实施方案 / 回滚预案
3. Open PR，在描述里 @ 仓库 maintainer
4. 等 Q3 三要素评审：(a) 审阅 (b) 入链评估 (c) 书面判断

**不要直接 PR 改宪法正文**，会被 close。

## 代码风格

- Shell: bash 5+ compatible, `set -euo pipefail`
- Python: 3.7+, 无外部依赖 (stdlib only)
- Markdown: CommonMark，避免 Obsidian-only 语法（除非必要，如 `[[wikilink]]`）

## 本地测试

贡献新 profile 前：

```bash
# 跑一次 bootstrap 看是否生成成功
bash scripts/bootstrap.sh --profile <你的新 profile> --out /tmp/test-vault

# 检查生成的 vault 结构
ls /tmp/test-vault/

# 跑一次健康检查（填占位后）
bash /tmp/test-vault/scripts/kms_health.sh
```

无报错 + `kms_health.sh` 跑通 → 可以提 PR。

## 提 PR

- **fork + feature branch**，不要直接 push 到 main
- **commit message**：
  - `profile: add product profile skeleton`
  - `workflow: add 代码片段沉淀 to engineering profile`
  - `schemas: add decision.yaml for product profile`
  - `fix: bootstrap.sh 不处理 profile 名含空格的情况`
- PR 描述包含：动机、改动要点、是否 breaking

## 项目入口文件实践

如果你将 Muninn 应用到自己的项目，入口文件（`CLAUDE.md` / `AGENTS.md` /
`.github/copilot-instructions.md` 等）的内容应符合 [`docs/agent-onboarding.md`](docs/agent-onboarding.md)
定义的"必要内容契约"。该文档：

- 列出 10 项必含字段（宪法版本 / vault 路径 / 角色边界 / R08 三档 / 启动顺序等）
- 提供整段可复制的入口文件模板
- 比较 3 种多入口文件同步策略（symlink / 同步声明 / 各自实现）
- 含合格检查清单

**Muninn 不强制文件名**，由项目和工具链决定，但**内容契约应一致**。

## 行为准则

- 对新人友好
- 不因贡献者的背景（学术 / 工程 / 产品）排斥其视角
- 用中文或英文都 OK
- 拒绝鄙视链

## 联系

issue / discussion 优先于邮件。
