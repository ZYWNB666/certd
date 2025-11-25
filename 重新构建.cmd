@echo off
chcp 65001 >nul

echo ==========================================
echo 修复构建错误并重新构建
echo ==========================================
echo.

echo [1/2] 重新构建所有包...
cd ..\..
call pnpm run init

if %errorlevel% neq 0 (
    echo ❌ 构建失败
    pause
    exit /b 1
)

echo.
echo ✅ 构建成功！
echo.
echo [2/2] 启动服务...
cd packages\ui\certd-server
call npm start

