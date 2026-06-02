#Requires -Version 7
$ErrorActionPreference = 'Stop'

Import-Module "$PSScriptRoot\Modules\request.psm1"
Import-Module "$PSScriptRoot\Modules\aria2.psm1"
Import-Module "$PSScriptRoot\Modules\msstore.psm1"

# 定义辅助函数

# 设置系统信息
switch ($MakeVersion) {
    "w1126h1a64" {
        # 制作 Win11 26H1 ARM64
        $os_ver = "11"
        $os_rsversion = "26H1"
        $os_build = "28000"
        $os_edition = "CoreCountrySpecific"
        $os_display = "Windows $os_ver $os_rsversion"
        $os_arch = "arm64"
        $os_lang = "zh-cn"
        $os_path = "/系统/Windows/Win10/Res/28000/arm64/28000.1.251103-1709.BR_RELEASE_CLIENTCHINA_OEM_A64FRE_ZH-CN.ISO"
        $os_md5 = "E8E187CAC22085FED8420BE8B97DE54A"
        $UpdateFromUUP = $true
        $uupid = (Invoke-UUPWebRequestLink `
                -Url "known.php?q=category:w11-26h1" `
                -LinkFilter @("*selectlang.php?id=*") `
                -ContentFilter @("*Windows 11,*arm64*") `
                -FirstLink
        ).Replace("selectlang.php?id=", "")
        $Miracast = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-WirelessDisplay-FOD-Package-arm64.cab"
        $MiracastLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-WirelessDisplay-FOD-Package-arm64-zh-CN.cab"
        $iexplorer = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-InternetExplorer-Optional-Package-arm64.cab"
        $iexplorerLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-InternetExplorer-Optional-Package-arm64-zh-CN.cab"
        $entgpack = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD"
        $entgLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-Client-LanguagePack-Package-arm64-zh-CN.esd"
        $msstore = $true
    }
    "w1126h164" {
        # 制作 Win11 26H1 X64
        $os_ver = "11"
        $os_rsversion = "26H1"
        $os_build = "28000"
        $os_edition = "CoreCountrySpecific"
        $os_display = "Windows $os_ver $os_rsversion"
        $os_arch = "x64"
        $os_lang = "zh-cn"
        $os_path = "/系统/Windows/Win10/Res/28000/amd64/28000.1.251103-1709.BR_RELEASE_CLIENTCHINA_OEM_X64FRE_ZH-CN.ISO"
        $os_md5 = "521276FBA781C5B151E89596EE32FC3D"
        $UpdateFromUUP = $true
        $uupid = (Invoke-UUPWebRequestLink `
                -Url "known.php?q=category:w11-26h1" `
                -LinkFilter @("*selectlang.php?id=*") `
                -ContentFilter @("*Windows 11,*amd64*") `
                -FirstLink
        ).Replace("selectlang.php?id=", "")
        $Miracast = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-WirelessDisplay-FOD-Package-amd64.cab"
        $MiracastLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-WirelessDisplay-FOD-Package-amd64-zh-CN.cab"
        $iexplorer = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-InternetExplorer-Optional-Package-amd64.cab"
        $iexplorerLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-InternetExplorer-Optional-Package-amd64-zh-CN.cab"
        $entgpack = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD"
        $entgLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-Client-LanguagePack-Package-amd64-zh-CN.esd"
        $msstore = $true
    }
    "w1125h2a64" {
        # 制作 Win11 25H2 ARM64
        $os_ver = "11"
        $os_rsversion = "25H2"
        $os_build = "26200"
        $os_edition = "CoreCountrySpecific"
        $os_display = "Windows $os_ver $os_rsversion"
        $os_arch = "arm64"
        $os_lang = "zh-cn"
        $os_path = "/系统/MSDN/NT10.0_Win11/26100_24H2/1742_OEM/X23-81947_26100.1742.240906-0331.ge_release_svc_refresh_CLIENTCHINA_OEM_A64FRE_zh-cn.iso"
        # $os_path = "/系统/MSDN/NT10.0_Win11/26100_24H2/1742_RTM/Win11_24H2_China_GGK_Chinese_Simplified_Arm64.iso"
        $os_md5 = "8cc8080e1c4b08ccd0ad4435ac0f2e5c"
        $UpdateFromUUP = $true
        $uupid = (Invoke-UUPWebRequestLink `
                -Url "known.php?q=category:w11-25h2" `
                -LinkFilter @("*selectlang.php?id=*") `
                -ContentFilter @("*Windows 11,*arm64*") `
                -FirstLink
        ).Replace("selectlang.php?id=", "")
        $Miracast = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-WirelessDisplay-FOD-Package-arm64.cab"
        $MiracastLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-WirelessDisplay-FOD-Package-arm64-zh-CN.cab"
        $iexplorer = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-InternetExplorer-Optional-Package-arm64.cab"
        $iexplorerLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-InternetExplorer-Optional-Package-arm64-zh-CN.cab"
        $entgpack = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD"
        $entgLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-Client-LanguagePack-Package-arm64-zh-CN.esd"
        $msstore = $true
        $Cleanup = $false
    }
    "w1125h264" {
        # 制作 Win11 25H2 X64
        $os_ver = "11"
        $os_rsversion = "25H2"
        $os_build = "26200"
        $os_edition = "CoreCountrySpecific"
        $os_display = "Windows $os_ver $os_rsversion"
        $os_arch = "x64"
        $os_lang = "zh-cn"
        $os_path = "/系统/MSDN/NT10.0_Win11/26100_24H2/1742_OEM/X23-81948_26100.1742.240906-0331.ge_release_svc_refresh_CLIENTCHINA_OEM_x64FRE_zh-cn.iso"
        # $os_path = "/系统/MSDN/NT10.0_Win11/26100_24H2/1742_RTM/Win11_24H2_China_GGK_Chinese_Simplified_x64.iso"
        $os_md5 = "e5c05b0215d3e4af2f2fd4ea16252f91"
        $UpdateFromUUP = $true
        $uupid = (Invoke-UUPWebRequestLink `
                -Url "known.php?q=category:w11-25h2" `
                -LinkFilter @("*selectlang.php?id=*") `
                -ContentFilter @("*Windows 11,*amd64*") `
                -FirstLink
        ).Replace("selectlang.php?id=", "")
        $Miracast = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-WirelessDisplay-FOD-Package-amd64.cab"
        $MiracastLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-WirelessDisplay-FOD-Package-amd64-zh-CN.cab"
        $iexplorer = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-InternetExplorer-Optional-Package-amd64.cab"
        $iexplorerLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-InternetExplorer-Optional-Package-amd64-zh-CN.cab"
        $entgpack = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD"
        $entgLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-Client-LanguagePack-Package-amd64-zh-CN.esd"
        $msstore = $true
        $Cleanup = $false
    }
    "w11lt24a64" {
        # 制作 Win11 LTSC2024 ARM64
        $os_ver = "11"
        $os_rsversion = "24H2"
        $os_build = "26100"
        $os_edition = "LTSC2024"
        $os_display = "Windows $os_ver LTSC 2024"
        $os_arch = "arm64"
        $os_lang = "zh-cn"
        $os_path = "/系统/Windows/Win10/Res/26100/arm64/26100.1742.240906-0331.ge_release_svc_refresh_CLIENT_ENTERPRISES_OEM_A64FRE_zh-cn.iso"
        $os_md5 = "53ec7752fceea6f95329a06955c3ff59"
        $UpdateFromUUP = $true
        $uupid = (Invoke-UUPWebRequestLink `
                -Url "known.php?q=category:w11-24h2" `
                -LinkFilter @("*selectlang.php?id=*") `
                -ContentFilter @("*Windows 11,*arm64*") `
                -FirstLink
        ).Replace("selectlang.php?id=", "")
        $iexplorer = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-InternetExplorer-Optional-Package-arm64.cab"
        $iexplorerLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-InternetExplorer-Optional-Package-arm64-zh-CN.cab"
        $MultiEdition = $false
        $Cleanup = $false
    }
    "w11lt2464" {
        # 制作 Win11 LTSC2024 X64
        $os_ver = "11"
        $os_rsversion = "24H2"
        $os_build = "26100"
        $os_edition = "LTSC2024"
        $os_display = "Windows $os_ver LTSC 2024"
        $os_arch = "x64"
        $os_lang = "zh-cn"
        $os_path = "/系统/MSDN/NT10.0_Win11/26100_LTSC2024/1742_RTM/zh-cn_windows_11_enterprise_ltsc_2024_x64_dvd_cff9cd2d.iso"
        $os_md5 = "1a13ade0178082432f90df951a88842f"
        $UpdateFromUUP = $true
        $uupid = (Invoke-UUPWebRequestLink `
                -Url "known.php?q=category:w11-24h2" `
                -LinkFilter @("*selectlang.php?id=*") `
                -ContentFilter @("*Windows 11,*amd64*") `
                -FirstLink
        ).Replace("selectlang.php?id=", "")
        $iexplorer = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-InternetExplorer-Optional-Package-amd64.cab"
        $iexplorerLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-InternetExplorer-Optional-Package-amd64-zh-CN.cab"
        $Cleanup = $false
    }
    "w1123h2a64" {
        # 制作 Win11 23H2 ARM64
        $os_ver = "11"
        $os_rsversion = "23H2"
        $os_build = "22631"
        $os_edition = "CoreCountrySpecific"
        $os_display = "Windows $os_ver $os_rsversion"
        $os_arch = "arm64"
        $os_lang = "zh-cn"
        $os_path = "/系统/Windows/Win10/Res/22621/22621.1.220506-1250.NI_RELEASE_CLIENTCHINA_OEM_A64FRE_ZH-CN.ISO"
        $os_md5 = "6ef5a0a8eb488a8064d8ca33f64ff835"
        $uupid = (Invoke-UUPWebRequestLink `
                -Url "known.php?q=category:w11-23h2" `
                -LinkFilter @("*selectlang.php?id=*") `
                -ContentFilter @("*Windows 11*arm64*") `
                -FirstLink
        ).Replace("selectlang.php?id=", "")
        $Miracast = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-WirelessDisplay-FOD-Package-arm64.cab"
        $MiracastLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-WirelessDisplay-FOD-Package-arm64-zh-CN.cab"
        $iexplorer = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-InternetExplorer-Optional-Package-arm64.cab"
        $iexplorerLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-InternetExplorer-Optional-Package-arm64-zh-CN.cab"
        $entgpack = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD"
        $entgLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-Client-LanguagePack-Package_zh-cn-arm64-zh-cn.esd"
        $msstore = $true
    }
    "w1123h264" {
        # 制作 Win11 23H2 X64
        $os_ver = "11"
        $os_rsversion = "23H2"
        $os_build = "22631"
        $os_edition = "CoreCountrySpecific"
        $os_display = "Windows $os_ver $os_rsversion"
        $os_arch = "x64"
        $os_lang = "zh-cn"
        $os_path = "/系统/MSDN/NT10.0_Win11/22631_23H2/2861_202312/Win11_23H2_China_GGK_Chinese_Simplified_x64v2.iso"
        $os_md5 = "99835f9f2efee5f30d0348f749484a88"
        if ($true -eq $UpdateFromUUP) {
            $uupid = (Invoke-UUPWebRequestLink `
                    -Url "known.php?q=category:w11-23h2" `
                    -LinkFilter @("*selectlang.php?id=*") `
                    -ContentFilter @("*Windows 11*amd64*") `
                    -FirstLink
            ).Replace("selectlang.php?id=", "")
            $Miracast = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-WirelessDisplay-FOD-Package-amd64.cab"
            $MiracastLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-WirelessDisplay-FOD-Package-amd64-zh-CN.cab"
            $iexplorer = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-InternetExplorer-Optional-Package-amd64.cab"
            $iexplorerLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-InternetExplorer-Optional-Package-amd64-zh-CN.cab"
            $entgpack = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD"
            $entgLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-Client-LanguagePack-Package_zh-cn-amd64-zh-cn.esd"
        } else {
            $WUScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/script_22621_x64.meta4"
            $Miracast = "https://list.xrgzs.top/d/pxy/System/Windows/Win10/Res/22621/amd64/Microsoft-Windows-WirelessDisplay-FOD-Package~31bf3856ad364e35~amd64~~.cab"
            $MiracastLP = "https://list.xrgzs.top/d/pxy/System/Windows/Win10/Res/22621/amd64/Microsoft-Windows-WirelessDisplay-FOD-Package~31bf3856ad364e35~amd64~zh-CN~.cab"
            $iexplorer = "https://list.xrgzs.top/d/pxy/System/Windows/Win10/Res/22621/amd64/Microsoft-Windows-InternetExplorer-Optional-Package~31bf3856ad364e35~amd64~~.cab"
            $iexplorerLP = "https://list.xrgzs.top/d/pxy/System/Windows/Win10/Res/22621/amd64/Microsoft-Windows-InternetExplorer-Optional-Package~31bf3856ad364e35~amd64~zh-CN~.cab"
            $entgpack = "https://list.xrgzs.top/d/pxy/System/Windows/Win10/Res/22621/amd64/Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD"
            $entgLP = "https://list.xrgzs.top/d/pxy/System/Windows/Win10/Res/22621/amd64/Microsoft-Windows-Client-LanguagePack-Package_zh-cn-amd64-zh-cn.esd"
        }
        $msstore = $true
    }
    "w1022h2a64" {
        # 制作 Win10 22H2 ARM64
        $os_ver = "10"
        $os_rsversion = "22H2"
        $os_build = "19045"
        $os_edition = "CoreCountrySpecific"
        $os_display = "Windows $os_ver $os_rsversion"
        $os_arch = "arm64"
        $os_lang = "zh-cn"
        $os_path = "/系统/Windows/Win10/Res/19041/arm64/19041.1.191206-1406.VB_RELEASE_CLIENTCHINA_OEM_A64FRE_ZH-CN.ISO"
        $os_md5 = "d84ddb4150d7c699a5dabf91a1430786"
        $UpdateFromUUP = $true
        $uupid = (Invoke-UUPWebRequestLink `
                -Url "known.php?q=category:w10-22h2" `
                -LinkFilter @("*selectlang.php?id=*") `
                -ContentFilter @("*Windows 10,*arm64*") `
                -FirstLink
        ).Replace("selectlang.php?id=", "")
        $Miracast = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-WirelessDisplay-FOD-Package-arm64.cab"
        $MiracastLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-WirelessDisplay-FOD-Package-arm64-zh-cn.cab"
        $entgpack = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD"
        $entgLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-Client-LanguagePack-Package_zh-cn-arm64-zh-cn.esd"
        $NETScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/netfx4.8/script_netfx4.8_19041_arm64.meta4"
        $msstore = $true
    }
    "w1022h264" {
        # 制作 Win10 22H2 X64
        $os_ver = "10"
        $os_rsversion = "22H2"
        $os_build = "19045"
        $os_edition = "CoreCountrySpecific"
        $os_display = "Windows $os_ver $os_rsversion"
        $os_arch = "x64"
        $os_lang = "zh-cn"
        $os_path = "/系统/MSDN/NT10.0_Win10/19045_22H2/2006_RTM/Win10_22H2_China_GGK_Chinese_Simplified_x64.iso"
        $os_md5 = "67615f768a49392d5e080e25a0036975"
        if ($true -eq $UpdateFromUUP) {
            $uupid = (Invoke-UUPWebRequestLink `
                    -Url "known.php?q=category:w10-22h2" `
                    -LinkFilter @("*selectlang.php?id=*") `
                    -ContentFilter @("*Windows 10,*amd64*") `
                    -FirstLink
            ).Replace("selectlang.php?id=", "")
            $Miracast = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-WirelessDisplay-FOD-Package-amd64.cab"
            $MiracastLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-WirelessDisplay-FOD-Package-amd64-zh-cn.cab"
            $entgpack = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD"
            $entgLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-Client-LanguagePack-Package_zh-cn-amd64-zh-cn.esd"
        } else {
            $WUScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/script_19041_x64.meta4"
            $Miracast = "https://list.xrgzs.top/d/pxy/System/Windows/Win10/Res/19041/amd64/Microsoft-Windows-WirelessDisplay-FOD-Package~31bf3856ad364e35~amd64~~.cab"
            $MiracastLP = "https://list.xrgzs.top/d/pxy/System/Windows/Win10/Res/19041/amd64/Microsoft-Windows-WirelessDisplay-FOD-Package~31bf3856ad364e35~amd64~zh-CN~.cab"
            $entgpack = "https://list.xrgzs.top/d/pxy/System/Windows/Win10/Res/19041/amd64/Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD"
            $entgLP = "https://list.xrgzs.top/d/pxy/System/Windows/Win10/Res/19041/amd64/Microsoft-Windows-Client-LanguagePack-Package_zh-cn-amd64-zh-cn.esd"
        }
        $NETScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/netfx4.8.1/script_netfx4.8.1_19041_x64.meta4"
        $msstore = $true
    }
    "w1022h232" {
        # 制作 Win10 22H2 X86
        $os_ver = "10"
        $os_rsversion = "22H2"
        $os_build = "19045"
        $os_edition = "CoreCountrySpecific"
        $os_display = "Windows $os_ver $os_rsversion"
        $os_arch = "x86"
        $os_lang = "zh-cn"
        $os_path = "/系统/MSDN/NT10.0_Win10/19045_22H2/2006_RTM/Win10_22H2_China_GGK_Chinese_Simplified_x32.iso"
        $os_md5 = "e85fc523e95410fb49901afab1e02876"
        if ($true -eq $UpdateFromUUP) {
            $uupid = (Invoke-UUPWebRequestLink `
                    -Url "known.php?q=category:w10-22h2" `
                    -LinkFilter @("*selectlang.php?id=*") `
                    -ContentFilter @("*Windows 10,*x86*") `
                    -FirstLink
            ).Replace("selectlang.php?id=", "")
            $Miracast = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-WirelessDisplay-FOD-Package-x86.cab"
            $MiracastLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-WirelessDisplay-FOD-Package-x86-zh-cn.cab"
            $entgpack = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD"
            $entgLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-Client-LanguagePack-Package_zh-cn-x86-zh-cn.esd"
        } else {
            $WUScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/script_19041_x86.meta4"
            $Miracast = "https://list.xrgzs.top/d/pxy/System/Windows/Win10/Res/19041/x86/Microsoft-Windows-WirelessDisplay-FOD-Package~31bf3856ad364e35~x86~~.cab"
            $MiracastLP = "https://list.xrgzs.top/d/pxy/System/Windows/Win10/Res/19041/x86/Microsoft-Windows-WirelessDisplay-FOD-Package~31bf3856ad364e35~x86~zh-CN~.cab"
            $entgpack = "https://list.xrgzs.top/d/pxy/System/Windows/Win10/Res/19041/x86/Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD"
            $entgLP = "https://list.xrgzs.top/d/pxy/System/Windows/Win10/Res/19041/x86/Microsoft-Windows-Client-LanguagePack-Package_zh-cn-x86-zh-cn.esd"
        }
        $NETScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/netfx4.8.1/script_netfx4.8.1_19041_x86.meta4"
        $msstore = $true
    }
    "w10lt2164" {
        # 制作 Win10 LTSC2021 X64
        $os_ver = "10"
        $os_rsversion = "21H2"
        $os_build = "19044"
        $os_edition = "LTSC2021"
        $os_display = "Windows $os_ver LTSC 2021"
        $os_arch = "x64"
        $os_lang = "zh-cn"
        $os_path = "/系统/MSDN/NT10.0_Win10/19044_LTSC2021/zh-cn_windows_10_enterprise_ltsc_2021_x64_dvd_033b7312.iso"
        $os_md5 = "2579b3865c0591ead3a2b45af3cabeee"
        if ($true -eq $UpdateFromUUP) {
            $uupid = (Invoke-UUPWebRequestLink `
                    -Url "known.php?q=category:w10-21h2" `
                    -LinkFilter @("*selectlang.php?id=*") `
                    -ContentFilter @("*Windows 10,*amd64*") `
                    -FirstLink
            ).Replace("selectlang.php?id=", "")
        } else {
            $WUScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/script_19041_x64.meta4"
        }
        $NETScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/netfx4.8.1/script_netfx4.8.1_19041_x64.meta4"
    }
    "w10lt2132" {
        # 制作 Win10 LTSC2021 X86
        $os_ver = "10"
        $os_rsversion = "21H2"
        $os_build = "19044"
        $os_edition = "LTSC2021"
        $os_display = "Windows $os_ver LTSC 2021"
        $os_arch = "x86"
        $os_lang = "zh-cn"
        $os_path = "/系统/MSDN/NT10.0_Win10/19044_LTSC2021/zh-cn_windows_10_enterprise_ltsc_2021_x86_dvd_30600d9c.iso"
        $os_md5 = "a4f6f8f67d9a59ad462ff51506c5cd3a"
        if ($true -eq $UpdateFromUUP) {
            $uupid = (Invoke-UUPWebRequestLink `
                    -Url "known.php?q=category:w10-21h2" `
                    -LinkFilter @("*selectlang.php?id=*") `
                    -ContentFilter @("*Windows 10,*x86*") `
                    -FirstLink
            ).Replace("selectlang.php?id=", "")
        } else {
            $WUScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/script_19041_x86.meta4"
        }
        $NETScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/netfx4.8.1/script_netfx4.8.1_19041_x86.meta4"
    }
    "w10lt1964" {
        # 制作 Win10 LTSC2019 X64
        $os_ver = "10"
        $os_rsversion = "1809"
        $os_build = "17763"
        $os_edition = "LTSC2019"
        $os_display = "Windows $os_ver LTSC 2019"
        $os_arch = "x64"
        $os_lang = "zh-cn"
        $os_path = "/系统/MSDN/NT10.0_Win10/17763_LTSC2019/1_RTM/cn_windows_10_enterprise_ltsc_2019_x64_dvd_2efc9ac2.iso"
        $os_md5 = "2eb4d2bf684f3852458991c654907d12"
        if ($true -eq $UpdateFromUUP) {
            $uupid = (Invoke-UUPWebRequestLink `
                    -Url "known.php?q=category:w10-1809" `
                    -LinkFilter @("*selectlang.php?id=*") `
                    -ContentFilter @("*Windows 10*amd64*") `
                    -FirstLink
            ).Replace("selectlang.php?id=", "")
        } else {
            $WUScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/script_17763_x64.meta4"
        }
        $NETScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/netfx4.8/script_netfx4.8_17763_x64.meta4"
    }
    "w10lt1932" {
        # 制作 Win10 LTSC2019 X86
        $os_ver = "10"
        $os_rsversion = "1809"
        $os_build = "17763"
        $os_edition = "LTSC2019"
        $os_display = "Windows $os_ver LTSC 2019"
        $os_arch = "x86"
        $os_lang = "zh-cn"
        $os_path = "/系统/MSDN/NT10.0_Win10/17763_LTSC2019/1_RTM/cn_windows_10_enterprise_ltsc_2019_x86_dvd_2908ee10.iso"
        $os_md5 = "c5d58f64093ed0693aa770e3f7b98e13"
        if ($true -eq $UpdateFromUUP) {
            $uupid = (Invoke-UUPWebRequestLink `
                    -Url "known.php?q=category:w10-1809" `
                    -LinkFilter @("*selectlang.php?id=*") `
                    -ContentFilter @("*Windows 10*x86*") `
                    -FirstLink
            ).Replace("selectlang.php?id=", "")
        } else {
            $WUScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/script_17763_x86.meta4"
        }
        $NETScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/netfx4.8/script_netfx4.8_17763_x86.meta4"
    }
    "w10lt1664" {
        # 制作 Win10 LTSB2016 X64 (不支持 UUP)
        $os_ver = "10"
        $os_rsversion = "1607"
        $os_build = "14393"
        $os_edition = "LTSB2016"
        $os_display = "Windows $os_ver LTSB 2016"
        $os_arch = "x64"
        $os_lang = "zh-cn"
        $os_path = "/系统/MSDN/NT10.0_Win10/14393_LTSB2016/cn_windows_10_enterprise_2016_ltsb_x64_dvd_9060409.iso"
        $os_md5 = "0343dc55184a406af9a8ab0d964cccc6"
        $WUScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/script_14393_x64.meta4"
        $NETScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/netfx4.8/script_netfx4.8_14393_x64.meta4"
        $MultiEdition = $false
    }
    "w10lt1632" {
        # 制作 Win10 LTSB2016 X86 (不支持 UUP)
        $os_ver = "10"
        $os_rsversion = "1607"
        $os_build = "14393"
        $os_edition = "LTSB2016"
        $os_display = "Windows $os_ver LTSB 2016"
        $os_arch = "x86"
        $os_lang = "zh-cn"
        # $os_path = "/系统/MSDN/NT10.0_Win10/14393_LTSB2016/cn_windows_10_enterprise_2016_ltsb_x86_dvd_9057089.iso"
        # $os_md5 = "e628fac2494476612967fdd86ae1b547"
        $os_path = "/系统/Windows/Win10/LTSB2016/cn_windows_10_enterprise_2016_ltsb_x86_dvd_9057089_FixSSShim.iso"
        $os_md5 = "dd23b8a175d76564c257b189fa7a3916"
        $WUScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/script_14393_x86.meta4"
        $NETScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/netfx4.8/script_netfx4.8_14393_x86.meta4"
        $MultiEdition = $false
    }
    default {
        Write-Error "未定义或不支持的操作系统版本！
        示例:
            `$MakeVersion   = [string] `"w1064`"
            `$UpdateFromUUP = [bool]   `$False
            `$MultiEdition  = [bool]   `$True
            .\msupdate.ps1
        "
    }
}

# LTS 版本修正
if ($os_edition -like "*LTS*") {
    $msstore = $true
    $os_release = $os_edition
} else {
    $os_release = $os_rsversion
    # os_edition 修正
    if ($MultiEdition -eq $true) {
        $os_edition = "Multi"
    }
}

# 清理临时文件
Remove-Item -Path ".\temp\" -Recurse -ErrorAction Ignore
Remove-Item -Path ".\entg\" -Recurse -ErrorAction Ignore
Remove-Item -Path ".\patch\" -Recurse -ErrorAction Ignore
Remove-Item -Path ".\fod\" -Recurse -ErrorAction Ignore
Remove-Item -Path ".\W10UI.cmd" -Recurse -ErrorAction Ignore
New-Item -Path ".\temp\" -ItemType "directory" -ErrorAction Ignore
New-Item -Path ".\bin\" -ItemType "directory" -ErrorAction Ignore

# 安装依赖
function Test-Hashes {
    param (
        [hashtable]$Hashes,
        [string]$Algorithm
    )
    return $Hashes.GetEnumerator() | ForEach-Object {
        $file = $_.Key
        $expectedHash = $_.Value
        Write-Host -ForegroundColor Blue "正在校验 $file 的 $Algorithm 哈希..."
        Write-Host -ForegroundColor Gray "期望值: $expectedHash"
        $actualHash = (Get-FileHash -Path $file -Algorithm $Algorithm).Hash
        Write-Host -ForegroundColor Gray "实际值: $actualHash"
        if ($actualHash -ne $expectedHash) {
            # return $false
            Write-Error "$file 哈希不匹配。"
        } else {
            Write-Host -ForegroundColor Green "$file 哈希校验通过。"
        }
    }
}
function Test-SHA256 ([hashtable]$Hashes) { return Test-Hashes -Hashes $Hashes -Algorithm "SHA256" }
function Test-MD5 ([hashtable]$Hashes) { return Test-Hashes -Hashes $Hashes -Algorithm "MD5" }

if (-not (Test-Path -Path "C:\Program Files\7-Zip\7z.exe")) {
    Write-Error "未找到 7-Zip，请手动安装！"
}
if (-not (Test-Path -Path ".\bin\aria2c.exe")) {
    Write-Host "未找到 aria2c，正在下载..."
    Invoke-WebRequest -Uri 'https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0-win-64bit-build1.zip' -OutFile ".\temp\aria2.zip"
    Expand-Archive -Path ".\temp\aria2.zip" -DestinationPath ".\temp" -Force
    Move-Item -Path ".\temp\aria2-1.37.0-win-64bit-build1\aria2c.exe" -Destination ".\bin\aria2c.exe" -Force
}
Test-SHA256 @{ 
    ".\bin\aria2c.exe" = "BE2099C214F63A3CB4954B09A0BECD6E2E34660B886D4C898D260FEBFE9D70C2" 
}
if (-not (Test-Path -Path ".\bin\wimlib-imagex.exe")) {
    Write-Host "未找到 wimlib-imagex，正在下载..."
    Invoke-WebRequest -Uri 'https://github.com/user-attachments/files/25449494/wimlib-1.14.5-windows-x86_64-bin.zip' -OutFile ".\temp\wimlib.zip"
    Expand-Archive -Path ".\temp\wimlib.zip" -DestinationPath ".\temp\wimlib" -Force
    Copy-Item -Path ".\temp\wimlib\wimlib-imagex.exe" -Destination ".\bin\wimlib-imagex.exe"
    Copy-Item -Path ".\temp\wimlib\libwim-15.dll" -Destination ".\bin\libwim-15.dll"
}
Test-SHA256 @{ 
    ".\bin\wimlib-imagex.exe" = "34C0C4165591AD1F592837ED99D08273C58D6ED3FE0ED6360CF34E7B0739B353"
    ".\bin\libwim-15.dll"     = "BA853EE1E3FC5F5798581F02E8E066BA07A0A2375F0BF444FE981431FD508495"
}
if (-not (Test-Path -Path ".\bin\PSFExtractor.exe")) {
    Write-Host "未找到 PSFExtractor，正在下载..."
    Invoke-WebRequest -Uri 'https://github.com/Secant1006/PSFExtractor/releases/download/v3.07/PSFExtractor-v3.07-x64.zip' -OutFile ".\temp\PSFExtractor.zip"
    Expand-Archive -Path ".\temp\PSFExtractor.zip" -DestinationPath ".\bin" -Force
}
Test-SHA256 @{ 
    ".\bin\PSFExtractor.exe" = "B8A08DD9592E64843056CF5FE518E782FD7ED517D1EE32B70A99B7D7E5767F6C"
}

# 获取 Windows 更新补丁
if ($UpdateFromUUP) {
    $UUPScript = "https://uupdump.net/get.php?id=$uupid&pack=0&edition=updateOnly&aria2=2"
    .\bin\aria2c.exe -c -R --retry-wait=5 --check-certificate=false -d ".\temp" -o "UUPScript.txt" "$UUPScript"
    if (!$?) { Write-Error "UUPScript 文件下载失败！" }
    .\bin\aria2c.exe -c -R --retry-wait=5 --check-certificate=false -x16 -s16 -j5 -d ".\patch" -i ".\temp\UUPScript.txt"
    if (!$?) { Write-Error "UUPScript 下载失败！" }
} elseif ($null -ne $WUScript) {
    Invoke-WebRequest -Uri $WUScript -OutFile ".\temp\WUScript.meta4"
    .\bin\aria2c.exe -c -R --retry-wait=5 --check-certificate=false -x16 -s16 -j5 -d ".\patch" -M ".\temp\WUScript.meta4"
    if (!$?) { Write-Error "WUScript 下载失败！" }
} else {
    Write-Error "未找到 Windows 更新脚本！"
}
if ($null -ne $NETScript) {
    Invoke-WebRequest -Uri $NETScript -OutFile ".\temp\NETScript.meta4"
    .\bin\aria2c.exe -c -R --retry-wait=5 --check-certificate=false -x16 -s16 -j5 -d ".\patch" -M ".\temp\NETScript.meta4" --metalink-language="neutral"
    if (!$?) { Write-Error "NETScript 下载失败！" }
    .\bin\aria2c.exe -c -R --retry-wait=5 --check-certificate=false -x16 -s16 -j5 -d ".\patch" -M ".\temp\NETScript.meta4" --metalink-language="zh-CN"
    if (!$?) { Write-Error "NETScript 下载失败！" }
}
# 将 WIM+PSF 转换为 msu
# Link: https://github.com/abbodi1406/BatUtil/issues/49
# if (Test-Path ".\patch\Windows*.wim") {
#     $patchPath = Resolve-Path ".\patch"
#     Write-Host "正在制作 MSU ($patchPath)..."
#     Invoke-WebRequest -Uri 'https://github.com/abbodi1406/WHD/raw/refs/heads/master/scripts/PSFX_MSU_5.zip' -OutFile .\temp\PSFX_MSU.zip
#     Expand-Archive -Path .\temp\PSFX_MSU.zip -DestinationPath .\temp\PSFX_MSU -Force
#     . ".\temp\PSFX_MSU\PSFX2MSU.cmd" "$patchPath"
# }

# 获取按需功能 (FOD)
if ($null -ne $Miracast) {
    # Microsoft-Windows-WirelessDisplay-FOD-Package.cab
    Invoke-Aria2Download -Uri $Miracast -Destination ".\fod\Miracast\" -Name "update.cab"
    expand -f:* ".\fod\Miracast\update.cab" ".\fod\Miracast\" >nul
    # Microsoft-Windows-WirelessDisplay-FOD-Package~zh-CN.cab
    Invoke-Aria2Download -Uri $MiracastLP -Destination ".\fod\MiracastLP\" -Name "update.cab"
    expand -f:* ".\fod\MiracastLP\update.cab" ".\fod\MiracastLP\" >nul
}
if ($null -ne $iexplorer) {
    # microsoft-windows-internetexplorer-optional-package.cab
    Invoke-Aria2Download -Uri $iexplorer -Destination ".\fod\iexplorer\" -Name "update.cab"
    expand -f:* ".\fod\iexplorer\update.cab" ".\fod\iexplorer\" >nul
}
if ($null -ne $iexplorerLP) {
    # Microsoft-Windows-InternetExplorer-Optional-Package-amd64-zh-cn.cab
    Invoke-Aria2Download -Uri $iexplorerLP -Destination ".\fod\iexplorerLP\" -Name "update.cab"
    expand -f:* ".\fod\iexplorerLP\update.cab" ".\fod\iexplorerLP\" >nul
}
# 获取企业版 G 包
if (($null -ne $entgpack) -and ($true -eq $MultiEdition)) {
    # Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD
    Invoke-Aria2Download -Uri $entgpack -Destination ".\temp\" -Name "entg.esd"
    ."C:\Program Files\7-Zip\7z.exe" x ".\temp\entg.esd" -o".\entg" -r
}
if (($null -ne $entgLP) -and ($true -eq $MultiEdition)) {
    # Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD
    Invoke-Aria2Download -Uri $entgLP -Destination ".\temp\" -Name "entgLP.esd"
    ."C:\Program Files\7-Zip\7z.exe" x ".\temp\entgLP.esd" -o".\entgLP" -r
}

# 获取应用商店组件
$MSStoreScript = "echo nostore"
if ($true -eq $msstore) {
    Remove-Item -Path "$PSScriptRoot\msstore" -Force -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Path "$PSScriptRoot\msstore" -ErrorAction SilentlyContinue
    if ($os_edition -like "*LTS*") {
        # Get-Appx 'Microsoft.VCLibs.140.00'
        Invoke-Aria2Download -Uri "https://aka.ms/Microsoft.VCLibs.$os_arch.14.00.Desktop.appx" -Destination "$PSScriptRoot\msstore\Microsoft.VCLibs.140.00.msix"
    } else {
        Get-Appx '9NBLGGH4NNS1' # 'Microsoft.DesktopAppInstaller'
        Get-Appx '9WZDNCRFJBMP' # 'Microsoft.WindowsStore'
        Get-Appx '9N0DX20HK701' # 'Microsoft.WindowsTerminal'
    }
    $MSStoreScript = @"
for %%a in (%~dp0msstore\Microsoft.VCLibs.140.00.UWPDesktop*.Appx) do call :Add-ProvisionedAppxPackage "%%a"
for %%a in (%~dp0msstore\Microsoft.VCLibs.140.00*.Appx) do call :Add-ProvisionedAppxPackage "%%a"
for %%a in (%~dp0msstore\Microsoft.VCLibs.140.00*.msix) do call :Add-ProvisionedAppxPackage "%%a"
for %%a in (%~dp0msstore\Microsoft.UI.Xaml*.Appx) do call :Add-ProvisionedAppxPackage "%%a"
for %%a in (%~dp0msstore\Microsoft.NET.Native.Runtime*.Appx) do call :Add-ProvisionedAppxPackage "%%a"
for %%a in (%~dp0msstore\Microsoft.NET.Native.Framework*.Appx) do call :Add-ProvisionedAppxPackage "%%a"
for %%a in (%~dp0msstore\Microsoft.WindowsStore*.Msixbundle) do call :Add-ProvisionedAppxPackage "%%a"
for %%a in (%~dp0msstore\Microsoft.DesktopAppInstaller*.Msixbundle) do call :Add-ProvisionedAppxPackage "%%a"
for %%a in (%~dp0msstore\Microsoft.WindowsTerminal*.Msixbundle) do call :Add-ProvisionedAppxPackage "%%a"
"@
}

if ($true -eq $SkipCheck) { 
    # 从 Windows 10 19041 最新安装程序获取 appraiserres.dll
    Invoke-WebRequest -Uri "https://github.com/user-attachments/files/17200856/appraiserres.zip" -OutFile ".\temp\appraiserres.zip"
    Expand-Archive -Path ".\temp\appraiserres.zip" -DestinationPath ".\temp"
}
if ($null -eq $Cleanup) { $Cleanup = $true }

# abbodi1406/W10UI, 自动注入钩子
$W10UI = "@chcp 65001`n"
$W10UI += (Invoke-WebRequest -Uri "https://github.com/abbodi1406/BatUtil/raw/refs/heads/master/W10UI/W10UI.cmd").Content
$W10UI = $W10UI.Replace("if %AddDrivers%==1 call :doDrv", "call %~dp0hook_beforewim.cmd`nif %AddDrivers%==1 call :doDrv")
$W10UI = $W10UI.Replace("if %net35%==1 call :enablenet35", "call %~dp0hook_beforenet35.cmd`nif %net35%==1 call :enablenet35")

# 写入 beforenet35 钩子脚本
@"
echo.
echo ============================================================
echo 钩子 W10UI beforenet35 执行成功！
echo 当前目录: %cd%
echo 挂载目录: !mountdir!
echo DISM 目标: %dismtarget%
echo Cab 目录: !_cabdir!
echo MumTarget: !mumtarget!
echo 架构: %arch%
echo ============================================================

if exist "!mumtarget!\Windows\Servicing\Packages\*WinPE-LanguagePack*.mum" (
    echo.
    echo ============================================================
    echo 跳过 WinPE 镜像...
    echo ============================================================
    goto :eof
)

if exist "!mountdir!\Windows\WinSxS\*microsoft-edge-webview*" (
    echo.
    echo ============================================================
    echo 正在移除 Edge WebView2 FOD...
    echo ============================================================
    %_dism2%:"!_cabdir!" %dismtarget% /Remove-Capability /CapabilityName:"Edge.WebView2.Platform~~~~"   
)
"@ | Out-File -FilePath ".\hook_beforenet35.cmd"

# 写入 beforewim 钩子脚本
@"
echo.
echo ============================================================
echo 钩子 W10UI beforewim 执行成功！
echo 当前目录: %cd%
echo 挂载目录: !mountdir!
echo DISM 目标: %dismtarget%
echo Cab 目录: !_cabdir!
echo MumTarget: !mumtarget!
echo 架构: %arch%
echo ============================================================

if /i "$SkipCheck"=="true" (
    echo 通过注册表跳过硬件检测
    REG.exe LOAD "HKLM\Mount_SYSTEM" "!mountdir!\Windows\System32\config\SYSTEM"
    for %%a in (BypassCPUCheck,BypassRAMCheck,BypassSecureBootCheck,BypassStorageCheck,BypassTPMCheck) do (
        REG.exe ADD "HKLM\Mount_SYSTEM\Setup\LabConfig" /f /v "%%a" /t REG_DWORD /d 1
    )
    REG.exe ADD "HKLM\Mount_SYSTEM\Setup\MoSetup" /f /v "AllowUpgradesWithUnsupportedTPMOrCPU" /t REG_DWORD /d 1
    REG.exe UNLOAD "HKLM\Mount_SYSTEM"

    echo 跳过 OOBE 强制登录检测
    REG.exe LOAD "HKLM\Mount_SOFTWARE" "!mountdir!\Windows\System32\config\SOFTWARE"
    REG.exe ADD "HKLM\Mount_SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v "BypassNRO" /t REG_DWORD /d "1" /f
    REG.exe DELETE "HKLM\Mount_SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\CompatMarkers" /f
    REG.exe DELETE "HKLM\Mount_SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Shared" /f
    REG.exe DELETE "HKLM\Mount_SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\TargetVersionUpgradeExperienceIndicators" /f
    REG.exe ADD "HKLM\Mount_SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\HwReqChk" /v "HwReqChkVars" /t REG_MULTI_SZ /d "SQ_SSE2ProcessorSupport=TRUE\0SQ_SSE4_2ProcessorSupport=TRUE\0SQ_NXProcessorSupport=TRUE\0SQ_CompareExchange128=TRUE\0SQ_LahfSahfSupport=TRUE\0SQ_PrefetchWSupport=TRUE\0SQ_PopCntInstructionSupport=TRUE\0SQ_SecureBootCapable=TRUE\0SQ_SecureBootEnabled=TRUE\0SQ_TpmVersion=2\0SQ_RamMB=9999\0SQ_SystemDiskSizeMB=99999\0SQ_CpuCoreCount=9\0SQ_CpuModel=99\0SQ_CpuFamily=99\0SQ_CpuMhz=9999" /f
    REG.exe UNLOAD "HKLM\Mount_SOFTWARE"
    
    echo 跳过中国版个人数据导出检测
    REG LOAD "HKLM\Mount_Default" "!mountdir!\Users\Default\NTUSER.DAT"
    REG ADD "HKLM\Mount_Default\Software\Microsoft\Windows\CurrentVersion\CloudExperienceHost\Intent\PersonalDataExport" /f /v "PDEShown" /t REG_DWORD /d 2
    REG UNLOAD "HKLM\Mount_Default"
)

if exist "!mountdir!\Windows\Servicing\Packages\*WinPE-LanguagePack*.mum" (
    echo.
    echo ============================================================
    echo 钩子不对 WinPE 操作，正在退出...
    echo ============================================================
    exit /b
)

echo.
echo ============================================================
echo 启用功能...
echo ============================================================

%_dism2%:"!_cabdir!" %dismtarget% /Enable-Feature:LegacyComponents /All
%_dism2%:"!_cabdir!" %dismtarget% /Enable-Feature:SMB1Protocol
%_dism2%:"!_cabdir!" %dismtarget% /Enable-Feature:TFTP
%_dism2%:"!_cabdir!" %dismtarget% /Enable-Feature:TelnetClient

echo.
echo ============================================================
echo 添加按需功能...
echo ============================================================

echo 当前目录: %cd%

if exist "%~dp0fod\Miracast\update.mum" (
    %_dism2%:"!_cabdir!" %dismtarget% /Add-Package /PackagePath:"%~dp0fod\Miracast\update.mum" 
    %_dism2%:"!_cabdir!" %dismtarget% /Add-Package /PackagePath:"%~dp0fod\MiracastLP\update.mum"
)
if exist "%~dp0fod\iexplorer\update.mum" (
    %_dism2%:"!_cabdir!" %dismtarget% /Add-Package /PackagePath:"%~dp0fod\iexplorer\update.mum" 
)
if exist "%~dp0fod\iexplorerLP\update.mum" (
    %_dism2%:"!_cabdir!" %dismtarget% /Add-Package /PackagePath:"%~dp0fod\iexplorerLP\update.mum" 
)
echo.
echo ============================================================
echo 正在更新 Microsoft Store...
echo ============================================================

$MSStoreScript

if /i not "$MultiEdition"=="true" EXIT /B

echo.
echo ============================================================
echo 正在提交基础版本...
echo ============================================================
%_dism2%:"!_cabdir!" /Commit-Image /MountDir:"!mountdir!"


echo.
echo ============================================================
echo 正在获取当前版本...
echo ============================================================
%_dism2%:"!_cabdir!" %dismtarget% /Get-CurrentEdition | find /i "CoreCountrySpecific" && goto :makefromccs
%_dism2%:"!_cabdir!" %dismtarget% /Get-CurrentEdition | find /i "EnterpriseS" && goto :makefroments
echo.
echo 当前版本不支持，正在退出...
set discard=1
EXIT /B


:makefromccs
echo.
echo ============================================================
echo 从 CoreCountrySpecific 转换多版本...
echo ============================================================
call :makemulti Core
call :makemulti CoreSingleLanguage
call :makemulti Professional
call :makemulti ProfessionalWorkstation
call :makemulti Education
call :makemulti Enterprise
call :makemulti IoTEnterprise
if exist "%~dp0entg\update.mum" call :makeEntG
if exist "%~dp0entg\update.mum" call :makemulti EnterpriseG
set discard=1
EXIT /B

:makefroments
echo.
echo ============================================================
echo 从 EnterpriseS 转换多版本...
echo ============================================================
FOR /F "tokens=3 delims=: " %%a in ('%_dism2%:"!_cabdir!" %dismtarget% /Get-TargetEditions ^| find /i "Target Edition : "') do (
    echo 可转换版本: %%a
    call :makemulti %%a
)
set discard=1
EXIT /B

:Add-ProvisionedAppxPackage
echo 正在安装 - %~n1
%_dism2%:"!_cabdir!" %dismtarget% /Add-ProvisionedAppxPackage /PackagePath:"%~1" /SkipLicense /Region:all
goto :EOF

:makemulti
echo.
echo ============================================================
echo 正在转换版本 - %1...
echo ============================================================
%_dism2%:"!_cabdir!" %dismtarget% /Set-Edition:%1
if !errorlevel! equ 0 (
    echo.
    echo ============================================================
    echo 正在提交版本 - %1...
    echo ============================================================
    %_dism2%:"!_cabdir!" /Commit-Image /MountDir:"!mountdir!" /Append
) else (
    echo.
    echo ============================================================
    echo 转换版本 - %1 失败！
    echo ============================================================
)
goto :EOF

:makeEntG
echo.
echo ============================================================
echo 正在制作企业版 G...
echo ============================================================

echo.
echo ============================================================
echo 正在安装企业版 G 包...
echo.
echo 注意: 如果出现错误，属于正常现象。
echo ============================================================
%_dism2%:"!_cabdir!" %dismtarget% /Set-Edition:Enterprise
FOR %%a IN (%~dp0entg\*.mum) DO %_dism2%:"!_cabdir!" %dismtarget% /Add-Package /PackagePath:"%%a"
rem add language pack
FOR %%a IN (%~dp0entgLP\*-EnterpriseG-*.mum) DO %_dism2%:"!_cabdir!" %dismtarget% /Add-Package /PackagePath:"%%a"

echo.
echo ============================================================
echo 正在复制服务包...
echo.
echo 注意: 如果出现错误，则必定100%失败。
echo ============================================================
for /d %%a in ("!_cabdir!\*") do for %%b in ("%%a\Microsoft-Windows-EnterpriseGEdition~*") do copy /y "%%~b" "!mountdir!\Windows\servicing\Packages"
for /d %%a in ("!_cabdir!\*") do for %%b in ("%%a\Microsoft-Windows-EnterpriseGEdition-wrapper~*") do copy /y "%%~b" "!mountdir!\Windows\servicing\Packages"

echo.
echo ============================================================
echo 正在从注册表获取信息...
echo ============================================================
REG.exe LOAD HKLM\EntGSOFTWARE "!mountdir!\Windows\System32\config\SOFTWARE"

set _target_arch=%arch%
if "%arch%"=="x64" (
    set _target_arch=amd64
)
for /f "tokens=6,7 delims=~." %%a in ('dir /b "!mountdir!\Windows\servicing\Packages\Microsoft-Windows-EnterpriseGEdition~*"') do set EntGEditionVersion=%%a.%%b

FOR /F "tokens=*" %%i IN ('REG QUERY "HKLM\EntGSOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages"^|find /i "Microsoft-Windows-Editions-EnterpriseG-Package~31bf3856ad364e35~"') DO (
    FOR /F "tokens=3* skip=2" %%j IN ('REG QUERY "%%i" /v InstallTimeHigh') DO SET "InstallTimeHigh=%%j"
    FOR /F "tokens=3* skip=2" %%k IN ('REG QUERY "%%i" /v InstallTimeLow') DO SET "InstallTimeLow=%%k"
    FOR /F "tokens=3* skip=2" %%l IN ('REG QUERY "%%i" /v InstallUser') DO SET "InstallUser=%%l"
    FOR /F "tokens=3* skip=2" %%m IN ('REG QUERY "%%i" /v InstallLocation') DO SET "InstallLocation=%%m"
)

echo.
echo ============================================================
echo 正在向注册表添加版本包信息...
echo.
echo 目标架构: %_target_arch%
echo EntGEditionVersion: %EntGEditionVersion%
echo InstallTimeHigh: %InstallTimeHigh%
echo InstallTimeLow: %InstallTimeLow%
echo InstallUser: %InstallUser%
echo InstallLocation: %InstallLocation%
echo ============================================================
REG.exe ADD "HKLM\EntGSOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~%_target_arch%~~10.0.%EntGEditionVersion%" /f
REG.exe ADD "HKLM\EntGSOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~%_target_arch%~~10.0.%EntGEditionVersion%" /f /v "CurrentState" /t REG_DWORD /d 112
REG.exe ADD "HKLM\EntGSOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~%_target_arch%~~10.0.%EntGEditionVersion%" /f /v "InstallClient" /t REG_SZ /d "DISM Package Manager Provider"
REG.exe ADD "HKLM\EntGSOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~%_target_arch%~~10.0.%EntGEditionVersion%" /f /v "InstallLocation" /t REG_SZ /d "\\?%WorkDisk%\%LCUName%"
REG.exe ADD "HKLM\EntGSOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~%_target_arch%~~10.0.%EntGEditionVersion%" /f /v "InstallName" /t REG_SZ /d "Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~%_target_arch%~~10.0.%EntGEditionVersion%.mum"
REG.exe ADD "HKLM\EntGSOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~%_target_arch%~~10.0.%EntGEditionVersion%" /f /v "InstallTimeHigh" /t REG_DWORD /d "%InstallTimeHigh%"
REG.exe ADD "HKLM\EntGSOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~%_target_arch%~~10.0.%EntGEditionVersion%" /f /v "InstallTimeLow" /t REG_DWORD /d "%InstallTimeLow%"
REG.exe ADD "HKLM\EntGSOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~%_target_arch%~~10.0.%EntGEditionVersion%" /f /v "InstallUser" /t REG_SZ /d "%InstallUser%"
REG.exe ADD "HKLM\EntGSOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~%_target_arch%~~10.0.%EntGEditionVersion%" /f /v "SelfUpdate" /t REG_DWORD /d 0
REG.exe ADD "HKLM\EntGSOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~%_target_arch%~~10.0.%EntGEditionVersion%" /f /v "Visibility" /t REG_DWORD /d 1
REG.exe ADD "HKLM\EntGSOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~%_target_arch%~~10.0.%EntGEditionVersion%\Owners" /f
REG.exe ADD "HKLM\EntGSOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~%_target_arch%~~10.0.%EntGEditionVersion%\Owners" /f /v "Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~%_target_arch%~~10.0.%EntGEditionVersion%" /t REG_DWORD /d 131184

REG.exe UNLOAD HKLM\EntGSOFTWARE

echo.
echo ============================================================
echo 正在设置产品密钥和许可证...
echo ============================================================
%_dism2%:"!_cabdir!" %dismtarget% /Set-ProductKey:FV469-WGNG4-YQP66-2B2HY-KD8YX
%_dism2%:"!_cabdir!" %dismtarget% /Get-CurrentEdition

goto :EOF
"@ | Out-File -FilePath ".\hook_beforewim.cmd"

if ($true -eq $MultiEdition) {
    $W10UI = $W10UI.Replace("`n:dvdproceed", "`n:dvdproceed`ncall %~dp0hook_beforedvd.cmd")
    @"
cd /d "%~dp0"
set "filename=ISO\sources\install.wim"
set "wimlib=bin\wimlib-imagex.exe"

for /F "tokens=3" %%a in ('%wimlib% info "%filename%" ^| findstr /C:"Image Count:"') do set "ImageCount=%%a"
for /L %%# in (1,1,%ImageCount%) do call :editwiminfo %%#

if /i "$SkipCheck"=="true" (
    echo 将安装类型更改为服务器版
    for /L %%# in (1,1,%ImageCount%) do (
        %wimlib% info "%filename%" %%# --image-property WINDOWS/INSTALLATIONTYPE=Server
    )

    echo 写入 ei.cfg
    >ISO\sources\ei.cfg echo [Channel]
    >>ISO\sources\ei.cfg echo _Default
    >>ISO\sources\ei.cfg echo [VL]
    >>ISO\sources\ei.cfg echo 0

    echo 将 appraiserres.dll 替换为 Windows 10 19041 安装程序版本
    copy /y "temp\appraiserres.dll" "ISO\sources\appraiserres.dll"

    echo 将 4+1+1 批处理文件写入 ISO 根目录
    >ISO\SkipCheck.cmd echo REG.exe ADD "HKLM\SYSTEM\Setup\LabConfig" /v "BypassTPMCheck" /t REG_DWORD /d "1" /f
    >>ISO\SkipCheck.cmd echo REG.exe ADD "HKLM\SYSTEM\Setup\LabConfig" /v "BypassSecureBootCheck" /t REG_DWORD /d "1" /f
    >>ISO\SkipCheck.cmd echo REG.exe ADD "HKLM\SYSTEM\Setup\LabConfig" /v "BypassRAMCheck" /t REG_DWORD /d "1" /f
    >>ISO\SkipCheck.cmd echo REG.exe ADD "HKLM\SYSTEM\Setup\LabConfig" /v "BypassStorageCheck" /t REG_DWORD /d "1" /f
    >>ISO\SkipCheck.cmd echo REG.exe ADD "HKLM\SYSTEM\Setup\MoSetup" /v "AllowUpgradesWithUnsupportedTPMOrCPU" /t REG_DWORD /d "1" /f
    >>ISO\SkipCheck.cmd echo REG.exe DELETE "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\CompatMarkers" /f
    >>ISO\SkipCheck.cmd echo REG.exe DELETE "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Shared" /f
    >>ISO\SkipCheck.cmd echo REG.exe DELETE "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\TargetVersionUpgradeExperienceIndicators" /f
    >>ISO\SkipCheck.cmd echo REG.exe ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\HwReqChk" /v "HwReqChkVars" /t REG_MULTI_SZ /d "SQ_SSE2ProcessorSupport=TRUE\0SQ_SSE4_2ProcessorSupport=TRUE\0SQ_NXProcessorSupport=TRUE\0SQ_CompareExchange128=TRUE\0SQ_LahfSahfSupport=TRUE\0SQ_PrefetchWSupport=TRUE\0SQ_PopCntInstructionSupport=TRUE\0SQ_SecureBootCapable=TRUE\0SQ_SecureBootEnabled=TRUE\0SQ_TpmVersion=2\0SQ_RamMB=9999\0SQ_SystemDiskSizeMB=99999\0SQ_CpuCoreCount=9\0SQ_CpuModel=99\0SQ_CpuFamily=99\0SQ_CpuMhz=9999" /f
    >>ISO\SkipCheck.cmd echo PAUSE
)
exit /b

:readwiminfo
for /f "tokens=1,2 delims=:" %%a in ('%wimlib% info "%filename%" %1 ^| find /i %2') do (for /f "tokens=*" %%c in ("%%b") do (set "%%a=%%c"))
goto :eof

:editwiminfo
call :readwiminfo %1 "Edition ID"
call :readwiminfo %1 "Build"
if %Build% GEQ 22000 (
    set sysver=Windows 11
) else (
    set sysver=Windows 10
)
if /i "%Edition ID%"=="Core" set "CNEDITION=家庭版"
if /i "%Edition ID%"=="CoreSingleLanguage" set "CNEDITION=家庭单语言版"
if /i "%Edition ID%"=="CoreCountrySpecific" set "CNEDITION=家庭中文版"
if /i "%Edition ID%"=="Professional" set "CNEDITION=专业版"
if /i "%Edition ID%"=="ProfessionalCountrySpecific" set "CNEDITION=专业中文版"
if /i "%Edition ID%"=="ProfessionalEducation" set "CNEDITION=专业教育版"
if /i "%Edition ID%"=="ProfessionalSingleLanguage" set "CNEDITION=专业单语言版"
if /i "%Edition ID%"=="ProfessionalWorkstation" set "CNEDITION=专业工作站版"
if /i "%Edition ID%"=="Education" set "CNEDITION=教育版"
if /i "%Edition ID%"=="Enterprise" set "CNEDITION=企业版"
if /i "%Edition ID%"=="IoTEnterprise" set "CNEDITION=IoT 企业版"
if /i "%Edition ID%"=="IoTEnterpriseK" set "CNEDITION=IoT 企业版订阅"
if /i "%Edition ID%"=="ServerRdsh" set "CNEDITION=企业版多会话"
if /i "%Edition ID%"=="CloudEdition" set "CNEDITION=SE"
if /i "%Edition ID%"=="EnterpriseG" set "CNEDITION=企业版 G"
if /i "%Edition ID%"=="EnterpriseS" set "CNEDITION=企业版 LTSC"
if /i "%Edition ID%"=="IoTEnterpriseS" set "CNEDITION=IoT 企业版 LTSC"
if /i "%Edition ID%"=="IoTEnterpriseSK" set "CNEDITION=IoT 企业版订阅 LTSC"
if /i "%CNEDITION%"=="" set "CNEDITION=%Edition ID%"
%wimlib% info "%filename%" %1 "%sysver% %Edition ID%" "%sysver% %Edition ID%" --image-property "DISPLAYNAME"="%sysver% %CNEDITION%" --image-property "DISPLAYDESCRIPTION"="%sysver% %CNEDITION%" --image-property "FLAGS"="%Edition ID%"
goto :eof
"@ | Out-File -FilePath ".\hook_beforedvd.cmd"
}

# 写入 W10UI
$W10UI | Out-File -FilePath ".\W10UI.cmd" -Encoding utf8
$W10UI = ""

# 获取系统镜像
# 获取原始系统直链
if ($null -ne $os_path) {
    Write-Host "获取原始系统镜像链接: $os_path..."
    $obj = Invoke-RestMethod -Uri "https://list.xrgzs.top/api/fs/get" `
        -Method "POST" `
        -ContentType "application/json;charset=UTF-8" `
        -Body (@{
            path     = $os_path
            password = ""
        } | Convertto-Json)
    if ($obj.data.name -and $obj.data.raw_url) {
        Write-Host "获取 $($obj.data.name): $($obj.data.raw_url)"
        $os_file = $obj.data.name
        $os_url = $obj.data.raw_url
    } else {
        Write-Error "获取原始系统镜像失败！$($obj | ConvertTo-Json)"
    }
}
Write-Host "原始系统文件: $os_file
原始系统下载链接: $os_url
"

Write-Host "正在下载原始系统镜像..."
Invoke-Aria2Download -Uri $os_url -Destination ".\temp\" -Name $os_file -Big

Write-Host "正在校验原始系统镜像哈希..."

if ($os_md5) {
    Test-MD5 @{".\temp\$os_file" = $os_md5 }
}

# $isopath = Resolve-Path -Path ".\temp\$os_file"
# $isomount = (Mount-DiskImage -ImagePath $isopath -PassThru | Get-Volume).DriveLetter
# Target        =${isomount}:
."C:\Program Files\7-Zip\7z.exe" x ".\temp\$os_file" -o".\ISO" -r

# 仅选择1个版本
# if ($null -ne $SelectEdition) {
#     .\bin\wimlib-imagex.exe info ".\ISO\sources\install.wim" --extract-xml ".\temp\WIMInfo.xml"
#     $WIMInfo = [xml](Get-Content ".\temp\WIMInfo.xml")
#     $WIMIndex = $WIMInfo.WIM.IMAGE | Where-Object {$_.WINDOWS.EDITIONID -eq "$SelectEdition"} | Select-Object -ExpandProperty INDEX
#     $WIMIndexs = $WIMInfo.WIM.IMAGE.Index | Measure-Object | Select-Object -ExpandProperty Count
#     for ($i = $WIMIndexs; $i -gt $WIMIndex; $i--) {
#         # .\bin\wimlib-imagex.exe delete ".\ISO\sources\install.wim" $i --soft
#         Remove-WindowsImage -ImagePath ".\ISO\sources\install.wim" -Index $i
#     }
#     for ($i = 1; $i -lt $WIMIndex; $i++) {
#         Remove-WindowsImage -ImagePath ".\ISO\sources\install.wim" -Index 1
#     }
# }

.\bin\wimlib-imagex.exe info ".\ISO\sources\install.wim" --extract-xml ".\temp\WIMInfo2.xml"
Get-Content ".\temp\WIMInfo2.xml"
# 写入 W10UI 配置
@"
[W10UI-Configuration]
Target        =%cd%\ISO
Repo          =%cd%\patch
DismRoot      =dism.exe

Net35         =1
Net35Source   =%cd%\ISO\sources\sxs
Cleanup       =$($Cleanup ? 1 : 0)
ResetBase     =0
LCUwinre      =1
WinRE         =1
UpdtBootFiles =1
SkipEdge      =0
UseWimlib     =1

_CabDir       =W10UItemp
MountDir      =W10UImount
WinreMount    =W10UImountre

wim2esd       =1
wim2swm       =0
ISO           =1
ISODir        =
Delete_Source =0


AutoStart     =1

AddDrivers    =0
Drv_Source    =\Drivers
"@ | Out-File -FilePath ".\W10UI.ini"

# 执行 W10UI 脚本
.\W10UI.cmd

# 确保 ISO 文件存在
$isoFiles = Get-ChildItem -Path ".\*.iso" -File
if (-not $isoFiles) {
    Write-Error "目录中未找到 ISO 文件，请确保脚本已正确生成 ISO 文件。"
    exit 1
}

# 重命名
$isoFiles | ForEach-Object {
    $NewName = $_.Name
    if ($os_edition -like "*LTS*") {
        $NewName = $NewName -replace "_CLIENT_", "_CLIENT_ENTERPRISES_"
    }
    if ($true -eq $MultiEdition) {
        $NewName = $NewName -replace "_CLIENT", "_CLIENTMULTI"
    }
    if ($true -eq $UpdateFromUUP) {
        $NameAppend += "_FromUUP"
    }
    if ($true -eq $AddVMD) {
        $NameAppend += "_VMD"
    }
    if ($true -eq $AddUnattend) {
        $NameAppend += "_Unattend"
    }
    if ($true -eq $SkipCheck) {
        $NameAppend += "_SkipCheck"
    }
    if ($null -ne $NameAppend) {
        $NewName = $NewName -replace ".iso", "$NameAppend.iso"
    }
    if ($_.Name -ne $NewName) {
        Rename-Item -Path $_.Name -NewName $NewName
    }
}

# 获取哈希
Get-ChildItem -Path ".\*.iso" -File | ForEach-Object {
    Write-Host "正在获取 $($_.Name) 的哈希..."
    $FileInfo = [ordered] @{}
    $FileInfo.uuid = [guid]::NewGuid().ToString()
    $FileInfo.name = $_.Name
    $FileInfo.size = $_.Length
    $FileInfo.date = $_.LastWriteTime
    $FileInfo.hash = @{}
    $FileInfo.hash.sha256 = Get-FileHash -Path $_.Name -Algorithm SHA256 | Select-Object -ExpandProperty Hash
    $FileInfo.hash.md5 = Get-FileHash -Path $_.Name -Algorithm MD5 | Select-Object -ExpandProperty Hash
    $FileInfo.os_ver = [string] $os_ver
    $FileInfo.os_display = $os_display
    $FileInfo.os_version = [string] $_.Name.Split(".")[0] + "." + $_.Name.Split(".")[1]
    $FileInfo.os_rsversion = $os_rsversion
    $FileInfo.os_release = $os_release
    $FileInfo.os_build = [string] $os_build
    $FileInfo.os_build_number = [string] $_.Name.Split(".")[0]
    $FileInfo.os_build_qfe = [string] $_.Name.Split(".")[1]
    $FileInfo.os_build_stamp = [string] $_.Name.Split(".")[2]
    $FileInfo.os_build_branch = [string] $_.Name.split(".")[3].split("_")[0] + "_" + $_.Name.split(".")[3].split("_")[1]
    $FileInfo.os_edition = $os_edition
    $FileInfo.os_arch = $os_arch
    $FileInfo.os_lang = $os_lang
    $FileInfo.os_type = "MSUpdate"
    $FileInfo.msupdate = @{}
    $FileInfo.msupdate.makeversion = $MakeVersion
    $FileInfo.msupdate.multiedition = $MultiEdition
    $FileInfo.msupdate.updatefromuup = $UpdateFromUUP
    $FileInfo.msupdate.addunattend = $AddUnattend
    $FileInfo.msupdate.skipcheck = $SkipCheck
    $FileInfo.msupdate.cleanup = $Cleanup
    $FileInfo.msupdate.makefrom = $os_file
    $FileInfo | ConvertTo-Json | Out-File -FilePath ".\$($_.Name).json" -Encoding utf8
}