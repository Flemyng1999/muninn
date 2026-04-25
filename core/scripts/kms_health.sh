#!/usr/bin/env bash
# ============================================================================
#  kms_health.sh — 知识管理系统健康度仪表盘
#
#  由 _Governance/@宪法.md v0.1 规定的周度检查脚本
#  复现 2026-04-23 体检的 8 大指标 + 按 rules.yaml 违规等级输出
#
#  用法:
#     scripts/kms_health.sh              # 输出 markdown 报告到 stdout
#     scripts/kms_health.sh --save       # 保存到 out/kms_health/YYYY-MM-DD.md
#     scripts/kms_health.sh --verbose    # 附加每条违规的具体样例
# ============================================================================
set -uo pipefail

# -------- 路径常量 --------
VAULT="<VAULT_ABSOLUTE_PATH>"
MEM="<CLAUDE_MEMORY_PATH_OR_EMPTY>"
REPO="<PROJECT_REPO_PATH>"
ZK="$VAULT/03-Zettelkasten"          # 自由演化区（思考/洞察/踩坑/经验/普通概念笔记）
CONCEPTS="$VAULT/_Concepts"          # SSOT 主卡区（authoritative；2026-04-24 起独立）
LOG_DIR="$VAULT/00-Journal"
OUT_DIR="$REPO/out/kms_health"

# -------- 参数 --------
SAVE=0
VERBOSE=0
for arg in "$@"; do
  case $arg in
    --save) SAVE=1 ;;
    --verbose) VERBOSE=1 ;;
    -h|--help)
      grep '^#' "$0" | head -20; exit 0 ;;
  esac
done

TODAY=$(date +%Y-%m-%d)
TMP=$(mktemp)
trap "rm -f $TMP" EXIT

# ============================================================================
#  报告写入 TMP
# ============================================================================
{
  echo "# 📊 KMS Health Report — $TODAY"
  echo ""
  echo "> 由 \`scripts/kms_health.sh\` 自动生成；规则参见 \`_Governance/rules.yaml\`"
  echo ""
  echo "---"
  echo ""

  # ============================================================================
  #  H. 规模基线
  # ============================================================================
  echo "## H. 规模基线"
  echo ""
  TOTAL_ZK=$(find "$ZK" -maxdepth 1 -name '*.md' -not -name '@*' | wc -l | tr -d ' ')
  TOTAL_MOC=$(find "$ZK" -maxdepth 1 -name '@*.md' | wc -l | tr -d ' ')
  TOTAL_CONCEPTS=$(find "$CONCEPTS" -maxdepth 1 -name '*.md' -not -name '@*' 2>/dev/null | wc -l | tr -d ' ')
  TOTAL_CONCEPTS_MOC=$(find "$CONCEPTS" -maxdepth 1 -name '@*.md' 2>/dev/null | wc -l | tr -d ' ')
  TOTAL_MEM=$(find "$MEM" -maxdepth 1 -name '*.md' -not -name 'MEMORY.md' | wc -l | tr -d ' ')
  TOTAL_LOG=$(find "$LOG_DIR" -maxdepth 1 -name '2*.md' | wc -l | tr -d ' ')
  echo "| 项 | 数量 |"
  echo "|---|---|"
  echo "| _Concepts SSOT 主卡 | $TOTAL_CONCEPTS |"
  echo "| _Concepts 领域 MOC | $TOTAL_CONCEPTS_MOC |"
  echo "| 03-Zettelkasten 自由演化卡 | $TOTAL_ZK |"
  echo "| 03-Zettelkasten MOC | $TOTAL_MOC |"
  echo "| Claude memory 文件 | $TOTAL_MEM |"
  echo "| 近期 log 文件 | $TOTAL_LOG |"
  echo ""

  # ============================================================================
  #  R01 — SSOT 违规扫描
  # ============================================================================
  echo "## R01 — SSOT 唯一主卡（核心概念）"
  echo ""
  # 并行数组：避免 bash 关联数组对 UTF-8 key 的脆弱性
  CONCEPT_NAMES=("ωL" "S_k(λ)" "w_k" "f_sun" "p_W" "R_dir1" "R_dif1" "R_ms" "Gate α" "Gate β" "Gate γ")
  CONCEPT_PATTERNS=(
    "ωL|omega_L|leaf_albedo"
    "S_k|Sk\\b|光谱核"
    "w_k|wk\\b|几何权重|路径比例"
    "f_sun|fsun|sunlit_fraction"
    "p_W|pW\\b|状态分布"
    "R_dir1|R_dir\\b"
    "R_dif1|R_dif\\b"
    "R_ms"
    "Gate α|Gate-α|gate_alpha|Gateα"
    "Gate β|Gate-β|gate_beta|Gateβ"
    "Gate γ|Gate-γ|gate_gamma|Gateγ"
  )
  echo "| 概念 | vault/ZK | vault/other | memory | docs | CLAUDE/AGENT | 裸定义位置总数 |"
  echo "|---|---|---|---|---|---|---|"
  SSOT_TOTAL=0
  for i in "${!CONCEPT_NAMES[@]}"; do
    concept="${CONCEPT_NAMES[$i]}"
    pattern="${CONCEPT_PATTERNS[$i]}"
    zk=$(grep -rlE "$pattern" "$ZK" 2>/dev/null | wc -l | tr -d ' ')
    other=$(grep -rlE "$pattern" "$VAULT" --include='*.md' 2>/dev/null | grep -v "03-Zettelkasten" | grep -v "_Governance" | wc -l | tr -d ' ')
    mem=$(grep -lE "$pattern" "$MEM"/*.md 2>/dev/null | wc -l | tr -d ' ')
    docs=$(grep -rlE "$pattern" "$REPO/docs/" --include='*.md' 2>/dev/null | wc -l | tr -d ' ')
    top=$(grep -lE "$pattern" "$REPO/CLAUDE.md" "$REPO/AGENTS.md" "$REPO/PROJECT.md" "$REPO/GAPS.md" 2>/dev/null | wc -l | tr -d ' ')
    total=$((zk + other + mem + docs + top))
    SSOT_TOTAL=$((SSOT_TOTAL + total))
    echo "| $concept | $zk | $other | $mem | $docs | $top | **$total** |"
  done
  echo ""
  echo "**SSOT 违规总位置数**: $SSOT_TOTAL （目标：主卡建立后每概念 ZK=1, 其他全为引用；违规阈值计算待迁移后定义）"
  echo ""

  # ============================================================================
  #  R02 — YAML 元数据覆盖
  # ============================================================================
  echo "## R02 — YAML 元数据覆盖率"
  echo ""
  total=0; fm=0; has_status=0; has_reviewed=0; has_type=0; has_scope=0
  for f in "$ZK"/*.md "$CONCEPTS"/*.md; do
    [ -f "$f" ] || continue
    total=$((total+1))
    head -1 "$f" | grep -q "^---$" || continue
    fm=$((fm+1))
    head -25 "$f" | grep -q "^status:" && has_status=$((has_status+1))
    head -25 "$f" | grep -q "^last_reviewed:" && has_reviewed=$((has_reviewed+1))
    head -25 "$f" | grep -q "^type:" && has_type=$((has_type+1))
    head -25 "$f" | grep -q "^scope:" && has_scope=$((has_scope+1))
  done
  pct() { [ "$2" -eq 0 ] && echo "0" || echo "$(( 100 * $1 / $2 ))"; }
  echo "| 字段 | 覆盖数 | 覆盖率 | 目标 | 状态 |"
  echo "|---|---|---|---|---|"
  echo "| frontmatter 存在 | $fm / $total | $(pct $fm $total)% | 100% | $([ $fm -eq $total ] && echo "✅" || echo "🔴") |"
  echo "| type | $has_type / $total | $(pct $has_type $total)% | 100% | $([ $has_type -eq $total ] && echo "✅" || echo "🔴") |"
  echo "| status | $has_status / $total | $(pct $has_status $total)% | 100% | $([ $has_status -eq $total ] && echo "✅" || echo "🔴") |"
  echo "| last_reviewed | $has_reviewed / $total | $(pct $has_reviewed $total)% | 100% | $([ $has_reviewed -eq $total ] && echo "✅" || echo "🔴") |"
  echo "| scope | $has_scope / $total | $(pct $has_scope $total)% | 100% | $([ $has_scope -eq $total ] && echo "✅" || echo "🔴") |"
  echo ""

  # ============================================================================
  #  R03 — Memory 瘦身
  # ============================================================================
  echo "## R03 — Memory 瘦身"
  echo ""
  # 按文件名前缀粗扫
  MEM_PROJECT_FILES=$(ls "$MEM"/project_*.md 2>/dev/null | wc -l | tr -d ' ')
  MEM_FEEDBACK=$(ls "$MEM"/feedback_*.md 2>/dev/null | wc -l | tr -d ' ')
  MEM_USER=$(ls "$MEM"/user_*.md 2>/dev/null | wc -l | tr -d ' ')
  MEM_REF=$(ls "$MEM"/reference_*.md 2>/dev/null | wc -l | tr -d ' ')
  MEM_POINTER_PREFIX=$(ls "$MEM"/pointer_*.md 2>/dev/null | wc -l | tr -d ' ')
  # 按 frontmatter type 精扫（v0.2 起更精确）：project_* 文件名但 type:pointer 算 pointer
  MEM_TYPE_POINTER=$(grep -lE '^type:[[:space:]]*pointer$' "$MEM"/*.md 2>/dev/null | wc -l | tr -d ' ')
  MEM_TRUE_PROJECT=0
  for f in "$MEM"/project_*.md; do
    [ -f "$f" ] || continue
    if ! head -10 "$f" | grep -qE '^type:[[:space:]]*pointer$'; then
      MEM_TRUE_PROJECT=$((MEM_TRUE_PROJECT+1))
    fi
  done
  POINTER_TOTAL=$((MEM_POINTER_PREFIX > MEM_TYPE_POINTER ? MEM_POINTER_PREFIX : MEM_TYPE_POINTER))
  echo "| 前缀/类型 | 数量 | 规则 | 状态 |"
  echo "|---|---|---|---|"
  echo "| user_* | $MEM_USER | 允许 | ✅ |"
  echo "| feedback_* | $MEM_FEEDBACK | 允许 | ✅ |"
  echo "| reference_* | $MEM_REF | 允许 | ✅ |"
  echo "| pointer (type 或前缀) | $POINTER_TOTAL | 允许 | ✅ |"
  echo "| **project_* 文件名** | $MEM_PROJECT_FILES | 文件名残留（含 pointer 命名兼容） | ℹ️ |"
  echo "| **真正 project 类领域知识** | **$MEM_TRUE_PROJECT** | **禁止（R03）** | $([ $MEM_TRUE_PROJECT -eq 0 ] && echo "✅" || echo "🔴 BLOCK") |"
  MEM_PROJECT=$MEM_TRUE_PROJECT  # 兼容下方汇总
  echo ""

  # ============================================================================
  #  R04 — 升级队列
  # ============================================================================
  echo "## R04 — 升级队列"
  echo ""
  UPGRADE_CNT=$(grep -rhE "定论|结论|PASS|FAIL|判据|决策" "$LOG_DIR" 2>/dev/null | wc -l | tr -d ' ')
  # 升级候选区（假设以 "升级候选" 或 "# 升级候选" 开头的区块）
  CANDIDATE_CNT=$(grep -rhc "升级候选" "$LOG_DIR" 2>/dev/null | awk -F: '{s+=$1} END {print s+0}')
  echo "| 项 | 值 | 阈值 | 状态 |"
  echo "|---|---|---|---|"
  echo "| 近 N 天 log 中 '定论/PASS/FAIL' 总数 | $UPGRADE_CNT | — | ℹ️ |"
  echo "| log 包含 '升级候选' 区的文件数 | $CANDIDATE_CNT | > 0 | $([ $CANDIDATE_CNT -gt 0 ] && echo "✅" || echo "🟠 WARN") |"
  echo ""

  # ============================================================================
  #  R05 — 孤儿卡
  # ============================================================================
  echo "## R05 — 孤儿卡"
  echo ""
  ORPH=0
  ORPH_LIST=""
  ORPH_DENOM=0
  for f in "$ZK"/*.md "$CONCEPTS"/*.md; do
    [ -f "$f" ] || continue
    name=$(basename "$f" .md)
    [[ "$name" == @* ]] && continue
    ORPH_DENOM=$((ORPH_DENOM+1))
    cnt=$(grep -rlF "[[$name" "$VAULT" --include='*.md' 2>/dev/null | grep -v "$f" | wc -l | tr -d ' ')
    if [ "$cnt" -eq 0 ]; then
      ORPH=$((ORPH+1))
      [ $VERBOSE -eq 1 ] && [ $ORPH -le 25 ] && ORPH_LIST="$ORPH_LIST\n  - $name"
    fi
  done
  ORPH_PCT=$(pct $ORPH $ORPH_DENOM)
  echo "| 项 | 值 | 阈值 | 状态 |"
  echo "|---|---|---|---|"
  echo "| 孤儿卡数 | $ORPH / $ORPH_DENOM | — | — |"
  echo "| 孤儿率 | ${ORPH_PCT}% | < 10% | $([ $ORPH_PCT -lt 10 ] && echo "✅" || echo "🟠 WARN") |"
  if [ $VERBOSE -eq 1 ]; then
    echo ""
    echo "<details><summary>孤儿卡样例（前 25）</summary>"
    echo ""
    echo -e "$ORPH_LIST"
    echo ""
    echo "</details>"
  fi
  echo ""

  # ============================================================================
  #  R06 — 断链
  # ============================================================================
  echo "## R06 — 断链"
  echo ""
  cd "$VAULT"
  all_links=$(grep -rhoE '\[\[[^]]+\]\]' . --include='*.md' 2>/dev/null \
    | sed -E 's/^\[\[//; s/\]\]$//' \
    | sed -E 's/\|.*$//' \
    | sed -E 's/#.*$//' \
    | sort -u)
  total_links=$(echo "$all_links" | grep -cv '^$')
  broken=0
  BROKEN_SAMPLES=""
  while IFS= read -r link; do
    [ -z "$link" ] && continue
    name=$(basename "$link")
    # v0.2: 跳过附件嵌入（IMG/PDF/GIF 等带扩展名的非 .md 链接）
    case "$name" in
      *.gif|*.png|*.jpg|*.jpeg|*.pdf|*.svg|*.webp|*.mp4|*.mov|*.csv|*.xlsx|*.zip)
        continue ;;
    esac
    if ! find . -type f -name "${name}.md" 2>/dev/null | grep -q .; then
      broken=$((broken+1))
      [ $VERBOSE -eq 1 ] && [ $broken -le 15 ] && BROKEN_SAMPLES="$BROKEN_SAMPLES\n  - $link"
    fi
  done <<< "$all_links"
  BROKEN_PCT=$(pct $broken $total_links)
  echo "| 项 | 值 | 阈值 | 状态 |"
  echo "|---|---|---|---|"
  echo "| 独立链接目标数 | $total_links | — | ℹ️ |"
  echo "| 断链数 | $broken | — | — |"
  echo "| 断链率 | ${BROKEN_PCT}% | < 5% | $([ $BROKEN_PCT -lt 5 ] && echo "✅" || ([ $BROKEN_PCT -lt 10 ] && echo "🟡" || echo "🔴")) |"
  if [ $VERBOSE -eq 1 ]; then
    echo ""
    echo "<details><summary>断链样例（前 15）</summary>"
    echo ""
    echo -e "$BROKEN_SAMPLES"
    echo ""
    echo "</details>"
  fi
  echo ""

  # ============================================================================
  #  R07 — Narrative Spine 入 vault
  # ============================================================================
  echo "## R07 — Narrative Spine 入 vault"
  echo ""
  SPINE_VAULT=$(find "$VAULT/02-Projects" -name "冠层反射率*.md" 2>/dev/null | head -1)
  SPINE_MEM=$(ls "$MEM"/project_narrative_spine.md 2>/dev/null)
  if [ -n "$SPINE_VAULT" ]; then
    LEN=$(wc -l < "$SPINE_VAULT" | tr -d ' ')
    echo "- vault 项目主文：**存在** ($SPINE_VAULT, $LEN 行)"
  else
    echo "- vault 项目主文：🔴 **缺失**"
  fi
  if [ -n "$SPINE_MEM" ]; then
    if head -5 "$SPINE_MEM" 2>/dev/null | grep -q "pointer\|POINTER"; then
      echo "- memory 侧：✅ 已改为 pointer"
    else
      echo "- memory 侧：🟠 仍为领域知识正文（违反 R07 + R03）"
    fi
  fi
  echo ""

  # ============================================================================
  #  R08 — 卡片生命周期治理（v0.1.2 引入）
  # ============================================================================
  echo "## R08 — 卡片生命周期治理"
  echo ""

  # ---- 8.a status 分布 ----
  s_seedling=0; s_live=0; s_superseded=0; s_deprecated=0; s_retracted=0; s_archived=0; s_other=0; s_total=0
  for f in "$ZK"/*.md "$CONCEPTS"/*.md; do
    [ -f "$f" ] || continue
    s_total=$((s_total+1))
    st=$(head -25 "$f" | grep -E '^status:' | head -1 | sed -E 's/^status:[[:space:]]*"?([a-z]+)"?.*/\1/')
    case "$st" in
      seedling)   s_seedling=$((s_seedling+1)) ;;
      live)       s_live=$((s_live+1)) ;;
      superseded) s_superseded=$((s_superseded+1)) ;;
      deprecated) s_deprecated=$((s_deprecated+1)) ;;
      retracted)  s_retracted=$((s_retracted+1)) ;;
      archived)   s_archived=$((s_archived+1)) ;;
      *)          s_other=$((s_other+1)) ;;
    esac
  done
  s_dead=$((s_superseded + s_deprecated + s_retracted + s_archived))
  pct_live=$(pct $s_live $s_total)
  pct_seed=$(pct $s_seedling $s_total)
  pct_dead=$(pct $s_dead $s_total)

  echo "### status 分布"
  echo ""
  echo "| 状态 | 数量 | 占比 | 阈值 | 状态 |"
  echo "|---|---|---|---|---|"
  echo "| live | $s_live | ${pct_live}% | ≥ 60% | $([ $pct_live -ge 60 ] && echo "✅" || echo "🟠") |"
  echo "| seedling | $s_seedling | ${pct_seed}% | ≤ 30% | $([ $pct_seed -le 30 ] && echo "✅" || echo "🟠") |"
  echo "| superseded | $s_superseded | — | — | ℹ️ |"
  echo "| deprecated | $s_deprecated | — | — | ℹ️ |"
  echo "| retracted | $s_retracted | — | — | ℹ️ |"
  echo "| archived | $s_archived | — | — | ℹ️ |"
  echo "| 非活跃合计 (superseded+deprecated+retracted+archived) | $s_dead | ${pct_dead}% | ≤ 10% | $([ $pct_dead -le 10 ] && echo "✅" || echo "🟠") |"
  [ $s_other -gt 0 ] && echo "| ⚠️ 其他/未识别 | $s_other | — | 0 | 🔴 |"
  echo ""

  # ---- 8.b retracted banner 合规 ----
  echo "### retracted banner 合规（§8.4）"
  echo ""
  BANNER_BAD=0
  BANNER_LIST=""
  for f in "$ZK"/*.md "$CONCEPTS"/*.md; do
    [ -f "$f" ] || continue
    st=$(head -25 "$f" | grep -E '^status:' | head -1 | sed -E 's/^status:[[:space:]]*"?([a-z]+)"?.*/\1/')
    [ "$st" = "retracted" ] || continue
    # 正文前 15 行（跳过 frontmatter）找 RETRACTED 字样
    body_start=$(grep -n '^---$' "$f" | sed -n '2p' | cut -d: -f1)
    [ -z "$body_start" ] && body_start=1
    if ! sed -n "${body_start},$((body_start+15))p" "$f" | grep -q "RETRACTED"; then
      BANNER_BAD=$((BANNER_BAD+1))
      BANNER_LIST="$BANNER_LIST\n  - $(basename "$f")"
    fi
  done
  if [ $s_retracted -eq 0 ]; then
    echo "- 无 status:retracted 卡；banner 检查 N/A ✅"
  else
    BANNER_OK=$((s_retracted - BANNER_BAD))
    echo "- status:retracted 卡：$s_retracted 张；banner 合规：$BANNER_OK 张；缺 banner：$BANNER_BAD 张 $([ $BANNER_BAD -eq 0 ] && echo "✅" || echo "🔴 BLOCK")"
    if [ $BANNER_BAD -gt 0 ] && [ $VERBOSE -eq 1 ]; then
      echo -e "  缺 banner 列表：$BANNER_LIST"
    fi
  fi
  echo ""

  # ---- 8.c supersedes/superseded_by 双向一致性 ----
  echo "### supersede 双向一致性（§schema/card invariant）"
  echo ""
  SUP_OK=0; SUP_BAD=0; SUP_LIST=""
  # 找所有带 superseded_by 的卡，检查其指向的新卡是否在 supersedes 列表里回指
  for f in "$ZK"/*.md "$CONCEPTS"/*.md; do
    [ -f "$f" ] || continue
    sb=$(head -30 "$f" | grep -E '^superseded_by:' | head -1 | sed -E 's/.*\[\[([^]]+)\]\].*/\1/')
    [ -z "$sb" ] && continue
    [ "$sb" = "$(head -30 "$f" | grep -E '^superseded_by:' | head -1)" ] && continue  # 没匹配到 [[...]]
    old_name=$(basename "$f" .md)
    new_file=$(find "$VAULT" -name "${sb##*/}.md" -type f 2>/dev/null | head -1)
    if [ -z "$new_file" ]; then
      SUP_BAD=$((SUP_BAD+1))
      SUP_LIST="$SUP_LIST\n  - $old_name → 目标 [[$sb]] 不存在"
      continue
    fi
    if head -30 "$new_file" | grep -E '^supersedes:|^\s+-\s+"?\[\[' | grep -q "$old_name"; then
      SUP_OK=$((SUP_OK+1))
    else
      SUP_BAD=$((SUP_BAD+1))
      SUP_LIST="$SUP_LIST\n  - $old_name → 新卡 $(basename "$new_file" .md) 未回指 supersedes"
    fi
  done
  SUP_TOTAL=$((SUP_OK + SUP_BAD))
  if [ $SUP_TOTAL -eq 0 ]; then
    echo "- 无 supersede 对；检查 N/A ✅"
  else
    echo "- supersede 对：$SUP_TOTAL；双向一致：$SUP_OK；不一致：$SUP_BAD $([ $SUP_BAD -eq 0 ] && echo "✅" || echo "🔴 BLOCK")"
    if [ $SUP_BAD -gt 0 ] && [ $VERBOSE -eq 1 ]; then
      echo -e "  不一致列表：$SUP_LIST"
    fi
  fi
  echo ""

  # ---- 8.d authoritative bit 唯一性（对齐 R01 / §8.5）----
  echo "### authoritative bit 唯一性（§8.5）"
  echo ""
  # 对每个 core concept（以 _Concepts 目录中的概念卡为锚），统计全 vault 下 authoritative:true 的重复数
  AUTH_DUP=0
  AUTH_LIST=""
  AUTH_TRUE_TOTAL=$(grep -rlE '^authoritative:[[:space:]]*true' "$VAULT" --include='*.md' 2>/dev/null | wc -l | tr -d ' ')
  # 检测同 canonical_name 下是否多于 1 张
  declare -a CNAMES=()
  while IFS= read -r f; do
    cn=$(head -30 "$f" | grep -E '^canonical_name:' | head -1 | sed -E 's/^canonical_name:[[:space:]]*"?([^"]+)"?.*/\1/')
    [ -z "$cn" ] && cn="(unnamed:$(basename "$f" .md))"
    CNAMES+=("$cn")
  done < <(grep -rlE '^authoritative:[[:space:]]*true' "$VAULT" --include='*.md' 2>/dev/null)
  # 统计重复
  if [ ${#CNAMES[@]} -gt 0 ]; then
    DUP_LINES=$(printf '%s\n' "${CNAMES[@]}" | sort | uniq -d)
    if [ -n "$DUP_LINES" ]; then
      AUTH_DUP=$(echo "$DUP_LINES" | wc -l | tr -d ' ')
      AUTH_LIST=$(echo "$DUP_LINES" | sed 's/^/  - /')
    fi
  fi
  echo "- authoritative:true 卡总数：$AUTH_TRUE_TOTAL"
  echo "- canonical_name 重复（多张 authoritative:true 同名）：$AUTH_DUP $([ $AUTH_DUP -eq 0 ] && echo "✅" || echo "🔴 BLOCK")"
  if [ $AUTH_DUP -gt 0 ]; then
    echo "$AUTH_LIST"
  fi
  echo ""

  # ============================================================================
  #  汇总状态
  # ============================================================================
  echo "---"
  echo ""
  echo "## 🎯 汇总"
  echo ""
  # R08 健康度综合判定：status 分布达标 + banner 合规 + supersede 一致 + authoritative 唯一
  R08_OK=1
  [ $pct_live -lt 60 ] && R08_OK=0
  [ $pct_seed -gt 30 ] && R08_OK=0
  [ $pct_dead -gt 10 ] && R08_OK=0
  [ $BANNER_BAD -gt 0 ] && R08_OK=0
  [ $SUP_BAD -gt 0 ] && R08_OK=0
  [ $AUTH_DUP -gt 0 ] && R08_OK=0
  echo "| 规则 | 状态 |"
  echo "|---|---|"
  echo "| R01 SSOT | SSOT 总占用数 = $SSOT_TOTAL（待主卡建立后基线化） |"
  echo "| R02 YAML 元数据 | status 覆盖 $(pct $has_status $total)% |"
  echo "| R03 Memory 瘦身 | project_* 剩余 $MEM_PROJECT 个 |"
  echo "| R04 升级队列 | 候选区覆盖 log 数 $CANDIDATE_CNT |"
  echo "| R05 孤儿卡率 | ${ORPH_PCT}% |"
  echo "| R06 断链率 | ${BROKEN_PCT}% |"
  echo "| R07 narrative spine | $([ -n "$SPINE_VAULT" ] && echo "✅ 在 vault" || echo "🔴 缺") |"
  echo "| R08 生命周期 | live ${pct_live}% / seedling ${pct_seed}% / 非活跃 ${pct_dead}%；banner 缺 $BANNER_BAD / supersede 不一致 $SUP_BAD / authoritative 重名 $AUTH_DUP $([ $R08_OK -eq 1 ] && echo "✅" || echo "🟠") |"
  echo ""
  echo "_下一步_: 按 \`_Governance/migration_v0.1.md\` Wave 1 开始核心概念主卡建立。"
  echo ""
  echo "---"
  echo "_Generated at $(date '+%Y-%m-%d %H:%M:%S')_"
} > "$TMP"

# ============================================================================
#  输出
# ============================================================================
if [ $SAVE -eq 1 ]; then
  mkdir -p "$OUT_DIR"
  DEST="$OUT_DIR/$TODAY.md"
  cp "$TMP" "$DEST"
  echo "✅ Report saved to: $DEST"
  echo ""
  echo "--- preview ---"
  head -60 "$DEST"
else
  cat "$TMP"
fi
