# Requires -Modules Pester
Import-Module Pester

BeforeAll {
    Import-Module "$PSScriptRoot/statepointer.psm1"
    # Pester 6 里 It 的作用域看不到顶层函数，助手必须定义在 BeforeAll 里
    function New-PointerState {
        param([bool]$Ok = $true, [bool]$Missing = $false, [string]$Version = "", [string]$Error = "")
        [pscustomobject]@{ Url = "https://x/latest_x64.json"; Ok = $Ok; Missing = $Missing; Version = $Version; Error = $Error }
    }
}

AfterAll {
    Remove-Module statepointer -ErrorAction SilentlyContinue
}

Describe "Get-RebuildDecision" {
    It "全部指针与 state 一致时返回 Match" {
        $pointers = @(New-PointerState -Version "28000.3231")
        Get-RebuildDecision -StateVersion "28000.3231" -PointerStates $pointers | Should -Be "Match"
    }

    It "多指针全部一致时返回 Match（w11-24h2 消费版 + LTSC 双指针的形态）" {
        $pointers = @(
            (New-PointerState -Version "26100.9725"),
            (New-PointerState -Version "26100.9725")
        )
        Get-RebuildDecision -StateVersion "26100.9725" -PointerStates $pointers | Should -Be "Match"
    }

    It "指针版本与 state 不一致时返回 NeedsRebuild（26H1 实况：state 3351、指针 3231）" {
        $pointers = @(New-PointerState -Version "28000.3231")
        Get-RebuildDecision -StateVersion "28000.3351" -PointerStates $pointers | Should -Be "NeedsRebuild"
    }

    It "多指针中只要有一个不一致就返回 NeedsRebuild" {
        $pointers = @(
            (New-PointerState -Version "26100.9725"),
            (New-PointerState -Version "26100.9000")
        )
        Get-RebuildDecision -StateVersion "26100.9725" -PointerStates $pointers | Should -Be "NeedsRebuild"
    }

    It "指针 404（从未产出）视为不一致，返回 NeedsRebuild" {
        $pointers = @(New-PointerState -Ok $false -Missing $true)
        Get-RebuildDecision -StateVersion "17763.9378" -PointerStates $pointers | Should -Be "NeedsRebuild"
    }

    It "指针取失败（网络/5xx）同样视为未确认一致" {
        $pointers = @(New-PointerState -Ok $false -Error "HTTP 502")
        Get-RebuildDecision -StateVersion "19045.7811" -PointerStates $pointers | Should -Be "NeedsRebuild"
    }

    It "指针取到 JSON 但缺 os_version（空版本）视为不一致" {
        $pointers = @(New-PointerState -Version "")
        Get-RebuildDecision -StateVersion "19045.7811" -PointerStates $pointers | Should -Be "NeedsRebuild"
    }

    It "不一致且 RebuiltFor 等于当前 state 版本时返回 AlreadyRetried（防每轮白打构建）" {
        $pointers = @(New-PointerState -Version "28000.3231")
        Get-RebuildDecision -StateVersion "28000.3351" -PointerStates $pointers -RebuiltFor "28000.3351" | Should -Be "AlreadyRetried"
    }

    It "指针 404 且已重试过同样返回 AlreadyRetried" {
        $pointers = @(New-PointerState -Ok $false -Missing $true)
        Get-RebuildDecision -StateVersion "17763.9378" -PointerStates $pointers -RebuiltFor "17763.9378" | Should -Be "AlreadyRetried"
    }

    It "RebuiltFor 是旧版本时不拦截（新版本要重新获得一次重试机会）" {
        $pointers = @(New-PointerState -Version "26200.9000")
        Get-RebuildDecision -StateVersion "26200.9807" -PointerStates $pointers -RebuiltFor "26200.8968" | Should -Be "NeedsRebuild"
    }

    It "RebuiltFor 为空时不拦截" {
        $pointers = @(New-PointerState -Version "26200.9000")
        Get-RebuildDecision -StateVersion "26200.9807" -PointerStates $pointers -RebuiltFor "" | Should -Be "NeedsRebuild"
    }

    It "没有配置指针时返回 NoPointers（保持旧行为）" {
        Get-RebuildDecision -StateVersion "19045.7811" -PointerStates @() | Should -Be "NoPointers"
    }
}

Describe "Get-PointerState" {
    # 模块内部调用的是模块作用域里的 Invoke-WebRequest，mock 必须打在模块作用域里，
    # 否则会真的发网络请求（2026-10-28 实测：mock 打在测试文件作用域时不拦截）。
    It "200 且带 os_version 时返回 Ok 和版本" {
        InModuleScope statepointer {
            Mock Invoke-WebRequest {
                [pscustomobject]@{ StatusCode = 200; Content = '{"os_version":"28000.3231","os_ver":"11"}' }
            }
            $r = Get-PointerState -Url "https://x/latest_x64.json"
            $r.Ok | Should -Be $true
            $r.Missing | Should -Be $false
            $r.Version | Should -Be "28000.3231"
        }
    }

    It "404 时返回 Missing（OpenList 对不存在的文件返回 404）" {
        InModuleScope statepointer {
            Mock Invoke-WebRequest {
                [pscustomobject]@{ StatusCode = 404; Content = "not found" }
            }
            $r = Get-PointerState -Url "https://x/latest_x64.json"
            $r.Ok | Should -Be $false
            $r.Missing | Should -Be $true
        }
    }

    It "5xx 时返回 Ok=false 且带原因，不算 Missing" {
        InModuleScope statepointer {
            Mock Invoke-WebRequest {
                [pscustomobject]@{ StatusCode = 502; Content = "bad gateway" }
            }
            $r = Get-PointerState -Url "https://x/latest_x64.json"
            $r.Ok | Should -Be $false
            $r.Missing | Should -Be $false
            $r.Error | Should -Be "HTTP 502"
        }
    }

    It "抛异常（超时/DNS）时返回 Ok=false 且 Error 带消息" {
        InModuleScope statepointer {
            Mock Invoke-WebRequest { throw "The operation has timed out." }
            $r = Get-PointerState -Url "https://x/latest_x64.json"
            $r.Ok | Should -Be $false
            $r.Error | Should -BeLike "*timed out*"
        }
    }
}

Describe "Get-ChannelPointers" {
    It "没配 Pointers 的通道（$null）返回空数组——这是 @(`$null).Count 等于 1 的坑的防线" {
        (Get-ChannelPointers -Pointers $null) | Should -Be @()
        (Get-ChannelPointers -Pointers $null).Count | Should -Be 0
    }

    It "正常列表原样通过，空项被滤掉" {
        $r = Get-ChannelPointers -Pointers @("https://a/latest_x64.json", "", "https://b/latest_x64.json")
        $r.Count | Should -Be 2
        $r[0] | Should -Be "https://a/latest_x64.json"
        $r[1] | Should -Be "https://b/latest_x64.json"
    }

    It "标量写法（Pointers: <url>）不会按字符逐个拆开" {
        $r = Get-ChannelPointers -Pointers "https://a/latest_x64.json"
        $r.Count | Should -Be 1
        $r[0] | Should -Be "https://a/latest_x64.json"
    }

    It "全空列表返回空数组" {
        (Get-ChannelPointers -Pointers @("", "")) | Should -Be @()
    }
}
