---

name: harness-propose
description: 创建新需求，生成 proposal.md 模板

---

# 创建新需求

## 用途
在 `openspec/changes/<change-id>/` 下创建标准化需求文档。

## 使用方式

```
/harness:propose <需求名称>
```

## 执行流程

### 第一步：生成 Change ID

```
change-id = <需求名称>-<日期>-<序号>
例：user-login-20260513-01
```

### 第二步：创建目录结构

```
openspec/changes/<change-id>/
├─ proposal.md
└─ archive/
```

### 第三步：生成 proposal.md 模板

```markdown
---
name: <change-id>
created: <当前日期>
status: draft
---

# 需求提案：<需求名称>

## 背景
<!-- 描述业务背景和解决的问题 -->

## 目标
<!-- 明确本次需求要达成什么 -->

## 非目标
<!-- 明确本次不包含的范围 -->

## 利益相关方
<!-- 谁会受影响 -->

## 验收标准
1.
2.
3.

## 备注
<!-- 附件、链接等 -->
```

### 第四步：提示下一步

```
需求提案已创建：openspec/changes/<change-id>/proposal.md

下一步：使用 /harness:plan <change-id> 进行战略设计和任务分解
```

## 与 Superpowers 的关系

此 skill 仅负责需求提案创建。设计阶段请使用 `/harness:plan` 调用 `superpowers:brainstorming` 进行深入探索。
