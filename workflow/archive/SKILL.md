---

name: harness-archive
description: 归档完成的 change，将变更记录移入 archive 目录

---

# 归档变更

## 用途
将完成的 change 工件归档到 archive 目录，保持 openspec 工作区整洁。

## 使用方式

```
/harness:archive <change-id>
```

## 执行流程

### 第一步：前置检查

```
检查 openspec/changes/<change-id>/ 是否存在
检查是否为已完成状态（Review 通过）

若 Review 未通过 → 提示需先完成评审
```

### 第二步：生成归档记录

```markdown
# <change-id> - 归档记录

## 基本信息
- change-id: <change-id>
- 创建时间：
- 完成时间：
- 归档时间：

## 需求摘要
<!-- 来自 proposal.md -->

## 技术方案摘要
<!-- 来自 design.md -->

## 实现摘要
<!-- 来自 apply 阶段的摘要 -->

## 评审结论
<!-- 来自 review 阶段的综合结论 -->

## 变更文件清单
<!-- 列出所有改动的文件 -->
```

### 第三步：归档操作

```
源：openspec/changes/<change-id>/
目标：openspec/changes/archive/<change-id>-<timestamp>/

移动内容：
  ├─ proposal.md
  ├─ design.md
  ├─ tasks.md
  └─ <归档记录>.md
```

### 第四步：更新 archive 索引

```
openspec/changes/archive/index.md（如不存在则创建）
追加归档记录索引
```

### 第五步：确认

```markdown
归档完成！

归档位置：openspec/changes/archive/<change-id>-<timestamp>/
工作区状态：openspec/changes/<change-id>/ 已清理

当前 OpenSpec 工作区状态：
  - 进行中：<其他进行中的 change 数量>
  - 已归档：<归档总数>

可开始新需求：/harness:propose <需求名称>
```
