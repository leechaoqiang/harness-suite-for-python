#!/usr/bin/env python3
"""
上下文变更保护 Hook - 确保在有效的 OpenSpec Change 上下文中执行
配合 settings.json 使用：
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [{
        "type": "command",
        "command": "python3 .claude/hooks/ensure_change_context.py"
      }]
    }]
  }
}
"""

import json
import os
import sys

data = json.load(sys.stdin)
tool_input = data.get("tool_input", {})
cmd = tool_input.get("command", "") or ""

# 安全命令前缀 - 不需要 Change 上下文即可执行
safe_prefixes = [
    "git status",
    "git diff",
    "git log",
    "git show",
    "git branch",
    # Python 工具命令（只读）
    "ruff check",
    "mypy",
    "pytest --collect",
    "python -m pip list",
    "python --version",
    # 查看类命令
    "ls",
    "cat",
    "find",
    "grep",
]

if any(cmd.startswith(p) for p in safe_prefixes):
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "allow",
            "permissionDecisionReason": "安全命令，允许执行"
        }
    }))
    sys.exit(0)

# 检查是否存在有效的 OpenSpec Change
change_dir = "openspec/changes"
has_change = os.path.isdir(change_dir) and any(
    os.path.isdir(os.path.join(change_dir, x))
    for x in os.listdir(change_dir)
    if x != "archive"
)

if not has_change:
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "ask",
            "permissionDecisionReason": "当前未检测到 OpenSpec Change，请确认是否继续"
        }
    }))
    sys.exit(0)

print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "allow",
        "permissionDecisionReason": "已检测到 OpenSpec Change"
    }
}))
