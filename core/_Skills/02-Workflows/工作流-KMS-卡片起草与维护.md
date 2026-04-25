---
type: AI工作流
date: 2026-04-23
tags: [AI, Workflow, KMS, Zettelkasten, Governance]
linked_role: [[_Skills/01-Roles/角色-KMS执行人]]
required_blocks:
  - [[_Skills/03-Blocks/组件-调用约定-最小固定模式]]
  - [[_Skills/03-Blocks/组件-KMS角色边界-非Arbiter]]
  - [[_Skills/03-Blocks/组件-frontmatter依赖字段规范]]
optional_blocks: []
related_templates: []
entry_prompt: [[_Skills/02-Workflows/工作流-KMS-卡片起草与维护-正式提示词]]
target_folders:
  - 03-Zettelkasten
  - 02-Projects
  - _Governance
scope_paths:
  - 03-Zettelkasten
  - 02-Projects
  - _Governance
  - 00-Journal
---

# 工作流-KMS-卡片起草与维护

正式投喂入口：[[_Skills/02-Workflows/工作流-KMS-卡片起草与维护-正式提示词]]

> [!abstract]- 适用场景
> 这是 KMS 执行人的主工作流。一份 prompt 覆盖四类任务：
>
> 1. 起草一张新卡（从 log / 推导 / 会议纪要）
> 2. 挂接孤儿卡 / 修断链 / 刷新 YAML（周度维护）
> 3. 跑 `kms_health.sh` 并生成整改清单
> 4. 处理 Wave 迁移型批处理（脚本辅助 + 人工核校）
>
> **不适用**：需要 Arbiter 决策的操作（建主卡、改 `_Governance/`、flip status）——这类任务 AI 只能起草"提议"，由 <ARBITER> 执行 merge。

## 依赖读取顺序

1. 先读 frontmatter 的 `linked_role`、`required_blocks`、`entry_prompt`。
2. 再读本页"执行步骤"和"分流规则"。
3. 补方法依赖：`_Governance/@宪法.md` + `rules.yaml` + `schemas/*.yaml` + `project_<name>.yaml`（这四份在执行前必须至少扫一遍）。
4. 再读业务上下文：本次要动的具体卡片、今日 log、相关 MOC。
5. 默认不全库搜索；如需找关联，只在 `03-Zettelkasten/`、`02-Projects/`、`_Governance/`、`00-Journal/` 的最小子集里找。

## 典型输入

1. 一段 log / 推导 / 会议纪要，含可升级为卡片的稳定结论。
2. 显式任务："跑体检"、"挂接孤儿"、"修一下 xxx 的断链"、"把 memory project_* 转成 vault seedling"。
3. 某次 Wave 迁移的具体节点（如 "Wave 4 断链治理"）。

## 四类任务分流

### 任务 A：起草新卡（Author 模式）

判定条件：用户给了原始素材 + "沉淀一下"/"做成卡片"类指令。

步骤：
1. 判断 `type`：`概念 / 洞察 / 思考 / 踩坑 / 经验 / 定律 / 排版`（schema 列表见 `rules.yaml` R02）。
2. 核查是否在 `project_<name>.yaml` 的 `core_concepts` 清单里；若是 → 这是**主卡级别**概念，你只能起草 seedling（`authoritative: false`），不能 flip。
3. 按 `schemas/concept.yaml` 或 `schemas/card.yaml` 补 frontmatter：`id / type / status: "seedling" / scope / created / last_reviewed / related`。
4. 正文结构按 schema 节数上限（≤ 4 节），典型：`定义 / 数学·物理形式 / 边界与假设 / 相关卡片`（概念类）或 `结论 / 锚定案例 / 一般原则 / 关联`（洞察/思考类）。
5. 挂到至少一个 MOC（`@索引-*` 或 `@项目*`）；否则列入 `_Governance/todo_wish_cards.md` 的"72h 待挂接"区。

### 任务 B：挂接孤儿 / 修断链 / 刷 YAML（Curator 模式）

判定条件：用户说"整理一下卡片盒"、"修断链"、"跑体检后处理"。

步骤：
1. 跑 `bash scripts/kms_health.sh` 记录 before 指标（R02/R05/R06 三项）。
2. 按 R06 分类处理断链：
   - `wish` → 追加到 `_Governance/todo_wish_cards.md`
   - `typo / moved` → 直接 Edit 修
   - `section-title 误识别`（如 `[[1基本辐射度量]]`）→ 转反引号 `` `1 基本辐射度量` ``
   - `attachment embed` 残缺（`![[IMG-xxx.gif]]`）→ 跳过（scope 外）
3. 按 R05 处理孤儿：先看 type，`experience / pitfall / typography` 允许永久 seedling 不强制挂接；其他必须挂到最合适的 `@索引-*`。若无合适索引，在本次对话末尾给 Arbiter 提 "建议新建 MOC" 的草案。
4. 按 R02 补 YAML：运行 `scripts/backfill_yaml.py --apply`（默认值 `status: "live"` 需用户授权，dry-run 先看）。
5. 跑 `kms_health.sh` 记录 after 指标，输出对比表。

### 任务 C：跑体检（Reporter 模式）

判定条件：用户说"看一下 KMS 状态"、"跑体检"、"R0x 现在什么样"。

步骤：
1. `bash scripts/kms_health.sh` 原样跑一次。
2. 把汇总表（R01–R07）抽出来，红色/黄色项挑出重点三条。
3. 对每条红色/黄色项给出"绕行出口"建议（比如断链率 17% → 实际健康链接 ≤5%，差距是 scanner 的 `.jpg/.png` 误报，建议 v0.2 修 scanner）。
4. 不主动改任何文件——Reporter 只报告，不动手。

### 任务 D：Wave 迁移（批处理模式）

判定条件：`_Governance/migration_*.md` 的某个 Wave 尚未完成，或用户说"继续 Wave N"。

步骤：
1. 读 `migration_*.md` 对应 Wave 的执行要求、验收标准、回滚预案。
2. 检查该 Wave 是否属于 Arbiter-only（如 v0.1 Wave 2.2 memory project_* 删除）；若是 → 拒绝执行，只能起草 pointer 文件草稿。
3. 非 Arbiter-only 的批操作按顺序执行：生成脚本 → dry-run → 用户确认 → `--apply`。
4. 每 Wave 结束跑一次 `kms_health.sh` 对比指标，必要时用户 `git commit`（由 <ARBITER> 执行，你不要 `git commit`）。

## 执行原则

1. **先度量后改造**：任何"整改"动作前跑一次 `kms_health.sh` 记基线；动作后再跑对比。没有基线数字的声明不要说。
2. **批处理先 dry-run**：超过 5 个文件的批改必须先 dry-run 列清单，用户确认后才 `--apply` / 实际写文件。
3. **Seedling 不是缺点**：所有 AI 新卡**默认 seedling**，不要为了看起来"完整"而自 flip 成 live。
4. **绕行出口齐全**：发现任何越权需求，一律映射到四条绕行 API（seedling / todo / migration / diff 片段）。
5. **落点清晰**：每次动作汇报都要写"动了哪些文件、每个文件动了什么字段"。

## 输出（按顺序）

1. **本次动作摘要**：动了哪些文件、哪些是新建、哪些是修改；新建的 seedling 清单 + "待 Arbiter 审阅"标注。
2. **指标对比**（如做了整改）：R02 / R05 / R06 before → after 三行表。
3. **Arbiter 待办清单**：本次提议但未执行的操作（flip status、删卡、改主卡正文、改 `_Governance/`）。
4. **下一步建议**：如还有 pending Wave、还有孤儿未挂、还有断链未分类，列出清单。

## 成功标准

1. 所有新建的卡片都带正确 frontmatter（通过 `kms_health.sh` R02 验证）。
2. 本次动作不违反 `组件-KMS角色边界-非Arbiter` 的硬性禁令。
3. 用户只需读"动作摘要"就能决定是否 merge / 回滚，不用去猜。
4. Arbiter 待办清单清晰，可直接执行。

## 禁止事项

1. 不建主卡。起草 seedling，flip 归 Arbiter。
2. 不改 `_Governance/`。写 diff 贴对话或放 `todo_*.md`。
3. 不跑 `git commit`（项目仓库和 vault 都不跑）；列出建议命令让用户执行。
4. 不声称指标改善但不附 `kms_health.sh` 输出。
5. 不把对话里的临时结论直接写进主卡，哪怕语法正确也不行。
6. 不把核心概念完整定义写进 log / docs / 对话——一律 `[[link]]` 到主卡。
