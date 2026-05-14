---

name: python-architecture-review
description: Python 架构评审，检查分层架构、类型安全、异步规范

---

# Python 架构评审

## 用途
检查 Python 代码是否遵循分层架构规则、类型安全规范和异步编程规范。

## 检查项

### 1. 分层架构检查

**FastAPI 项目**：
```
Router → Service → Repository → Model
   │         │          │         │
   │         │          │         └─ SQLAlchemy Model / Django Model
   │         │          └─ 数据访问封装层
   │         └─ 业务逻辑层
   └─ 请求处理层
```

**Django 项目**：
```
View → Service → Manager/QuerySet → Model
  │        │            │             │
  │        │            │             └─ Django Model
  │        │            └─ 查询封装
  │        └─ 业务逻辑层
  └─ 请求处理层
```

**通用 Python**：
```
API/CLI → Service → Gateway/Repository → Model
```

**违规检查**：

| 违规模式 | 说明 | 严重等级 |
|----------|------|----------|
| 路由/视图中包含业务逻辑 | 数据处理、计算、状态判断写在路由中 | 严重 |
| 路由直接操作 ORM/数据库 | 路由中直接执行查询/写入 | 严重 |
| Service 依赖 Web 层对象 | Service 接收 Request 对象 | 警告 |
| Schema 当持久化模型用 | Pydantic Model 直接写入数据库 | 警告 |
| 反向依赖 | Repository 依赖 Service | 严重 |

### 2. 类型安全检查

| 检查项 | 说明 | 严重等级 |
|--------|------|----------|
| 关键函数缺少类型注解 | 公共方法/函数无 type hints | 警告 |
| 使用 `Any` 类型 | 过度使用 Any 绕过类型检查 | 警告 |
| Optional 未处理 None | Optional 类型未做 None 检查 | 严重 |
| 类型不匹配 | 实际返回与注解不一致 | 严重 |

### 3. 异步规范检查

| 检查项 | 说明 | 严重等级 |
|--------|------|----------|
| async 函数中同步阻塞调用 | 在 async def 中使用 requests / time.sleep 等 | 严重 |
| 缺少 await | 返回 coroutine 而非结果 | 严重 |
| 异步/混用 | 同一调用链中混用 sync/async | 警告 |
| 事件循环嵌套 | 在 async 中调用 asyncio.run() | 严重 |

### 4. 代码风格检查

| 检查项 | 说明 | 严重等级 |
|--------|------|----------|
| 违反 PEP 8 | ruff 检查未通过 | 警告 |
| 缺少 docstring | 公共函数无说明 | 建议 |
| 魔法数字 | 硬编码数字未提取为常量 | 建议 |
| 过长函数 | 函数超过 50 行 | 警告 |

## 输出格式

```markdown
# Python 架构评审报告：<change-id>

## 分层架构问题
### 严重
1. [文件:行号] 路由中包含业务逻辑：<具体描述>

### 警告
1. [文件:行号] <描述>

## 类型安全问题
### 严重
1. [文件:行号] <描述>

## 异步规范问题
### 严重
1. [文件:行号] <描述>

## 代码风格问题
### 警告
1. [文件:行号] <描述>

## 总结
- 严重问题：N 个
- 警告问题：N 个
- 建议项：N 个
```
