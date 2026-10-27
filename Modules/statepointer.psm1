#Requires -Version 7
# 指针一致性核查：state 记录的是"检查源认为的最新版"，但不保证上次构建真的
# 产出了这一版——构建可能失败（2026-10-17 state 推到 28000.3351 后两局 make
# 全挂在旧 mupan 存储上，九天没人发现），也可能构建源与检查源看到的版本不同
# （2026-10-26 实测：state 28000.3351、实际产出 28000.3231）。指针里的
# os_version 是"线上到底是谁"的唯一可信来源，两者不一致就按正常更新的方式
# 再触发一次构建。

function Get-PointerState {
    <#
    .SYNOPSIS
    拉取一个 latest 指针，归一化成判定所需的形状。
    .RETURN
    Ok      = 取到了 JSON（Version 可能为空串，同样视为异常数据）
    Missing = 服务端明确 404（指针从未产出，即这一版从未成功构建上传）
    其余    = 取失败（网络/5xx/解析失败），Error 里带原因
    #>
    [OutputType([pscustomobject])]
    param (
        [Parameter(Mandatory)][string]$Url
    )
    $result = [pscustomobject]@{
        Url     = $Url
        Ok      = $false
        Missing = $false
        Version = ""
        Error   = ""
    }
    try {
        $res = Invoke-WebRequest -Uri $Url -SkipHttpErrorCheck -TimeoutSec 30
        if ($res.StatusCode -eq 404) {
            $result.Missing = $true
            return $result
        }
        if ($res.StatusCode -ne 200) {
            $result.Error = "HTTP $($res.StatusCode)"
            return $result
        }
        $json = $res.Content | ConvertFrom-Json
        $result.Ok = $true
        $result.Version = [string]$json.os_version
        return $result
    } catch {
        $result.Error = $_.Exception.Message
        return $result
    }
}

function Get-RebuildDecision {
    <#
    .SYNOPSIS
    纯判定：所有指针都取到、且 os_version 与 state 完全一致，才算正常。
    .NOTES
    任何缺失/不一致/取失败都算"未确认一致"→ 需要重建；但同一 state 版本只重试
    一次（RebuiltFor 记录本次已重试过的版本），防止检查源与构建源永久分歧时
    每轮都白打一次构建。返回值：
      Match           全部一致
      NeedsRebuild    存在未确认一致的指针，且本版本尚未重试过
      AlreadyRetried  存在不一致，但本版本已重试过一次，只告警不再触发
      NoPointers      该通道没有配置指针（保持旧行为，跳过核查）
    #>
    [OutputType([string])]
    param (
        [Parameter(Mandatory)][string]$StateVersion,
        [AllowEmptyCollection()][object[]]$PointerStates,
        [string]$RebuiltFor = ""
    )
    if ($PointerStates.Count -eq 0) { return "NoPointers" }

    $unconfirmed = @($PointerStates | Where-Object {
        (-not $_.Ok) -or ($_.Version -ne $StateVersion)
    })
    if ($unconfirmed.Count -eq 0) { return "Match" }
    if (-not [string]::IsNullOrEmpty($RebuiltFor) -and $RebuiltFor -eq $StateVersion) {
        return "AlreadyRetried"
    }
    return "NeedsRebuild"
}

Export-ModuleMember -Function Get-PointerState, Get-RebuildDecision
