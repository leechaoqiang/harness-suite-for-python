#!/bin/bash
#
# Python 检查 Hook - 每次 Edit/Write 后自动运行
# 配合 settings.json 使用：
# {
#   "hooks": {
#     "PostToolUse": [{
#       "matcher": "Edit|Write",
#       "hooks": [{
#         "type": "command",
#         "command": "bash .claude/hooks/run_checks.sh"
#       }]
#     }]
#   }
# }
#

set -euo pipefail

# 1. 获取当前所有被修改、新增或删除的文件列表
CHANGED_FILES=$(git status --porcelain 2>/dev/null | awk '{print $2}') || {
    echo "[Hook] 无法获取 git status，跳过检查"
    exit 0
}

# 2. 如果没有文件变动，直接退出
if [ -z "$CHANGED_FILES" ]; then
    exit 0
fi

# 3. 检查是否只修改了文档文件（不需要检查）
NON_DOC_CHANGES=$(echo "$CHANGED_FILES" | grep -vE '\.(md|txt|csv|json|yaml|yml|toml|cfg|ini|rst)$') || true

if [ -z "$NON_DOC_CHANGES" ]; then
    echo "[Hook] 仅检测到文档变动，跳过检查。"
    exit 0
fi

# 4. 筛选 Python 文件变动
PY_CHANGES=$(echo "$NON_DOC_CHANGES" | grep -E '\.py$') || true

if [ -z "$PY_CHANGES" ]; then
    echo "[Hook] 无 Python 文件变动，跳过检查。"
    exit 0
fi

echo "[Hook] 检测到 Python 文件变动，执行检查..."

# 5. 检测虚拟环境
VENV_PYTHON=""
if [ -f ".venv/bin/python" ]; then
    VENV_PYTHON=".venv/bin/python"
elif [ -f "venv/bin/python" ]; then
    VENV_PYTHON="venv/bin/python"
fi

# 6. 执行 ruff 检查（格式 + lint）
if command -v ruff &>/dev/null; then
    echo "[Hook] 执行 ruff check..."
    ruff check --quiet $PY_CHANGES 2>/dev/null || echo "[Hook] ruff check 发现问题，请检查"
elif [ -n "$VENV_PYTHON" ] && [ -f "${VENV_PYTHON%/bin/python}/bin/ruff" ]; then
    echo "[Hook] 执行 ruff check (venv)..."
    "${VENV_PYTHON%/bin/python}/bin/ruff" check --quiet $PY_CHANGES 2>/dev/null || echo "[Hook] ruff check 发现问题，请检查"
else
    echo "[Hook] ruff 未安装，跳过 lint 检查"
fi

# 7. 执行 mypy 类型检查（仅对修改的文件）
if command -v mypy &>/dev/null; then
    echo "[Hook] 执行 mypy 类型检查..."
    mypy --no-error-summary $PY_CHANGES 2>/dev/null || echo "[Hook] mypy 发现类型问题，请检查"
elif [ -n "$VENV_PYTHON" ] && [ -f "${VENV_PYTHON%/bin/python}/bin/mypy" ]; then
    echo "[Hook] 执行 mypy 类型检查 (venv)..."
    "${VENV_PYTHON%/bin/python}/bin/mypy" --no-error-summary $PY_CHANGES 2>/dev/null || echo "[Hook] mypy 发现类型问题，请检查"
else
    echo "[Hook] mypy 未安装，跳过类型检查"
fi

# 8. 执行 pytest（如有测试目录）
if [ -d "tests" ] || [ -d "test" ]; then
    echo "[Hook] 执行相关测试..."
    if [ -n "$VENV_PYTHON" ]; then
        $VENV_PYTHON -m pytest --tb=short -q 2>/dev/null || echo "[Hook] 测试未通过，请检查"
    elif command -v pytest &>/dev/null; then
        pytest --tb=short -q 2>/dev/null || echo "[Hook] 测试未通过，请检查"
    else
        echo "[Hook] pytest 未安装，跳过测试"
    fi
fi

echo "[Hook] 检查完成"
