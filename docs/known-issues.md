# Known Issues / Debt Log

> Muninn 已知问题与技术债务清单。每条含：发现时间 / 影响 / 候选方案 / 优先级 / 目标版本。
> 解决后归档到本文件底部 "Resolved" 节，不删除（保留追溯）。

---

## 🔴 P1 — 阻碍验收线达成

（暂无）

---

## 🟡 P2 — 影响首次接入体验

### KMS-DEBT-001 — 模板内置 workflows 引用未自建的辅助卡片（v0.1.4 已缓解）

**发现**：2026-04-25（v0.1.3 Batch 1 端到端测试）

**现象**：用 `bash scripts/bootstrap.sh --profile research` 生成空 vault 后立即跑
`bash scripts/kms_health.sh`，R06 报告 actionable rate **11.2%**（远超 5% 验收线）。
深度分析（`kms_r06_classify.py --verbose`）显示 16 条 `skills-active` 来自：

| 引用源（内置 workflow） | 引用目标（用户应自建） | 出现次数 |
|---|---|---|
| `_Skills/02-Workflows/工作流-会议沉淀-*.md` | `[[会议笔记模版]]` | 5 |
| `_Skills/02-Workflows/工作流-文献沉淀-*.md` | `[[文献笔记模板]]` | 4 |
| `_Skills/02-Workflows/工作流-流水记录-*.md` | `[[@未来任务池]]` | 4 |
| `_Skills/02-Workflows/工作流-晚间结项-*.md` | `[[@未来任务池]]` | 2 |
| `_Skills/01-Roles/角色-Obsidian知识审计员.md` | `[[@未来任务池]]` | 1 |

**影响**：
- 新用户 Day 5 第一次跑体检即看到 🔴，错觉以为模板有 bug
- 使 R06-actionable 验收线（< 5%）形同虚设
- 削弱"卡通过 → 体检过线"的因果链信任

**根因**：
内置 workflows 来源于 hsi-canopy-relight 真实 vault，引用了**用户应自建**的辅助资产
（如会议笔记模板、文献笔记模板、未来任务池 MOC）。模板未提供这些卡的占位或 wish-cards 登记。

**候选方案**（按推荐顺序）：

#### 方案 A（推荐）：补 wish-cards + 模板占位
1. `_Governance/todo_wish_cards.md` 模板加入这 3 个 target 作为"用户首周任务"
2. 在 `00-Journal/README.md` / `02-Projects/README.md` 注释建议建立这些 MOC
3. 这样 R06 分类器自动归为 `wish-link`（非 actionable）

**工作量**：~1h；不动 workflow 文件
**风险**：低

#### 方案 B：扩展 schema `health.r06.expected_user_assets`
1. schema 加新字段 `health.r06.expected_user_assets: [list]`
2. 分类器加新档 `expected-user-asset`（非 actionable）
3. profile 默认值含这 3 个目标

**工作量**：~3h；改 schema + 改分类器 + 改默认配置
**风险**：中（schema 改动）

#### 方案 C：删 workflow 里的硬编码引用
1. 把 `[[会议笔记模版]]` 等改为占位提示文字"（你的会议笔记模板，建议命名 *会议笔记模版*.md）"
2. workflow 仍可读，但不再产生真链接

**工作量**：~2h；改 6 份 workflow 文件
**风险**：中（workflow 是宪法接近层，改动需保守）

**当前选择**：v0.1.4 已采用 **方案 A** 的最小版本：在
`core/_Governance/todo_wish_cards.md` 预登记 `[[会议笔记模版]]`、`[[文献笔记模板]]`、
`[[@未来任务池]]`。R06 分类器会把这些目标归为 `wish-link`，不计入 actionable。

**目标版本**：v0.1.4（已缓解；后续若需要可继续补 README 引导）

**临时缓解**：在 `core/scripts/README.md` 加一条 FAQ："首次跑 R06 actionable
偏高是预期的；模板内 workflow 引用了用户应自建的辅助卡片，登记它们或建好就降下来。"

---

## 🟢 P3 — 长期改进

### KMS-DEBT-002 — `backfill_yaml.py` 未 profile 化

**发现**：2026-04-25（Batch 1 反哺时遗漏）

**现象**：`backfill_yaml.py` 仍带占位（`<VAULT_ABSOLUTE_PATH>` / `<PROJECT_REPO_PATH>`），
不像 `kms_health.sh` 和 `kms_r06_classify.py` 已 profile-driven。

**影响**：
- 用户跑完 health + classify 后，要修复 R02 时被打回"填占位"年代，体验断裂
- 与 schema v1.0 整体设计不一致

**候选方案**：仿 `kms_r06_classify.py` 重构，从 `meta.vault_path` / `meta.repo_path`
派生路径，从 `paths.draft_cards_dir` 取 ZK 目录。

**工作量**：~2h
**风险**：低（脚本独立）
**目标版本**：v0.2.0

### KMS-DEBT-003 — `kms_health.sh` MVP 缺 R01 / R03 / R04 / R07 / R08

**发现**：2026-04-25（Batch 1 lean MVP 决定）

**现象**：当前 muninn `kms_health.sh` 只实现 R02 / R05 / R06 三档。
R01 SSOT 扫描 / R03 memory 瘦身 / R04 narrative spine / R07 升级队列 / R08 生命周期
还在 hsi-canopy-relight 项目侧 538 行版本里，未完整反哺。

**影响**：
- 周度体检覆盖度比项目源版本低
- R01 SSOT 是宪法第一条，缺它意味着核心保护没 enforced

**候选方案**：分阶段反哺。优先级 R01 > R08 > R04 > R03 > R07。
每个 R 拆成独立函数，profile-driven。

**工作量**：每个 R ~2h，总 ~10h
**风险**：低（可增量做）
**目标版本**：v0.2.0

---

## 🔵 已暴露但暂不处理

### KMS-DEBT-004 — Section title 分类规则只看首字符是否数字

**发现**：2026-04-25

**现象**：`is_section_title()` 判据是 `target[0].isdigit()`。会**误识别**：
- `[[2024Smith-paper]]`（年份开头的真文献卡名）→ 误判 section-title
- `[[1.5x speedup]]`（含数字的描述）→ 误判

**影响**：低。研究文献多半含 `Author2024Year` 模式，但首字母通常是 Author（字母）。
真冲突场景罕见。

**候选方案**：用更复杂正则（如 `^\d+\s` 或 `^\d+章` 或 `^\d+\.`）
但任何启发式都会有边界。

**当前决定**：保持简单，等真冲突案例出现再细化。

---

## Resolved

（暂无）

---

## 维护规则

- 新发现的 debt 加到对应优先级章节
- 每条至少含：现象 / 影响 / 候选方案 / 目标版本
- 解决后从主体移到 "Resolved" 节，标注解决版本和 commit
- 每次发布版本时 review 本文件（看是否阻碍版本目标）
- 优先级判断：P1 阻碍验收 / P2 影响首次接入 / P3 长期改进 / 🔵 暂不处理
