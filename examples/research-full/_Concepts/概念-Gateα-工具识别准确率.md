---
id: "概念-Gateα-工具识别准确率"
type: concept
status: "live"
authoritative: true
scope: "project:urban-crow-toolevo"
tier: "L2"
created: "2026-02-20"
last_reviewed: "2026-03-25"
gate_name: "gate_alpha_tool_recognition_accuracy"
criterion_version: "1.0"
pass_condition: "视频 pipeline 在验证集（2 只标注员双盲标注 500 片段）的 F1 ≥ 0.85"
fail_fallback: "回到人工复核 + 半自动 pipeline，不阻塞后续 Gate β 推进"
related:
  - "[[概念-工具使用定义]]"
  - "[[03-Zettelkasten/实验-E1-野外工具识别率]]"
source: "本项目 2026-02 Gate α 方案"
tags: [concept, gate, criterion]
---

# 概念-Gateα-工具识别准确率

## 定义

视频标注 pipeline 必须满足：**在两名标注员双盲标注的 500 段视频验证集上**，自动识别"工具使用事件"（按 [[概念-工具使用定义]] 四条件判据）的 **F1 分数 ≥ 0.85**。

## 过线硬条件

- **精确率 (Precision) ≥ 0.80**（避免把非工具行为误判）
- **召回率 (Recall) ≥ 0.80**（避免漏检罕见工具行为）
- **F1 ≥ 0.85**（几何均值约束）
- **两标注员 Cohen's κ ≥ 0.75**（无此则验证集本身不可信）

满足上述四条 → **PASS**。

## 证据汇总

- 2026-03-18 验证集标注完成（n=500，κ = 0.79）
- 2026-03-25 pipeline 冻结版本在验证集：Precision = 0.87, Recall = 0.84, F1 = **0.855**
- 2026-03-25 **Gate α PASS** 宣告（[[_Governance/CHANGELOG]] v0.1.3.2 之前）

详细评估报告：`out/gate_alpha/2026-03-25_validation.md`（项目 repo 侧）

## 为什么这个判据

- F1 单指标易被 P/R 极端比例 game → 加 P ≥ 0.80 + R ≥ 0.80 双闸
- κ 独立闸防止"高分 但评判标准本身乱"
- 0.85 对标业界动物行为识别 SOTA（2024–2025 DeepLabCut + BehaviorAtlas 在类似任务上 F1 ≈ 0.82–0.88）

## 退路 / 失败处置

若 F1 跌破 0.85：
1. **不阻塞 Gate β**：Gate β 用人工标注的高质量子集（n = 200）仍可推进
2. **平行改进 pipeline**：启动 Phase 2 标注器（Transformer-based，备选）
3. **不降阈值**："凑过线"违反本项目不接受的科学实践

## 相关卡片

- [[概念-工具使用定义]] —— 判据的观测对象
- [[03-Zettelkasten/实验-E1-野外工具识别率]] —— 本 Gate 的证据实验
- [[03-Zettelkasten/踩坑-视频标注一致性]] —— 从 κ = 0.62 到 0.79 的过程
