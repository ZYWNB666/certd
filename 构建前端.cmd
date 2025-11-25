@echo off
chcp 65001 >nul

echo ==========================================
echo 构建前端页面
echo ==========================================
echo.

echo [1/2] 构建前端项目...
cd packages\ui\certd-client
call pnpm run build

if %errorlevel% neq 0 (
    echo ❌ 前端构建失败
    pause
    exit /b 1
)

echo.
echo ✅ 前端构建成功！
echo.
echo [2/2] 重启后端服务...
cd ..\certd-server

echo.
echo ==========================================
echo ✅ 前端构建完成！
echo ==========================================
echo.
echo 请按 Ctrl+C 停止当前运行的服务
echo 然后重新运行: npm start
echo.
echo 或者直接访问: http://localhost:7001
echo.
pause

