#Requires -Version 7
# 一键触发 State.yml 中的所有构建任务

$ErrorActionPreference = 'Stop'

$StateFile = Join-Path $PSScriptRoot 'State.yml'

# 自动检测 GitHub 仓库
$Repo = (git -C $PSScriptRoot remote get-url origin 2>$null) -replace '.*github\.com[/:]', '' -replace '\.git$', ''
if (-not $Repo) {
    Write-Error "无法从 git remote 检测仓库地址，请确保项目已配置 origin remote。"
    exit 1
}
Write-Host -ForegroundColor Cyan "检测到仓库: $Repo"

if (-not (Test-Path $StateFile)) {
    Write-Error "未找到 State.yml 文件: $StateFile"
    exit 1
}

$Content = Get-Content $StateFile
$Commands = @()
$CurrentSection = ''

foreach ($line in $Content) {
    $trimmed = $line.Trim()

    # 跳过空行和注释行
    if ([string]::IsNullOrWhiteSpace($trimmed)) { continue }
    if ($trimmed.StartsWith('#')) { continue }

    # 检测顶层段落名 (如 w11-26h1:)，必须无缩进
    if ($line -match '^[a-zA-Z0-9_-]+:\s*$') {
        $CurrentSection = $line.Trim().TrimEnd(':')
        continue
    }

    # 提取未注释的 Commands 条目，自动注入 -R 仓库参数
    if ($trimmed -match '^\s*-\s+(gh\s+.+)$') {
        $cmd = $Matches[1].Trim()
        if ($cmd -notmatch '-R\s') {
            $cmd = $cmd -replace '^(gh\s+workflow\s+run)', "`$1 -R $Repo"
        }
        $Commands += [PSCustomObject]@{
            Section = $CurrentSection
            Command = $cmd
        }
    }
}

if ($Commands.Count -eq 0) {
    Write-Host -ForegroundColor Yellow "State.yml 中没有找到可执行的命令。"
    exit 0
}

Write-Host -ForegroundColor Cyan "========================================"
Write-Host -ForegroundColor Cyan "  一键触发所有 State.yml 构建任务"
Write-Host -ForegroundColor Cyan "========================================"
Write-Host ""
Write-Host -ForegroundColor White "共发现 $($Commands.Count) 个构建任务:"
Write-Host ""

for ($i = 0; $i -lt $Commands.Count; $i++) {
    $c = $Commands[$i]
    Write-Host -ForegroundColor Gray "  [$($i + 1)] ($($c.Section)) $($c.Command)"
}

Write-Host ""
$confirm = Read-Host "确认触发所有构建任务? (y/N)"
if ($confirm -notin @('y', 'Y', 'yes', 'Yes')) {
    Write-Host -ForegroundColor Yellow "已取消。"
    exit 0
}

Write-Host ""

$SuccessCount = 0
$FailCount = 0

for ($i = 0; $i -lt $Commands.Count; $i++) {
    $c = $Commands[$i]
    Write-Host -ForegroundColor Cyan "[$($i + 1)/$($Commands.Count)] [$($c.Section)] 正在触发..."
    Write-Host -ForegroundColor Gray "  > $($c.Command)"

    try {
        Invoke-Expression $c.Command
        if ($LASTEXITCODE -eq 0) {
            Write-Host -ForegroundColor Green "  -> 触发成功!"
            $SuccessCount++
        } else {
            Write-Host -ForegroundColor Red "  -> 触发失败 (退出码: $LASTEXITCODE)"
            $FailCount++
        }
    } catch {
        Write-Host -ForegroundColor Red "  -> 触发失败: $_"
        $FailCount++
    }

    Write-Host ""

    # 多个任务之间间隔 2 秒，避免 GitHub API 限流
    if ($i -lt $Commands.Count - 1) {
        Start-Sleep -Seconds 2
    }
}

Write-Host -ForegroundColor Cyan "========================================"
Write-Host -ForegroundColor Cyan "  执行完毕"
Write-Host -ForegroundColor Cyan "========================================"
Write-Host -ForegroundColor Green "  成功: $SuccessCount"
Write-Host -ForegroundColor $(if ($FailCount -gt 0) { 'Red' } else { 'Green' }) "  失败: $FailCount"
Write-Host ""
