---

name: harness-review
description: 并行执行多个 Review Skill，全方位检查代码变更

---

# 并行评审

## 用途
读取 OpenSpec 工件和代码变更，并行调用多个 Review Skill 进行全方位检查。

## 使用方式

```
/harness:review <change-id>
```

## 执行流程

### 第一步：读取变更上下文

```
读取 openspec/changes/<change-id>/proposal.md
读取 openspec/changes/<change-id>/design.md
读取 openspec/changes/<change-id>/tasks.md

识别本次改动的文件列表：
  git diff --name-only (如有 git)
  或根据 tasks.md 推断
```

### 第二步：并行执行 Review Skills

```
┌─────────────────────────────────────────────┐
│  并行启动以下 Review Agents/Skills          │
├─────────────────────────────────────────────┤
│  1. superpowers:receive-code-review         │
│     - 主评审：OpenSpec 对齐、范围漂移        │
│                                              │
│  2. prepare-review                           │
│     - 生成评审摘要                           │
│     - 变更影响范围                           │
│                                              │
│  3. python-architecture-review               │
│     - Python 分层检查                        │
│     - 依赖方向检查                           │
│     - 业务逻辑放置检查                       │
│     - 类型注解完整性                         │
│     - 异步/混用检查                          │
│                                              │
│  4. sql-risk-review                          │
│     - ORM/SQL 风险                           │
│     - 批量操作风险                           │
│     - N+1 查询风险                           │
└─────────────────────────────────────────────┘
```

### 第二步附：评审知识捕获

在 Review 过程中，持续关注并捕获**风险点**和**注意事项**：

**捕获类型**：

| 类型 | 示例 | 建议存储位置 |
|------|------|-------------|
| 架构风险 | "在 XXX 场景下直接调用 YYY 会循环导入" | `architecture/index.md` |
| SQL 风险 | "此查询在大数据量下会全表扫描" | `standards/database.md` |
| 接口风险 | "此接口未做幂等，重复调用会出错" | `specs/api.md` |
| 业务风险 | "用户余额扣减存在并发问题" | `product/index.md` |
| 隐性坑点 | "历史数据中 status=None 含义特殊" | `implicit-contracts.md` |

### 第三步：汇总评审结果

```markdown
# 评审报告：<change-id>

## 主评审结果 (superpowers:receive-code-review)
### 严重问题
-
### 警告问题
-

## 架构评审 (python-architecture-review)
### 严重问题
-
### 警告问题
-

## SQL 风险评审 (sql-risk-review)
### 严重问题
-
### 警告问题
-

## 变更摘要 (prepare-review)
- 影响模块：
- 涉及文件：
- 测试情况：

## 综合结论
- [ ] 通过 - 可合并
- [ ] 有条件通过 - 需修复以下问题
- [ ] 不通过 - 需重大修改

## 待解决问题
1.
2.
```

### 第四步：Review Agent 汇总

```
调用 Skill(skills:superpowers:requesting-code-review)
输入：所有 Review 结果
输出：最终评审意见和下一步建议
```

## 与 Superpowers 的关系

- 调用 `superpowers:receive-code-review` 作为主评审
- 调用 `superpowers:requesting-code-review` 汇总结果
- review-skills 中的 Skill 作为专项检查并行执行
