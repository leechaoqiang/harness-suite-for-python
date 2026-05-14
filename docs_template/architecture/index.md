# 架构总览

## 系统分层

### FastAPI 项目

| 层级 | 职责 |
|------|------|
| `api/routers` | 路由层，负责请求接收、参数校验、响应封装 |
| `services` | 业务编排层，负责核心业务流程 |
| `repositories` | 数据访问层，封装数据库操作 |
| `models` | SQLAlchemy ORM 模型 / 数据模型 |
| `schemas` | Pydantic 请求/响应模型 |
| `core` | 配置、依赖注入、中间件 |

### Django 项目

| 层级 | 职责 |
|------|------|
| `views` | 视图层，负责请求接收、响应封装 |
| `services` | 业务编排层，负责核心业务流程 |
| `managers` | 查询封装层，自定义 Manager/QuerySet |
| `models` | Django ORM 模型 |
| `serializers` | 序列化/反序列化 |
| `urls` | URL 路由 |

### 通用 Python 项目

| 层级 | 职责 |
|------|------|
| `api` / `cli` | 对外接口层 |
| `services` | 业务逻辑层 |
| `repositories` / `gateways` | 数据访问 / 外部调用层 |
| `models` | 数据模型 |

## 依赖方向

```
Router/View → Service → Repository → Model
```

**规则**：
- 路由/视图不允许直接操作 ORM/数据库
- Repository 不允许反向依赖 Service
- Web 层对象（Request/Response）不允许深入渗透到业务层
- Pydantic Schema 不允许直接当 ORM Model 使用

## 高风险区域

以下区域修改时必须重点说明：

- 认证/鉴权
- 支付/订单
- 定时任务（Celery / APScheduler）
- 数据库迁移
- 批量更新/批量删除
- 核心 SQL 查询
- 外部 API 集成

## 变更设计要求

如果 change 涉及高风险区域，design.md 中必须说明：

- 影响的模块和文件
- 事务边界
- ORM / SQL / 索引影响
- 回滚方案
- 测试策略
