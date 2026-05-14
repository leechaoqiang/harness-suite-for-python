---

name: harness-plan
description: 战略设计 + 任务分解，调用 brainstorming 生成 design.md 和 tasks.md

---

# 战略设计与任务分解

## 用途
读取 proposal.md，调用 `superpowers:brainstorming` 进行战略设计，输出 design.md 和 tasks.md。

## 使用方式

```
/harness:plan <change-id>
```

## 执行流程

### 第一步：前置检查

```
检查 openspec/changes/<change-id>/proposal.md 是否存在
  └─ 若不存在 → 提示先执行 /harness:propose
```

### 第二步：读取需求上下文

```
读取 proposal.md 内容
读取 docs/architecture/index.md（如存在）
读取 docs/product/index.md（如存在）
读取 docs/architecture/implicit-contracts.md（如存在）
```

### 第三步：调用 Brainstorming

```
调用 Skill(skills:superpowers:brainstorming)
输入：proposal.md 内容 + 项目上下文
输出：设计决策 + 任务列表
```

**Brainstorming 重点探索**：
- 实现方案选择（权衡点）
- 影响范围评估
- 风险识别
- 任务拆分粒度
- Python 特有考量（异步/同步选择、ORM 选型、依赖管理）

### 第四步：生成 design.md

```markdown
---
name: <change-id>
status: designed
---

# 技术方案：<change-id>

## 方案概述
<!-- 高层设计方案 -->

## 详细设计

### 架构变更
<!-- 涉及哪些模块、类 -->

### 数据模型变更
<!-- 如有数据库变更，包括 Alembic 迁移 -->

### 接口变更
<!-- 如有 API 变更 -->

### 类型设计
<!-- 新增/修改的类型定义 -->

## 影响范围
- 受影响模块：
- 受保护路径变更：
- 向后兼容性：

## 风险评估
| 风险 | 等级 | 缓解方案 |
|------|------|----------|
|      |      |          |

## 事务与数据
- 事务边界：
- 数据迁移：
- 回滚方案：

## 测试策略
<!-- 如何验证本次变更 -->

## 依赖变更
<!-- 新增 pip 依赖需说明理由 -->
```

### 第五步：生成 tasks.md

```markdown
---
name: <change-id>
status: planned
---

# 执行任务：<change-id>

## 任务列表

### Milestone 1：<里程碑名称>
- [ ] Task 1.1：<任务描述>
- [ ] Task 1.2：<任务描述>

### Milestone 2：<里程碑名称>
- [ ] Task 2.1：<任务描述>

## 验收检查点
- [ ] ruff 检查通过
- [ ] mypy 类型检查通过
- [ ] pytest 测试通过
- [ ] Review 通过

## 下一步
执行 /harness:apply <change-id>
```

## 与 Superpowers 的关系

- 调用 `superpowers:brainstorming` 进行深度设计探索
- 生成的文件格式兼容 `superpowers:implementing-plans` 的输入要求
