# 宪法变更史 + 重大决策留痕

## v0.1.3 — 2025-11-03（项目启动）

**动作**：接收 Muninn research profile v0.1.3 骨架，建项目 yaml + 前 3 张主卡

**审核人**：researcher（Arbiter）

---

## v0.1.3.1 — 2026-02-12（规则微调）

**动作**：R02 frontmatter 必填字段在本项目新增 `informant_id` 字段（用于识别个体乌鸦 ID）

**档**：🟡 structure_refactor（改 schema 扩展）

**流程**：
- Arbiter 审阅 `schemas/extensions/experiment.yaml` 改动 ✅
- grep 入链扫描：影响 12 张实验卡，全部已补字段 ✅
- `kms_health.sh` 回归 R02 覆盖率从 97% → 100% ✅

**审核人**：researcher

---

## v0.1.3.2 — 2026-04-18（定义治理，Q3 三要素）

**动作**：将 `概念-社会学习指标` 的定义从 "个体间行为同步率" 改为 "行为同步率 − 独立创新 baseline"

**档**：🔴 definition_governance（改定义）

**Q3 三要素执行**：
- **a. Arbiter 审阅**：✅ researcher 亲自读完新定义，比对旧定义
- **b. 入链评估**：✅ grep 发现 6 处引用，其中 3 处结论会翻转（旧定义下 p=0.03 显著，新定义下 p=0.28 不显著）
- **c. 书面判断**：✅ "旧定义混淆了个体创新和社会学习，在高密度鸦群场景下会系统性高估 SLI。新定义减去 baseline 是必要修正。接受新定义，旧版本标记 superseded_by: 概念-社会学习指标"

**影响面**：
- `概念-社会学习指标.md` 从 `authoritative: true` + `status: "live"` 降级为 `status: "superseded"`
- 新建同名文件（git 保留旧版本于 history）
- 3 份实验卡结论需重跑，已加入 `_Governance/todo_wish_cards.md`

**审核人**：researcher

---

## 规则

- 每次 `_Governance/` / `_Concepts/` 定义级改动必须留痕
- 仅 Arbiter 修改
- 🔴 档操作必须记录完整 Q3 三要素执行过程（本 CHANGELOG v0.1.3.2 为示范）
