# Muninn 快速上手（5 分钟）

[English](QUICKSTART.md) · [中文](QUICKSTART.zh.md)

## 假设你是谁

- 你在做研究 / 产品 / 工程，需要结构化沉淀
- 你用过 AI 协作，吃过 AI 乱改笔记的亏
- 你愿意花 1 小时换未来几年的秩序

不满足任一条 → 先不用，去 [docs/philosophy.md](docs/philosophy.md) §七 看"什么情况下别用"。

## Step 0：装 Obsidian（5 分钟，一次性）

https://obsidian.md → 下载对应系统 → 安装。

## Step 1：clone 这个仓库（1 分钟）

```bash
git clone https://github.com/<yourname>/muninn.git
cd muninn
```

## Step 2：生成你的 vault（1 分钟）

```bash
# 研究者
bash scripts/bootstrap.sh --profile research --out ~/my-vault

# 纯骨架（产品 / 工程 profile 还 WIP，先用 core-only）
bash scripts/bootstrap.sh --profile none --out ~/my-vault
```

## Step 3：Obsidian 打开（2 分钟）

1. 打开 Obsidian
2. 左下 "Open another vault" → "Open folder as vault"
3. 选 `~/my-vault/`
4. 左侧看到 `_Governance / _Skills / _Concepts / 00-Journal / 03-Zettelkasten / README.md`

## Step 4：装 4 个 Obsidian 插件（10 分钟）

左下齿轮 → Community plugins → Turn on → Browse，依次装：
- **Templater**（必需）
- **Dataview**（必需）
- **Obsidian Git**（强推）
- **Kanban**（可选）

装完重启 Obsidian。

## Step 5：填健康检查脚本的占位（5 分钟，一次性）

打开 `~/my-vault/scripts/kms_health.sh`，改顶部 3 个路径占位：

```bash
VAULT="<VAULT_ABSOLUTE_PATH>"          # → 改成 /Users/你/my-vault（绝对路径）
MEM="<CLAUDE_MEMORY_PATH_OR_EMPTY>"    # → 不用 Claude Code 填空字符串 ""
REPO="<PROJECT_REPO_PATH>"             # → 你的项目 git 仓库路径，没有填 /tmp/kms-out
```

`scripts/backfill_yaml.py` 同样填两个占位。

详见 `~/my-vault/scripts/README.md`。

## Step 6：读必读 4 份文件（30 分钟）

按顺序打开读一遍，不必全记：

1. `~/my-vault/README.md`（顶层）
2. `_Governance/@宪法.md` 重点 §三 角色 / §六 规则速览 / §R08 §8.7
3. `_Skills/02-Workflows/@工作流索引.md`（知道 8 套工作流都在哪）
4. `_Concepts/README.md` + `03-Zettelkasten/README.md`（知道什么放哪）

## Step 7：跑一遍"AI 接入"流程（10 分钟）

1. 打开一个 AI（ChatGPT / Claude.ai / Gemini）新会话
2. 打开 `_Skills/02-Workflows/工作流-AI接入KMS-正式提示词.md`
3. 复制 `---PROMPT START---` 到 `---PROMPT END---` 的全部内容，粘给 AI
4. AI 会要求你贴几份关键文件（宪法 / rules / schemas），按它要求贴
5. AI 答验收清单 5 条，通过 → 你的第一次 AI 协作通道建立

## Step 8：开始日常（Day 1 开始）

参考 `_Skills/02-Workflows/工作流-早间启动-条件Git-正式提示词.md`，每天走一遍：

- **早上**：建 Journal + 今天 2–3 任务
- **白天**：遇事 `[HH:MM] 事件`，涉及核心概念用 `[[双链]]`
- **晚上**：AI 过一遍 Journal，挑沉淀点

## Day 14 验收

```bash
cd ~/my-vault
bash scripts/kms_health.sh
```

- R02 frontmatter 覆盖率 ≥ 95%
- R05 孤儿卡 = 0
- R06 断链率 < 10%
- `00-Journal/` ≥ 10 文件，每条 `[HH:MM]` 时间戳
- `_Concepts/概念-*.md` 3–10 张 seedling

全中 → 毕业，独立运转。

## 我应该选哪个 Profile？

| 你是 | 选 |
|---|---|
| 博士生 / 研究员 | `--profile research` |
| 产品 / 设计 / 创业 | `--profile none`（等 product profile 成熟） |
| 工程师 / 架构师 | `--profile none`（等 engineering profile 成熟） |
| 不确定 | `--profile none`，两周后你会知道 |

详见 [docs/profile-comparison.md](docs/profile-comparison.md)。

## 遇到问题

- AI 自称改了 `_Governance/` → 不信，让它重读 `工作流-AI接入KMS-正式提示词.md`
- 脚本跑不起来 → `scripts/README.md` 末尾有"常见报错"
- 想改宪法 → 先用满 2 个月再说。90% 的"想改规则"其实是"没理解"
- 不想用了 → 所有文件是标准 Markdown，无 lock-in，直接关 Obsidian 就行

## 下一步

- 深度理解：[docs/philosophy.md](docs/philosophy.md)
- 对比 profile：[docs/profile-comparison.md](docs/profile-comparison.md)
- 贡献 profile / 工作流：[CONTRIBUTING.md](CONTRIBUTING.md)
