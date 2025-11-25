@echo off
REM VIP绕过设置脚本 - Windows版本
chcp 65001 >nul

echo ======================================
echo Certd VIP 绕过设置脚本
echo ======================================
echo.

REM 步骤0: 修复 package.json 的 overrides 配置
echo [0/6] 检查并修复配置...
powershell -Command "(Get-Content package.json -Raw) -replace '\"@certd/plus-core\": \"workspace:packages/libs/plus-core-mock\"', '\"@certd/plus-core\": \"workspace:*\"' | Set-Content package.json"
echo ✅ 配置已修复
echo.

REM 步骤1: 编译Mock模块
echo [1/6] 编译 Mock 模块...
cd packages\libs\plus-core-mock

echo    安装依赖...
call npm install --legacy-peer-deps 

echo    编译 TypeScript...
call npx tsc

if not exist "dist" (
    echo ❌ Mock模块编译失败，请检查错误信息
    pause
    exit /b 1
)
echo ✅ Mock模块编译成功
cd ..\..\..

REM 步骤2: 清理依赖
echo.
echo [2/6] 清理旧依赖...
if exist node_modules rmdir /s /q node_modules
if exist pnpm-lock.yaml del /f /q pnpm-lock.yaml
for /d /r packages %%d in (node_modules) do @if exist "%%d" rd /s /q "%%d"
echo ✅ 依赖清理完成

REM 步骤3: 检查并安装pnpm
echo.
echo [3/5] 检查 pnpm...
where pnpm >nul 2>nul
if %errorlevel% neq 0 (
    echo    pnpm 未安装，正在全局安装...
    call npm install -g pnpm
    if %errorlevel% neq 0 (
        echo ❌ pnpm 安装失败，请手动安装: npm install -g pnpm
        pause
        exit /b 1
    )
)
echo ✅ pnpm 已就绪

REM 步骤4: 重新安装依赖
echo.
echo [4/6] 重新安装依赖 (可能需要几分钟)...
call pnpm install

if %errorlevel% neq 0 (
    echo ❌ 依赖安装失败，请检查错误信息
    pause
    exit /b 1
)
echo ✅ 依赖安装完成

REM 步骤5: 验证Mock是否生效
echo.
echo [5/6] 验证配置...
findstr /c:"workspace:packages/libs/plus-core-mock" pnpm-lock.yaml >nul
if %errorlevel% equ 0 (
    echo ✅ Mock模块已正确配置
) else (
    echo ⚠️  警告: Mock模块可能未正确配置，请手动检查
)

REM 步骤6: 构建项目
echo.
echo [6/6] 构建项目...
call pnpm run init

if %errorlevel% neq 0 (
    echo ⚠️  警告: 项目构建出现错误，但可以尝试运行
)

echo.
echo ======================================
echo ✅ 设置完成！
echo ======================================
echo.
echo 现在可以启动项目了：
echo   cd packages\ui\certd-server
echo   npm start
echo.
echo 启动后查看日志，如果看到以下内容说明成功：
echo   [MOCK] Verifying license: ...
echo   授权信息:permanent,2099-12-31
echo.
echo ⚠️  注意: 此修改仅供学习研究，建议购买正版支持作者
echo.

pause

