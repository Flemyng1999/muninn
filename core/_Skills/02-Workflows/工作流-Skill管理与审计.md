---
name: skill-management-audit
type: workflow
status: seedling
scope: global
version: 0.1.0
updated: 2026-05-23
owner: <ARBITER>
triggers: [Skill 管理, Skill 审计, 技能清理, 技能迁移, 技能使用统计]
usage_tracking: journal_marker
linked_role: [[_Skills/01-Roles/角色-Obsidian知识审计员]]
required_blocks:
  - [[_Skills/03-Blocks/组件-调用约定-最小固定模式]]
entry_prompt: [[_Skills/02-Workflows/工作流-Skill管理与审计-正式提示词]]
target_folders:
  - _Skills
  - _Governance
scope_paths:
  - _Skills
  - _Governance
---

# 工作流-Skill管理与审计

正式投喂入口：[[_Skills/02-Workflows/工作流-Skill管理与审计-正式提示词]]

> [!abstract]- 适用场景
> 当你要创建、修改、迁移、弃用、删除、审计或统计 KMS Skill 时使用。目标是保护 `_Skills/` 作为长期 SSOT，同时清理不用的 Skill。

## 依赖读取顺序

1. 先读 `_Governance/@宪法.md` §5 与 `rules.yaml` R09。
2. 再读 `_Governance/schemas/skill.yaml`。
3. 再读 `_Skills/AGENTS.md`、`@技能库总览`、`@技能使用手册`。
4. 按任务类型读取目标 Skill、索引、usage rollup。

## 分流

| 场景 | 动作 |
|---|---|
| 新 workflow 只服务单个 repo | 留在 repo adapter，不升 KMS |
| 新 workflow 跨项目复用 | 起草 seedling Skill |
| live Skill patch/minor | Curator 可维护，留 source anchor |
| live Skill major/lifecycle/governance | Arbiter 决策 |
| 低频 Skill | 进入 review candidate，不自动删除 |
| 本地 agent copy 漂移 | 对照 KMS canonical source/version |

## 审计清单

1. metadata completeness。
2. live trigger uniqueness。
3. dead links。
4. forbidden write boundary。
5. requires_adapter 是否有 adapter。
6. usage marker / rollup 是否存在。
7. 低频、重复、过宽、过窄 Skill 候选。

## 输出

- 实际修改清单。
- lifecycle / usage / adapter 风险。
- 保留 / 合并 / deprecated / archived 建议。
- 需要 Arbiter 决策的项目。
