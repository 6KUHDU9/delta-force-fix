@echo off
setlocal enabledelayedexpansion
title 三角洲行动 - 环境清洁与网络修复
color 0A

:: ---------- 自动申请管理员权限 ----------
>nul 2>&1 net session
if %errorlevel% neq 0 (
    echo 需要管理员权限, 正在申请...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: ---------- 安全校验 ----------
if not defined temp (
    echo [错误] TEMP 环境变量为空, 终止操作.
    pause
    exit /b 1
)
if not exist "%temp%\" (
    echo [错误] TEMP 路径无效.
    pause
    exit /b 1
)
for %%i in ("%temp%") do set "TEMP_DIR=%%~fi"
echo !TEMP_DIR! | findstr /r "^[A-Za-z]:\\$" >nul
if !errorlevel! equ 0 (
    echo [错误] TEMP 为根目录, 已拒绝执行.
    pause
    exit /b 1
)

set "WIN_TEMP=C:\Windows\Temp"
if not exist "%WIN_TEMP%\" set "WIN_TEMP="
set "PREFETCH=C:\Windows\Prefetch"
if not exist "%PREFETCH%\" set "PREFETCH="
set "ACE_DIR=C:\Program Files\AntiCheatExpert"
if not exist "%ACE_DIR%\" set "ACE_DIR="
set "GAME_DIR=D:\WeGameApps\rail_apps\DeltaForce(2001918)"
if not exist "%GAME_DIR%\" set "GAME_DIR="
set "GAME_CACHE=D:\WeGameApps\rail_user_data\2001918\Cache"
if not exist "%GAME_CACHE%\" set "GAME_CACHE="

cls
echo ============================================================
echo            三角洲行动 - 环境清洁与网络修复
echo ============================================================
echo.
echo  本脚本将执行:
echo    [1] 清理用户临时文件
echo    [2] 清理 Windows 临时文件夹
echo    [3] 清空 Prefetch 预读取缓存
echo    [4] 刷新 DNS 缓存
echo    [5] 重置 Winsock 目录 (需重启)
echo    [6] 重置 TCP/IP 协议栈 (需重启)
echo    [7] 清空 ACE 反作弊启动日志
echo    [8] 结束常见干扰进程
echo    [9] 清理三角洲行动本地缓存
echo.
set /p confirm=确认执行请按 Y: 
if /i not "%confirm%"=="Y" goto :END

echo.
echo [1/9] 清理用户临时文件...
del /f /s /q "!TEMP_DIR!\*.*" >nul 2>&1
for /d %%i in ("!TEMP_DIR!\*") do rd /s /q "%%i" >nul 2>&1
echo      完成.

echo.
echo [2/9] 清理 Windows 临时文件夹...
if defined WIN_TEMP (
    del /f /s /q "%WIN_TEMP%\*.*" >nul 2>&1
    for /d %%i in ("%WIN_TEMP%\*") do rd /s /q "%%i" >nul 2>&1
)
echo      完成.

echo.
echo [3/9] 清空 Prefetch...
if defined PREFETCH del /f /q "%PREFETCH%\*.*" >nul 2>&1
echo      完成.

echo.
echo [4/9] 刷新 DNS 缓存...
ipconfig /flushdns
echo      完成.

echo.
echo [5/9] 重置 Winsock...
netsh winsock reset
echo      完成 (重启后生效).

echo.
echo [6/9] 重置 TCP/IP...
netsh int ip reset
netsh int ipv4 reset
netsh int ipv6 reset
echo      完成 (重启后生效).

echo.
echo [7/9] 清空 ACE 日志...
if defined ACE_DIR (
    del /f /q "%ACE_DIR%\ace-boot-*.log" >nul 2>&1
    del /f /q "%ACE_DIR%\*.log" >nul 2>&1
)
echo      完成 (保留驱动和程序).

echo.
echo [8/9] 结束干扰进程...
taskkill /f /im QQGameService.exe >nul 2>&1
taskkill /f /im QQGameServiceHelper.exe >nul 2>&1
taskkill /f /im QQGame.exe >nul 2>&1
taskkill /f /im QQGameMaker.exe >nul 2>&1
taskkill /f /im dnplayer.exe >nul 2>&1
taskkill /f /im Nox.exe >nul 2>&1
taskkill /f /im LDPlayer.exe >nul 2>&1
taskkill /f /im Snipaste.exe >nul 2>&1
taskkill /f /im ShareX.exe >nul 2>&1
taskkill /f /im WeGameTray.exe >nul 2>&1
echo      完成.

echo.
echo [9/9] 清理游戏缓存...
if defined GAME_DIR if exist "%GAME_DIR%\Temp" del /f /s /q "%GAME_DIR%\Temp\*.*" >nul 2>&1
if defined GAME_CACHE del /f /s /q "%GAME_CACHE%\*.*" >nul 2>&1
echo      完成.

echo.
echo ============================================================
echo  全部完成! 请重启电脑后再进游戏.
echo ============================================================
echo.
echo  注意:
echo    1. 重启后先开 WeGame 用游戏修复校验文件
echo    2. 进游戏前不要开 QQ游戏大厅/模拟器/按键精灵
echo    3. 排查 VPN/代理/鼠标宏/路由器翻墙插件
echo.
set /p reboot=是否立即重启? (Y/N): 
if /i "%reboot%"=="Y" shutdown /r /t 5 /c 5秒后重启

:END
endlocal
pause
