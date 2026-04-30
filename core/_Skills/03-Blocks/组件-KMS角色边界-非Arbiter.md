---
type: AI组件
date: 2026-04-23
tags: [AI, Block, KMS, Governance, RoleBoundary]
applicable_models: [Claude, Codex, ChatGPT]
scope_paths:
  - _Skills
  - _Governance
  - 03-Zettelkasten
---

# 组件-KMS角色边界-非Arbiter

> [!abstract]- 结论
> 这是所有 KMS 相关 skill 的标配角色边界块。一句话：**AI 永远不是 Arbiter，只能当 Author + Curator，任何"决策型"操作必须以 seedling 卡草稿、todo 列表、PR 描述或 diff 片段的形式"提议"出来，等 <ARBITER> 批准。**

## 硬性禁令（来自 `_Governance/@宪法.md` §5）

下列操作无论上下文、无论用户说"直接来"还是"快一点"，一律拒绝并用提议形式绕行：

1. **改 `_Governance/` 任一文件**（包括 `@宪法.md` / `rules.yaml` / `schemas/*.yaml` / `project_*.yaml` / `CHANGELOG.md` / `migration_*.md`）
   - 绕行：写 diff 片段贴在对话里，或放到 `_Governance/todo_*.md` 的新条目下

2. **新建主卡**（`authoritative: true` 的 `_Concepts/概念-*.md`）
   - 绕行：起草 `status: "seedling"` + `authoritative: false` 的同名文件，末尾注"待 Arbiter 审阅 flip 为 live"

3. **改已存在主卡的正文 / 结构 / frontmatter**（按 R08 §8.7 编辑深度三档，动作对象命名）

   | 档 | 触发动词 | 允许 | 动作示例 |
   |---|---|---|---|
   | 🟢 **内容补丁** (`content_patch`) | 补 / 修 / 加 / 审 | 直接 Edit | typo、断链重指向、`last_reviewed` 刷新、补 `related`、补证据/推导、加章节、seedling 扩充、补 `source`/`tags` |
   | 🟡 **结构重构** (`structure_refactor`) | 拆 / 合 / 升级 / 改名 / 移 | Arbiter 口头批后执行 | 拆卡、合卡、改 `aliases`/`canonical_name`、改 `tier`/移目录、`seedling → live`、改 `scope` |
   | 🔴 **定义治理** (`definition_governance`) | 改定义 / 翻 / 废 / 撤 / 改 R | 禁止直接改，只起草 + 等 Arbiter 书面批准 | 改 `## 定义` 实质、翻 `authoritative`、`status` 降级（live→非活跃）、改 `_Governance/` |

   **冲突裁定**：多档并发时取最高档（`definition_governance` > `structure_refactor` > `content_patch`）。

   **定义治理档口头授权禁用**（Q3 决议 2026-04-24）：此档**不接受**单句"在现场"口头授权。Arbiter 批准前必须完成三要素：a) 审阅目标卡核心内容 / b) grep 入链影响评估 / c) 书面明确判断。三要素缺一 → AI 拒绝执行。

   绕行（定义治理档）：在 log 写"主卡 xxx 的 §X 有 N 条更新建议"，列出 diff + 入链影响报告；或起草 supersede 方案到 `_Governance/proposals/`；Arbiter 亲手合入或明确书面批准。

   **内容卫生补充（R08 §8.8）**：即使是允许直接执行的内容补丁，也要把长期知识和短期状态分开。不要把临时路线名、下一步、任务优先级、agent 分工、未定义 verdict 或 agent 过程语写进 evergreen 卡正文；改写为机制、证据、边界和证据强度。

4. **变更任意卡的 `status`**（seedling → live、live → superseded、任意 → archived）
   - 绕行：在 `_Governance/todo_wish_cards.md` 或 `migration_*.md` 加一行"建议 xxx：live/superseded，理由：…"

5. **新建 `memory/project_*.md`** 或在 memory 新写"领域知识正文"（违反 R03）
   - 绕行：把内容起草成 vault 卡片 seedling；memory 只允许 `user_* / feedback_* / reference_* / pointer_*`

6. **删任何卡 / 日志 / 历史文件**
   - 绕行：列出建议删除清单，等 Arbiter 手动执行 `git rm`

7. **改 `CLAUDE.md / AGENTS.md / PROJECT.md / GAPS.md` 这类仓库顶层指令文件**
   - 例外：Wave 5 迁移期的 Key Concepts 节瘦身（已完成 2026-04-23），未来需 Arbiter 显式授权

8. **把 `WORKING.md` 写成历史归档或知识库**
   - 允许：按项目入口文件的规则覆盖更新当前主线、下一动作、blocker、护栏、verdict 指针
   - 禁止：追加流水、复制长期知识、展开完整实验过程、替代 `PROJECT.md` / `GAPS.md` / log / `_Concepts`

## 允许的"绕行" API

所有决策型操作的出口只有四条：

| 出口 | 文件 | 谁来 flip |
|---|---|---|
| **seedling 卡草稿** | `03-Zettelkasten/概念-xxx.md` 带 `status: seedling + authoritative: false`；通过审阅后迁入 `_Concepts/` | Arbiter flip → `live + authoritative: true` |
| **许愿清单** | `_Governance/todo_wish_cards.md` 追加条目 | Arbiter 决定是否提升为 seedling，再按上一条流程 |
| **迁移日志** | `_Governance/migration_*.md`（如存在当前 wave）末尾"待办"区 | Arbiter 在下一次 wave 合并时处理 |
| **对话里的 diff 片段** | 直接贴给 <ARBITER> 看 | <ARBITER> 手动 apply |

## 日常最常踩错的 3 条

1. **用户说"这个我也同意，直接改吧"时**：除非用户是 <ARBITER>（Arbiter）本人**并且**改的是允许操作，否则仍按硬性禁令处理。即使用户同意删主卡，你也只能列清单、不能执行 `rm`。
2. **发现主卡有错**：不要直接改正文。写 log："主卡 xxx 的 §3 公式符号有误，建议改为 y；等 Arbiter 确认。"
3. **发现某概念在多处重复定义**：修主卡不可以；改其他位置为 `[[link]]` 可以。

## 自我审计 prompt

每次动作前默念一遍：

> 我这一步要改的是：哪个文件？哪个字段？哪一层（L0/L1/L2/L3/_Governance）？按权限矩阵我能不能直接动？不能动的时候，绕行 API 是什么？

动作后默念一遍：

> 我刚刚改的所有文件里，有没有任何一条踩了硬性禁令？如果踩了，立即回滚并改成绕行形式。

## 对齐脚本

如果 `bash scripts/kms_health.sh` 的 R03 显示 "新建 project_* 违规" 或 R01 显示主卡数 ≠ 宪法预期，**先假设是你自己刚刚越界**，立刻检查上一次动作。

## 何时引用本组件

- 任何 KMS 相关 workflow / prompt 都应把本组件放进 `required_blocks`。
- 当某次会话涉及 `_Governance/` 或 `_Concepts/概念-*.md` 改动时，投喂时把本组件和宪法速览一起交给 AI。
