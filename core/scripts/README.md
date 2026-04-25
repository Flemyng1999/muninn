# scripts/ — KMS 维护工具（profile-driven）

## 内容

- `kms_health.sh` —— 周度健康度仪表盘（R02 / R05 / R06 三档 MVP）
- `kms_r06_classify.py` —— R06 断链 raw / actionable 双指标分类器
- `backfill_yaml.py` —— frontmatter 元数据批量回填（R02 修复用）

## 第一次用前

**不需要改脚本文件。** 所有项目特定数据从 `_Governance/project_<id>.yaml`
（项目 KMS profile）读取。

第一次跑：

```bash
# 法 1：用 KMS_PROJECT_PROFILE 环境变量
export KMS_PROJECT_PROFILE="$HOME/my-vault/_Governance/project_my-project.yaml"
bash scripts/kms_health.sh

# 法 2：每次显式传 --profile
bash scripts/kms_health.sh --profile $HOME/my-vault/_Governance/project_my-project.yaml
```

如果你还没建 project profile，复制 `_Governance/project_TEMPLATE.yaml` 到
`_Governance/project_<your_id>.yaml`，**至少填**这两个字段：

```yaml
meta:
  project_id: "<your_project_id>"
  vault_path: "<vault_absolute_path>"   # 必填，Obsidian vault 绝对路径
```

其他字段（paths / core_concepts / health 配置）有 schema 默认值。

完整 schema 见 `_Governance/schemas/project_profile.yaml`。

## 用法

```bash
# kms_health.sh
bash scripts/kms_health.sh                    # markdown 到 stdout
bash scripts/kms_health.sh --save             # 保存到 <repo_path>/out/kms_health/<date>.md
bash scripts/kms_health.sh --verbose          # 附违规样例

# kms_r06_classify.py（kms_health.sh 内部会调一次；也可单独跑做深度分析）
python scripts/kms_r06_classify.py            # markdown 到 stdout
python scripts/kms_r06_classify.py --save     # 保存 markdown
python scripts/kms_r06_classify.py --json out/r06.json   # 机读 JSON
python scripts/kms_r06_classify.py --window-days 60      # 覆盖 historical 窗口
python scripts/kms_r06_classify.py --verbose             # 展开各类详情

# backfill_yaml.py（仍带占位，待 profile 化）
python scripts/backfill_yaml.py               # dry-run
python scripts/backfill_yaml.py --apply       # 真写盘
```

## 验收线（两周后）

R02 frontmatter 覆盖率 ≥ 95%
R05 孤儿率 = 0
R06 actionable 率 < 5%

## 自定义健康检查阈值

在 `_Governance/project_<id>.yaml` 加 `health:` 节即可（schema 默认值会兜底）：

```yaml
health:
  r06:
    historical_window_days: 60               # 改 30 → 60 天窗口
    placeholder_keywords:                    # 加自己的占位词
      - "对应的"
      - "某个"
      - "你的项目名"
    actionable_threshold: 3.0                # 阈值改 5% → 3%
  r02:
    coverage_threshold: 98.0
  r05:
    allowed_orphan_types: [experience, pitfall, typography, log]
```

完整 schema 见 `_Governance/schemas/project_profile.yaml` 的 `health` 节。

## 依赖

- bash 5+（macOS 自带 3.x 也能跑）
- python 3.8+
- **PyYAML**（`pip install pyyaml`）—— `kms_health.sh` 嵌入 Python 解析 profile 时需要
- 标准 unix 工具：find / grep / sed / wc / tr

## 反向 Q & A

**Q：每次开新项目都要新建 profile？**
A：是。每个项目对应一份 `project_<id>.yaml`。这是 SSOT 边界。

**Q：能否一份 profile 多项目复用？**
A：不建议。profile 含 project_id / repo_path / core_concepts，多项目混用会破坏 SSOT。

**Q：`backfill_yaml.py` 还没 profile 化？**
A：是，仍是占位时代版本。后续 v0.1.4 会改造。
