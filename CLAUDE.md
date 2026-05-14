@AGENTS.md

# Claude Code 项目规则

## 你的角色

你是一个在 Harness 工作流中执行实现和评审任务的代理。

## 必须遵守的工作流程

1. **开始实现前**，必须先阅读对应的 OpenSpec change：
   - `openspec/changes/<change-id>/proposal.md` - 需求提案
   - `openspec/changes/<change-id>/design.md` - 技术方案
   - `openspec/changes/<change-id>/tasks.md` - 执行任务

2. 修改代码前，**先总结本次需求范围**

3. **只允许实现 `tasks.md` 中明确列出的内容**

4. 每完成一个里程碑，必须执行相关检查

5. 最终输出简短总结，包括：
   - 改动了哪些模块/文件
   - 跑了哪些测试
   - 还存在哪些风险

## 架构规则

- **路由/视图层** 只负责参数接收、返回结果，不写核心业务逻辑
- **业务逻辑必须放在 Service 层**
- 路由层不允许直接调用 Model/ORM 执行数据库操作
- Service 不允许直接依赖 Web 层对象（Request/Response）
- Schema/DTO 不允许直接当作持久化模型使用
- 涉及数据库查询变更时，必须关注索引、分页、条件范围和 N+1 风险
- 新增外部依赖时，必须在 design.md 中说明理由
- 使用类型注解，关键函数必须有类型签名
- 异步代码必须正确处理 async/await，禁止同步阻塞调用在异步上下文中

## 测试规则

- 任何行为变化都必须补充至少一个相关测试
- Service 层变更优先补单元测试（pytest + mock）
- API 行为变更优先补集成测试（test client）
- Bug 修复在条件允许时必须补 regression test
- 修改 ORM 查询 / SQL 时，必须至少说明验证方式

## 事务与数据规则

- 涉及写操作时，必须明确事务边界
- **不允许无条件全表更新/删除**
- 批量操作必须说明范围控制条件
- 修改数据库迁移文件、核心查询时必须谨慎，必要时停止并请求确认
- 使用 Alembic 迁移时，必须提供 upgrade 和 downgrade

## 安全规则

除以下情况外，不允许修改受保护路径：
- OpenSpec design 明确要求修改
- 经过团队确认

**受保护路径**：
- `.env` / `.env.*`
- `alembic/`
- `settings.py` / `config.py`
- `deploy/`
- `infra/`
- `secrets/`
- `docker-compose*.yml`
- `Dockerfile*`

**禁止操作**：
- 部署、推送、生产环境相关命令
- 如果需求边界不清楚，应停止并报告，**不允许自行脑补需求**

## 代码风格

- 遵循 PEP 8，使用 ruff 格式化
- 使用类型注解（type hints）
- 函数/方法必须有 docstring（简要说明，不超过一行）
- 变量命名使用 snake_case，类名使用 PascalCase
- 常量使用 UPPER_SNAKE_CASE

## 与 Superpowers 的关系

| 阶段 | 调用 Skill |
|------|-----------|
| 设计探索 | `superpowers:brainstorming` |
| 执行实现 | `superpowers:implementing-plans` |
| 里程碑验证 | `superpowers:verification-before-completion` |
| 代码评审 | `superpowers:receive-code-review` |
| 提交前检查 | `superpowers:requesting-code-review` |
