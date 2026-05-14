# AGENTS.md

## 项目说明

本仓库采用 Harness 风格工作流：

- OpenSpec 负责定义需求与变更工件
- Claude Code 在项目规则内执行
- 实现与评审分离
- Hooks、权限和 CI 负责硬约束

## 首先阅读

1. `docs/architecture/index.md` - 架构总览
2. `docs/product/index.md` - 产品规则
3. `docs/standards/testing.md` - 测试规范
4. `docs/standards/database.md` - 数据库规范
5. `openspec/specs/` - 系统规格
6. `openspec/changes/<change-id>/` - 当前变更工件
7. `docs/architecture/implicit-contracts.md` - 隐性业务约定

## 工作规则

- **没有 OpenSpec change，不允许直接开始开发**
- 不允许超出 `tasks.md` 自行扩需求
- 每完成一个里程碑，都必须运行相关检查
- 修改数据库、配置、高风险业务时，必须明确说明影响范围
- 合并前必须经过 review 和 verify

## 受保护目录

以下目录修改需特别谨慎：

- `.env` / `.env.*`
- `alembic/`
- `settings.py` / `config.py`
- `deploy/`
- `infra/`
- `secrets/`
- `docker-compose*.yml`
- `Dockerfile*`

## 主流程命令

| 命令 | 用途 |
|------|------|
| `/harness:propose <名称>` | 创建新需求 |
| `/harness:plan <change-id>` | 战略设计 + 任务分解 |
| `/harness:apply <change-id>` | 执行实现 |
| `/harness:review <change-id>` | 并行评审 |
| `/harness:archive <change-id>` | 归档完成变更 |
