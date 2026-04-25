#!/usr/bin/env bash
# ============================================================================
#  kms_health.sh — Muninn 知识管理健康度仪表盘（profile-driven MVP）
#
#  Schema：_Governance/schemas/project_profile.yaml v1.0
#  实现：R02 frontmatter 覆盖率 / R05 孤儿率 / R06 断链分类（调 kms_r06_classify.py）
#
#  用法：
#      bash scripts/kms_health.sh --profile <path/to/project_<id>.yaml>
#      bash scripts/kms_health.sh --save             # 保存 markdown 到 <repo>/out/kms_health/
#      bash scripts/kms_health.sh --verbose          # 附违规样例
#
#  Profile 解析顺序：
#      1. --profile CLI
#      2. KMS_PROJECT_PROFILE 环境变量
#      3. 退出（profile 必需）
#
#  本脚本不写死项目名 / vault 路径 / 阈值。所有特化通过 profile 驱动。
#
#  依赖：bash 5+ (macOS 自带 3.x 也能跑) / python3 + PyYAML / find / grep
# ============================================================================
set -uo pipefail

SAVE=0
VERBOSE=0
PROFILE_CLI=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --save) SAVE=1; shift ;;
    --verbose) VERBOSE=1; shift ;;
    --profile) PROFILE_CLI="$2"; shift 2 ;;
    -h|--help) grep '^#' "$0" | head -25; exit 0 ;;
    *) echo "未知参数: $1" >&2; exit 1 ;;
  esac
done

# ----------------------------------------------------------------------------
#  Profile 加载
# ----------------------------------------------------------------------------
PROJECT_PROFILE="${PROFILE_CLI:-${KMS_PROJECT_PROFILE:-}}"
if [ -z "$PROJECT_PROFILE" ]; then
  echo "❌ 缺少 project profile：传 --profile <path> 或设置 KMS_PROJECT_PROFILE" >&2
  exit 1
fi
if [ ! -f "$PROJECT_PROFILE" ]; then
  echo "❌ profile 文件不存在：$PROJECT_PROFILE" >&2
  exit 1
fi

CONFIG_TMP=$(mktemp)
TMP_REPORT=$(mktemp)
trap "rm -f $CONFIG_TMP $TMP_REPORT" EXIT

python3 - "$PROJECT_PROFILE" > "$CONFIG_TMP" <<'PY'
import os, shlex, sys
from pathlib import Path
try:
    import yaml
except ImportError:
    sys.exit("❌ kms_health.sh 需要 PyYAML：pip install pyyaml")

profile_path = Path(sys.argv[1]).expanduser().resolve()
data = yaml.safe_load(profile_path.read_text(encoding="utf-8")) or {}
meta = data.get("meta", {}) or {}
paths = data.get("paths", {}) or {}
health = data.get("health", {}) or {}
r02 = health.get("r02", {}) or {}
r05 = health.get("r05", {}) or {}

def q(v):
    return shlex.quote(str(v))

vault = meta.get("vault_path")
if vault:
    vault = Path(vault).expanduser()
else:
    vault = profile_path.parent.parent
if not vault.exists():
    sys.exit(f"❌ vault 不存在：{vault}")

def join_vault(rel, default):
    p = Path(str(rel or default)).expanduser()
    if not p.is_absolute():
        p = vault / p
    return p

repo = Path(str(meta.get("repo_path") or os.getcwd())).expanduser()
concepts_dir = join_vault(paths.get("concept_cards_dir"), "_Concepts")
zk_dir       = join_vault(paths.get("draft_cards_dir"), "03-Zettelkasten")
log_dir      = join_vault(paths.get("obsidian_log_dir"), "00-Journal")
out_dir      = repo / "out" / "kms_health"

r02_required_default = ["id", "type", "status", "scope", "created", "last_reviewed"]
r02_required = r02.get("required_fields") or r02_required_default
r05_allowed = r05.get("allowed_orphan_types") or ["experience", "pitfall", "typography"]

print(f"VAULT={q(vault)}")
print(f"REPO={q(repo)}")
print(f"CONCEPTS={q(concepts_dir)}")
print(f"ZK={q(zk_dir)}")
print(f"LOG_DIR={q(log_dir)}")
print(f"OUT_DIR={q(out_dir)}")
print(f"PROJECT_ID={q(meta.get('project_id') or 'unknown')}")

def arr(name, items):
    body = " ".join(q(i) for i in items)
    print(f"declare -a {name}=({body})")
arr("R02_REQUIRED", r02_required)
arr("R05_ALLOWED_TYPES", r05_allowed)
PY

# shellcheck disable=SC1090
source "$CONFIG_TMP"

TODAY=$(date +%Y-%m-%d)

pct() { [ "$2" -eq 0 ] && echo "0.0" || python3 -c "print(f'{100*$1/$2:.1f}')"; }

# ----------------------------------------------------------------------------
#  报告生成
# ----------------------------------------------------------------------------
{
  echo "# 📊 KMS Health Report — $TODAY"
  echo ""
  echo "- **Project**: \`$PROJECT_ID\`"
  echo "- **Vault**: \`$VAULT\`"
  echo "- **Profile**: \`$PROJECT_PROFILE\`"
  echo ""
  echo "---"
  echo ""

  # ==== H. 规模基线 ====
  echo "## H. 规模基线"
  echo ""
  TOTAL_CONCEPTS=$(find "$CONCEPTS" -maxdepth 1 -name '概念-*.md' 2>/dev/null | wc -l | tr -d ' ')
  TOTAL_MOC=$(find "$CONCEPTS" -maxdepth 1 -name '@*.md' 2>/dev/null | wc -l | tr -d ' ')
  TOTAL_ZK=$(find "$ZK" -maxdepth 1 -name '*.md' -not -name '@*' -not -name 'README.md' 2>/dev/null | wc -l | tr -d ' ')
  TOTAL_LOG=$(find "$LOG_DIR" -name '20*.md' 2>/dev/null | wc -l | tr -d ' ')
  echo "| 项 | 数量 |"
  echo "|---|---|"
  echo "| _Concepts SSOT 主卡 | $TOTAL_CONCEPTS |"
  echo "| _Concepts 领域 MOC | $TOTAL_MOC |"
  echo "| 03-Zettelkasten 自由演化卡 | $TOTAL_ZK |"
  echo "| Journal 文件 | $TOTAL_LOG |"
  echo ""

  # ==== R02 ====
  echo "## R02 — Frontmatter 覆盖率"
  echo ""
  total=0; fm=0
  # 并行数组（bash 3.2 兼容；R02_FIELD_COUNT[i] 对应 R02_REQUIRED[i]）
  R02_FIELD_COUNT=()
  for i in "${!R02_REQUIRED[@]}"; do R02_FIELD_COUNT[$i]=0; done
  for f in "$CONCEPTS"/*.md "$ZK"/*.md; do
    [ -f "$f" ] || continue
    [ "$(basename "$f")" = "README.md" ] && continue
    total=$((total+1))
    head -1 "$f" | grep -q '^---$' || continue
    fm=$((fm+1))
    for i in "${!R02_REQUIRED[@]}"; do
      field="${R02_REQUIRED[$i]}"
      head -25 "$f" | grep -qE "^${field}:" && R02_FIELD_COUNT[$i]=$((${R02_FIELD_COUNT[$i]}+1))
    done
  done
  fm_pct=$(pct $fm $total)
  echo "| 字段 | 覆盖 | % | 目标 | 状态 |"
  echo "|---|---|---|---|---|"
  fm_status=$([ "$fm" -eq "$total" ] && echo "✅" || echo "🔴")
  echo "| frontmatter 存在 | $fm / $total | ${fm_pct}% | 100% | $fm_status |"
  for i in "${!R02_REQUIRED[@]}"; do
    field="${R02_REQUIRED[$i]}"
    cnt=${R02_FIELD_COUNT[$i]}
    p=$(pct $cnt $total)
    icon=$([ "$cnt" -eq "$total" ] && echo "✅" || echo "🔴")
    echo "| $field | $cnt / $total | ${p}% | 100% | $icon |"
  done
  echo ""

  # ==== R05 ====
  echo "## R05 — 孤儿卡（无入链）"
  echo ""
  orphans=0; total_cards=0; allowed_orphans=0
  ORPHAN_LIST=""
  for f in "$CONCEPTS"/*.md "$ZK"/*.md; do
    [ -f "$f" ] || continue
    name=$(basename "$f" .md)
    [ "$name" = "README" ] && continue
    [[ "$name" == @* ]] && continue
    total_cards=$((total_cards+1))
    cnt=$(grep -rlF "[[$name" "$VAULT" --include='*.md' 2>/dev/null | grep -v "$f" | wc -l | tr -d ' ')
    if [ "$cnt" -eq 0 ]; then
      type_field=$(head -25 "$f" | grep -E '^type:' | head -1 | sed -E 's/^type:[[:space:]]*"?([a-z_]+)"?.*/\1/')
      is_allowed=0
      for t in "${R05_ALLOWED_TYPES[@]}"; do [ "$type_field" = "$t" ] && is_allowed=1; done
      if [ "$is_allowed" -eq 1 ]; then
        allowed_orphans=$((allowed_orphans+1))
      else
        orphans=$((orphans+1))
        [ $VERBOSE -eq 1 ] && [ $orphans -le 10 ] && ORPHAN_LIST="$ORPHAN_LIST\n  - \`$name\`（type=$type_field）"
      fi
    fi
  done
  orphan_pct=$(pct $orphans $total_cards)
  orphan_icon=$([ "$orphans" -eq 0 ] && echo "✅" || echo "🔴")
  echo "| 项 | 值 | 阈值 | 状态 |"
  echo "|---|---|---|---|"
  echo "| 孤儿卡数（不含允许类型）| $orphans | 0 | $orphan_icon |"
  echo "| 孤儿率 | ${orphan_pct}% | 0% | $orphan_icon |"
  echo "| 允许类型孤儿（experience/pitfall/typography 等）| $allowed_orphans | — | ℹ️ |"
  if [ $VERBOSE -eq 1 ] && [ -n "$ORPHAN_LIST" ]; then
    echo ""
    echo "<details><summary>孤儿样例（前 10）</summary>"
    echo ""
    echo -e "$ORPHAN_LIST"
    echo ""
    echo "</details>"
  fi
  echo ""

  # ==== R06 ====
  echo "## R06 — 断链分类"
  echo ""
  SCRIPT_DIR=$(dirname "$0")
  if [ -f "$SCRIPT_DIR/kms_r06_classify.py" ]; then
    R06_ARGS=("--profile" "$PROJECT_PROFILE")
    [ $VERBOSE -eq 1 ] && R06_ARGS+=("--verbose")
    R06_OUT=$(python3 "$SCRIPT_DIR/kms_r06_classify.py" "${R06_ARGS[@]}" 2>/dev/null) || true
    # 抽指标 + 分类明细 + （verbose 时）详情
    echo "$R06_OUT" | sed -n '/^## 指标/,/^## 分类明细/p' | sed '$d'
    echo "$R06_OUT" | sed -n '/^## 分类明细/,/^## 详情/p' | sed '$d'
    if [ $VERBOSE -eq 1 ]; then
      echo "$R06_OUT" | sed -n '/^## 详情/,$p'
    fi
  else
    echo "⚠️  kms_r06_classify.py 不存在于 $SCRIPT_DIR/，跳过 R06"
  fi
  echo ""

  echo "---"
  echo ""
  echo "_本报告由 \`scripts/kms_health.sh\` 生成。规则参见 \`_Governance/rules.yaml\`。_"
  echo "_配置项见 \`_Governance/schemas/project_profile.yaml\` health 节。_"
} > "$TMP_REPORT"

cat "$TMP_REPORT"

if [ $SAVE -eq 1 ]; then
  mkdir -p "$OUT_DIR"
  OUT_FILE="$OUT_DIR/$TODAY.md"
  cp "$TMP_REPORT" "$OUT_FILE"
  echo "✅ 报告保存到 $OUT_FILE" >&2
fi
