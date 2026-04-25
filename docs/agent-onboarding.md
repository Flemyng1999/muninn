# Agent Onboarding —— 项目入口文件实践

> Muninn 推荐模式。**不强制文件名**：你可以叫它 `AGENTS.md` / `CLAUDE.md` /
> `.github/copilot-instructions.md` / `agents/onboarding.md` —— 由你的项目和工具链决定。
> 但**内容契约**应一致。

## 这是什么 / 解决什么问题

新 AI 会话接入项目仓库时，没有持久记忆，只能靠**仓库根的入口文件**自举。
不同 IDE / 工具有约定俗成的命名：

| 工具 | 期望的入口文件 |
|---|---|
| Claude Code | `CLAUDE.md`（自动加载） |
| Codex / OpenAI Agents | `AGENTS.md` |
| GitHub Copilot Chat | `.github/copilot-instructions.md` |
| Cursor | `.cursorrules` 或 `.cursor/rules/*.mdc` |
| Generic AI（粘贴提示词） | 任意文件，由用户复制 |

**问题**：如果项目同时被多个 AI 工具协作，文件不一致 → 行为不一致。
入口质量差 → AI 不读 KMS、瞎改主卡、跳过 Q3 三要素。

**Muninn 的答案**：定义**一份内容契约**（本文档），项目按需复制到一个或多个入口文件。
所有入口文件的**内容相互一致**，文件名由项目和工具链决定。

## 必要内容契约（10 个字段）

无论入口文件叫什么，应**至少**包含以下 10 项：

| # | 字段 | 内容 | 为什么 |
|---|---|---|---|
| 1 | **宪法版本号** | "本项目按 KMS 宪法 v0.1.3" | 防止漂移 |
| 2 | **接口文档指针** | `docs/repo-vault-interface.md` | repo↔vault 桥梁 |
| 3 | **Vault 绝对路径** | `<VAULT_ABSOLUTE_PATH>` | AI 找不到 vault 就抓瞎 |
| 4 | **Project profile 路径** | `<VAULT>/_Governance/project_<id>.yaml` | 机读契约入口 |
| 5 | **角色边界** | "AI 永远是 Executor，不是 Arbiter；不能改 _Governance/ / _Concepts/概念-* / _Skills/" | R08 §8.7 硬禁令 |
| 6 | **R08 三档摘要** | 🟢 content_patch / 🟡 structure_refactor / 🔴 definition_governance + Q3 三要素 | 编辑深度边界 |
| 7 | **启动顺序** | AI 必须按顺序读哪几份文件（建议至少 6 份） | 自举质量 |
| 8 | **健康检查命令** | `bash scripts/kms_health.sh --profile <path>` | 可立即跑 |
| 9 | **写入路由** | 新知识第一落点是 Journal / Zettelkasten / _Concepts | SSOT 守则 |
| 10 | **冲突优先级** | rules.yaml > @宪法.md > 入口文件 > 代码注释 | 治理冲突解决 |

## 入口文件模板

把下面整段复制到你的入口文件（替换 `<占位>`）：

```markdown
# <PROJECT_NAME> — AI Agent 接入说明

> 本项目使用 [Muninn KMS](https://github.com/<org>/muninn) 治理知识资产。
> 详细接口见 `docs/repo-vault-interface.md`。

## 1. 宪法版本

- **KMS 宪法 v0.1.3**（含 R08 §8.7 编辑深度矩阵）
- 治理源：`<VAULT>/_Governance/@宪法.md`
- 机读法条：`<VAULT>/_Governance/rules.yaml`
- 项目 profile：`<VAULT>/_Governance/project_<PROJECT_ID>.yaml`
- 接口契约：`docs/repo-vault-interface.md`（repo ↔ vault 桥梁）

其中 `<VAULT>` = `<VAULT_ABSOLUTE_PATH>`。

## 2. 你的角色

**Executor / Curator helper，永远不是 Arbiter。**

硬禁令（违反即 abort）：
- 不直接写 `<VAULT>/_Governance/` 任何文件
- 不直接改 `<VAULT>/_Concepts/概念-*.md` 主卡正文 / `authoritative` / `status`
- 不直接改 `<VAULT>/_Skills/` 任何文件
- 不经 Q3 三要素落 🔴 档动作（改定义 / 翻 authoritative / 改 _Governance/）

## 3. R08 §8.7 编辑深度矩阵

按动作动词分档：

| 档 | 触发动词 | AI 行为 |
|---|---|---|
| 🟢 content_patch | 补 / 修 / 加 / 审 | 直接改，报 diff |
| 🟡 structure_refactor | 拆 / 合 / 升级 / 改名 / 移 | Arbiter 口头批，执行 + grep 入链报告 |
| 🔴 definition_governance | 改定义 / 翻 / 废 / 撤 / 改 _Governance/ | **只起草**，等 Q3 三要素书面批准 |

Q3 三要素：(a) Arbiter 审阅 (b) 入链评估 (c) 书面明确判断（非"OK"一字）

## 4. 启动顺序（必读）

1. 本文件
2. `docs/repo-vault-interface.md`
3. `<VAULT>/_Governance/@宪法.md`
4. `<VAULT>/_Governance/rules.yaml`
5. `<VAULT>/_Governance/project_<PROJECT_ID>.yaml`
6. `PROJECT.md` + `WORKING.md`

读完 6 份再开始任何实施任务。

## 5. 健康检查

- 周度体检：`bash scripts/kms_health.sh --profile <VAULT>/_Governance/project_<PROJECT_ID>.yaml`
- R06 深度分析：`python scripts/kms_r06_classify.py --profile <...> --verbose`
- 验收线：R02 ≥ 95% / R05 = 0 / R06-actionable < 5%

## 6. 写入路由

| 新信息 | 第一落点 |
|---|---|
| 实验原始结果 | `log/YYYY-MM-DD.md` |
| 当前下一步 | `WORKING.md` |
| Gate 证据 | `PROJECT.md` |
| 方法学缺陷 | `GAPS.md` |
| 稳定洞察 | `<VAULT>/03-Zettelkasten/` 起 seedling |
| 核心概念定义 | `<VAULT>/_Concepts/概念-*.md`（仅 Arbiter）|
| KMS 规则修改 | proposal 或 diff（仅 Arbiter）|

## 7. 冲突优先级

`rules.yaml` > `@宪法.md` > 本文件 > 代码注释

## 8. 执行分工 / 路径规则 / 项目特定细节

<在此粘贴你项目特有的内容：执行平台、conda 环境、路径映射、Gate 序列等>
```

## 多入口文件场景

如果你的项目同时被多种 AI 工具协作，建议：

### 方案 A：单一权威 + 软链接
**唯一权威**：`AGENTS.md`（人读）
**别名**：用 git 不可见的 symlink 或 git tracked 直接复制

```bash
ln -s AGENTS.md CLAUDE.md
ln -s AGENTS.md .github/copilot-instructions.md
```

优点：永远同步。
缺点：部分工具不识别 symlink（Cursor / Copilot 已 OK）。

### 方案 B：单一权威 + 同步说明
**权威**：选一个文件作 source of truth（多数项目选 `AGENTS.md` 或 `CLAUDE.md`）
**其他文件**：开头加同步说明 + 简短指针

```markdown
# CLAUDE.md（同步自 AGENTS.md）

> 本文件与 `AGENTS.md` 应保持同步。修改任意一个时，检查另一个是否需要对应更新。
> AGENTS.md 是所有 AI agent 的显式行为规范；本文件是 Claude Code 自动加载入口。
> 两者内容不重复，但规则不得冲突。

## ... <内容>
```

优点：每份文件可附工具特定调整。
缺点：人工同步负担。

### 方案 C：内容契约 + 各自实现
**根本方案**：本文档定义"必要内容契约"，各入口文件按工具最佳实践写。
入口文件**不互相同步**，但都符合契约。

适合：项目对各 AI 工具调优要求高。
不适合：小项目（维护负担过重）。

## 推荐组合

| 项目规模 | 推荐 | 原因 |
|---|---|---|
| 单人 / 单 AI 工具 | 方案 B 单一文件（如 `CLAUDE.md`）| 最简单 |
| 多 AI 工具协作 | 方案 A symlink | 自动同步 |
| 团队 / 高定制需求 | 方案 C 各自实现 + 本文契约 | 灵活 |

## 实战经验（hsi-canopy-relight 为例）

- 同时维护 `AGENTS.md` (66 行) + `CLAUDE.md` (180 行)
- 选方案 B：CLAUDE.md 是 Claude Code 自动加载，AGENTS.md 是其他 AI 显式入口
- 两者顶部互相声明同步约束
- v0.1.3 升级时通过 proposal 文件起草 diff，Arbiter Q3 三要素批准后合入两份

完整案例 + proposal 模式见 hsi-canopy-relight 项目（如果你有访问权限）。

## 检查清单：你的入口文件合格吗？

新 AI 会话接入你的项目时：

- [ ] AI 能从入口文件找到 vault 绝对路径吗？
- [ ] AI 能从入口文件找到 project profile 路径吗？
- [ ] AI 能不能识别自己是 Executor 不是 Arbiter？
- [ ] AI 知道 R08 三档怎么用吗？
- [ ] AI 知道改 `_Governance/` 需要 Q3 三要素吗？
- [ ] AI 知道周度体检命令是什么吗？
- [ ] AI 知道新知识第一落点在哪吗？

7 项全过 → 入口文件合格。

## 何时升级入口文件

- KMS 宪法版本 bump → 改宪法版本号字段（必）+ R08 三档摘要（如果改了）
- 新 profile 路径 → 改第 1 节 + 第 4 节
- 新接口文档 → 改第 1 节
- 新工具集成（如开始用 Cursor）→ 加新入口文件 + 软链接

不必为小变动改入口文件（profile 内字段变了不需要改入口；profile 文件名变了才需要改）。

## 起源

本模式抽自 hsi-canopy-relight 项目 2026-04 实践。原始动机：v0.1.3 升级时
发现 `AGENTS.md` 缺关键字段、`CLAUDE.md` 版本号漂移，新 AI 会话自举质量
急速下降。proposal 流程定义后才稳定。

更广义：在 AI 多代际协作场景，**入口契约 ≥ 入口实现**。
