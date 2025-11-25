@echo off
REM Certd VIP版本 构建脚本 (Windows)

chcp 65001 >nul

echo ==========================================
echo 构建 Certd VIP 破解版 Docker 镜像
echo ==========================================
echo.

REM 配置
set IMAGE_NAME=certd-vip
set TAG=%1
if "%TAG%"=="" set TAG=latest
set FULL_IMAGE_NAME=%IMAGE_NAME%:%TAG%

echo [1/4] 检查环境...
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker 未安装或未运行
    pause
    exit /b 1
)
docker --version
echo ✅ Docker 检查通过
echo.

echo [2/4] 清理旧镜像...
docker rmi %FULL_IMAGE_NAME% 2>nul
echo ✅ 清理完成
echo.

echo [3/4] 构建镜像 (这可能需要几分钟)...
docker build ^
  -t %FULL_IMAGE_NAME% ^
  -f Dockerfile.production ^
  --no-cache ^
  .

if %errorlevel% neq 0 (
    echo ❌ 构建失败
    pause
    exit /b 1
)
echo ✅ 构建成功
echo.

echo [4/4] 验证镜像...
docker images %IMAGE_NAME%
echo.

echo ==========================================
echo ✅ 构建完成！
echo ==========================================
echo.
echo 镜像名称: %FULL_IMAGE_NAME%
echo.
echo 快速启动:
echo   docker run -d ^
echo     --name certd-vip ^
echo     -p 7001:7001 ^
echo     -p 7002:7002 ^
echo     -v %cd%\data:/app/data ^
echo     %FULL_IMAGE_NAME%
echo.
echo 或使用 Docker Compose:
echo   docker-compose -f docker-compose.production.yml up -d
echo.
pause

