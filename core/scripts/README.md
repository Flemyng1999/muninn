# scripts/ — KMS 维护工具

## 内容

- `kms_health.sh` —— 周度健康度仪表盘（R01–R08 八大指标）
- `backfill_yaml.py` —— frontmatter 元数据批量回填（R02 修复用）

## 第一次用前必填（占位 5 个）

打开 `kms_health.sh`，把顶部以下占位改成你的真实路径：

| 占位 | 改成 |
|---|---|
| `<VAULT_ABSOLUTE_PATH>` | 你的 Obsidian vault 绝对路径，例 `/Users/xxx/Documents/kms-template` |
| `<PROJECT_REPO_PATH>` | 你的项目 git 仓库路径（没有就填 `/tmp/kms-out` 这样的临时目录） |
| `<CLAUDE_MEMORY_PATH_OR_EMPTY>` | 用 Claude Code 才填它 memory 路径；不用就填空字符串 `""`（R03 检查会跳过） |

`backfill_yaml.py` 类似，改两个：`<VAULT_ABSOLUTE_PATH>` 和 `<PROJECT_REPO_PATH>`。

## 用法

```bash
# 跑体检（输出 markdown 到 stdout）
bash scripts/kms_health.sh

# 体检 + 保存到 out/kms_health/YYYY-MM-DD.md
bash scripts/kms_health.sh --save

# 体检 + 显示每条违规具体样例
bash scripts/kms_health.sh --verbose

# YAML 回填（dry-run）
python scripts/backfill_yaml.py

# YAML 回填（真写盘）
python scripts/backfill_yaml.py --apply
```

## 验收线（两周后）

R02 ≥ 95%（frontmatter 覆盖率）
R05 = 0（孤儿卡）
R06 < 10%（断链率）

## 依赖

- bash 5+（macOS 自带 3.x 也能跑，但 `sed -i ''` 是 macOS 风格，Linux 改 `sed -i`）
- python 3.7+
- ripgrep（`rg`）—— `kms_health.sh` 部分检查用，没装会有警告但能跑
