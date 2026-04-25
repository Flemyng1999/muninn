#!/usr/bin/env bash
# ============================================================================
#  bootstrap.sh — 从 Muninn 仓库生成一个可用的 Obsidian vault
#
#  用法：
#     bash scripts/bootstrap.sh --profile research --out ~/my-vault
#     bash scripts/bootstrap.sh --profile none --out ~/my-vault
#     bash scripts/bootstrap.sh --profile research,engineering --out ~/my-vault
#
#  做什么：
#     1. rsync core/ → OUT
#     2. 按顺序 rsync 每个 profile/ 的内容覆盖到 OUT（后面的覆盖前面的）
#     3. 在 OUT 写一份 .muninn-version 记录 core 版本 + 使用的 profile
#     4. git init + 初始 commit
# ============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROFILE=""
OUT=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --profile) PROFILE="$2"; shift 2 ;;
    --out) OUT="$2"; shift 2 ;;
    -h|--help)
      grep '^#' "$0" | head -20
      echo ""
      echo "可用 profile："
      find "$REPO_ROOT/profiles" -maxdepth 2 -name profile.yaml \
        -exec dirname {} \; | xargs -n1 basename
      exit 0 ;;
    *) echo "未知参数: $1"; exit 1 ;;
  esac
done

if [ -z "$PROFILE" ] || [ -z "$OUT" ]; then
  echo "错误：--profile 和 --out 都必填"
  echo "示例：bash scripts/bootstrap.sh --profile research --out ~/my-vault"
  exit 1
fi

if [ -e "$OUT" ] && [ -n "$(ls -A "$OUT" 2>/dev/null)" ]; then
  echo "错误：$OUT 已存在且非空"
  exit 1
fi

echo "Muninn 仓库:    $REPO_ROOT"
echo "输出 vault:     $OUT"
echo "Profile:        $PROFILE"
echo ""

mkdir -p "$OUT"

# Step 1: rsync core/
echo "[1/3] 复制 core/ 骨架..."
rsync -a --exclude='.DS_Store' "$REPO_ROOT/core/" "$OUT/"

# Step 2: rsync profiles（按顺序 overlay）
IFS=',' read -ra PROFILES <<< "$PROFILE"
for p in "${PROFILES[@]}"; do
  if [ "$p" = "none" ]; then
    echo "[2/3] profile=none，跳过 profile overlay"
    continue
  fi
  PDIR="$REPO_ROOT/profiles/$p"
  if [ ! -d "$PDIR" ]; then
    echo "错误：profile '$p' 不存在，检查 $REPO_ROOT/profiles/"
    exit 1
  fi
  echo "[2/3] overlay profile: $p"
  # profile 的元数据（profile.yaml / README.md）不进 vault
  rsync -a --exclude='.DS_Store' --exclude='profile.yaml' --exclude='README.md' \
    "$PDIR/" "$OUT/"
done

# Step 3: 版本标记 + git init
MUNINN_VERSION=$(cat "$REPO_ROOT/VERSION" 2>/dev/null || echo "unknown")
cat > "$OUT/.muninn-version" <<EOF
# Muninn 仓库生成的 vault 元数据（此文件不要删）
core_version: $MUNINN_VERSION
profile: $PROFILE
bootstrap_date: $(date +%Y-%m-%d)
source_repo: $REPO_ROOT
EOF

echo "[3/3] git init..."
(cd "$OUT" && git init -q && git add . && git commit -q -m "muninn bootstrap: profile=$PROFILE")

echo ""
echo "✅ 完成！你的新 vault 在：$OUT"
echo ""
echo "下一步："
echo "   1. 打开 Obsidian → Open folder as vault → 选 $OUT"
echo "   2. 读 $OUT/README.md（三天上手节奏）"
echo "   3. 复制 $OUT/_Governance/project_TEMPLATE.yaml → project_<你的项目>.yaml"
echo "      至少填 meta.project_id 和 meta.vault_path 两个必填字段"
echo "      Schema：_Governance/schemas/project_profile.yaml"
echo "   4. 跑体检："
echo "      export KMS_PROJECT_PROFILE=\"$OUT/_Governance/project_<你的项目>.yaml\""
echo "      bash $OUT/scripts/kms_health.sh --verbose"
echo "   5. 按 $OUT/_Skills/02-Workflows/@工作流索引.md 开始日常使用"
