# Repo ↔ Vault Interface

> **本文档是 Muninn 的核心模式之一**，建议每个使用 Muninn 的项目仓库都放一份本文件
> 的副本（命名 `docs/kms_interface.md` 或 `docs/repo-vault-interface.md`），
> 改写其中的项目占位为你自己的项目数据。

## 这是什么 / 为什么

如果你同时有一个**项目代码仓库**（git 跟踪）和一个**知识 vault**（Muninn /
Obsidian），它们之间需要稳定低耦合的接口契约：

- **项目仓库**：拥有代码、notebook、实验、数据路径、Gate 证据、当前任务状态、
  研究 GAP（bug-like）
- **知识 Vault**：拥有概念 SSOT 主卡、生命周期状态、领域 MOC、卡片升级规则、
  治理规则（宪法 / rules / schemas）

**核心原则**：两个系统通过**稳定指针 + 周期性同步**互相加强，**任一方都不应该是
另一方的运行时依赖**。具体地：
- 项目脚本不能要求 vault 链接才能跑核心实验
- vault 卡片不能承载易变的任务状态
- 健康检查脚本应该是 reporter，不是 auto-rewriter

## 模板：Canonical Locations

> 复制这段表到你自己的 `docs/kms_interface.md`，把占位 `<PROJECT_*>` 替换为真实值。

| 职责 | Source of truth | 备注 |
|---|---|---|
| KMS 宪法 + 规则 | `<VAULT>/_Governance/` | AI 只读，仅 Arbiter 改 |
| 项目 KMS profile | `<VAULT>/_Governance/project_<PROJECT_ID>.yaml` | 机读契约：core_concepts / paths / gate_status / health 配置 |
| Profile schema | `<VAULT>/_Governance/schemas/project_profile.yaml` | 字段类型 / 默认值 |
| 项目稳定事实 + Gate 证据 | `<PROJECT_REPO>/PROJECT.md` | KMS `gate_status` 镜像它，不替代它 |
| 当前任务状态 | `<PROJECT_REPO>/WORKING.md` | 会话交接，不存常青概念 |
| 已发现 / 已解决 GAP | `<PROJECT_REPO>/GAPS.md` | 研究 bug tracker；解决的可升级到 vault 卡 |
| 每日记录 | `<PROJECT_REPO>/log/YYYY-MM-DD.md` | 仓库符号链接，指向 `<VAULT>/<obsidian_log_dir>` |
| 常青概念定义 | `<VAULT>/_Concepts/概念-*.md` | 项目文档应链或指向，不重定义 |
| 自由演化笔记 | `<VAULT>/03-Zettelkasten/` | seedling / 洞察 / 踩坑 / 思考，从 log 升级而来 |
| 项目叙事骨架 | `<VAULT>/02-Projects/<PROJECT_NAME>.md` | 人面向的项目 MOC |

## 模板：Startup Contract for Agents

> 同样：复制到你的 `docs/kms_interface.md`，按本项目实际清单调整顺序。

会话开始前 AI 必须按顺序读：

1. `<PROJECT_REPO>/AGENTS.md` 或 `<PROJECT_REPO>/CLAUDE.md`（角色边界 + 仓库规则）
2. `<PROJECT_REPO>/docs/kms_interface.md`（本接口契约）
3. `<VAULT>/_Governance/@宪法.md`（KMS 宪法）
4. `<VAULT>/_Governance/rules.yaml`（机读法条）
5. `<VAULT>/_Governance/project_<PROJECT_ID>.yaml`（项目 profile）
6. `<PROJECT_REPO>/PROJECT.md` + `<PROJECT_REPO>/WORKING.md`

KMS 面向工作还需读相关 MOC 或目标卡。

**默认 AI 角色：Executor / Curator helper，永远不是 Arbiter。** AI 不能：
- 直接修改 `<VAULT>/_Governance/`
- flip `authoritative` / `status` 字段
- 创建 `authoritative: true` 概念主卡
- 跑不可逆 git 操作

除非用户给出明确项目侧指令且 KMS 规则允许。

## 模板：Write Routing

| 新信息 | 第一落点 | 升级路径 |
|---|---|---|
| 实验原始结果 | `log/YYYY-MM-DD.md` | 若可复用，加日志的"升级候选"节 |
| 当前下一步 / 会话状态 | `WORKING.md` | 保持短；不变成知识库 |
| 稳定 Gate 证据 | `PROJECT.md` | KMS profile 镜像 status 快照 |
| 开放方法学缺陷 | `GAPS.md` | 解决的经验可升级为 insight / pitfall 卡 |
| 稳定洞察 / 踩坑 / 思考 | `<VAULT>/03-Zettelkasten/` 起 seedling | Curator / Arbiter 可后续 promote 或挂链 |
| 核心概念定义 | `<VAULT>/_Concepts/概念-*.md` | 仅 Arbiter 治理的 SSOT；项目文档指向它 |
| KMS 规则修改 | proposal 或 diff | Arbiter 更新 `_Governance/` + CHANGELOG |

## 耦合规则（不变量）

- 项目脚本**不能**要求 Obsidian 链接 / vault 文件能跑核心实验
- 项目文档**避免**复制 KMS 治理规则；指向宪法 / rules.yaml
- KMS 卡片**不携带**易变任务状态；用 `WORKING.md` 和 log
- Gate 状态由 `PROJECT.md` 决定；KMS profile 镜像它供机读治理
- 每日 log 是**追加友好**的研究记录；KMS 卡片是**生命周期管理**的知识资产
- 健康检查**报告 + 指引**；不静默 rewrite 治理文件

## 健康检查方向

Muninn 现有脚本（位于 `<MUNINN_REPO>/core/scripts/`）：

- `kms_health.sh` —— 周度健康度（R02 frontmatter 覆盖率 / R05 孤儿率 / 调 R06 分类器）
- `kms_r06_classify.py` —— R06 断链 raw / actionable 双指标分类

两者都通过 `--profile` 或 `KMS_PROJECT_PROFILE` 环境变量加载项目 profile，
不写死项目路径。

复制到你自己的项目仓库 `scripts/` 后：
- 不需要改脚本本身
- 只要给 profile 指向 `<VAULT>/_Governance/project_<PROJECT_ID>.yaml`

## 维护规则

若本文件与 `<VAULT>/_Governance/@宪法.md` 或 `rules.yaml` 冲突，**KMS 治理文件赢**。
本文件是桥梁摘要，仅在 Arbiter 修改治理源后才更新本文件。

## 怎么用本模板

1. 复制本文件到你的项目仓库：`<PROJECT_REPO>/docs/kms_interface.md`
2. 全文搜索替换以下占位：
   - `<VAULT>` → 你的 Obsidian vault 绝对路径
   - `<PROJECT_REPO>` → 项目仓库绝对路径
   - `<PROJECT_ID>` → 项目 ID（与 profile yaml 文件名一致）
   - `<PROJECT_NAME>` → 项目中文名
   - `<MUNINN_REPO>` → Muninn 仓库路径（若你 vendor 了脚本）或删除该行
3. 删除"## 怎么用本模板"节（仅模板需要）
4. commit 到项目仓库
5. 更新 `AGENTS.md` / `CLAUDE.md` / `<entry-file>` 的启动清单加入本文件指针

## 起源

本接口模式抽自 hsi-canopy-relight 项目（2026-04-25）的 `docs/kms_interface.md`
实际使用经验。原始动机：研究项目仓库和知识库（vault）混合，AI 协作时频繁
混淆边界，需要稳定的接口契约定义"什么住哪里"。
