#Requires -Version 7
param (
    [switch]$DatabaseOnly
)
$ErrorActionPreference = 'Stop'

Import-Module "$PSScriptRoot/../../Modules/compare.psm1"
Import-Module "$PSScriptRoot/../../Modules/request.psm1"
Import-Module "$PSScriptRoot/../../Modules/statepointer.psm1"

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
    # Filter 与构建侧（msupdate.ps1 对应 makeversion 的 -ContentFilter）同源同语义，
    # State.yml 里每通道一份；缺省回落旧宽过滤（*amd64*），但现役通道都已配置
    $LatestVersion = Request-Update -Category $Category -ContentFilter "$($CurrentState.$Category.Filter)"

    if ($LatestVersion) {
        $IsNewerVersion = Compare-Version -CurrentVersion $CurrentVersion -LatestVersion $LatestVersion
        
        if ($IsNewerVersion) {
            Write-Host -ForegroundColor Green "$Category 发现新版本: $LatestVersion (当前: $CurrentVersion)"
            $CurrentState.$Category.Version = $LatestVersion
            # 重置重试标记：新版本由正常路径触发构建；若这次构建没产出这一版
            # （失败，或构建源给的版本与检查源不同），下一轮的指针核查要能重新
            # 获得一次自动重试的机会
            $CurrentState.$Category.RebuiltFor = ""

            $scriptBlock = [scriptblock]::Create($CurrentState.$Category.Commands -join "`n")

            if (!$DatabaseOnly) {
                Write-Host -ForegroundColor Green "正在执行 $Category 的命令..."
                Write-Host -ForegroundColor Yellow $scriptBlock
                . $scriptBlock
            }
        } else {
            Write-Host -ForegroundColor Yellow "$Category 已是最新版本 ($CurrentVersion)，跳过 ($LatestVersion)..."

            # ── 指针一致性核查：state 说"最新"不等于上次构建真的产出了这一版 ──
            # 两种真实发生过的情况：
            #   1) 构建失败但 state 已推进：2026-10-17 state 推到 28000.3351，两局 make
            #      全挂在旧 mupan 存储上（SPO license），之后九天每次检查都"已是最新"，
            #      没有任何机制发现 3351 的镜像从未产出；
            #   2) 检查源与构建源看到的版本不同：2026-10-26 实测 state 28000.3351、
            #      实际产出 28000.3231（两边的 UUP 镜像/接口口径不一致）。
            # latest 指针里的 os_version 是"线上到底是谁"的唯一可信来源。不一致就按
            # 正常更新的方式再触发一次构建；同一版本只重试一次（RebuiltFor），防止
            # 两个源永久分歧时每轮都白打一次构建。
            # 尚未配置 Pointers 的通道（如刚加入、还没首建的 26H2）不参与核查：
            # 归一化在 Get-ChannelPointers 里（@($null).Count 是 1 的坑、标量写法、
            # 空项过滤都在那一处挡住并有测试覆盖）
            $pointerUrls = @(Get-ChannelPointers -Pointers $CurrentState.$Category.Pointers)
            if (-not $DatabaseOnly -and $pointerUrls.Count -gt 0) {
                $pointerStates = @(foreach ($u in $pointerUrls) { Get-PointerState -Url $u })
                foreach ($p in $pointerStates) {
                    if ($p.Ok) {
                        Write-Host "  指针 $($p.Url) → $($p.Version)"
                    } elseif ($p.Missing) {
                        Write-Host -ForegroundColor Red "  指针不存在（该版本从未成功构建上传）: $($p.Url)"
                    } else {
                        Write-Host -ForegroundColor Red "  指针获取失败: $($p.Url)（$($p.Error)）"
                    }
                }
                $decision = Get-RebuildDecision -StateVersion $CurrentVersion `
                    -PointerStates $pointerStates `
                    -RebuiltFor "$($CurrentState.$Category.RebuiltFor)"
                switch ($decision) {
                    "Match" {
                        Write-Host -ForegroundColor Green "$Category 指针与 state 一致，无需处理"
                    }
                    "NeedsRebuild" {
                        Write-Host -ForegroundColor Green "$Category 指针与 state 不一致（state=$CurrentVersion），按正常更新再触发一次构建..."
                        $scriptBlock = [scriptblock]::Create($CurrentState.$Category.Commands -join "`n")
                        Write-Host -ForegroundColor Yellow $scriptBlock
                        . $scriptBlock
                        $CurrentState.$Category.RebuiltFor = $CurrentVersion
                    }
                    "AlreadyRetried" {
                        # 已知取舍（审查确认）：一个版本只有一次自动重试机会，与不一致
                        # 的原因无关。若重试那局构建又失败（比如 2026-10-17 那种基础设施
                        # 故障），本通道该版本不会再自动重试，只能靠这条红告警把人引来。
                        # 这好过修指针核查前的"永远静默卡死"，但不是全自动自愈。
                        Write-Host -ForegroundColor Red "$Category 指针与 state 仍不一致，但本版本已重试过一次，跳过——多为检查源与构建源的镜像差异，需人工核对"
                    }
                    default {
                        Write-Host -ForegroundColor Yellow "$Category 指针核查返回 $decision，跳过"
                    }
                }
            }
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

    # RebuiltFor 紧跟 Version 行（State.yml 里的固定布局），同样按通道定位替换；
    # 没有该行的通道（旧布局）替换不到，等于保持原样。
    # ⚠️ 布局约定：若以后调整 State.yml 里键的顺序（比如把 Pointers 挪到
    # RebuiltFor 前面），这里的锚点会静默失配——RebuiltFor 从此不再写回，
    # 每个版本会退回"每轮都重试"。改布局必须同步改这条正则（审查 2026-10-28 提出）。
    $NewRebuiltFor = [string]$CurrentState.$Category.RebuiltFor
    $patternRebuilt = "(?m)(^$([regex]::Escape($Category)):\s*\r?\n\s*Version:\s*""[^""\r\n]*""\s*\r?\n\s*RebuiltFor:\s*"")[^""\r\n]*("")"
    $replacementRebuilt = "`${1}${NewRebuiltFor}`${2}"
    $StateContent = [regex]::Replace($StateContent, $patternRebuilt, $replacementRebuilt)
}
# 写回时保持原始文件的结尾换行状态
if ($StateContent[-1] -eq "`n") {
    Set-Content -Path $StatePath -Value $StateContent
} else {
    Set-Content -Path $StatePath -Value $StateContent -NoNewline
}