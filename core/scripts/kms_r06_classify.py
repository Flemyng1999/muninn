#!/usr/bin/env python3
"""
kms_r06_classify.py — R06 断链分类统计（profile-driven）

扫描 vault 所有 .md 文件，对每条 `[[link]]` 记录 (source, target) pair；
判断断链后按规则分类，输出 raw / actionable 双指标 + 分类明细。

完全由 project profile（_Governance/project_<id>.yaml）驱动；本脚本不写死项目名 /
路径 / 阈值。Schema 见 _Governance/schemas/project_profile.yaml v1.0。

用法:
    python scripts/kms_r06_classify.py --profile <path/to/project_<id>.yaml>
    python scripts/kms_r06_classify.py --save                              # 保存 markdown
    python scripts/kms_r06_classify.py --json out/r06.json                 # 机读 JSON
    python scripts/kms_r06_classify.py --window-days 60                    # 覆盖 historical 窗口
    python scripts/kms_r06_classify.py --verbose                           # 展开各类样例

Profile 解析顺序（首个命中即用）:
    1. --profile CLI
    2. KMS_PROJECT_PROFILE 环境变量
    3. 错误退出（profile 是必需输入）

Vault 派生:
    1. profile.meta.vault_path（schema 约定 absolute path）
    2. profile_path.parent.parent（fallback：profile 在 <VAULT>/_Governance/ 下）

链接规范化（normalize_link）:
    - 去 alias `|alias` / anchor `#sec`
    - 去 markdown 转义残留尾部反斜杠
    - 去尾部 `.md`（Obsidian wikilink stem 基）
    - 取 basename

分类规则（按优先级匹配，首个命中即止）:
    schema-placeholder   target 在 health.r06.schema_placeholders 列表
    wish-link            target 已登记 _Governance/todo_wish_cards.md
    doc-placeholder      target 含 health.r06.doc_placeholder_keywords 任一关键字
    section-title        target 数字开头（章节标题写错为 wikilink）
    governance-example   source 在 health.r06.governance_roots 任一根下
    skills-template      source 在 health.r06.template_roots 任一根下
    historical-journal   source 在 health.r06.journal_roots 任一根下且日期超 window
    skills-active        source 在 health.r06.skills_roots 任一根下（非 template）
    active-broken        其他

Actionable categories: 由 health.r06.actionable_categories 决定（schema 默认含
active-broken / skills-active / section-title）。

依赖：仅 stdlib（PyYAML 可选，缺失时用最小内置 YAML 读取）。
"""
from __future__ import annotations

import argparse
import datetime as _dt
import json
import os
import re
import sys
from pathlib import Path
from typing import Any


# ============================================================================
#  Profile 加载（带 PyYAML fallback）
# ============================================================================

def _load_yaml(path: Path) -> dict:
    """优先 PyYAML，缺失时用极简 fallback（只支持 schema v1 必要的扁平+列表结构）。"""
    text = path.read_text(encoding="utf-8")
    try:
        import yaml  # type: ignore
        return yaml.safe_load(text) or {}
    except ImportError:
        return _minimal_yaml(text)


def _minimal_yaml(text: str) -> dict:
    """
    极简 YAML：支持本 schema 用到的结构（嵌套 dict / dict-of-list / list-of-dict / 标量）。
    不支持：anchors / 多文档 / 复杂 string 引用。仅作 PyYAML 缺失 fallback。
    """
    import yaml  # 兜底再尝试一次
    return yaml.safe_load(text) or {}


def load_profile(profile_path: Path) -> dict:
    if not profile_path.exists():
        sys.exit(f"❌ profile 不存在：{profile_path}")
    return _load_yaml(profile_path)


def resolve_vault(profile: dict, profile_path: Path) -> Path:
    meta = profile.get("meta", {}) or {}
    vault_str = meta.get("vault_path")
    if vault_str:
        p = Path(str(vault_str)).expanduser()
        if p.exists():
            return p
    # Fallback: profile 在 <VAULT>/_Governance/ 下
    candidate = profile_path.parent.parent
    if candidate.exists():
        return candidate
    sys.exit(f"❌ 无法定位 vault（meta.vault_path={vault_str}, fallback={candidate}）")


# ============================================================================
#  默认值（schema v1.0 health.r06.* 字段的默认）
# ============================================================================

DEFAULT_R06 = {
    "historical_window_days": 30,
    "governance_roots": ["_Governance"],
    "template_roots": ["_Skills/90-Templates"],
    "skills_roots": ["_Skills"],
    "journal_roots": ["00-Journal"],
    "schema_placeholders": [
        "g", "link", "master_card", "target_card_name", "concept",
        "新", "旧", "本项目名称", "...",
    ],
    "doc_placeholder_keywords": [
        "对应的", "某个", "你的项目", "your_project",
        "xxx", "yyy", "zzz", "todo",
    ],
    "actionable_categories": ["active-broken", "skills-active", "section-title"],
    "attachment_extensions": [
        ".gif", ".png", ".jpg", ".jpeg", ".pdf", ".svg", ".webp",
        ".mp4", ".mov", ".csv", ".xlsx", ".zip",
    ],
    "actionable_threshold": 5.0,
}


def merge_r06_config(profile: dict, cli_window: int | None) -> dict:
    cfg = dict(DEFAULT_R06)
    user = ((profile.get("health") or {}).get("r06") or {})
    for k, v in user.items():
        if v is not None:
            cfg[k] = v
    if cli_window is not None:
        cfg["historical_window_days"] = cli_window
    # 标准化 path roots（去尾部斜杠）
    for root_key in ("governance_roots", "template_roots", "skills_roots", "journal_roots"):
        cfg[root_key] = [r.strip("/") for r in cfg[root_key]]
    return cfg


# ============================================================================
#  扫描 + 链接规范化
# ============================================================================

WIKILINK_RE = re.compile(r"\[\[([^\]]+)\]\]")


def normalize_link(raw: str) -> str:
    s = raw.split("|", 1)[0]
    s = s.split("#", 1)[0]
    s = s.strip()
    while s.endswith("\\"):
        s = s[:-1].rstrip()
    base = s.split("/")[-1]
    if base.lower().endswith(".md"):
        base = base[:-3]
    return base


def is_attachment(target: str, attachment_exts: list[str]) -> bool:
    base = target.split("/")[-1]
    ext = Path(base).suffix.lower()
    return ext in attachment_exts


def scan_vault(vault: Path, attachment_exts: list[str]) -> tuple[set[str], list[tuple[Path, str]]]:
    """返回 (existing_card_stems, all_link_pairs)"""
    existing: set[str] = set()
    pairs: list[tuple[Path, str]] = []
    for md in vault.rglob("*.md"):
        if ".git" in md.parts or ".obsidian" in md.parts:
            continue
        existing.add(md.stem)
    for md in vault.rglob("*.md"):
        if ".git" in md.parts or ".obsidian" in md.parts:
            continue
        try:
            text = md.read_text(encoding="utf-8", errors="ignore")
        except Exception:
            continue
        for match in WIKILINK_RE.finditer(text):
            raw = match.group(1)
            if not raw:
                continue
            target = normalize_link(raw)
            if not target or is_attachment(target, attachment_exts):
                continue
            pairs.append((md, target))
    return existing, pairs


def load_wish_targets(vault: Path) -> set[str]:
    wish_file = vault / "_Governance" / "todo_wish_cards.md"
    if not wish_file.exists():
        return set()
    text = wish_file.read_text(encoding="utf-8", errors="ignore")
    targets: set[str] = set()
    for match in WIKILINK_RE.finditer(text):
        targets.add(normalize_link(match.group(1)))
    for match in re.finditer(r"`([^`]+)`", text):
        name = match.group(1).strip()
        if "/" in name or name.endswith(".md"):
            targets.add(Path(name).stem)
    return targets


# ============================================================================
#  分类
# ============================================================================

def is_doc_placeholder(target: str, keywords: list[str]) -> bool:
    if not target:
        return False
    low = target.lower()
    return any(kw.lower() in low for kw in keywords)


def is_section_title(target: str) -> bool:
    return bool(target) and target[0].isdigit()


def starts_with_any(rel: Path, roots: list[str]) -> bool:
    rel_str = str(rel).replace(os.sep, "/")
    return any(rel_str == r or rel_str.startswith(r + "/") for r in roots)


def parse_journal_date(filename: str) -> _dt.date | None:
    m = re.search(r"(\d{4}-\d{2}-\d{2})", filename)
    if not m:
        return None
    try:
        return _dt.date.fromisoformat(m.group(1))
    except ValueError:
        return None


def classify(
    source: Path,
    target: str,
    vault: Path,
    wish_targets: set[str],
    cfg: dict,
    today: _dt.date,
) -> str:
    rel = source.relative_to(vault)

    # 1. Schema placeholder
    if target.startswith("<") and target.endswith(">"):
        return "schema-placeholder"
    if target in cfg["schema_placeholders"]:
        return "schema-placeholder"

    # 2. Wish link
    if target in wish_targets:
        return "wish-link"

    # 3. Doc placeholder
    if is_doc_placeholder(target, cfg["doc_placeholder_keywords"]):
        return "doc-placeholder"

    # 4. Section title
    if is_section_title(target):
        return "section-title"

    # 5. Governance
    if starts_with_any(rel, cfg["governance_roots"]):
        return "governance-example"

    # 6. Skills templates（在 skills 之前判，否则被 skills_roots 吃掉）
    if starts_with_any(rel, cfg["template_roots"]):
        return "skills-template"

    # 7. Skills active
    if starts_with_any(rel, cfg["skills_roots"]):
        return "skills-active"

    # 8. Historical journal
    if starts_with_any(rel, cfg["journal_roots"]):
        date = parse_journal_date(rel.name)
        if date and (today - date).days > cfg["historical_window_days"]:
            return "historical-journal"

    return "active-broken"


# ============================================================================
#  输出
# ============================================================================

ALL_CATEGORIES = [
    "active-broken", "skills-active", "section-title",
    "historical-journal", "governance-example", "skills-template",
    "doc-placeholder", "schema-placeholder", "wish-link",
]

CATEGORY_DISPOSITION = {
    "active-broken": "✅ 本周修",
    "skills-active": "✅ 本周修（_Skills 非模板）",
    "section-title": "✅ 批量改：`[[X]]` → `` `X` ``",
    "historical-journal": "❄️ append-only，不改",
    "governance-example": "📐 Arbiter 专属",
    "skills-template": "📐 模板占位",
    "doc-placeholder": "📐 文档描述占位（非真链）",
    "schema-placeholder": "📐 schema 字段",
    "wish-link": "📝 已登记 todo_wish_cards",
}


def build_report(
    total_pairs: int,
    broken: list[tuple[Path, str, str]],
    vault: Path,
    cfg: dict,
    verbose: bool,
    today: _dt.date,
) -> str:
    by_cat: dict[str, list[tuple[Path, str]]] = {c: [] for c in ALL_CATEGORIES}
    for src, tgt, cat in broken:
        by_cat.setdefault(cat, []).append((src, tgt))

    actionable_cats = set(cfg["actionable_categories"])
    total_broken = len(broken)
    actionable = sum(len(by_cat.get(c, [])) for c in actionable_cats)

    def pct(n: int, d: int) -> float:
        return (100.0 * n / d) if d > 0 else 0.0

    raw_pct = pct(total_broken, total_pairs)
    action_pct = pct(actionable, total_pairs)
    threshold = cfg["actionable_threshold"]
    status = "✅" if action_pct < threshold else ("🟡" if action_pct < threshold * 2 else "🔴")

    lines = [
        f"# R06 断链分类报告 ({today.isoformat()})",
        "",
        f"- **Vault**: `{vault}`",
        f"- **Total wikilink pairs**: {total_pairs}",
        f"- **Total broken pairs**: {total_broken}",
        "",
        "## 指标",
        "",
        "| 指标 | 值 | 阈值 | 状态 |",
        "|---|---|---|---|",
        f"| **R06-actionable**（可治理）| {actionable}/{total_pairs} = **{action_pct:.1f}%** | < {threshold:.0f}% | {status} |",
        f"| R06-raw（含历史/模板/schema）| {total_broken}/{total_pairs} = {raw_pct:.1f}% | — | ℹ️ |",
        "",
        "## 分类明细",
        "",
        "| 类别 | 数 | actionable | 处置 |",
        "|---|---|---|---|",
    ]
    for cat in ALL_CATEGORIES:
        n = len(by_cat.get(cat, []))
        is_act = "✅" if cat in actionable_cats else ""
        marker = "**" if cat in actionable_cats and n > 0 else ""
        lines.append(f"| {marker}{cat}{marker} | {n} | {is_act} | {CATEGORY_DISPOSITION[cat]} |")
    lines.append("")

    if verbose:
        lines.extend(["## 详情", ""])
        for cat in ALL_CATEGORIES:
            items = by_cat.get(cat, [])
            if not items:
                continue
            n_show = len(items) if cat in actionable_cats else min(3, len(items))
            lines.append(f"### {cat} ({len(items)})")
            lines.append("")
            for src, tgt in items[:n_show]:
                rel_src = src.relative_to(vault)
                lines.append(f"- `{rel_src}` → [[{tgt}]]")
            if len(items) > n_show:
                lines.append(f"- _...(另有 {len(items) - n_show} 条)_")
            lines.append("")
    return "\n".join(lines) + "\n"


def build_json(
    total_pairs: int,
    broken: list[tuple[Path, str, str]],
    vault: Path,
    cfg: dict,
    today: _dt.date,
) -> dict:
    by_cat: dict[str, list[dict]] = {}
    for src, tgt, cat in broken:
        by_cat.setdefault(cat, []).append({
            "source": str(src.relative_to(vault)),
            "target": tgt,
        })
    actionable_cats = set(cfg["actionable_categories"])
    total_broken = len(broken)
    actionable = sum(len(by_cat.get(c, [])) for c in actionable_cats)
    return {
        "schema_version": 1,
        "scan_date": today.isoformat(),
        "vault": str(vault),
        "total_pairs": total_pairs,
        "total_broken": total_broken,
        "actionable_broken": actionable,
        "raw_rate": (100.0 * total_broken / total_pairs) if total_pairs else 0.0,
        "actionable_rate": (100.0 * actionable / total_pairs) if total_pairs else 0.0,
        "actionable_categories": list(actionable_cats),
        "category_counts": {c: len(by_cat.get(c, [])) for c in ALL_CATEGORIES},
        "by_category": by_cat,
    }


# ============================================================================
#  Main
# ============================================================================

def resolve_profile_path(cli_profile: Path | None) -> Path:
    if cli_profile:
        return cli_profile.expanduser()
    env = os.environ.get("KMS_PROJECT_PROFILE", "").strip()
    if env:
        return Path(env).expanduser()
    sys.exit(
        "❌ 缺少 project profile。请设置 KMS_PROJECT_PROFILE 环境变量\n"
        "   或传 --profile <path/to/project_<id>.yaml>"
    )


def main() -> int:
    ap = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    ap.add_argument("--profile", type=Path, help="project_<id>.yaml 路径")
    ap.add_argument("--window-days", type=int, default=None, help="覆盖 historical-journal 窗口")
    ap.add_argument("--save", action="store_true", help="保存 markdown 到 <repo>/out/kms_health/r06_<date>.md")
    ap.add_argument("--json", type=Path, default=None, help="额外输出 JSON 到指定路径")
    ap.add_argument("--verbose", action="store_true", help="展开 actionable 全条 + 其他类样例 3")
    args = ap.parse_args()

    profile_path = resolve_profile_path(args.profile)
    profile = load_profile(profile_path)
    vault = resolve_vault(profile, profile_path)
    cfg = merge_r06_config(profile, args.window_days)

    print(f"📂 vault:   {vault}", file=sys.stderr)
    print(f"📄 profile: {profile_path}", file=sys.stderr)

    today = _dt.date.today()
    existing, pairs = scan_vault(vault, cfg["attachment_extensions"])
    wish_targets = load_wish_targets(vault)
    broken: list[tuple[Path, str, str]] = []
    for source, target in pairs:
        if target not in existing:
            cat = classify(source, target, vault, wish_targets, cfg, today)
            broken.append((source, target, cat))

    report = build_report(len(pairs), broken, vault, cfg, args.verbose, today)
    sys.stdout.write(report)

    if args.save:
        repo = (profile.get("meta") or {}).get("repo_path") or os.getcwd()
        out_dir = Path(str(repo)).expanduser() / "out" / "kms_health"
        out_dir.mkdir(parents=True, exist_ok=True)
        out_file = out_dir / f"r06_{today.isoformat()}.md"
        out_file.write_text(report, encoding="utf-8")
        print(f"✅ 报告保存到 {out_file}", file=sys.stderr)

    if args.json:
        args.json.parent.mkdir(parents=True, exist_ok=True)
        data = build_json(len(pairs), broken, vault, cfg, today)
        args.json.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
        print(f"✅ JSON 保存到 {args.json}", file=sys.stderr)

    return 0


if __name__ == "__main__":
    sys.exit(main())
