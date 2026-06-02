function Invoke-UUPApiRequest {
    param (
        [string] $Url
    )
    $RetryCount = 0
    while ($RetryCount -lt 10) {
        switch ($RetryCount % 2) {
            0 { $Entrypoint = "https://api.uupdump.net" }
            1 { $Entrypoint = "https://uup.xrgzs.top/json-api" }
        }
        $RequestUri = "$Entrypoint/$Url"
        Write-Host -ForegroundColor Yellow "正在尝试请求 $RequestUri (第 $($RetryCount + 1) 次)..."
        $Response = Invoke-WebRequest -Uri $RequestUri `
            -SkipHttpErrorCheck `
            -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0" `
            -Headers @{ "accept-language" = "zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6" }
        if ($Response.Content -notmatch 'Just a moment' -and $Response.StatusCode -eq 200 -and $Response.Content -ne "") {
            Write-Host -ForegroundColor Green "请求成功！"
            return $Response
        }
        Write-Host -ForegroundColor Red "请求失败，1秒后重试..."
        Start-Sleep -Seconds 1
        $RetryCount++
    }
    throw "经过10次尝试后仍无法从 $Url 获取内容。"
}

function Invoke-UUPWebRequest {
    param (
        [string]$Url
    )
    $RetryCount = 0
    while ($RetryCount -lt 10) {
        switch ($RetryCount % 3) {
            0 { $Entrypoint = "https://uupdump.net" }
            1 { $Entrypoint = "https://uup.xrgzs.top" }
            2 { $Entrypoint = "https://uup.671001.xyz" }
        }
        $RequestUri = "$Entrypoint/$Url"
        Write-Host -ForegroundColor Yellow "正在尝试请求 $RequestUri (第 $($RetryCount + 1) 次)..."
        $Response = Invoke-WebRequest -Uri $RequestUri `
            -SkipHttpErrorCheck `
            -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0" `
            -Headers @{ "accept-language" = "zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6" }
        if ($Response.Content -notmatch 'Just a moment' -and $Response.StatusCode -eq 200) {
            Write-Host -ForegroundColor Green "请求成功！"
            return $Response
        }
        Write-Host -ForegroundColor Red "请求失败，1秒后重试..."
        Start-Sleep -Seconds 1
        $RetryCount++
    }
    throw "经过10次尝试后仍无法从 $Url 获取内容。"
}

function Invoke-UUPWebRequestLink {
    param(
        [string]$Url,
        $LinkFilter,
        $ContentFilter,
        [switch]$FirstLink
    )
    $Response = Invoke-UUPWebRequest -Url $Url
    $Links = $Response.Links
    if ($LinkFilter) {
        if ($LinkFilter -is [string]) {
            $Links = $Links | Where-Object { $_.href -like $LinkFilter }
        } elseif ($LinkFilter -is [array]) {
            foreach ($f in $LinkFilter) {
                $Links = $Links | Where-Object { $_.href -like $f }
            }
        }
    }
    if ($ContentFilter) {
        if ($ContentFilter -is [string]) {
            $Links = $Links | Where-Object { $_.outerHTML -like $ContentFilter }
        } elseif ($ContentFilter -is [array]) {
            foreach ($f in $ContentFilter) {
                $Links = $Links | Where-Object { $_.outerHTML -like $f }
            }
        }
    }
    if ($null -ne $Links -and $Links.Count -gt 0) {
        if ($FirstLink) {
            return $Links[0].href
        } else {
            return $Links
        }
    } else {
        Write-Error "No links found!"
        return $null
    }
}

function Request-Update {
    [OutputType([string])]
    param (
        [string] $Category,
        [string] $QueryString
    )
    if ($Category) {
        $Name = $Category
        $AllLinks = Invoke-UUPWebRequestLink -Url "known.php?q=category:$Category" -LinkFilter @("*selectlang.php?id=*") -ContentFilter @("*amd64*")
    } elseif ($QueryString) {
        $Name = $QueryString
        $AllLinks = Invoke-UUPWebRequestLink -Url "known.php?q=$QueryString" -LinkFilter @("*selectlang.php?id=*") -ContentFilter @("*amd64*")
    } else {
        Write-Host -ForegroundColor Red "请指定正确的参数。"
        return $null
    }
    Write-Host "已获取 $Name 的所有已知链接: $($AllLinks | ConvertTo-Json)"

    $Link = $AllLinks | Where-Object { $_.outerHTML -notmatch '\.NET' -and $_.outerHTML -match 'Windows.*\((\d{5}\.\d{4})\)' } | Select-Object -First 1
    if ($Link -and $Link.outerHTML -match 'Windows.*\((\d{5}\.\d{4})\)') {
        $LatestVersion = $Matches[1]
        Write-Host -ForegroundColor Green "$Name 的最新版本为 $LatestVersion"
        return $LatestVersion
    }
    Write-Host -ForegroundColor Red "获取 $Name 最新版本失败"
    return $null
}

function Get-UUPFiles {
    param(
        [Parameter(Mandatory = $True)]
        [string] $Id,

        [string] $Lang,
        [string] $Edition,
        [switch] $NoLink
    )
    $query = [System.Web.HttpUtility]::ParseQueryString("")
    if ($id) { $query["id"] = $Id } else { throw "Id is required." }
    if ($lang) { $query["lang"] = $Lang }
    if ($edition) { $query["edition"] = $Edition }
    if ($NoLink) { $query["nolink"] = "1" }

    $response = Invoke-UUPApiRequest -Url "get.php?$($query.ToString())" | ConvertFrom-Json -AsHashtable

    if ($null -eq $response) {
        throw "从 UUP API 收到空响应。"
    }


    # {
    #   "response": {
    #     "apiVersion": "string", // Current UUP dump API version
    #     "updateName": "string", // Update title, such as Windows 10 Insider Preview 19577.1000 (rs_prerelease)
    #     "arch": "string", // Update architecture, for example x86
    #     "build": "string", // Update build number, for example 19577.1000
    #     "files": { // All files contained in the package
    #       "string": { // File name, such as 'core_en-us.esd', 'microsoft-windows-client-features-package.esd', etc.
    #         "sha1": "string", // The file's SHA1 checksum.
    #         "size": "string", // File size in bytes
    #         "url": "string", // File download link, 'null' if noLinks=1
    #         "uuid": "string", // File UUIDv4, 'null' if noLinks=1 used
    #         "expire": "string", // Link expiration date, '0' if noLinks=1 used
    #         "debug": "string" // Raw data from Microsoft servers, 'null' if noLinks=1 used
    #       },
    #       ...
    #     }
    #   },
    #   "jsonApiVersion": "string" // Current JSON API version
    # }

    Write-Host -ForegroundColor Green "远程 UUP JSON API 版本: $($response.jsonApiVersion)"
    Write-Host -ForegroundColor Green "更新名称: $($response.response.updateName)"
    Write-Host -ForegroundColor Green "架构: $($response.response.arch)"
    Write-Host -ForegroundColor Green "构建版本号: $($response.response.build)"

    # 转换为哈希表以便于访问
    $filesHashtable = @{}
    foreach ($fileName in $response.response.files.Keys) {
        $filesHashtable[$fileName] = $response.response.files.$fileName
        # $file = $response.response.files.$fileName
        # Write-Host -ForegroundColor Cyan "File: $fileName, Size: $($file.size), SHA1: $($file.sha1), URL: $($file.url)"
    }

    return $filesHashtable
}


$UUPFilesCacheById = @{}
function Get-UUPFile {
    param (
        [Parameter(Mandatory = $True)]
        [string] $Id,

        [Parameter(Mandatory = $True)]
        [string] $FileName
    )

    if (-not $UUPFilesCacheById.ContainsKey($Id)) {
        Write-Host -ForegroundColor Yellow "Id $Id 缓存未命中，正在获取 UUP 文件..."
        $files = Get-UUPFiles -Id $Id
        $UUPFilesCacheById[$Id] = $files
    } else {
        Write-Host -ForegroundColor Green "Id $Id 缓存命中。"
        $files = $UUPFilesCacheById[$Id]
    }

    return $files[$FileName]
}

function Get-UUPFileLink {
    param (
        [Parameter(Mandatory = $True)]
        [string] $Id,

        [Parameter(Mandatory = $True)]
        [string] $FileName
    )

    $file = Get-UUPFile -Id $Id -FileName $FileName
    if ($null -eq $file.url) {
        throw "Id $Id 和文件名 $FileName 的文件 URL 为空。"
    }
    return $file.url
}

Export-ModuleMember -Function Invoke-UUPWebRequest, Invoke-UUPWebRequestLink, Request-Update, Get-UUPFiles, Get-UUPFile, Get-UUPFileLink, Invoke-UUPApiRequest
