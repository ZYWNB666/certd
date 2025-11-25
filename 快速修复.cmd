@echo off
chcp 65001 >nul

echo ==========================================
echo Certd VIP 快速修复脚本
echo ==========================================
echo.

echo [步骤 1] 清理环境...
cd packages\libs\plus-core-mock
if exist dist rd /s /q dist
if exist node_modules rd /s /q node_modules
cd ..\..\..

if exist node_modules rd /s /q node_modules
if exist pnpm-lock.yaml del /f /q pnpm-lock.yaml

echo ✅ 清理完成
echo.

echo [步骤 2] 编译 Mock 模块...
cd packages\libs\plus-core-mock
call npm install --legacy-peer-deps
call npx tsc

if not exist "dist\index.js" (
    echo ❌ 编译失败
    cd ..\..\..
    pause
    exit /b 1
)

echo ✅ Mock 模块编译成功
cd ..\..\..
echo.

echo [步骤 3] 安装依赖...
call pnpm install

if %errorlevel% neq 0 (
    echo ❌ 依赖安装失败
    pause
    exit /b 1
)

echo ✅ 依赖安装成功
echo.

echo [步骤 4] 验证替换...
findstr /c:"@certd/plus-core" pnpm-lock.yaml | findstr /c:"link:" >nul
if %errorlevel% equ 0 (
    echo ✅ Mock 模块替换成功
) else (
    echo ⚠️  警告：可能未正确替换
)
echo.

echo [步骤 5] 构建项目...
call pnpm run init

echo.
echo ==========================================
echo ✅ 修复完成！
echo ==========================================
echo.
echo 现在启动服务：
echo   cd packages\ui\certd-server
echo   npm start
echo.
echo 查看日志中是否有：
echo   [MOCK] Verifying license...
echo   授权信息:permanent,2099-12-31
echo.
pause

