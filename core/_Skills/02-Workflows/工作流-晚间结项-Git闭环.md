---
type: AI工作流
date: 2026-03-09
tags: [AI, Workflow, Journal, Git]
linked_role: [[_Skills/01-Roles/角色-Obsidian知识审计员]]
required_blocks:
	- [[_Skills/03-Blocks/组件-调用约定-最小固定模式]]
optional_blocks: []
related_templates: []
entry_prompt: [[_Skills/02-Workflows/工作流-晚间结项-Git闭环-正式提示词]]
target_folders:
	- 00-Journal
	- 02-Projects
scope_paths:
	- 00-Journal
	- 02-Projects
	- 03-Zettelkasten
---

# 工作流-晚间结项-Git闭环

> [!abstract]- 适用场景
> 下班前执行。目标不是只写 commit message，而是先完成 Journal 闭环、待办分流与明日启动锚点整理。

## 依赖读取顺序

1. 先读取 frontmatter 中的 `linked_role`、`required_blocks`、`entry_prompt`。
2. 再读取当前正文里的规则，不要跳过正文直接执行。
3. 若 `entry_prompt` 可用，优先把它视为实际调用入口。
4. 补齐方法依赖后，再去读取 `target_folders`、`scope_paths` 对应的业务文件。
5. 默认先读 `00-Journal` 与 `02-Projects`，只有在上下文不足时再扩展到 `03-Zettelkasten`。

## 触发条件

1. 今天已经有 Journal 记录。
2. 存在未整理的 Inbox、未勾选收尾项、未明确的明天第一动作，或今天有值得提交的资产变更。

## 输入

1. 今日日记。
2. 当前工作区内容。
3. git diff 与变更状态。

## 执行步骤

1. 检查今日日记中的 `Inbox`、`晚间收尾`、`明天第一动作` 与所有未完成事项。
2. 将“不属于今天但未来要做”的事项转移到 [[02-Projects/@未来任务池]] 的合适列。
3. 保留“今天已完成”的事项在 Journal 中，不转移。
4. 保留真正属于明天启动锚点的“明天第一动作”，必要时改写得更可执行。
5. 基于明日待办与日程，补齐：每条待办一个明确提醒时间；每条日程一个开始时间与持续时长。
6. 生成一段可直接口述给 Siri 的自然语言，包含明日待办与日程（带时间）。
7. 勾选或更新晚间收尾复选框，让 Journal 真正闭环。
8. 基于实际 diff 生成高信息密度的 commit message。
9. 输出可直接执行的 Git 命令。

## 输出

1. 先汇报对笔记系统做了哪些实际修改。
2. 给出“明日待办 + 日程”清单（含提醒时间/开始时间/持续时长）。
3. 给出一段可直接口述给 Siri 的话。
4. 再给出 commit message。
5. 最后给出 bash 命令。

## 成功标准

1. Journal 不再承担未来任务池角色。
2. 明天第一动作具体、单步、可立即开始。
3. commit message 基于真实改动，而非脑补总结。

## 禁止事项

1. 不只生成 commit message 而不处理遗留事项。
2. 不把所有未完成项都留在 Journal。
3. 不机械地把明天第一动作移入任务池。
