# makeMSUpdate：制作原版集成更新的系统镜像

基于原版镜像，集成系统更新，创建多版本的系统镜像。

## 项目介绍

MSUpdate 能帮助你轻松获取最新集成更新版本的 Windows 系统镜像

> [!note]
>
> 该项目为 Latest10.win 停运后的替代方案
> 该项目为非盈利项目，与 Microsoft 无关，也不是 Microsoft 旗下网站！

服务器定时从 [UUPDUMP](https://uupdump.net/)、 [adavak/Win_ISO_Patching_Scripts](https://github.com/adavak/Win_ISO_Patching_Scripts) 检测新 Build ，并自动集成更新、校验打包后上传。

> [!tip]
>
> 目前使用 UUP 构建的系统，或多或少会出现一些莫名其妙的问题，因此，我们尽量不从 UUP 构建，仅基于官网 RTM 版本集成更新制作，最多只是从 UUP 下载更新包，避免出现组件缺失等问题

## 特点

### 保持最新

集成系统更新至最新版本

### 直链下载

提供 HTTP 直链下载，任何平台都能轻松获取到最新 Windows 镜像

### 组件完整

集成.NET3.5 - 4.8.1 运行库

- 26h1+不包含.NET3.5，已独立成类似 VC 的组件，[点此下载](https://dotnet.microsoft.com/zh-cn/download/dotnet-framework/net35-sp1)

更新内置 UWP：Microsoft Store、 WinGet 及 运行库 到最新版本

集成 无线显示器（Miracast 投屏）、.NET 3.5、IE 11 及中文语言包等 Features On Demand 组件

开启 Telnet 客户端、Direct Play 等功能

### 过程开源

使用仓库 [xrgzs/MSUpdate](https://github.com/xrgzs/MSUpdate) 集成更新，整个集成过程（包括用到第三方程序）全部开源，请放心使用

### 不夹带私货

未集成任何第三方程序，纯净安全可靠

未对系统进行任何优化调整，保证原滋原味

### 整合多个 SKU

由 家庭中文版 集成更新并转换为 9 个版本：

- 家庭中文版 CoreCountrySpecific
- 家庭版 Core
- 家庭单语言版 CoreSingleLanguage
- 专业版 Professional
- 专业工作站版 ProfessionalWorkstation
- 教育版 Education
- 企业版 Enterprise
- IoT 企业版 IoTEnterprise
- 企业版 G EnterpriseG (可能会转换失败)

#### 多版本转换实现机制

MSUpdate 会在构建时下载 [abbodi1406/BatUtil/W10UI](https://github.com/abbodi1406/BatUtil) 的 `W10UI.cmd`，并通过替换脚本内容插入钩子。W10UI 负责挂载 `install.wim`、集成更新、提交镜像、转换 ESD 和封装 ISO；多版本转换本身由 MSUpdate 注入的 `hook_beforewim.cmd` 完成。

实际判断当前镜像版本时，不依赖 ISO 文件名，也不依赖脚本里预设的 `$os_edition`。W10UI 挂载镜像后，钩子会对当前离线镜像执行：

```bat
DISM /Image:"挂载目录" /Get-CurrentEdition
```

如果输出包含 `CoreCountrySpecific`，就按家庭中文版处理并进入多版本转换；如果输出包含 `EnterpriseS`，就按企业版 LTSC 处理。释放 ISO 文件阶段只负责解压，不做版本判断。

家庭中文版转换路径：

- 输入版本：`CoreCountrySpecific`（家庭中文版）
- 基础版本先提交保留：`CoreCountrySpecific`
- 追加转换输出：`Core`、`CoreSingleLanguage`、`Professional`、`ProfessionalWorkstation`、`Education`、`Enterprise`、`IoTEnterprise`
- 如果存在企业版 G 版本包，还会尝试生成：`EnterpriseG`

企业版 LTSC 转换路径：

- 输入版本：`EnterpriseS`（企业版 LTSC）
- 输出版本：不写死版本列表，而是通过 `DISM /Get-TargetEditions` 获取当前镜像支持转换的目标版本，再逐个执行转换

每个目标版本的转换流程都是先执行 `DISM /Set-Edition:<目标版本>`，成功后再执行 `DISM /Commit-Image /Append` 追加到同一个 `install.wim`。W10UI 后续继续负责处理 WIM/ESD 和 ISO 封装。构建 ISO 前，`hook_beforedvd.cmd` 会再用 `wimlib-imagex` 修正各镜像索引的显示名称、描述和 `FLAGS`。

### ESD 打包

效率更高，方便快速装机

### 提供 ARM64 版本

### 提供部分旧版本 Build 镜像

## 获取镜像

<https://sys.xrgzs.top/get/msupdate>

网盘备用：

<https://url.xrgzs.top/msupdate>

## 持续集成

MSUpdate 现在使用 GitHub Actions 的 Windows Runner 进行自动构建，能持续获取到最新的 Windows 系统映像。

### 自动化流水线

项目包含以下自动化流水线，通过定时任务或手动触发实现全自动化的检测、构建和清理：

| 流水线 | 文件 | 触发方式 | 说明 |
|--------|------|----------|------|
| 版本检测 | `check.yml` | 定时 + 手动 | 检测上游更新，自动触发构建 |
| 镜像构建 | `make.yml` | 手动（或由 check 自动触发） | 集成更新并上传镜像 |
| 版本清理 | `cleanup.yml` | 定时 + 手动 | 清理云端旧版本，释放空间 |

#### 版本检测（check.yml）

- **定时触发**：每天两次，北京时间 **12:20** 和 **00:20**（UTC 04:20 和 16:20）
- **工作流程**：读取 `State.yml` 中记录的当前版本号，通过 `Request-Update` 查询上游最新版本，发现新版本时自动执行 `gh workflow run make.yml` 触发对应的构建任务
- 可手动触发，支持 `DatabaseOnly` 参数仅更新版本数据而不触发构建

#### 版本清理（cleanup.yml）

- **定时触发**：每周日北京时间 **09:10**（UTC 01:10）
- **保留策略**：每个系统版本保留最新的 **3** 个版本目录 + `latest_*.json` 中引用的版本，其余自动删除
- 可手动触发，支持自定义保留数量（`keep_count`）和试运行模式（`dry_run`，仅预览不删除）

```shell
# 手动触发清理（试运行，看看哪些会被删）
gh workflow run cleanup.yml -f dry_run=true

# 手动触发清理（实际删除，保留最新 3 个）
gh workflow run cleanup.yml

# 自定义保留数量
gh workflow run cleanup.yml -f keep_count=2
```

#### 全自动链路

```
check.yml（定时检测）
  └─ 发现新版本 → gh workflow run make.yml（自动构建）
                      └─ 构建完成 → rclone 上传到 OneDrive

cleanup.yml（定时清理）
  └─ 扫描云端目录 → 保留最新 3 个 + JSON 引用版本 → 删除旧版本
```

### 手动构建

Github Cli 一键执行所有构建：

```shell
gh workflow run make.yml -f makeversion=w1126h1a64 -f UpdateFromUUP=true -f MultiEdition=true -f SkipCheck=false
# gh workflow run make.yml -f makeversion=w1126h1a64 -f UpdateFromUUP=true -f MultiEdition=true -f SkipCheck=true
gh workflow run make.yml -f makeversion=w1126h164 -f UpdateFromUUP=true -f MultiEdition=true -f SkipCheck=false
gh workflow run make.yml -f makeversion=w1126h164 -f UpdateFromUUP=true -f MultiEdition=true -f SkipCheck=true

gh workflow run make.yml -f makeversion=w1125h2a64 -f UpdateFromUUP=true -f MultiEdition=true -f SkipCheck=false
# gh workflow run make.yml -f makeversion=w1125h2a64 -f UpdateFromUUP=true -f MultiEdition=true -f SkipCheck=true
gh workflow run make.yml -f makeversion=w1125h264 -f UpdateFromUUP=true -f MultiEdition=true -f SkipCheck=false
gh workflow run make.yml -f makeversion=w1125h264 -f UpdateFromUUP=true -f MultiEdition=true -f SkipCheck=true

gh workflow run make.yml -f makeversion=w1124h264 -f UpdateFromUUP=true -f MultiEdition=true -f SkipCheck=false
gh workflow run make.yml -f makeversion=w1124h264 -f UpdateFromUUP=true -f MultiEdition=true -f SkipCheck=true

gh workflow run make.yml -f makeversion=w11lt24a64 -f UpdateFromUUP=true -f MultiEdition=false -f SkipCheck=false
# gh workflow run make.yml -f makeversion=w11lt24a64 -f UpdateFromUUP=true -f MultiEdition=false -f SkipCheck=true
gh workflow run make.yml -f makeversion=w11lt2464 -f UpdateFromUUP=true -f MultiEdition=true -f SkipCheck=false
gh workflow run make.yml -f makeversion=w11lt2464 -f UpdateFromUUP=true -f MultiEdition=true -f SkipCheck=true

gh workflow run make.yml -f makeversion=w1123h2a64 -f UpdateFromUUP=true -f MultiEdition=true -f SkipCheck=false
# gh workflow run make.yml -f makeversion=w1123h2a64 -f UpdateFromUUP=true -f MultiEdition=true -f SkipCheck=true
gh workflow run make.yml -f makeversion=w1123h264 -f UpdateFromUUP=true -f MultiEdition=true -f SkipCheck=false
gh workflow run make.yml -f makeversion=w1123h264 -f UpdateFromUUP=true -f MultiEdition=true -f SkipCheck=true
# gh workflow run make.yml -f makeversion=w1123h264 -f UpdateFromUUP=false -f MultiEdition=true -f SkipCheck=false
# gh workflow run make.yml -f makeversion=w1123h264 -f UpdateFromUUP=false -f MultiEdition=true -f SkipCheck=true

gh workflow run make.yml -f makeversion=w1121h264 -f UpdateFromUUP=true -f MultiEdition=true -f SkipCheck=false
gh workflow run make.yml -f makeversion=w1121h264 -f UpdateFromUUP=true -f MultiEdition=true -f SkipCheck=true
# gh workflow run make.yml -f makeversion=w1121h264 -f UpdateFromUUP=false -f MultiEdition=true -f SkipCheck=false
# gh workflow run make.yml -f makeversion=w1121h264 -f UpdateFromUUP=false -f MultiEdition=true -f SkipCheck=true

gh workflow run make.yml -f makeversion=w1022h2a64 -f UpdateFromUUP=true -f MultiEdition=true -f SkipCheck=false
gh workflow run make.yml -f makeversion=w1022h264 -f UpdateFromUUP=true -f MultiEdition=true -f SkipCheck=false
gh workflow run make.yml -f makeversion=w1022h232 -f UpdateFromUUP=true -f MultiEdition=true -f SkipCheck=false
# gh workflow run make.yml -f makeversion=w1022h264 -f UpdateFromUUP=false -f MultiEdition=true -f SkipCheck=false
# gh workflow run make.yml -f makeversion=w1022h232 -f UpdateFromUUP=false -f MultiEdition=true -f SkipCheck=false

gh workflow run make.yml -f makeversion=w10lt2164 -f UpdateFromUUP=true -f MultiEdition=true -f SkipCheck=false
gh workflow run make.yml -f makeversion=w10lt2132 -f UpdateFromUUP=true -f MultiEdition=true -f SkipCheck=false
# gh workflow run make.yml -f makeversion=w10lt2164 -f UpdateFromUUP=false -f MultiEdition=false -f SkipCheck=false
# gh workflow run make.yml -f makeversion=w10lt2132 -f UpdateFromUUP=false -f MultiEdition=false -f SkipCheck=false

gh workflow run make.yml -f makeversion=w10lt1964 -f UpdateFromUUP=true -f MultiEdition=true -f SkipCheck=false
gh workflow run make.yml -f makeversion=w10lt1932 -f UpdateFromUUP=true -f MultiEdition=true -f SkipCheck=false
# gh workflow run make.yml -f makeversion=w10lt1964 -f UpdateFromUUP=false -f MultiEdition=false -f SkipCheck=false
# gh workflow run make.yml -f makeversion=w10lt1932 -f UpdateFromUUP=false -f MultiEdition=false -f SkipCheck=false

gh workflow run make.yml -f makeversion=w10lt1664 -f UpdateFromUUP=false -f MultiEdition=false -f SkipCheck=false
gh workflow run make.yml -f makeversion=w10lt1632 -f UpdateFromUUP=false -f MultiEdition=false -f SkipCheck=false
```

手动构建方法：

```powershell
$MakeVersion   = [string] "w1164"
$UpdateFromUUP = [bool]   $True
$MultiEdition  = [bool]   $True
$SkipCheck     = [bool]   $True
.\msupdate.ps1
```

目前支持的参数有：

- MakeVersion：选择制作的系统版本
  - w1125h264
  - w1124h264
  - w1123h264
  - w1121h264
  - w1022h264
  - w1022h232
  - w11lt2464
  - w10lt2164
  - w10lt2132
  - w10lt1964
  - w10lt1932
  - w10lt1664
  - w10lt1632
- UpdateFromUUP：从 UUPDUMP 获取更新(1809+)
- MultiEdition：转换多版本(LTSC 勿选)
- SkipCheck：跳过硬件检测(Win11)

构建完成后会生成 BuildLabEx 样式的 .iso 文件和 .iso.json 的校验信息文件

## 构建依赖

本项目需要使用到大量工具进行构建，包括但不限于：

- [PowerShell 7](https://github.com/PowerShell/powershell)：执行脚本
  - 不支持 Windows PowerShell 5.1

- [7-Zip](https://www.7-zip.org)：解压 ISO 等文件
- [Windows ADK](https://learn.microsoft.com/zh-cn/windows-hardware/get-started/adk-install)：可选安装，建议安装
  - DISM：镜像处理
  - Oscdimg：ISO 打包

如果您在国内使用，还得再加一个依赖：

- [Watt Toolkit](https://github.com/BeyondDimension/SteamTools)：使用 Hosts 加速模式，配置好「加速 GitHub」（免费）
- 不推荐使用系统代理，程序可能无法正常调用
- 亦可使用其它工具的 Tun 模式，仅需加速 GitHub 即可

上述依赖必须提前手动安装到默认路径，其它依赖会自动下载到 bin 文件夹内。因此，请确保有稳定的互联网连接，毕竟如果没有网络无法下载所需的更新包。

其它使用到的依赖：

- [aria2c](https://github.com/aria2/aria2)：多线程高速下载
- [rclone](https://github.com/rclone/rclone)：网盘自动发布
- [abbodi1406/BatUtil/W10UI](https://github.com/abbodi1406/BatUtil)：集成系统更新
- [wimlib-imagex](https://wimlib.net/)：镜像信息编辑、ESD 格式转换
- [M2Team/NanaRun](https://github.com/M2Team/NanaRun)：管理员权限提升
- [Secant1006/PSFExtractor](https://github.com/Secant1006/PSFExtractor)：系统补丁格式转换

系统更新列表来自：

- [adavak/Win_ISO_Patching_Scripts](https://github.com/adavak/Win_ISO_Patching_Scripts)
- [UUPDUMP.net](https://uupdump.net/)
