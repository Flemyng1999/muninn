---
type: AI工作流
date: 2026-03-09
tags: [AI, Workflow, Journal, Git, Plan]
linked_role: [[_Skills/01-Roles/角色-Obsidian知识审计员]]
required_blocks:
	- [[_Skills/03-Blocks/组件-调用约定-最小固定模式]]
optional_blocks: []
related_templates: []
entry_prompt: [[_Skills/02-Workflows/工作流-早间启动-条件Git-正式提示词]]
target_folders:
	- 00-Journal
	- 02-Projects
scope_paths:
	- 00-Journal
	- 02-Projects
	- 01-Literature
	- @Home.md
---

# 工作流-早间启动-条件Git

> [!abstract]- 适用场景
> 早上进入系统后，判断今天的计划是否值得版本化保存。早间 Git 是条件触发，不是每日强制动作。

## 依赖读取顺序

1. 先读取 frontmatter 中的 `linked_role`、`required_blocks`、`entry_prompt`。
2. 再读取当前正文里的触发条件与不触发条件，不能只看标题名猜测逻辑。
3. 若 `entry_prompt` 可用，优先把它视为实际调用入口。
4. 补齐方法依赖后，再去读取 `target_folders`、`scope_paths` 对应的业务文件。
5. 默认先读今日日记与本次绑定的项目 / 文献页，不先扩展搜索整个 vault。

## 触发条件

满足以下任意一条时，可进入早间 Git：

1. 今日日记已经写清 2-3 件核心任务。
2. 已写下清晰、可执行的第一推进动作。
3. 计划已绑定项目、文献或输出，并出现双链。
4. 早上同步调整了首页、模板、任务池、项目页或其他系统结构。

## 不触发条件

1. 只是新建了 Journal 文件。
2. 只有空白模板或模糊口号。
3. 今日主线还不清晰。
4. 信息密度不足，不值得形成一次版本记录。

## 输入

1. 今日日记。
2. 当前工作区内容。
3. git diff。

## 执行步骤

1. 先判断今天是否值得执行早间 Git。
2. 若不值得，明确拒绝并说明原因，不生成命令。
3. 若值得，提炼今日战略目标、项目聚焦、潜在阻碍和启动锚点。
4. 生成 `plan` 类型 commit message 与 bash 命令。

## 输出

1. 先输出判断结果。
2. 只有在满足条件时才输出 commit message 和命令。

## 成功标准

1. 不为了维持节奏而强行 Git。
2. 早间 commit 真正代表“作战意图已经清晰”。

## 禁止事项

1. 不把仅创建 Journal 文件说成值得提交。
2. 不虚构核心任务、聚焦对象或潜在阻碍。
