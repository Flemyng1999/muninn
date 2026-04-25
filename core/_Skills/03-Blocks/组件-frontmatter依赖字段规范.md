---
type: AI组件
date: 2026-03-09
tags: [AI, Block, Frontmatter, Schema]
applicable_models: [Copilot, Codex, Claude, ChatGPT]
scope_paths:
  - _Skills
---

# 组件-frontmatter依赖字段规范

> [!abstract]- 目标
> 给 role / workflow / prompt / block 定义一套统一且最小的 frontmatter 依赖字段，让 AI 能沿着明确依赖查找需要的 skill 文件，而不是靠猜。

## 设计原则

1. 字段尽量少，但必须足够表达“我依赖谁、我入口是谁、我会落到哪里”。
2. 优先使用统一字段名，不为每一种文件发明不同命名。
3. 允许某些字段留空，不强求所有类型都填满。
4. 优先描述 skill 依赖，不把业务上下文也塞进 frontmatter。

## 统一字段清单

这些字段是整个 `_Skills` 体系的推荐统一字段：

### 基础字段

1. `type`
2. `date`
3. `tags`
4. `applicable_models`

### 依赖字段

1. `linked_role`
用途：当前文件依赖的主角色。

2. `linked_workflow`
用途：当前文件对应或依附的工作流。

3. `required_blocks`
用途：执行时必须同时读取的 block。

4. `optional_blocks`
用途：可选增强 block，不是硬依赖。

5. `related_templates`
用途：本 skill 依赖的页面模板或结构模板。

6. `entry_prompt`
用途：当前 workflow 或 role 对应的正式提示词入口。

7. `target_folders`
用途：这个 skill 主要会落库到哪些目录。

8. `scope_paths`
用途：这个 skill 常用来搜索或补充关联的范围。

## 字段解释与建议格式

### `linked_role`

格式：单个 wiki link

示例：

`linked_role: [[_Skills/01-Roles/角色-Obsidian知识审计员]]`

### `linked_workflow`

格式：单个 wiki link

示例：

`linked_workflow: [[_Skills/02-Workflows/工作流-会议沉淀-规范落库]]`

### `required_blocks`

格式：YAML 数组

示例：

```yaml
required_blocks:
  - [[_Skills/03-Blocks/组件-调用约定-最小固定模式]]
```

### `optional_blocks`

格式：YAML 数组

示例：

```yaml
optional_blocks:
  - [[_Skills/03-Blocks/某个增强组件]]
```

### `related_templates`

格式：YAML 数组

示例：

```yaml
related_templates:
  - [[_Templates/会议笔记模版]]
```

### `entry_prompt`

格式：单个 wiki link

示例：

`entry_prompt: [[_Skills/02-Workflows/工作流-会议沉淀-规范落库-正式提示词]]`

### `target_folders`

格式：YAML 数组，填目录路径字符串

示例：

```yaml
target_folders:
  - 00-Journal
```

### `scope_paths`

格式：YAML 数组，填常用搜索范围字符串

示例：

```yaml
scope_paths:
  - 02-Projects
  - 03-Zettelkasten
```

## 各类型最小字段集

### 1. Role

推荐最少保留：

```yaml
type: AI角色
date: 2026-03-09
tags: [AI, Role]
applicable_models: []
required_blocks: []
optional_blocks: []
entry_prompt: ""
scope_paths: []
```

说明：

1. role 一般不需要 `linked_role`。
2. role 可以通过 `required_blocks` 指定默认调用约定。
3. 如果这个角色常服务某一类任务，可在 `scope_paths` 里放常用业务范围。

### 2. Workflow

推荐最少保留：

```yaml
type: AI工作流
date: 2026-03-09
tags: [AI, Workflow]
linked_role: ""
required_blocks: []
optional_blocks: []
related_templates: []
entry_prompt: ""
target_folders: []
scope_paths: []
```

说明：

1. workflow 是依赖关系最核心的一层。
2. `linked_role`、`entry_prompt`、`related_templates` 基本应当填写。

### 3. Prompt

推荐最少保留：

```yaml
type: AI工作流提示词
date: 2026-03-09
tags: [AI, Workflow, Prompt]
linked_role: ""
linked_workflow: ""
required_blocks: []
optional_blocks: []
related_templates: []
target_folders: []
scope_paths: []
```

说明：

1. prompt 页是“实际投喂入口”，必须能回指 workflow。
2. prompt 页通常不再需要 `entry_prompt`，因为它自己就是入口。

### 4. Block

推荐最少保留：

```yaml
type: AI组件
date: 2026-03-09
tags: [AI, Block]
applicable_models: []
scope_paths: []
```

说明：

1. block 通常不依赖 role 或 workflow。
2. block 的职责是被 workflow 或 prompt 通过 `required_blocks` / `optional_blocks` 调用。


## AI 应如何沿依赖查找

如果 AI 已经拿到某个 skill 文件，推荐按这个顺序继续查找：

1. `entry_prompt`
2. `linked_role`
3. `linked_workflow`
4. `required_blocks`
5. `related_templates`
6. `scope_paths`

也就是说：

先补 skill 依赖，再去碰业务文件。

## 命名约束

1. 不再新增 `default_role`、`main_role`、`prompt_entry` 这类近义字段。
2. 已存在的 `source_prompt` 视为过渡字段，后续优先统一到 `entry_prompt`。
3. 所有多值依赖字段一律用 YAML 数组。

## 最小结论

对你这套系统，真正应固定的统一依赖字段只有这 8 个：

1. `linked_role`
2. `linked_workflow`
3. `required_blocks`
4. `optional_blocks`
5. `related_templates`
6. `entry_prompt`
7. `target_folders`
8. `scope_paths`
