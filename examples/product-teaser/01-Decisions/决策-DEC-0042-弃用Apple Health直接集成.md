---
id: "决策-DEC-0042-弃用Apple Health直接集成"
type: decision
status: "live"
authoritative: true
decision_status: "accepted"     # accepted | proposed | superseded | deprecated
scope: "project:mobile-health-app"
tier: "L2"
created: "2026-03-10"
last_reviewed: "2026-04-10"
review_date: "2026-09-10"       # 6 个月后必须复查本决策
supersedes: null
superseded_by: null
related:
  - "[[画像-通勤健身族]]"
  - "[[概念-North Star指标定义]]"
decision_makers:
  - "PM: @alice"
  - "Eng: @bob"
  - "Design: @carol"
tags: [decision, integration, architecture, apple-health]
---

# 决策-DEC-0042：弃用 Apple Health 直接集成，改用中间抽象层

## 语境（Context）

v2.4 上线 Apple Health 深度集成后：
- iOS 用户活跃度 +18%（好）
- 但 Android 用户流失 +7%（不好，感觉被"二等公民化"）
- Apple Health API 2026-02 大改版，打破我们 12 个 endpoint，紧急 hotfix 两周
- 我们核心 [[画像-通勤健身族]] 的 42% 是 Android 用户

## 选项（Options）

### Option A：继续深度依赖 Apple Health + Google Fit 镜像
- 优：开发快
- 缺：每次平台 API 变动都要救火；Android 体验永远落后

### Option B（采纳）：抽象为 HealthDataProvider 接口 + 多 provider 实现
- 优：平台独立；未来加 Fitbit / Garmin 等易；Android / iOS 功能对等
- 缺：前 3 个月慢（接口设计 + 重写）；短期 iOS 用户感知无变化

### Option C：完全自研数据层，不依赖平台
- 优：最大自主性
- 缺：失去平台集成优势（iOS 用户期待 Apple Health 统一视图）
- 成本过高

## 权衡（Tradeoffs）

| 维度 | A | B | C |
|---|---|---|---|
| 短期交付速度 | ⭐⭐⭐ | ⭐⭐ | ⭐ |
| 长期维护成本 | ⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| Android 用户体验 | ⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| 平台变动韧性 | ⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| iOS 用户感知 | ⭐⭐⭐ | ⭐⭐ | ⭐ |

## 决策（Decision）

**采纳 Option B**：抽象为 `HealthDataProvider` 接口层。

## 后果（Consequences）

**预期正向**：
- Q3 交付 Android 等价功能（目标 [[概念-North Star指标定义]] DAU +15%）
- 未来集成 Fitbit / Garmin 成本从 6 周降到 2 周
- 平台 API 变动只改一个 provider，不再全面救火

**预期代价**：
- 接口设计期（Q2 前 6 周）新功能暂停
- 原来紧耦合 Apple Health 的 12 个 feature 需要重写
- 对 [[画像-通勤健身族]] 的 iOS 用户群短期体验无提升

## 度量（成功判据）

- **6 个月后（2026-09-10）review 时检查**：
  - Android 用户流失率是否降到 2025-Q4 的水平以下
  - iOS 用户活跃度是否保持 v2.4 水平
  - Fitbit 集成是否在 2 周内完成（架构假设的验证）

若两项以上未达成 → 考虑 superseded，可能回到 Option A 或探索 Option C。

## 关联

- [[画像-通勤健身族]] —— Android 比例 42% 是本决策的核心驱动数据
- [[概念-North Star指标定义]] —— 决策度量锚定
- （未来）[[决策-DEC-0041-Apple Health 初次集成]] —— 本决策的前一跳，未建

---

## AI 起草痕迹

> 本卡由 `_Skills/02-Workflows/工作流-决策记录-ADR式` 起草（v1，2026-03-10）
> AI 基于 3 次产品会议录音转写 + Slack 讨论归档
> Arbiter 审阅：@alice 2026-03-10（把 Option B 的"3 个月"改为"6 周"）
> 再审阅：@alice 2026-04-10（月度 review，状态保持 accepted）
