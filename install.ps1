# Harness Suite for Python - PowerShell 安装脚本
#
# 用法:
#   .\install.ps1
#   .\install.ps1 -Force
#   .\install.ps1 -Target "C:\Projects\MyProject"
#
# 参数:
#   -SkipSuperpowers   跳过 superpowers 安装检查
#   -Force             强制覆盖已有文件
#   -Target <path>     指定安装目标目录

param(
    [switch]$SkipSuperpowers = $false,
    [switch]$Force = $false,
    [string]$Target = (Get-Location).Path
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "========================================" -ForegroundColor Green
Write-Host " Harness Suite for Python 安装" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# 创建 .claude 目录
$ClaudeDir = Join-Path $Target ".claude"
if (-not (Test-Path $ClaudeDir)) {
    New-Item -ItemType Directory -Path $ClaudeDir -Force | Out-Null
    Write-Host "[INFO] 已创建 .claude 目录" -ForegroundColor Blue
}

$SkillsDir = Join-Path $ClaudeDir "skills"
New-Item -ItemType Directory -Path $SkillsDir -Force | Out-Null

# Skill 列表
$Skills = @(
    "harness-setup",
    "harness-propose",
    "harness-plan",
    "harness-apply",
    "harness-review",
    "harness-archive",
    "prepare-review",
    "python-architecture-review",
    "sql-risk-review"
)

# 创建 skill 目录
foreach ($skill in $Skills) {
    $dir = Join-Path $SkillsDir $skill
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
}

# 复制 setup skill
$setupSrc = Join-Path $ScriptDir "setup\SKILL.md"
$setupDst = Join-Path $SkillsDir "harness-setup\SKILL.md"
if (Test-Path $setupSrc) {
    Copy-Item $setupSrc $setupDst -Force
    Write-Host "[SUCCESS] 复制 harness-setup" -ForegroundColor Green
}

# 复制 review-skills
$reviewSkills = @("prepare-review", "python-architecture-review", "sql-risk-review")
foreach ($skill in $reviewSkills) {
    $src = Join-Path $ScriptDir "review-skills\$skill\SKILL.md"
    $dst = Join-Path $SkillsDir "$skill\SKILL.md"
    if (Test-Path $src) {
        Copy-Item $src $dst -Force
        Write-Host "[SUCCESS] 复制 $skill" -ForegroundColor Green
    }
}

# 复制 workflow skills
$workflowMap = @{
    "workflow\propose" = "harness-propose"
    "workflow\plan" = "harness-plan"
    "workflow\apply" = "harness-apply"
    "workflow\review" = "harness-review"
    "workflow\archive" = "harness-archive"
}

foreach ($entry in $workflowMap.GetEnumerator()) {
    $src = Join-Path $ScriptDir "$($entry.Key)\SKILL.md"
    $dst = Join-Path $SkillsDir "$($entry.Value)\SKILL.md"
    if (Test-Path $src) {
        Copy-Item $src $dst -Force
        Write-Host "[SUCCESS] 复制 $($entry.Value)" -ForegroundColor Green
    }
}

# 复制 agents
$agentsDir = Join-Path $ClaudeDir "agents"
New-Item -ItemType Directory -Path $agentsDir -Force | Out-Null
$reviewerSrc = Join-Path $ScriptDir "agents\reviewer.md"
$reviewerDst = Join-Path $agentsDir "reviewer.md"
if (Test-Path $reviewerSrc) {
    Copy-Item $reviewerSrc $reviewerDst -Force
    Write-Host "[SUCCESS] 复制 reviewer agent" -ForegroundColor Green
}

# 复制 hooks
$hooksDir = Join-Path $ClaudeDir "hooks"
New-Item -ItemType Directory -Path $hooksDir -Force | Out-Null
$hooks = @("guard_write.py", "ensure_change_context.py", "run_checks.sh")
foreach ($hook in $hooks) {
    $src = Join-Path $ScriptDir "hooks\$hook"
    $dst = Join-Path $hooksDir $hook
    if (Test-Path $src) {
        Copy-Item $src $dst -Force
        Write-Host "[SUCCESS] 复制 $hook" -ForegroundColor Green
    }
}

# 复制规约文件
$specFiles = @("AGENTS.md", "CLAUDE.md", "REVIEW.md")
foreach ($file in $specFiles) {
    $src = Join-Path $ScriptDir $file
    $dst = Join-Path $Target $file
    if (Test-Path $src) {
        if ((Test-Path $dst) -and -not $Force) {
            Write-Host "[WARN] $file 已存在，跳过 (使用 -Force 覆盖)" -ForegroundColor Yellow
        } else {
            Copy-Item $src $dst -Force
            Write-Host "[SUCCESS] 复制 $file" -ForegroundColor Green
        }
    }
}

# 创建 settings.json
$settingsFile = Join-Path $ClaudeDir "settings.json"
$commandsJson = @{
    commands = @{
        harness = @{
            setup = "harness-setup"
            propose = "harness-propose"
            plan = "harness-plan"
            apply = "harness-apply"
            review = "harness-review"
            archive = "harness-archive"
        }
    }
}

if (-not (Test-Path $settingsFile)) {
    $commandsJson | ConvertTo-Json -Depth 10 | Set-Content $settingsFile
    Write-Host "[SUCCESS] 创建 settings.json" -ForegroundColor Green
} else {
    Write-Host "[WARN] settings.json 已存在，请手动合并 commands 配置" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host " 安装完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "下一步:" -ForegroundColor Yellow
Write-Host "  1. 重启 Claude Code 会话使 commands 生效"
Write-Host "  2. 执行 /harness:setup 初始化项目"
