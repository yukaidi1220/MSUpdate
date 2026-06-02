# Requires -Modules Pester
Import-Module Pester

BeforeAll {
    # 导入待测试的模块
    Import-Module "$PSScriptRoot/compare.psm1"
}

AfterAll {
    Remove-Module compare
}

Describe "Compare-Version" {
    It "当 LatestVersion 大于 CurrentVersion 时返回 $true" {
        Compare-Version -CurrentVersion "26100.1234" -LatestVersion "26100.2345" | Should -Be $true
        Compare-Version -CurrentVersion "19045.1" -LatestVersion "19045.123" | Should -Be $true
        Compare-Version -CurrentVersion "17763.123" -LatestVersion "17763.8765" | Should -Be $true
    }

    It "当 LatestVersion 等于 CurrentVersion 时返回 $false" {
        Compare-Version -CurrentVersion "26100.1" -LatestVersion "26100.1" | Should -Be $false
        Compare-Version -CurrentVersion "19045.1234" -LatestVersion "19045.1234" | Should -Be $false
    }

    It "当 LatestVersion 小于 CurrentVersion 时返回 $false" {
        Compare-Version -CurrentVersion "26100.2345" -LatestVersion "26100.1234" | Should -Be $false
        Compare-Version -CurrentVersion "19045.123" -LatestVersion "19045.1" | Should -Be $false
        Compare-Version -CurrentVersion "17763.8765" -LatestVersion "17763.123" | Should -Be $false
    }

    It "当任一版本为空时返回 $false" {
        Compare-Version -CurrentVersion "" -LatestVersion "26100.1234" | Should -Be $false
        Compare-Version -CurrentVersion "26100.1234" -LatestVersion "" | Should -Be $false
        Compare-Version -CurrentVersion $null -LatestVersion "26100.1234" | Should -Be $false
        Compare-Version -CurrentVersion "26100.1234" -LatestVersion $null | Should -Be $false
    }

    It "当版本字符串无效时返回 $false 并输出错误" {
        Compare-Version -CurrentVersion "abc" -LatestVersion "26100.1234" | Should -Be $false
        Compare-Version -CurrentVersion "26100.1234" -LatestVersion "xyz" | Should -Be $false
        Compare-Version -CurrentVersion "foo" -LatestVersion "bar" | Should -Be $false
    }
}
