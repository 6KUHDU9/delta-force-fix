@echo off
chcp 65001 >nul
title 无畏契约 一键帧率优化
setlocal enabledelayedexpansion

REM ============ 1. 自动提权 ============
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo 正在请求管理员权限,请在弹窗中点击"是"...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)
cd /d "%~dp0"

echo ================================================
echo        无畏契约 一键帧率优化
echo        硬件: i5-12400F / RTX 4060 / 16G
echo ================================================
echo.

REM ============ 2. 备份注册表 ============
set STAMP=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set STAMP=%STAMP: =0%
set BK=%~dp0backup_%STAMP%
mkdir "%BK%" 2>nul

echo [1/6] 备份注册表(用于日后撤销)...
reg export "HKCU\SOFTWARE\Microsoft\GameBar" "%BK%\GameBar.reg" /y >nul 2>&1
reg export "HKCU\System\GameConfigStore" "%BK%\GameConfigStore.reg" /y >nul 2>&1
reg export "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" "%BK%\GameDVR.reg" /y >nul 2>&1
reg export "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" "%BK%\GraphicsDrivers.reg" /y >nul 2>&1
reg export "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" "%BK%\Run.reg" /y >nul 2>&1
echo     已备份到: %BK%
echo.

REM ============ 3. 电源计划 ============
echo [2/6] 电源计划...
set E_HIGH=0
powercfg /getactivescheme | findstr /i "8c5e7fda" >nul 2>&1 && set E_HIGH=1
if "!E_HIGH!"=="1" (
    echo     [已是最优] 电源计划已是「高性能」
) else (
    powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >nul 2>&1
    if !errorlevel! equ 0 (
        echo     [完成] 已切换为「高性能」电源计划
    ) else (
        echo     [提示] 未找到「高性能」计划,尝试创建...
        for /f "tokens=3" %%a in ('powercfg /duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c ^| findstr /i "GUID"') do set NEWG=%%a
        if defined NEWG (
            powercfg /setactive !NEWG! >nul 2>&1
            echo     [完成] 已创建并启用「高性能」计划
        ) else (
            echo     [失败] 无法创建,请到 控制面板-电源选项 手动设置高性能
        )
    )
)
echo.

REM ============ 4. 游戏模式 / 后台录制 ============
echo [3/6] 游戏模式 与 后台录制...
reg add "HKCU\SOFTWARE\Microsoft\GameBar" /v AutoGameModeEnabled /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /t REG_DWORD /d 0 /f >nul 2>&1
echo     [完成] 游戏模式已开启; GameDVR/后台录制已关闭
echo.

REM ============ 5. HAGS ============
echo [4/6] 硬件加速GPU计划(HAGS)...
set E_HAGS=0
reg query "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v HwSchMode | findstr /i "0x2" >nul 2>&1 && set E_HAGS=1
if "!E_HAGS!"=="1" (
    echo     [已是最优] HAGS 已开启
) else (
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v HwSchMode /t REG_DWORD /d 2 /f >nul 2>&1
    echo     [完成] 已开启 HAGS,重启后生效
)
echo.

REM ============ 6. 关闭后台高占用程序 ============
echo [5/6] 释放内存: 关闭后台高占用程序
echo.
echo     将尝试关闭(需你的确认):
echo       - 剪映专业版   (当前占用约 2.2 GB)
echo       - 抖音         (当前占用约 1.2 GB)
echo       - 通义千问 / 夸克
echo.
echo     注意: 剪映未保存的草稿会丢失!
choice /c YN /m "是否立即关闭上述程序"
if !errorlevel! equ 1 (
    taskkill /IM JianyingPro.exe /F >nul 2>&1
    taskkill /IM douyin.exe /F >nul 2>&1
    taskkill /IM qianwen.exe /F >nul 2>&1
    taskkill /IM quark.exe /F >nul 2>&1
    echo     [完成] 已尝试关闭,释放约 3.5 GB 内存
) else (
    echo     [跳过] 保持后台程序运行
)
echo.

REM ============ 7. 禁用非必需自启动项 ============
echo [6/6] 禁用非必需开机自启动项
echo.
echo     将禁用(注册表已备份,可随时恢复):
echo       - 通义千问 / 夸克 / 夸克更新器
echo       - Edge 后台预启动
echo.
choice /c YN /m "是否禁用这些自启动项"
if !errorlevel! equ 1 (
    reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v qianwen /f >nul 2>&1
    reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v quark /f >nul 2>&1
    reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v QuarkUpdaterTaskUser1.0.0.21 /f >nul 2>&1
    reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v MicrosoftEdgeAutoLaunch_98769996E24836F99EC8617644423B4C /f >nul 2>&1
    echo     [完成] 已禁用自启动项
) else (
    echo     [跳过] 保持原自启动项
)
echo.

REM ============ 8. 生成撤销脚本 ============
echo [完成] 生成撤销脚本...
echo @echo off> "%BK%\撤销本次优化.bat"
echo chcp 65001 ^>nul>> "%BK%\撤销本次优化.bat"
echo title 撤销无畏契约优化>> "%BK%\撤销本次优化.bat"
echo net session ^>nul 2^>^&1 >> "%BK%\撤销本次优化.bat"
echo if %%errorlevel%% neq 0 ^(>> "%BK%\撤销本次优化.bat"
echo     powershell -NoProfile -Command "Start-Process -FilePath '%%~f0' -Verb RunAs">> "%BK%\撤销本次优化.bat"
echo     exit /b>> "%BK%\撤销本次优化.bat"
echo ^)>> "%BK%\撤销本次优化.bat"
echo cd /d "%%~dp0">> "%BK%\撤销本次优化.bat"
echo echo 正在恢复备份时的设置...>> "%BK%\撤销本次优化.bat"
echo reg import "%%~dp0GameBar.reg">> "%BK%\撤销本次优化.bat"
echo reg import "%%~dp0GameConfigStore.reg">> "%BK%\撤销本次优化.bat"
echo reg import "%%~dp0GameDVR.reg">> "%BK%\撤销本次优化.bat"
echo reg import "%%~dp0GraphicsDrivers.reg">> "%BK%\撤销本次优化.bat"
echo reg import "%%~dp0Run.reg">> "%BK%\撤销本次优化.bat"
echo echo.>> "%BK%\撤销本次优化.bat"
echo echo 已恢复备份时的全部注册表设置, 包括游戏模式/后台录制/HAGS/自启动项。>> "%BK%\撤销本次优化.bat"
echo echo 注: HAGS 恢复后重启才完全生效, 被关闭的后台程序请手动重新打开。>> "%BK%\撤销本次优化.bat"
echo pause>> "%BK%\撤销本次优化.bat"
echo     撤销脚本: %BK%\撤销本次优化.bat
echo.

echo ================================================
echo 优化完成! 以下建议请你手动操作:
echo.
echo [1] 显示器刷新率 —— 当前 60Hz, 这是最大瓶颈!
echo     你的 4060 在无畏契约里能轻松跑 300+ 帧,
echo     但 60Hz 屏幕实际只能显示 60 帧。
echo     操作: 设置-系统-显示-高级显示设置, 看是否有更高刷新率;
echo           若显示器支持 144Hz+, 请用 DP 线并选最高刷新率;
echo           若面板本身只有 60Hz, 换 144Hz 显示器提升最明显。
echo.
echo [2] NVIDIA 控制面板: 管理3D设置-全局设置
echo     电源管理模式 = 最高性能优先
echo     低延时模式 = 开(配合游戏内 Reflex 最佳)
echo     垂直同步 = 关
echo.
echo [3] 游戏内设置:
echo     显示模式 = 全屏独占;  垂直同步 = 关
echo     帧率上限 = 显示器刷新率(60Hz 屏设 60, 144Hz 屏设 144+)
echo     NVIDIA Reflex = 开+加速;  画质中高即可
echo.
echo [4] 玩之前手动关掉浏览器/微信, 效果立竿见影
echo.
echo 撤销: 运行备份目录中的「撤销本次优化.bat」
echo 备份目录: %BK%
echo ================================================
pause