# Requires -Modules Pester
Import-Module Pester

BeforeAll {
    # 导入待测试的模块
    Import-Module "$PSScriptRoot/request.psm1"
}

AfterAll {
    Remove-Module request
}

Describe "Request-Update" {
    Context "当 QueryString 为正则表达式模式时" {
        It "应返回 number.number 格式的版本号" {
            $result = Request-Update -QueryString "regex:^(?:(?!Insider|Server|HCI).)*26100"
            $result | Should -Match '^26100\.\d+$'
        }
    }

    Context "当 Category 为 w11-24h2 时" {
        It "应返回 number.number 格式的版本号" {
            $result = Request-Update -Category "w11-24h2"
            $result | Should -Match '^26100\.\d+$'
        }
    }

    Context "当 Category 为 w10-22h2 时" {
        It "应返回 number.number 格式的版本号" {
            $result = Request-Update -Category "w10-22h2"
            $result | Should -Match '^19045\.\d+$'
        }
    }

    Context "当 Category 为 w11-19h2 时" {
        It "应抛出错误" {
            { Request-Update -Category "w11-19h2" } | Should -Throw
        }
    }
}

Describe "Get-UUPFiles" {
    Context "当提供 Id 时" {
        It "应返回非空的哈希表" {
            $result = Get-UUPFiles -Id "8c10c883-071c-43c3-bff8-8ed82fba2436"
            $result | Should -Not -Be $null
            $result | Should -BeOfType 'System.Collections.Hashtable'
            $result.Keys | Should -Contain "Microsoft-Windows-WirelessDisplay-FOD-Package-x86.cab"
        }
    }
}

Describe "Get-UUPFile" {
    Context "当提供 Id 和 FileName 时" {
        It "应返回文件详情" {
            $fileName = "Microsoft-Windows-WirelessDisplay-FOD-Package-x86.cab"
            $result = Get-UUPFile -Id "8c10c883-071c-43c3-bff8-8ed82fba2436" -FileName $fileName
            $result | Should -Not -Be $null
            $result | Should -BeOfType 'PSCustomObject'
            $result.url | Should -Match '^https?://'
            $result.size | Should -BeGreaterThan 0
            $result.sha1 | Should -Match '^[a-fA-F0-9]{40}$'
        }
        It "第二次调用应命中缓存" {
            $fileName = "Microsoft-Windows-WirelessDisplay-FOD-Package-x86.cab"
            # 第一次调用填充缓存
            $null = Get-UUPFile -Id "8c10c883-071c-43c3-bff8-8ed82fba2436" -FileName $fileName
            # 第二次调用应命中缓存
            $result = Get-UUPFile -Id "8c10c883-071c-43c3-bff8-8ed82fba2436" -FileName $fileName
            $result | Should -Not -Be $null
            $result | Should -BeOfType 'PSCustomObject'
        }
    }
}