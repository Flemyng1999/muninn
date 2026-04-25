---
id: "ADR-0017-从Kafka迁至Pulsar"
type: adr
adr_number: 17
status: "live"
authoritative: true
adr_status: "accepted"          # proposed | accepted | superseded | deprecated
scope: "project:payment-service"
tier: "L2"
created: "2026-01-20"
last_reviewed: "2026-04-05"
supersedes: null
superseded_by: null
deciders:
  - "Tech Lead: @alice"
  - "SRE: @bob"
  - "Arch: @carol"
related:
  - "[[概念-最终一致性边界]]"
tags: [adr, messaging, architecture, kafka, pulsar]
---

# ADR-0017：从 Kafka 迁至 Pulsar

## 语境（Context）

`payment-service` 自 2022 起使用 Kafka 作消息总线。2025-Q4 起遇到：

- **多租户难**：单个租户爆发流量影响其他租户（Kafka 无原生多租户隔离）
- **长期积压**：某些对账流需保留 90 天消息，Kafka 配置下运维成本高
- **跨地域复制**：MirrorMaker 2 运维痛点多；灾备切换 RTO > 30 min
- **2026-Q2 要支持**：美国 + 欧洲 + 亚太三地域强一致写（监管要求），Kafka 架构下需要大量自研

评估期（2025-11 ~ 2026-01）评估了 Pulsar / NATS JetStream / Redis Streams 三个候选。

## 考虑过的方案（Options Considered）

### Option A：保留 Kafka + 自研多租户层
- 优：团队熟，少学习成本
- 缺：多租户隔离要自己做（估 3–4 人月）；跨地域问题依旧

### Option B（采纳）：迁移至 Apache Pulsar
- 优：原生多租户；分层存储（BookKeeper + 对象存储）解决长期积压；Geo-Replication 原生支持
- 缺：团队学习成本 + 工具链迁移（监控 / 客户端库）；生态不如 Kafka 成熟

### Option C：NATS JetStream
- 优：轻；延迟低
- 缺：长期保留 + 多地域强一致不如 Pulsar；不适合我们规模

## 决策（Decision）

**采纳 Option B**：迁移至 Apache Pulsar 4.x。迁移窗口 2026-Q1 – Q2。

## 后果（Consequences）

**正向**：
- 多租户隔离解决（每租户独立 namespace）
- 2026-Q2 跨地域合规要求有了原生支持
- 长期积压存储成本预期下降 40%（S3 冷存储分层）

**代价**：
- 迁移期间 2–3 个月双运维（Kafka + Pulsar 并行）
- Runbook / 监控 / 告警全部要重写
- 客户端库 breaking change（`@InjectedProducer` 注解需重构）

**风险**：
- Pulsar 4.x 刚发布（2026-Q1），企业级 bug 风险
- 我们对 BookKeeper 运维经验几乎为零

## 度量（成功判据）

迁移完成（预计 2026-Q2 末）+ 3 个月后（2026-Q3 末）review：
- 多租户事故从 Q1 的 3 次降到 0
- 跨地域灾备 RTO < 5 min（Q1 是 30+ min）
- 长期积压存储月账单降至当前 60% 以下

若未达成 → 考虑回迁（但 3 个月对比期已足够；回迁成本 > 继续调优）。

## 实施

- 2026-01：评估 + ADR 起草
- 2026-02：POC（单一低流量租户试点）
- 2026-03：核心支付流并行双写 + 一致性验证
- 2026-04：生产切流（50% 先切）
- 2026-05：100% 切流 + Kafka 下线
- 2026-06 ~ 2026-09：观察 + 调优

## 这个决策怎么影响核心概念

本决策**不改变** [[概念-最终一致性边界]]，但**收紧了可行性**：
- 之前 Kafka 下"跨地域强一致"只能自研，本项目选择在"订单创建"放宽到最终一致性（用户可接受 2s 延迟）
- Pulsar 原生支持强一致跨地域写 → 未来可以重新评估"订单创建"是否升级到 strong，但**不在本 ADR 范围内**（另起 ADR-0018）

## 关联

- [[概念-最终一致性边界]] —— 被本决策间接影响的主卡
- （未来）[[ADR-0018-订单创建一致性重评估]] —— 本决策的下一跳

---

## AI 起草痕迹

> 本 ADR 由 `_Skills/02-Workflows/工作流-ADR起草-规范落库` 起草（v1 概念模型，2026-01-20）
> AI 输入：2026-01 评估期 4 次架构会议录音 + 3 个 POC 笔记
> Arbiter 审阅：@alice + @bob 2026-01-22（改了 "Pulsar 4.x 成熟度" 风险描述）
> 月度 review：2026-04-05 状态维持 accepted
