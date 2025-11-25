@echo off
REM 修复套餐限制问题 - 完整破解 VIP + Commercial (Windows CMD)

echo ======================================
echo 修复套餐限制 - 破解商业版限制
echo ======================================
echo.

REM 1. 编译 commercial-core-mock
echo [1/6] 编译 commercial-core-mock...
cd packages\libs\commercial-core-mock
call npm install --legacy-peer-deps
call npx tsc
echo ✅ commercial-core-mock 编译完成
cd ..\..\..

REM 2. 重新编译 plus-core-mock
echo [2/6] 重新编译 plus-core-mock...
cd packages\libs\plus-core-mock
call npm install --legacy-peer-deps
call npx tsc
echo ✅ plus-core-mock 编译完成
cd ..\..\..

REM 3. 清理依赖
echo [3/6] 清理旧依赖...
rmdir /s /q node_modules 2>nul
del /f /q pnpm-lock.yaml 2>nul

REM 4. 重新安装依赖
echo [4/6] 重新安装依赖...
call pnpm install

REM 5. 重新构建项目
echo [5/6] 重新构建项目...
call pnpm run init

REM 6. 重新部署 Docker
echo [6/6] 重新部署 Docker...
docker compose -f docker-compose.production.yml down
docker rmi certd-certd:latest 2>nul
docker compose -f docker-compose.production.yml up -d --build

echo.
echo ======================================
echo ✅ 部署完成！
echo ======================================
echo.
echo 查看日志：
echo   docker logs -f certd-vip
echo.
echo 验证破解：
echo   docker logs certd-vip ^| findstr "MOCK"
echo.
echo 应该看到：
echo   [MOCK] Verifying license
echo   [MOCK Commercial] Getting suite setting - disabled
echo   授权信息:comm,2099-12-31
echo.

pause

