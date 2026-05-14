---

name: harness-setup
description: 初始化 Harness 工作流，自动探索 Python 项目背景，生成个性化配置

---

# Harness Suite for Python 初始化

## 目的

自动探索 Python 项目背景，生成个性化配置。最小化用户输入。

---

## Step 1: 自动探索项目

### 静默检测

```
========================================
  正在探索你的 Python 项目...
========================================

  ├─ 检测项目类型...
  ├─ 分析目录结构...
  ├─ 识别技术栈...
  ├─ 扫描现有文档...
  └─ 生成个性化配置...

  [按任意键跳过探索]
```

### 检测内容

| 检测项 | 方式 | 输出 |
|--------|------|------|
| 项目类型 | 检测 pyproject.toml/setup.py/requirements.txt | FastAPI/Django/Flask/通用 Python |
| 目录结构 | ls -la src/ 或项目根 | 模块列表 |
| 技术栈 | 扫描依赖文件 | 框架、ORM、测试框架 |
| 现有文档 | 检测 docs/ | 已有知识库 |
| 构建命令 | 检测构建文件 | pytest/ruff/mypy |
| Python 版本 | 检测 .python-version / runtime.txt | Python 3.x |
| 虚拟环境 | 检测 venv/ / .venv/ / poetry.lock | 环境管理方式 |

### 探索结果示例

```
========================================
  探索完成！
========================================

  项目类型：FastAPI
  Python 版本：3.12
  包管理：poetry
  源码目录：src/
  测试目录：tests/

  检测到的模块：
    ├─ api/ (8 files)
    ├─ services/ (16 files)
    ├─ repositories/ (12 files)
    ├─ models/ (10 files)
    ├─ schemas/ (6 files)
    └─ core/ (4 files)

  技术栈：
    ├─ FastAPI
    ├─ SQLAlchemy 2.0
    ├─ Alembic
    ├─ Pydantic v2
    └─ pytest

  代码质量工具：
    ├─ ruff (linter + formatter)
    ├─ mypy (type checker)
    └─ pytest-cov (coverage)

  现有知识库：
    ├─ docs/architecture/ ✓
    └─ docs/standards/ ✓

  高风险区域（推测）：
    ├─ 认证/鉴权
    ├─ 数据库迁移
    └─ 核心 SQL 查询

========================================
```

---

## Step 2: 用户确认

### 两种选择

```
┌─────────────────────────────────────────┐
│                                         │
│  检测结果是否符合你的预期？               │
│                                         │
│    [确认]  → 使用以上配置，生成文档      │
│    [讨论]  → 告诉我需要修改的地方       │
│                                         │
└─────────────────────────────────────────┘
```

### "确认"路径

跳过所有问题，直接生成文档。

### "讨论"路径

```
┌─────────────────────────────────────────┐
│  请告诉我需要修改的部分：               │
│                                         │
│  [1] 项目类型（当前：FastAPI）           │
│  [2] 模块结构                           │
│  [3] 技术栈                             │
│  [4] 高风险区域                         │
│  [5] 代码质量工具                       │
│  [6] 其他（自由输入）                   │
│                                         │
│  输入编号或直接描述：                   │
└─────────────────────────────────────────┘
```

---

## Step 3: 生成文档

### 生成过程

```
========================================
  正在生成文档...
========================================

  ├─ 创建 openspec/ 目录结构...
  ├─ 生成 docs/architecture/index.md...
  ├─ 生成 docs/architecture/implicit-contracts.md...
  ├─ 生成 docs/product/index.md...
  ├─ 生成 docs/standards/testing.md...
  ├─ 生成 docs/standards/database.md...
  └─ 更新知识索引...

  [====== 100% ======]
```

### 生成结果

```
========================================
  初始化完成！
========================================

  已创建/更新的文件：

  ┌─ openspec/
  │  ├─ changes/
  │  └─ specs/
  │
  └─ docs/
     ├─ architecture/
     │  ├─ index.md
     │  └─ implicit-contracts.md
     ├─ product/
     │  └─ index.md
     └─ standards/
        ├─ testing.md
        └─ database.md

  关键文件：
    ├─ CLAUDE.md
    ├─ AGENTS.md
    └─ REVIEW.md

========================================

  下一步：
    /harness:propose <需求名称>  开始第一个需求

========================================
```

---

## 命令行选项

```
/harness:setup              交互式初始化（推荐）
/harness:setup --auto       完全自动，使用检测结果
/harness:setup --force      覆盖已有文件
/harness:setup --docs-only  仅生成文档，跳过 openspec
/harness:setup --help       显示帮助
```

---

## 项目类型检测规则

| 标识文件 | 项目类型 | 架构模式 |
|----------|----------|----------|
| `pyproject.toml` 含 `fastapi` | FastAPI | Router → Service → Repository → Model |
| `pyproject.toml` 含 `django` | Django | View → Service → Manager/QuerySet → Model |
| `pyproject.toml` 含 `flask` | Flask | Blueprint → Service → Model |
| `pyproject.toml` 含 `celery` | 异步任务 | Task → Service → Model |
| 无框架标识 | 通用 Python | 按目录结构推断 |

---

## 关键文件说明

### CLAUDE.md
```
位置：项目根目录
用途：Python 技术规约
包含：架构分层规则、类型安全要求、测试要求、异步规范、受保护路径
```

### AGENTS.md
```
位置：项目根目录
用途：代理行为规范
包含：工作流程、必读文件清单、命令速查
```

### REVIEW.md
```
位置：项目根目录
用途：评审标准
包含：评审检查项、OpenSpec 对齐验证、Python 特定检查
```
