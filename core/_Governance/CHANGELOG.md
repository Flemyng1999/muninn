# 宪法变更史（CHANGELOG）

本文件记录本 vault 的宪法 / 规则 / schema 变更。原始模板基于 v0.1.4（2026-04-28）。

## 规则

- 每次 `_Governance/@宪法.md` / `rules.yaml` / `schemas/` 变更必须留痕
- 仅 Arbiter 修改
- 格式：版本号 + 日期 + 改动要点 + 审核人

---

## v0.1.4 — <从原始模板接收日期>

**动作**：接收原始 KMS 模板（宪法 v0.1.4 骨架）

**规则增量**：
- R08 新增 §8.8 卡片长期可理解性与证据卫生。
- 卡片正文应去语境化，避免短期路线名、未定义 verdict、agent 过程语污染长期知识。
- 状态/任务调度应留在 Journal / WORKING / GAPS / 任务区，卡片保留事实、证据、机制、边界。
- 新卡和重大修订卡应尽量标注或暗示证据强度。
- Repo ↔ vault interface 明确 `WORKING.md` 是项目侧运行态控制面板：覆盖更新、详情外迁、保持单主线和少量 verdict 指针。

**审核人**：<ARBITER>

---

## v0.1.3 — <从原始模板接收日期>

**动作**：接收原始 KMS 模板（宪法 v0.1.3 骨架）

**下一步**：按 `README.md` 两周节奏表上手。任何后续宪法变更从 v0.1.4 起记录。

**审核人**：<ARBITER>

## v0.1.6 (2026-05-26)

### Governance
- Constitution upgraded to v0.1.6: `_Skills/` namespace brought under formal governance
- **R09 — Skill Lifecycle & Usage Governance**: new rule defining Skill lifecycle states, metadata schema (`skill.yaml`), audit triggers, and forbidden write boundaries. Skills must carry `name/type/status/scope/version/updated/owner` frontmatter.

### New Schema
- `schemas/skill.yaml`: formal schema for all `_Skills/` assets (workflow/prompt/role/block/template), with required/optional fields, invariants, and legacy compatibility notes.

### New Workflows
- **Skill管理与审计** (workflow + formal prompt): Skill lifecycle management, audit checklist, migration procedures, usage tracking.
- **健康体检**: lightweight layered health check (L0 routing → L1 structure → L2 content sampling → L3 full audit), with weekly/monthly calendar prompts.
- **文献沉淀-规范落库** (workflow + formal prompt): Literature → KMS structured ingestion pipeline.

### Rules
- `rules.yaml`: version 0.1.4 → 0.1.6. Added R09 section. Simplified lifecycle states (removed `retracted`). Updated scope to include `_Skills/`. Naming scheme examples updated.
