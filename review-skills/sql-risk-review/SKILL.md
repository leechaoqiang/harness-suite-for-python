---

name: sql-risk-review
description: SQL/ORM 风险评审，检查查询安全、性能和数据一致性

---

# SQL / ORM 风险评审

## 用途
检查 Python 项目中的数据库操作是否存在安全风险、性能问题和数据一致性隐患。

## 检查范围

- SQLAlchemy 查询（2.0 style）
- Django ORM 查询
- Alembic 迁移文件
- 原始 SQL 语句

## 检查项

### 1. 安全风险

| 检查项 | 说明 | 严重等级 |
|--------|------|----------|
| SQL 注入 | 使用 f-string / format 拼接 SQL | 严重 |
| 原始 SQL 无参数化 | text() 不使用 bind parameters | 严重 |
| 敏感数据明文 | 密码/密钥未加密存储 | 严重 |

**SQL 注入示例**：

```python
# 严重：SQL 注入风险
session.execute(text(f"SELECT * FROM user WHERE name = '{name}'"))

# 正确：参数化查询
session.execute(text("SELECT * FROM user WHERE name = :name"), {"name": name})
```

### 2. 性能风险

| 检查项 | 说明 | 严重等级 |
|--------|------|----------|
| N+1 查询 | 循环中执行关联查询 | 严重 |
| 全表扫描 | 缺少 WHERE / 索引 | 严重 |
| 无分页限制 | 查询未限制返回数量 | 警告 |
| SELECT * | 查询不需要的字段 | 警告 |
| 缺少索引 | 高频查询字段无索引 | 警告 |

**N+1 查询示例**：

```python
# 严重：N+1 查询
users = session.query(User).all()
for user in users:
    orders = session.query(Order).filter(Order.user_id == user.id).all()

# 正确：使用 joinedload / selectinload
users = session.query(User).options(joinedload(User.orders)).all()
```

**Django N+1 示例**：

```python
# 严重：N+1 查询
users = User.objects.all()
for user in users:
    orders = user.orders.all()

# 正确：使用 prefetch_related / select_related
users = User.objects.prefetch_related('orders').all()
```

### 3. 数据一致性风险

| 检查项 | 说明 | 严重等级 |
|--------|------|----------|
| 无事务保护 | 写操作未包裹在事务中 | 严重 |
| 无条件全表操作 | UPDATE/DELETE 无 WHERE | 严重 |
| 批量操作无范围限制 | 大批量更新/删除 | 严重 |
| 并发更新无锁 | 金额/库存更新未加锁 | 严重 |
| 迁移无 downgrade | Alembic 缺少 downgrade() | 警告 |

**事务保护示例**：

```python
# 严重：无事务保护
user = User(name="test")
session.add(user)
order = Order(user_id=user.id)
session.add(order)
# 如果 order 插入失败，user 已经写入，数据不一致

# 正确：事务保护
async with session.begin():
    user = User(name="test")
    session.add(user)
    await session.flush()
    order = Order(user_id=user.id)
    session.add(order)
```

**并发更新示例**：

```python
# 严重：无锁并发更新
user = await session.get(User, user_id)
user.balance -= amount
await session.commit()

# 正确：使用 select_for_update
async with session.begin():
    user = await session.execute(
        select(User).where(User.id == user_id).with_for_update()
    )
    user.scalar_one().balance -= amount
```

### 4. 迁移风险

| 检查项 | 说明 | 严重等级 |
|--------|------|----------|
| 破坏性迁移 | 删列/改类型无数据迁移 | 严重 |
| 缺少 downgrade | Alembic 缺 downgrade() | 警告 |
| 大表 ALTER | 大表加列/改类型可能导致锁表 | 警告 |
| 数据迁移缺失 | 新增 NOT NULL 列无默认值 | 严重 |

## 输出格式

```markdown
# SQL/ORM 风险评审报告：<change-id>

## 安全风险
### 严重
1. [文件:行号] <描述>

## 性能风险
### 严重
1. [文件:行号] <描述>

## 数据一致性风险
### 严重
1. [文件:行号] <描述>

## 迁移风险
### 严重
1. [文件:行号] <描述>

## 总结
- 严重问题：N 个
- 警告问题：N 个
- 建议项：N 个
```
