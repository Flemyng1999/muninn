# Research Profile

**适合谁**：博士生 / 科研人员 / 学术工作者。

**沉淀对象**：论文、实验结果、推导、核心概念、Gate 判据。

## 相比 core 多了什么

1. **新工作流**：`工作流-文献沉淀-规范落库`（读完一篇 paper → AI 按模板落到 `01-Literature/`）
2. **新数据目录**：`01-Literature/`（文献卡）
3. **schema 扩展**（`schemas/extensions/`）：
   - `experiment.yaml` —— 实验卡字段
   - `gate.yaml` —— Gate 判据卡字段
4. **专用 project yaml 模板**：含 `core_concepts` / `gate_status` / `core_concepts` 的 L1/L2 分层建议

## 哪些 core 工作流对研究者特别重要

1. `工作流-早间启动-条件Git` —— 多天回来不迷路
2. `工作流-晚间结项-Git闭环` —— 日结 + AI 挑沉淀点
3. `工作流-KMS-卡片起草与维护` —— 起 seedling + 修断链

## 不适合谁

- 纯工程项目（建议 `engineering` profile，WIP）
- 产品 / 设计（建议 `product` profile，WIP）
- 个人生活知识库（太重，用 core 空 profile 就行）

## 安装

```bash
bash scripts/bootstrap.sh --profile research --out ~/my-research-vault
```
