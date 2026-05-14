#!/bin/bash
#
# Harness Suite for Python 安装脚本
# 用法: bash install.sh
# 或: bash install.sh --target /path/to/project
#
# 支持的参数:
#   --skip-superpowers   跳过 superpowers 安装检查
#   --force              强制覆盖已有文件
#   --target <path>      指定安装目标目录（默认当前目录）
#

set -euo pipefail

# ============================================
# 颜色定义
# ============================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ============================================
# 日志函数
# ============================================
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# ============================================
# 变量
# ============================================
SKIP_SUPERPOWERS=false
FORCE=false
TARGET_DIR="${PWD}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ============================================
# 解析参数
# ============================================
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-superpowers)
            SKIP_SUPERPOWERS=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --target)
            TARGET_DIR="$2"
            shift 2
            ;;
        --help)
            echo "用法: $0 [选项]"
            echo "选项:"
            echo "  --skip-superpowers   跳过 superpowers 安装检查"
            echo "  --force              强制覆盖已有文件"
            echo "  --target <path>      指定安装目标目录"
            exit 0
            ;;
        *)
            shift
            ;;
    esac
done

# ============================================
# 前置检查
# ============================================
log_info "开始安装 Harness Suite for Python..."

# 检查/创建 Claude Code 环境
if [ ! -d "${TARGET_DIR}/.claude" ]; then
    log_warn "检测到 .claude 目录不存在，正在创建..."
    mkdir -p "${TARGET_DIR}/.claude"
    log_success ".claude 目录已创建"
fi

SKILLS_DIR="${TARGET_DIR}/.claude/skills"
mkdir -p "${SKILLS_DIR}"

# ============================================
# Step 1: 检测/安装 Superpowers
# ============================================
if [ "$SKIP_SUPERPOWERS" = false ]; then
    log_info "检查 Superpowers..."

    if [ -d "${SKILLS_DIR}/superpowers-guide" ]; then
        log_success "Superpowers 已安装"
    else
        log_info "Superpowers 未安装"
        log_warn "建议稍后执行 /superpowers:install 或手动安装 superpowers"
    fi
fi

# ============================================
# Step 2: 创建 skill 目录结构
# ============================================
log_info "创建 skill 目录结构..."

HARNESS_SKILLS=(
    "harness-setup"
    "harness-propose"
    "harness-plan"
    "harness-apply"
    "harness-review"
    "harness-archive"
    "prepare-review"
    "python-architecture-review"
    "sql-risk-review"
)

SKILL_MAP=(
    "workflow/propose:harness-propose"
    "workflow/plan:harness-plan"
    "workflow/apply:harness-apply"
    "workflow/review:harness-review"
    "workflow/archive:harness-archive"
)

for skill in "${HARNESS_SKILLS[@]}"; do
    mkdir -p "${SKILLS_DIR}/${skill}"
done

# ============================================
# Step 3: 复制 skill 文件
# ============================================
log_info "复制 skill 文件..."

# 主 setup skill
if [ -f "${SCRIPT_DIR}/setup/SKILL.md" ]; then
    cp "${SCRIPT_DIR}/setup/SKILL.md" "${SKILLS_DIR}/harness-setup/SKILL.md"
    log_success "复制 harness-setup"
fi

# review-skills
for skill_path in prepare-review python-architecture-review sql-risk-review; do
    src="${SCRIPT_DIR}/review-skills/${skill_path}/SKILL.md"
    if [ -f "$src" ]; then
        cp "$src" "${SKILLS_DIR}/${skill_path}/SKILL.md"
        log_success "复制 $skill_path"
    fi
done

# workflow skills
for mapping in "${SKILL_MAP[@]}"; do
    IFS=':' read -r src dst <<< "$mapping"
    src_file="${SCRIPT_DIR}/${src}/SKILL.md"
    if [ -f "$src_file" ]; then
        cp "$src_file" "${SKILLS_DIR}/${dst}/SKILL.md"
        log_success "复制 $dst"
    fi
done

# ============================================
# Step 4: 复制 agents 和 hooks
# ============================================
log_info "复制 agents 和 hooks..."

mkdir -p "${TARGET_DIR}/.claude/agents"
mkdir -p "${TARGET_DIR}/.claude/hooks"

if [ -f "${SCRIPT_DIR}/agents/reviewer.md" ]; then
    cp "${SCRIPT_DIR}/agents/reviewer.md" "${TARGET_DIR}/.claude/agents/reviewer.md"
    log_success "复制 reviewer agent"
fi

for hook in guard_write.py ensure_change_context.py run_checks.sh; do
    src="${SCRIPT_DIR}/hooks/${hook}"
    if [ -f "$src" ]; then
        cp "$src" "${TARGET_DIR}/.claude/hooks/${hook}"
        chmod +x "${TARGET_DIR}/.claude/hooks/${hook}"
        log_success "复制 $hook"
    fi
done

# ============================================
# Step 5: 复制规约文件
# ============================================
log_info "复制规约文件..."

for file in AGENTS.md CLAUDE.md REVIEW.md; do
    src="${SCRIPT_DIR}/${file}"
    dst="${TARGET_DIR}/${file}"
    if [ -f "$src" ]; then
        if [ -f "$dst" ] && [ "$FORCE" = false ]; then
            log_warn "${file} 已存在，跳过 (使用 --force 覆盖)"
        else
            cp "$src" "$dst"
            log_success "复制 $file"
        fi
    fi
done

# ============================================
# Step 6: 配置 commands
# ============================================
log_info "配置 commands..."

SETTINGS_FILE="${TARGET_DIR}/.claude/settings.json"

COMMANDS_JSON='{
  "harness": {
    "setup": "harness-setup",
    "propose": "harness-propose",
    "plan": "harness-plan",
    "apply": "harness-apply",
    "review": "harness-review",
    "archive": "harness-archive"
  }
}'

if [ -f "$SETTINGS_FILE" ]; then
    if grep -q '"commands"' "$SETTINGS_FILE" 2>/dev/null; then
        log_info "检测到已有 commands 配置，需要手动合并"
        log_warn "请手动将以下内容添加到 settings.json 的 commands 字段中:"
        echo "$COMMANDS_JSON"
    else
        log_info "settings.json 存在，建议手动添加 commands 配置"
    fi
else
    echo "{\"commands\": $COMMANDS_JSON}" > "$SETTINGS_FILE"
    log_success "创建 settings.json"
fi

# ============================================
# Step 7: 配置 hooks
# ============================================
log_info "配置 hooks..."

HOOKS_JSON='{
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
}'

if [ -f "$SETTINGS_FILE" ]; then
    if grep -q '"hooks"' "$SETTINGS_FILE" 2>/dev/null; then
        log_info "检测到已有 hooks 配置，需要手动合并"
        log_warn "请手动将以下 hooks 配置添加到 settings.json 中:"
        echo "$HOOKS_JSON"
    else
        log_info "settings.json 存在，建议手动添加 hooks 配置"
    fi
fi

# ============================================
# 完成
# ============================================
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN} Harness Suite for Python 安装完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "已安装的 Skills:"
for skill in "${HARNESS_SKILLS[@]}"; do
    echo "  - /harness:${skill#harness-}"
done
echo ""
echo "已安装的 Review Skills:"
echo "  - /prepare-review"
echo "  - /python-architecture-review"
echo "  - /sql-risk-review"
echo ""
echo "规约文件:"
echo "  - AGENTS.md"
echo "  - CLAUDE.md"
echo "  - REVIEW.md"
echo ""
echo -e "${YELLOW}下一步:${NC}"
echo "  1. 重启 Claude Code 会话使 commands 生效"
echo "  2. 执行 /harness:setup 初始化项目"
echo ""
