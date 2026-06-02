
function Invoke-Aria2Download {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Uri,

        [Parameter(Position = 1)]
        [string]$Destination,

        [Parameter(Position = 2)]
        [string]$Name,
        
        [switch]$Big,

        [string[]]$Options = @()
    )
    
    function Get-RedirectedUrl {
        param(
            [Parameter(Mandatory, ValueFromPipeline)][string]$Uri,
            [string]$UserAgent = "aria2/1.37.0"
        )
        try {
            while ($true) {
                $req = [System.Net.WebRequest]::Create($Uri)
                $req.UserAgent = $UserAgent
                $req.AllowAutoRedirect = $false
                $res = $req.GetResponse()
                $loc = $res.GetResponseHeader('Location')
                $res.Close()
                if ($loc) { $Uri = $loc } else { return $Uri }
            }
        } catch { return $Uri }
    }
    
    function Get-Aria2Error($exitcode) {
        $codes = @{
            0  = '所有下载均成功'
            1  = '发生未知错误'
            2  = '超时'
            3  = '资源未找到'
            4  = 'Aria2 达到指定的"资源未找到"错误次数。参见 --max-file-not-found 选项'
            5  = '因下载速度过慢而中止下载。参见 --lowest-speed-limit 选项'
            6  = '网络问题'
            7  = '存在未完成的下载。仅当所有已完成的下载均成功且队列中仍有未完成的下载时，aria2 因用户按 Ctrl-C 或发送 TERM/INT 信号退出时报告此错误'
            8  = '远程服务器不支持续传，但续传是完成下载所必需的'
            9  = '磁盘空间不足'
            10 = '分片大小与 .aria2 控制文件中的不同。参见 --allow-piece-length-change 选项'
            11 = 'Aria2 当时正在下载同一文件'
            12 = 'Aria2 当时正在下载相同信息哈希的种子'
            13 = '文件已存在。参见 --allow-overwrite 选项'
            14 = '文件重命名失败。参见 --auto-file-renaming 选项'
            15 = 'Aria2 无法打开已有文件'
            16 = 'Aria2 无法创建新文件或截断已有文件'
            17 = '文件 I/O 错误'
            18 = 'Aria2 无法创建目录'
            19 = '域名解析失败'
            20 = 'Aria2 无法解析 Metalink 文档'
            21 = 'FTP 命令失败'
            22 = 'HTTP 响应头异常或不符合预期'
            23 = '重定向次数过多'
            24 = 'HTTP 认证失败'
            25 = 'Aria2 无法解析 bencoded 文件（通常是 .torrent 文件）'
            26 = '".torrent" 文件已损坏或缺少 aria2 所需的信息'
            27 = 'Magnet URI 格式错误'
            28 = '提供了无效/无法识别的选项或意外的选项参数'
            29 = '远程服务器因临时过载或维护而无法处理请求'
            30 = 'Aria2 无法解析 JSON-RPC 请求'
            31 = '保留，未使用'
            32 = '校验失败'
        }
        if ($null -eq $codes[$exitcode]) {
            return '发生未知错误'
        }
        return $codes[$exitcode]
    }

    # aria2 选项
    $Options += @(
        '--no-conf=true'
        '--continue'
        '--allow-overwrite=true'
        '--summary-interval=0'
        '--remote-time=true'
        '--retry-wait=5'
        '--check-certificate=false'
    )

    # 设置任务信息
    $Uri = Get-RedirectedUrl -Uri $Uri
    $Options += "`"$Uri`""
    if ($Destination) {
        $Options += "--dir=`"$Destination`""
    }
    if ($Name) {
        $Options += "--out=`"$Name`""
    }
    if ($Big) {
        $Options += @(
            '-s16'
            '-x16'
        )
    }

    # 构建 aria2 命令
    $aria2 = "& .\bin\aria2c.exe $($Options -join ' ')"

    # 处理 aria2 控制台输出
    Write-Host '正在使用 aria2 开始下载...' -ForegroundColor Green
    Write-Host "  命令: $aria2" -ForegroundColor Cyan
    Invoke-Command ([scriptblock]::Create($aria2))

    # 处理 aria2 错误
    Write-Host ''
    if ($LASTEXITCODE -gt 0) {
        Write-Error "下载失败！(错误 $LASTEXITCODE) $(Get-Aria2Error $lastexitcode)"
    }
}

Export-ModuleMember -Function Invoke-Aria2Download