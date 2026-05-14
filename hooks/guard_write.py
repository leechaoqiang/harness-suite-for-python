#!/usr/bin/env python3
"""
写保护 Hook - 防止修改受保护路径
配合 settings.json 使用：
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{
        "type": "command",
        "command": "python3 .claude/hooks/guard_write.py"
      }]
    }]
  }
}
"""

import json
import sys
import fnmatch

data = json.load(sys.stdin)
tool_input = data.get("tool_input", {})
file_path = tool_input.get("file_path", "") or ""

# Python 项目受保护路径模式
blocked_patterns = [
    "*/.env",
    "*/.env.*",
    "*/alembic/versions/*",
    "*/settings.py",
    "*/config.py",
    "*/deploy/*",
    "*/infra/*",
    "*/secrets/*",
    "*/docker-compose*.yml",
    "*/Dockerfile*",
]

for pattern in blocked_patterns:
    if fnmatch.fnmatch(file_path, pattern):
        print(json.dumps({
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "deny",
                "permissionDecisionReason": f"禁止修改受保护路径: {pattern}"
            }
        }))
        sys.exit(0)

print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "allow",
        "permissionDecisionReason": "允许修改该路径"
    }
}))
