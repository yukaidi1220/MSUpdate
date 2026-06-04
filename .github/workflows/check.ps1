#Requires -Version 7
param (
    [switch]$DatabaseOnly
)
$ErrorActionPreference = 'Stop'

Import-Module "$PSScriptRoot\..\..\Modules\compare.psm1"
Import-Module "$PSScriptRoot\..\..\Modules\request.psm1"

if (-not (Get-Module -ListAvailable -Name powershell-yaml)) {
    Write-Host "正在安装 PowerShell 模块 powershell-yaml..."
    Install-Module -Name powershell-yaml -Force -ErrorAction Stop
} else {
    Write-Host "PowerShell 模块 powershell-yaml 已安装。"
}

$StatePath = Join-Path '.' 'State.yml' -Resolve
$StateContent = Get-Content -Path $StatePath -Raw
$CurrentState = $StateContent | ConvertFrom-Yaml -Ordered

foreach ($Category in $CurrentState.Keys) {
    $CurrentVersion = $CurrentState.$Category.Version
    Write-Host -ForegroundColor Yellow "$Category 当前版本: $CurrentVersion"
    $LatestVersion = Request-Update -Category $Category

    if ($LatestVersion) {
        $IsNewerVersion = Compare-Version -CurrentVersion $CurrentVersion -LatestVersion $LatestVersion
        
        if ($IsNewerVersion) {
            Write-Host -ForegroundColor Green "$Category 发现新版本: $LatestVersion (当前: $CurrentVersion)"
            $CurrentState.$Category.Version = $LatestVersion

            $scriptBlock = [scriptblock]::Create($CurrentState.$Category.Commands -join "`n")

            if (!$DatabaseOnly) {
                Write-Host -ForegroundColor Green "正在执行 $Category 的命令..."
                Write-Host -ForegroundColor Yellow $scriptBlock
                . $scriptBlock
            }
        } else {
            Write-Host -ForegroundColor Yellow "$Category 已是最新版本 ($CurrentVersion)，跳过 ($LatestVersion)..."
        }
    } else {
        Write-Host -ForegroundColor Red "获取 $Category 最新版本失败，跳过..."
    }
}

# 文本级别替换版本号，保留注释和格式
foreach ($Category in $CurrentState.Keys) {
    $NewVersion = $CurrentState.$Category.Version
    $pattern = "(?m)(^$([regex]::Escape($Category)):\s*\r?\n\s*Version:\s*""?)[^""\r\n]+(""?\s*$)"
    $replacement = "`${1}${NewVersion}`${2}"
    $StateContent = [regex]::Replace($StateContent, $pattern, $replacement)
}
# 写回时保持原始文件的结尾换行状态
if ($StateContent[-1] -eq "`n") {
    Set-Content -Path $StatePath -Value $StateContent
} else {
    Set-Content -Path $StatePath -Value $StateContent -NoNewline
}