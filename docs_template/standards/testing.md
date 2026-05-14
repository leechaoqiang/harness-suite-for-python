# 测试规范

## 最低要求

| 变更类型 | 测试要求 |
|----------|----------|
| 行为变化 | 至少补 1 个相关测试 |
| Bug 修复 | 优先补 regression test |
| Service 层逻辑修改 | 优先补单元测试 |
| API 路由改动 | 补集成测试（test client） |
| ORM/SQL 改动 | 至少说明验证方法和边界数据 |

## 测试分层

```
┌─────────────────────────────────────┐
│     E2E / Integration Test          │  ← 接口级验证（test client）
├─────────────────────────────────────┤
│         Service Test                │  ← 业务逻辑验证（mock 依赖）
├─────────────────────────────────────┤
│       Repository Test               │  ← 数据访问验证（数据库 fixture）
└─────────────────────────────────────┘
```

## 测试工具

| 工具 | 用途 |
|------|------|
| `pytest` | 测试框架 |
| `pytest-asyncio` | 异步测试 |
| `pytest-cov` | 覆盖率 |
| `factory_boy` / `faker` | 测试数据生成 |
| `httpx` / `TestClient` | API 集成测试 |

## 测试命名约定

```python
# 测试文件：test_<module>.py
# 测试类：Test<Feature>
# 测试方法：test_<scenario>_<expected_result>

class TestUserService:
    def test_create_user_with_valid_data_returns_user(self):
        ...

    def test_create_user_with_duplicate_email_raises_error(self):
        ...
```

## Fixture 规范

```python
# conftest.py 中定义共享 fixture

@pytest.fixture
def db_session():
    """测试数据库 session"""
    ...

@pytest.fixture
def user_factory():
    """用户测试数据工厂"""
    ...
```

## 异步测试

```python
# 使用 pytest-asyncio
@pytest.mark.asyncio
async def test_async_service():
    result = await service.do_something()
    assert result is not None
```

## 评审要求

提交 review 时必须说明：

- 跑了哪些测试
- 哪些部分没有测
- 为什么跳过这些检查仍然可以接受

## 常用命令

| 命令 | 用途 |
|------|------|
| `pytest` | 运行所有测试 |
| `pytest tests/unit/` | 运行单元测试 |
| `pytest tests/integration/` | 运行集成测试 |
| `pytest --cov=src` | 带覆盖率运行 |
| `pytest -x` | 遇到第一个失败停止 |
| `pytest -k "test_name"` | 按名称过滤 |

## 测试覆盖率

- 核心业务逻辑覆盖率应达到 **80%+**
- 新增代码必须附带测试
- 测试不完善的功能不允许发布
