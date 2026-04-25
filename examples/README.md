# Examples

三套示例，展示 Muninn 在不同场景下的形态。

| 示例 | 规模 | 展示什么 | 状态 |
|---|---|---|---|
| [`research-full/`](research-full/) | ~15 文件，完整 vault | 研究者典型用法（概念主卡 / Gate 判据 / 实验 / 文献 / Journal / 生命周期治理） | ✅ 完整 |
| [`product-teaser/`](product-teaser/) | 3 文件 | 产品人未来用法预览（决策 ADR / 用户画像 / North Star 指标） | 🟡 teaser |
| [`engineering-teaser/`](engineering-teaser/) | 3 文件 | 工程师未来用法预览（ADR / 故障复盘 / 一致性边界） | 🟡 teaser |

## 推荐阅读顺序

### 研究者

1. 先读 `research-full/README.md` 知道它在展示什么
2. 读 `research-full/02-Projects/城市乌鸦工具使用演化研究.md`（项目叙事骨架）
3. 读 `research-full/_Concepts/概念-社会学习指标.md`（最能体现生命周期治理：v0.1 → v0.2 的 Q3 三要素实例）
4. 读 `research-full/00-Journal/2026-04-18.md`（看 🔴 档实战）

### 产品 / 工程

1. 先读 `product-teaser/README.md` 或 `engineering-teaser/README.md`
2. 读 1 张 ADR 卡和 1 张 主卡，感受"SSOT + 完整决策链"的效果
3. 思考自己工作中反复出现的决策 / 复盘是不是值得这样沉淀

## 重要声明

这些示例**不是可直接运行的 vault**，它们是**只读参考资料**，展示卡片结构 / 双链布局 / frontmatter 字段。

要真正使用 Muninn：

```bash
bash scripts/bootstrap.sh --profile research --out ~/my-vault
# 然后把本 examples 里的卡当模板，改成自己的内容
```

## 关于虚构

三套示例涉及的项目 / 产品 / 服务**全部是虚构的**：
- `urban-crow-toolevo`（虚构的城市乌鸦研究项目）
- `mobile-health-app`（虚构的健康追踪 app）
- `payment-service`（虚构的支付微服务）

真实引用的文献（Taylor 2007, Rutz 2010, St Amant & Horton 2008）是真论文，但对它们的"本项目作用"讨论是为了示例虚构的。
