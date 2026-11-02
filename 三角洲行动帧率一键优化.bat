@echo off
chcp 65001 >nul
title 三角洲行动 帧率一键优化
echo ==========================================
echo   三角洲行动 · 帧率一键优化（可回滚）
echo ==========================================
echo.
echo 将执行以下优化（全部可逆，自动备份+生成撤销脚本）：
echo   1. 电源计划 - 高性能
echo   2. 游戏模式 - 开启
echo   3. 关闭 Xbox Game DVR 后台录制
echo   4. 开启硬件加速GPU计划(HAGS)，需重启生效
echo.
echo 不涉及：删除文件、卸载软件、禁用杀毒安全软件
echo.
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo 正在申请管理员权限，请在弹窗中点击“是”...
    powershell -NoProfile -Command "Start-Process powershell -Verb RunAs -Wait -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File','%~dp0delta_boost.ps1','-EnableHAGS','-LogPath','%~dp0delta_boost_log.txt'"
    echo.
    echo 优化完成！日志：%~dp0delta_boost_log.txt
    echo 撤销：桌面“游戏优化备份”文件夹中最新“撤销游戏优化.ps1”
    echo.
    pause
    exit /b
)
echo 已获得管理员权限，开始执行...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0delta_boost.ps1" -EnableHAGS -LogPath "%~dp0delta_boost_log.txt"
echo.
echo ==========================================
echo 优化完成！运行日志：%~dp0delta_boost_log.txt
echo 撤销方法：桌面“游戏优化备份”文件夹中
echo   最新的“撤销游戏优化.ps1”，右键用 PowerShell 运行
echo ==========================================
pause