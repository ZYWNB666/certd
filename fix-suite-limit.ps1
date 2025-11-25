# 修复套餐限制问题 - 完整破解 VIP + Commercial (PowerShell)

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "修复套餐限制 - 破解商业版限制" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# 1. 编译 commercial-core-mock
Write-Host "[1/6] 编译 commercial-core-mock..." -ForegroundColor Yellow
Set-Location packages\libs\commercial-core-mock
npm install --legacy-peer-deps
npx tsc
Write-Host "✅ commercial-core-mock 编译完成" -ForegroundColor Green
Set-Location ..\..\..

# 2. 重新编译 plus-core-mock
Write-Host "[2/6] 重新编译 plus-core-mock..." -ForegroundColor Yellow
Set-Location packages\libs\plus-core-mock
npm install --legacy-peer-deps
npx tsc
Write-Host "✅ plus-core-mock 编译完成" -ForegroundColor Green
Set-Location ..\..\..

# 3. 清理依赖
Write-Host "[3/6] 清理旧依赖..." -ForegroundColor Yellow
Remove-Item -Recurse -Force node_modules -ErrorAction SilentlyContinue
Remove-Item -Force pnpm-lock.yaml -ErrorAction SilentlyContinue

# 4. 重新安装依赖
Write-Host "[4/6] 重新安装依赖..." -ForegroundColor Yellow
pnpm install

# 5. 重新构建项目
Write-Host "[5/6] 重新构建项目..." -ForegroundColor Yellow
pnpm run init

# 6. 重新部署 Docker
Write-Host "[6/6] 重新部署 Docker..." -ForegroundColor Yellow
docker compose -f docker-compose.production.yml down
docker rmi certd-certd:latest 2>$null
docker compose -f docker-compose.production.yml up -d --build

Write-Host ""
Write-Host "======================================" -ForegroundColor Green
Write-Host "✅ 部署完成！" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""
Write-Host "查看日志：" -ForegroundColor Cyan
Write-Host "  docker logs -f certd-vip" -ForegroundColor White
Write-Host ""
Write-Host "验证破解：" -ForegroundColor Cyan
Write-Host "  docker logs certd-vip | Select-String 'MOCK'" -ForegroundColor White
Write-Host ""
Write-Host "应该看到：" -ForegroundColor Cyan
Write-Host "  [MOCK] Verifying license" -ForegroundColor White
Write-Host "  [MOCK Commercial] Getting suite setting - disabled" -ForegroundColor White
Write-Host "  授权信息:comm,2099-12-31" -ForegroundColor White
Write-Host ""

Write-Host "按任意键退出..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

