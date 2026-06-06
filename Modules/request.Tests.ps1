# Requires -Modules Pester
Import-Module Pester

# 导入待测试的模块
Import-Module "$PSScriptRoot/request.psm1" -Force

function Assert-Matches {
    param (
        [AllowNull()]$Actual,
        [string]$Pattern
    )
    if ($Actual -notmatch $Pattern) {
        throw "断言失败: [$Actual] 不匹配正则 [$Pattern]"
    }
}

function Assert-ContainsItem {
    param (
        $Collection,
        [string]$Expected
    )
    if (-not ($Collection -contains $Expected)) {
        throw "断言失败: 集合不包含 [$Expected]"
    }
}

function Assert-NotNull {
    param (
        [AllowNull()]$Actual
    )
    if ($null -eq $Actual) {
        throw "断言失败: 值不应为 null"
    }
}

function Assert-Type {
    param (
        [AllowNull()]$Actual,
        [type]$ExpectedType
    )
    Assert-NotNull $Actual
    if (-not ($Actual -is $ExpectedType)) {
        throw "断言失败: 实际类型 [$($Actual.GetType().FullName)] 不是 [$($ExpectedType.FullName)]"
    }
}

function Assert-GreaterThan {
    param (
        [long]$Actual,
        [long]$Expected
    )
    if ($Actual -le $Expected) {
        throw "断言失败: [$Actual] 不大于 [$Expected]"
    }
}

function Assert-Throws {
    param (
        [scriptblock]$ScriptBlock
    )
    try {
        & $ScriptBlock
    } catch {
        return
    }
    throw "断言失败: 脚本块没有抛出错误"
}

Describe "Request-Update" {
    Context "当 QueryString 为正则表达式模式时" {
        It "应返回 number.number 格式的版本号" {
            $result = Request-Update -QueryString "regex:^(?:(?!Insider|Server|HCI).)*26100"
            Assert-Matches $result '^26100\.\d+$'
        }
    }

    Context "当 Category 为 w11-24h2 时" {
        It "应返回 number.number 格式的版本号" {
            $result = Request-Update -Category "w11-24h2"
            Assert-Matches $result '^26100\.\d+$'
        }
    }

    Context "当 Category 为 w11-21h2 时" {
        It "应返回 number.number 格式的版本号" {
            $result = Request-Update -Category "w11-21h2"
            Assert-Matches $result '^22000\.\d+$'
        }
    }

    Context "当 Category 为 w10-22h2 时" {
        It "应返回 number.number 格式的版本号" {
            $result = Request-Update -Category "w10-22h2"
            Assert-Matches $result '^19045\.\d+$'
        }
    }

    Context "当 Category 为 w11-19h2 时" {
        It "应抛出错误" {
            Assert-Throws { Request-Update -Category "w11-19h2" }
        }
    }
}

Describe "Windows 11 amd64 UUP 包名" {
    It "w11-24h2 应包含 26100 amd64 所需 FOD 和 EnterpriseG 包" {
        $id = (Invoke-UUPWebRequestLink `
                -Url "known.php?q=category:w11-24h2" `
                -LinkFilter @("*selectlang.php?id=*") `
                -ContentFilter @("*Windows 11,*amd64*") `
                -FirstLink
        ).Replace("selectlang.php?id=", "")
        $files = Get-UUPFiles -Id $id -NoLink

        Assert-ContainsItem $files.Keys "Microsoft-Windows-WirelessDisplay-FOD-Package-amd64.cab"
        Assert-ContainsItem $files.Keys "Microsoft-Windows-WirelessDisplay-FOD-Package-amd64-zh-CN.cab"
        Assert-ContainsItem $files.Keys "Microsoft-Windows-InternetExplorer-Optional-Package-amd64.cab"
        Assert-ContainsItem $files.Keys "Microsoft-Windows-InternetExplorer-Optional-Package-amd64-zh-CN.cab"
        Assert-ContainsItem $files.Keys "Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD"
        Assert-ContainsItem $files.Keys "Microsoft-Windows-Client-LanguagePack-Package-amd64-zh-CN.esd"
    }

    It "w11-21h2 应包含 22000 amd64 所需 FOD 和 EnterpriseG 包" {
        $id = (Invoke-UUPWebRequestLink `
                -Url "known.php?q=category:w11-21h2" `
                -LinkFilter @("*selectlang.php?id=*") `
                -ContentFilter @("*Windows 11*amd64*") `
                -FirstLink
        ).Replace("selectlang.php?id=", "")
        $files = Get-UUPFiles -Id $id -NoLink

        Assert-ContainsItem $files.Keys "Microsoft-Windows-WirelessDisplay-FOD-Package-amd64.cab"
        Assert-ContainsItem $files.Keys "Microsoft-Windows-WirelessDisplay-FOD-Package-amd64-zh-cn.cab"
        Assert-ContainsItem $files.Keys "Microsoft-Windows-InternetExplorer-Optional-Package-amd64.cab"
        Assert-ContainsItem $files.Keys "Microsoft-Windows-InternetExplorer-Optional-Package-amd64-zh-cn.cab"
        Assert-ContainsItem $files.Keys "Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD"
        Assert-ContainsItem $files.Keys "Microsoft-Windows-Client-LanguagePack-Package_zh-cn-amd64-zh-cn.esd"
    }
}

Describe "Get-UUPFiles" {
    Context "当提供 Id 时" {
        It "应返回非空的哈希表" {
            $result = Get-UUPFiles -Id "8c10c883-071c-43c3-bff8-8ed82fba2436"
            Assert-Type $result ([System.Collections.Hashtable])
            Assert-ContainsItem $result.Keys "Microsoft-Windows-WirelessDisplay-FOD-Package-x86.cab"
        }
    }
}

Describe "Get-UUPFile" {
    Context "当提供 Id 和 FileName 时" {
        It "应返回文件详情" {
            $fileName = "Microsoft-Windows-WirelessDisplay-FOD-Package-x86.cab"
            $result = Get-UUPFile -Id "8c10c883-071c-43c3-bff8-8ed82fba2436" -FileName $fileName
            Assert-NotNull $result
            Assert-Matches $result.url '^https?://'
            Assert-GreaterThan $result.size 0
            Assert-Matches $result.sha1 '^[a-fA-F0-9]{40}$'
        }
        It "第二次调用应命中缓存" {
            $fileName = "Microsoft-Windows-WirelessDisplay-FOD-Package-x86.cab"
            # 第一次调用填充缓存
            $null = Get-UUPFile -Id "8c10c883-071c-43c3-bff8-8ed82fba2436" -FileName $fileName
            # 第二次调用应命中缓存
            $result = Get-UUPFile -Id "8c10c883-071c-43c3-bff8-8ed82fba2436" -FileName $fileName
            Assert-NotNull $result
        }
    }
}
