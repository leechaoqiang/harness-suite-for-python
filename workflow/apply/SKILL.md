---

name: harness-apply
description: 执行实现，读取 tasks.md，调用 superpowers:implementing-plans

---

# 执行实现

## 用途
读取 tasks.md，按里程碑执行实现，调用 `superpowers:implementing-plans`。

## 使用方式

```
/harness:apply <change-id>
```

## 执行流程

### 第一步：前置检查

```
检查 openspec/changes/<change-id>/tasks.md 是否存在
  └─ 若不存在 → 提示先执行 /harness:plan
```

### 第二步：读取 OpenSpec 工件

```
读取 openspec/changes/<change-id>/proposal.md
读取 openspec/changes/<change-id>/design.md
读取 openspec/changes/<change-id>/tasks.md
```

### 第三步：执行实现

```
调用 Skill(skills:superpowers:executing-plans)
输入：design.md + tasks.md
执行模式：按里程碑顺序执行
```

**执行过程中**：
- 每个 Milestone 完成后提示
- 遇到阻塞时停止，等待用户决策
- 不允许超出 tasks.md 范围自行扩需求
- 遵循 CLAUDE.md 中的代码风格规范

### 第三步附：知识捕获（执行中）

在实现过程中，持续关注并捕获**隐性知识**：

**捕获触发条件**：

| 场景 | 示例 | 建议存储位置 |
|------|------|-------------|
| 发现前后端隐性约定 | "前端依赖 status=None 表示未初始化" | `implicit-contracts.md` |
| 发现架构坑点 | "XXX 模块不能直接调用 YYY" | `architecture/index.md` |
| 发现接口规范 | "某接口返回必须包含 XXX" | `specs/api.md` |
| 发现 ORM/SQL 规范 | "某场景必须使用 select_for_update" | `standards/database.md` |
| 发现业务规则 | "用户删除后数据需保留 30 天" | `product/index.md` |

**捕获交互**：

```
[检测到潜在知识]

发现：XXX
来源：<文件:行号>
建议添加到：docs/architecture/implicit-contracts.md

  [是] 添加到文档
  [编辑] 编辑后添加
  [跳过] 忽略
  [后续] 暂存，后续一起处理
```

**捕获时机**：
- 首次发现新知识点时立即询问
- 每个 Milestone 完成后汇总询问
- 整体完成后回顾询问

### 第四步：里程碑检查

每个 Milestone 完成后：

```
[Milestone X 完成]
检查项：
  □ ruff format + ruff check 通过
  □ mypy 类型检查通过
  □ 相关 pytest 测试通过
  □ 代码符合 CLAUDE.md 规约

发现的新知识点：
  □ 暂无
  □ 有 N 个待处理（查看详情）

是否继续下一个 Milestone？
```

### 第五步：完成后输出摘要

```markdown
# 实现完成：<change-id>

## 改动摘要
- 改动文件：
- 新增文件：
- 删除文件：

## 测试情况
- 单元测试：
- 集成测试：
- 类型检查：
- 代码风格：

## 知识捕获
- 新增知识条目：N 条
- 待处理：M 条

## 风险说明
- 已识别风险：
- 未解决风险：

## 下一步
/harness:review <change-id> - 进行评审
```

## 与 Superpowers 的关系

- 调用 `superpowers:executing-plans` 执行实现
- 每个里程碑完成后调用 `superpowers:verification-before-completion` 验证
- 严格遵循 tasks.md 范围，不自行扩需求
