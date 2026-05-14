# Harness Suite for Python

基于 OpenSpec 思想 + Superpowers 工作流的轻量级 Python 研发规约框架。

## 理念

**战略设计（OpenSpec）** + **战术执行（Superpowers）** = **高效的 AI 辅助开发**

## 特性

- 适配 Python 项目架构（FastAPI / Django / Flask / 通用 Python）
- Python 专属评审规则（分层架构、类型安全、异步检查）
- 内置 ruff / mypy / pytest 检查钩子
- 支持 SQLAlchemy / Django ORM / Alembic 数据库规范
- 跨平台安装（Bash / PowerShell）

## 安装

### 一键安装（推荐）

在 Claude Code 项目根目录直接执行，无需克隆仓库：

**Bash（Linux / macOS）：**

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/leechaoqiang/harness-suite-for-python/main/install.sh)
```

**PowerShell（Windows）：**

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/leechaoqiang/harness-suite-for-python/main/install.ps1" -OutFile "install.ps1"; .\install.ps1; Remove-Item install.ps1
```

### 从源码安装

```bash
git clone https://github.com/leechaoqiang/harness-suite-for-python.git
cd harness-suite-for-python
bash install.sh --target /path/to/your/project
```

### 参数

| Bash 参数 | PowerShell 参数 | 说明 |
|-----------|----------------|------|
| `--skip-superpowers` | `-SkipSuperpowers` | 跳过 superpowers 安装检查 |
| `--force` | `-Force` | 强制覆盖已有文件 |
| `--target <path>` | `-Target <path>` | 指定安装目标目录 |

示例：

```bash
# 一键安装并指定目标目录
bash <(curl -fsSL https://raw.githubusercontent.com/leechaoqiang/harness-suite-for-python/main/install.sh) --target /path/to/your/project

# 从源码安装，跳过 superpowers 检查并强制覆盖
bash install.sh --skip-superpowers --force
```

### 安装后

1. 重启 Claude Code 会话使 commands 生效
2. 执行 `/harness:setup` 初始化项目

## 源码目录结构

```
harness-suite-for-py/
├── setup/                          # 初始化 Skill
│   └── SKILL.md
├── workflow/                       # 工作流 Skills
│   ├── propose/SKILL.md            # 创建需求
│   ├── plan/SKILL.md               # 战略设计 + 任务分解
│   ├── apply/SKILL.md              # 执行实现
│   ├── review/SKILL.md             # 并行评审
│   └── archive/SKILL.md            # 归档
├── review-skills/                  # 专项评审 Skills
│   ├── prepare-review/SKILL.md     # 变更摘要
│   ├── python-architecture-review/SKILL.md  # Python 架构评审
│   └── sql-risk-review/SKILL.md    # SQL/ORM 风险评审
├── agents/
│   └── reviewer.md                 # 评审代理
├── hooks/                          # 安全钩子
│   ├── guard_write.py              # 写保护（敏感路径拦截）
│   ├── ensure_change_context.py    # 变更上下文校验
│   └── run_checks.sh               # 编辑后自动检查（ruff/mypy/pytest）
├── docs_template/                  # 文档模板
│   ├── architecture/
│   │   ├── index.md                # 架构总览
│   │   └── implicit-contracts.md   # 隐性业务约定
│   ├── product/
│   │   └── index.md                # 产品规则
│   └── standards/
│       ├── testing.md              # 测试规范
│       └── database.md             # 数据库规范
├── AGENTS.md                       # 代理行为规范
├── CLAUDE.md                       # Python 技术规约
├── REVIEW.md                       # 评审标准
├── install.sh                      # Bash 安装脚本
└── install.ps1                     # PowerShell 安装脚本
```

## 安装后目标项目结构

```
your-project/
├── .claude/
│   ├── skills/                     # 已安装的 Skills
│   │   ├── harness-setup/
│   │   ├── harness-propose/
│   │   ├── harness-plan/
│   │   ├── harness-apply/
│   │   ├── harness-review/
│   │   ├── harness-archive/
│   │   ├── prepare-review/
│   │   ├── python-architecture-review/
│   │   └── sql-risk-review/
│   ├── agents/
│   │   └── reviewer.md
│   ├── hooks/
│   │   ├── guard_write.py
│   │   ├── ensure_change_context.py
│   │   └── run_checks.sh
│   └── settings.json               # commands + hooks 配置
├── openspec/                       # OpenSpec 变更工件
│   ├── changes/
│   │   └── <change-id>/
│   │       ├── proposal.md
│   │       ├── design.md
│   │       └── tasks.md
│   └── specs/
├── docs/                           # 项目文档
│   ├── architecture/
│   ├── product/
│   └── standards/
├── AGENTS.md
├── CLAUDE.md
└── REVIEW.md
```

## 快速开始

### 1. 初始化

```
/harness:setup
```

自动检测项目类型（FastAPI / Django / Flask / 通用 Python），生成规约骨架。

可选参数：`--auto`（跳过交互确认）、`--force`（覆盖已有文件）、`--docs-only`（仅生成文档）。

### 2. 创建需求

```
/harness:propose 用户登录功能
```

在 `openspec/changes/<change-id>/` 下生成 `proposal.md`。

### 3. 战略设计

```
/harness:plan user-login-20260513-01
```

基于 proposal 生成 `design.md`（技术方案）和 `tasks.md`（执行计划与里程碑）。

### 4. 执行实现

```
/harness:apply user-login-20260513-01
```

按 tasks.md 中的里程碑逐步实现，执行过程中自动遵守 CLAUDE.md 规约。

### 5. 并行评审

```
/harness:review user-login-20260513-01
```

并行执行多个评审 Skill，输出综合评审报告。

### 6. 归档

```
/harness:archive user-login-20260513-01
```

将变更工件归档至 `openspec/changes/archive/`。

## 专项评审

| Skill | 命令 | 说明 |
|-------|------|------|
| 变更摘要 | `/prepare-review` | 分析代码变更，按层级分类输出结构化摘要 |
| 架构评审 | `/python-architecture-review` | 检查分层依赖、类型安全、异步规范等违规项 |
| SQL 风险评审 | `/sql-risk-review` | 检查 SQL 注入、ORM 查询风险、迁移安全性等 |

## 与 Superpowers 的关系

| 阶段 | 调用 | 作用 |
|------|------|------|
| 设计 | `superpowers:brainstorming` | 深度探索、权衡分析 |
| 执行 | `superpowers:implementing-plans` | 计划执行、里程碑管理 |
| 验证 | `superpowers:verification-before-completion` | 里程碑检查 |
| 评审 | `superpowers:receive-code-review` | 代码质量审查 |
| 提交 | `superpowers:requesting-code-review` | 最终检查 |

## 核心规约

- **AGENTS.md** - 代理行为规范和工作流程
- **CLAUDE.md** - Python 技术规约（分层架构、测试、类型安全、异步等）
- **REVIEW.md** - 评审标准和检查项

## Hooks 配置

安装脚本会自动在 `.claude/settings.json` 中配置以下钩子：

| 钩子 | 触发时机 | 作用 |
|------|----------|------|
| `guard_write.py` | Edit/Write 前置 | 拦截对 `.env`、`alembic/`、`settings.py` 等敏感路径的修改 |
| `ensure_change_context.py` | Bash 前置 | 确保执行操作时存在有效的 OpenSpec 变更上下文 |
| `run_checks.sh` | Edit/Write 后置 | 自动运行 ruff check、mypy 类型检查、pytest（仅对代码文件） |

手动配置示例：

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [{
          "type": "command",
          "command": "python3 .claude/hooks/guard_write.py"
        }]
      },
      {
        "matcher": "Bash",
        "hooks": [{
          "type": "command",
          "command": "python3 .claude/hooks/ensure_change_context.py"
        }]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [{
          "type": "command",
          "command": "bash .claude/hooks/run_checks.sh"
        }]
      }
    ]
  }
}
```

## License

MIT
