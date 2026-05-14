# 数据库与 ORM 规范

## 基本规则

- **不允许无条件 UPDATE / DELETE**
- 批量更新必须明确 WHERE 条件和影响范围
- 分页查询必须明确排序条件
- 不允许在高频接口中引入明显的 N+1 查询
- 修改 ORM 查询时，必须关注索引命中情况
- 使用 Alembic 管理迁移，每个迁移必须有 upgrade 和 downgrade

## 必须说明的内容

以下场景必须在 design.md 或 review 摘要中说明：

- 是否影响索引
- 是否会放大扫描范围
- 是否会引入锁竞争
- 是否需要数据修复或迁移
- 是否影响历史数据兼容性

## SQLAlchemy 查询规范

### SELECT

```python
# 正确：明确列出需要的字段，使用 2.0 style
result = await session.execute(
    select(User.id, User.name, User.status).where(User.id == user_id)
)

# 错误：无选择性加载
result = await session.execute(select(User))  # 可能加载不需要的关联
```

### UPDATE

```python
# 正确：带有 WHERE 条件
await session.execute(
    update(User).where(User.id == user_id).values(status=1)
)

# 错误：无条件更新
await session.execute(update(User).values(status=1))  # 影响全表
```

### DELETE

```python
# 正确：带有 WHERE 条件
await session.execute(
    delete(User).where(User.id == user_id)
)

# 错误：无条件删除
await session.execute(delete(User))  # 删除全表
```

### 关联查询

```python
# 正确：使用 joinedload / selectinload 避免 N+1
result = await session.execute(
    select(User).options(selectinload(User.orders))
)

# 错误：循环中查询
users = (await session.execute(select(User))).scalars().all()
for user in users:
    orders = (await session.execute(
        select(Order).where(Order.user_id == user.id)
    )).scalars().all()  # N+1
```

## Django ORM 规范

### 查询

```python
# 正确：使用 select_related / prefetch_related
users = User.objects.select_related('profile').prefetch_related('orders').all()

# 错误：循环中查询
users = User.objects.all()
for user in users:
    orders = user.orders.all()  # N+1
```

### 批量操作

```python
# 正确：使用批量操作
User.objects.filter(is_active=False).update(status='archived')

# 错误：循环中逐个更新
for user in User.objects.filter(is_active=False):
    user.status = 'archived'
    user.save()  # N 次查询
```

## Alembic 迁移规范

### 必须包含 upgrade 和 downgrade

```python
def upgrade() -> None:
    op.add_column('user', sa.Column('email', sa.String(255), nullable=True))

def downgrade() -> None:
    op.drop_column('user', 'email')
```

### 破坏性迁移

- 删列前确认无代码引用
- 改类型需提供数据迁移
- 新增 NOT NULL 列需提供默认值或数据迁移

## 高风险目录

- `alembic/versions/`
- `migrations/`（Django）
- 包含原始 SQL 的文件

修改以上目录内容时需额外谨慎。

## 索引设计原则

1. **区分度**高的字段优先
2. **避免**在频繁更新的字段上建索引
3. **复合索引**遵循最左前缀原则
4. **定期**检查慢查询，评估索引有效性
