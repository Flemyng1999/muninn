#!/usr/bin/env python3
"""
backfill_yaml.py — Wave 3 YAML 元数据批量回填

依据 _Governance/migration_v0.1.md Wave 3 规范：为 03-Zettelkasten 下所有未带
`status` / `last_reviewed` / `scope` / `type` 的卡片补齐默认字段，达到 R02
100% 覆盖率目标。

默认 dry-run；加 --apply 才真正写盘。每次执行产出变更日志到
`out/kms_health/backfill_YYYY-MM-DD.log`。

用法:
    python scripts/backfill_yaml.py                # dry-run 预览
    python scripts/backfill_yaml.py --apply        # 真正写盘
    python scripts/backfill_yaml.py --apply --verbose
"""
from __future__ import annotations

import argparse
import datetime as _dt
import os
import re
import sys
from pathlib import Path

VAULT = Path(
    "<VAULT_ABSOLUTE_PATH>"
)
ZK = VAULT / "03-Zettelkasten"
OUT_DIR = Path("<PROJECT_REPO_PATH>/out/kms_health")

TODAY = _dt.date.today().isoformat()

# 文件名前缀 → type 推断
TYPE_BY_PREFIX = {
    "概念-": "concept",
    "洞察-": "insight",
    "踩坑-": "pitfall",
    "经验-": "experience",
    "思考-": "thought",
    "定律-": "law",
    "排版-": "typography",
    "@索引-": "moc",
    "@卡片盒": "moc",
    "@Home": "moc",
}


def infer_type(filename: str) -> str | None:
    for prefix, t in TYPE_BY_PREFIX.items():
        if filename.startswith(prefix):
            return t
    return None


L0_KEYWORDS = (
    # 排版/LaTeX/写作工具
    "booktabs", "tabularx", "上下标", "像素DPI", "函数运算符",
    "单位数字", "图像分辨率", "多字母变量", "微分符号",
    "投稿文件", "浮动体", "Elsevier", "特殊符号",
    # 写作 meta
    "关键词", "摘要-", "数据段", "方法写作", "方法结构",
    "标题-", "Highlight", "引言畏惧", "科研写作",
    "论文审视", "建构效度", "I-O优化",
    # Linux/OS/网络/备份基础设施
    "Linux", "Ubuntu", "Windows", "DNS", "OpenWRT", "GLiNet",
    "rsync", "systemd", "autofs", "TimeMachine", "mnt-系统",
    "Claude Desktop", "WireGuard", "UEFI", "端口", "代理",
    "训练存储",
)

L0_SCIENTIFIC_WRITING_MOCS = ("@索引-科研写作投稿",)


def infer_scope(filename: str) -> str:
    # 无扩展名主体
    base = filename[:-3] if filename.endswith(".md") else filename
    # MOC / governance-level
    if base in ("@Home", "@卡片盒总览"):
        return "global"
    # 科研写作 MOC → L0（工具性知识，跨项目可复用）
    for moc in L0_SCIENTIFIC_WRITING_MOCS:
        if base.startswith(moc):
            return "L0"
    # 排版-* 全 L0
    if base.startswith("排版-"):
        return "L0"
    # 关键词匹配 → L0
    for kw in L0_KEYWORDS:
        if kw in base:
            return "L0"
    # MOC 其他 → global
    if base.startswith("@"):
        return "global"
    # 默认域内
    return "project:<YOUR_PROJECT>"


def split_frontmatter(text: str) -> tuple[dict | None, str, str]:
    """
    Return (fields_dict, raw_frontmatter_block, body).
    fields_dict 是有序的 {key: raw_value_line}；若无 frontmatter 返回 (None, '', text).
    """
    if not text.startswith("---\n"):
        return None, "", text
    end = text.find("\n---\n", 4)
    if end == -1:
        return None, "", text
    fm_block = text[4:end]
    body = text[end + 5:]

    fields: dict[str, str] = {}
    # 逐行解析；支持顶层 `key: value`、多行块（list / nested）原样保留在 raw
    current_key = None
    for line in fm_block.split("\n"):
        m = re.match(r"^([A-Za-z_][A-Za-z0-9_-]*):\s*(.*)$", line)
        if m:
            current_key = m.group(1)
            fields[current_key] = line
        elif current_key is not None:
            # 续行（YAML 列表项 / 多行值）
            fields[current_key] += "\n" + line
    return fields, fm_block, body


def rebuild_frontmatter(fields: dict[str, str]) -> str:
    # 保持原序 + 新增字段（新增字段按 canonical 顺序追加）
    return "---\n" + "\n".join(fields.values()) + "\n---\n"


def needs_backfill(fields: dict[str, str]) -> list[str]:
    missing = []
    for key in ("status", "last_reviewed", "scope", "type"):
        if key not in fields:
            missing.append(key)
    return missing


def backfill(path: Path) -> dict | None:
    """
    Inspect `path`. Return action dict {path, missing, new_frontmatter, changed}
    or None if no frontmatter (skip).
    """
    text = path.read_text(encoding="utf-8")
    fields, _fm_block, body = split_frontmatter(text)
    if fields is None:
        return {
            "path": path,
            "missing": ["<no frontmatter>"],
            "skip_reason": "no frontmatter",
            "changed": False,
        }

    missing = needs_backfill(fields)
    if not missing:
        return {"path": path, "missing": [], "changed": False}

    new_fields = dict(fields)
    fname = path.name

    if "status" in missing:
        new_fields["status"] = 'status: "live"'
    if "last_reviewed" in missing:
        new_fields["last_reviewed"] = f"last_reviewed: {TODAY}"
    if "scope" in missing:
        scope = infer_scope(fname)
        new_fields["scope"] = f'scope: "{scope}"'
    if "type" in missing:
        t = infer_type(fname)
        if t is not None:
            new_fields["type"] = f"type: {t}"
        else:
            missing.remove("type")  # 无法推断则不加

    new_text = rebuild_frontmatter(new_fields) + body
    return {
        "path": path,
        "missing": missing,
        "new_text": new_text,
        "changed": True,
    }


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument(
        "--apply", action="store_true", help="真正写盘（默认只 dry-run）"
    )
    ap.add_argument("--verbose", action="store_true")
    ap.add_argument(
        "--scope-dir",
        default=str(ZK),
        help="扫描目录（默认 03-Zettelkasten/）",
    )
    args = ap.parse_args()

    scope_dir = Path(args.scope_dir)
    if not scope_dir.exists():
        print(f"[error] {scope_dir} not found", file=sys.stderr)
        return 1

    results: list[dict] = []
    for md in sorted(scope_dir.glob("*.md")):
        r = backfill(md)
        if r is None:
            continue
        results.append(r)

    total = len(results)
    changed = [r for r in results if r["changed"]]
    skipped = [r for r in results if not r["changed"] and r.get("skip_reason")]
    already_ok = [
        r for r in results if not r["changed"] and not r.get("skip_reason")
    ]

    print(f"[scan] {total} files in {scope_dir.name}/")
    print(f"  already OK: {len(already_ok)}")
    print(f"  skip (no frontmatter): {len(skipped)}")
    print(f"  need backfill: {len(changed)}")
    print()

    if args.verbose or not args.apply:
        for r in changed:
            name = r["path"].name
            fields = ", ".join(r["missing"])
            print(f"  + {name}  ← +{fields}")

    if not args.apply:
        print()
        print("[dry-run] no files written. rerun with --apply to persist.")
        return 0

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    log_path = OUT_DIR / f"backfill_{TODAY}.log"
    with log_path.open("w", encoding="utf-8") as log:
        log.write(f"# backfill run {TODAY}\n")
        log.write(f"# scope: {scope_dir}\n\n")
        for r in changed:
            r["path"].write_text(r["new_text"], encoding="utf-8")
            log.write(f"{r['path'].name}\t+{','.join(r['missing'])}\n")

    print(f"[apply] wrote {len(changed)} files; log: {log_path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
