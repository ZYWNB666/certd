# VIP绕过设置脚本 - PowerShell版本

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Certd VIP 绕过设置脚本" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# 步骤0: 修复 package.json 的 overrides 配置
Write-Host "[0/7] 检查并修复配置..." -ForegroundColor Yellow
$packageJson = Get-Content package.json -Raw
$packageJson = $packageJson -replace '"@certd/plus-core": "workspace:packages/libs/plus-core-mock"', '"@certd/plus-core": "workspace:*"'
$packageJson | Set-Content package.json -NoNewline
Write-Host "✅ 配置已修复" -ForegroundColor Green
Write-Host ""

# 步骤1: 编译Mock模块
Write-Host "[1/7] 编译 Mock 模块..." -ForegroundColor Yellow
Push-Location packages/libs/plus-core-mock

# 先安装 TypeScript（如果没有的话）
Write-Host "   安装依赖..." -ForegroundColor Gray
npm install --legacy-peer-deps 2>$null

# 编译
Write-Host "   编译 TypeScript..." -ForegroundColor Gray
npx tsc

if (-not (Test-Path "dist")) {
    Write-Host "❌ Mock模块编译失败，请检查错误信息" -ForegroundColor Red
    Pop-Location
    exit 1
}
Write-Host "✅ Mock模块编译成功" -ForegroundColor Green
Pop-Location

# 步骤2: 清理依赖
Write-Host ""
Write-Host "[2/7] 清理旧依赖..." -ForegroundColor Yellow
if (Test-Path "node_modules") {
    Remove-Item -Recurse -Force "node_modules"
}
if (Test-Path "pnpm-lock.yaml") {
    Remove-Item -Force "pnpm-lock.yaml"
}
Get-ChildItem -Path "packages" -Recurse -Directory -Filter "node_modules" | Remove-Item -Recurse -Force
Write-Host "✅ 依赖清理完成" -ForegroundColor Green

# 步骤3: 检查并安装pnpm
Write-Host ""
Write-Host "[3/7] 检查 pnpm..." -ForegroundColor Yellow
$pnpmExists = Get-Command pnpm -ErrorAction SilentlyContinue
if (-not $pnpmExists) {
    Write-Host "   pnpm 未安装，正在全局安装..." -ForegroundColor Gray
    npm install -g pnpm
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ pnpm 安装失败，请手动安装: npm install -g pnpm" -ForegroundColor Red
        exit 1
    }
}
Write-Host "✅ pnpm 已就绪" -ForegroundColor Green

# 步骤4: 重新安装依赖
Write-Host ""
Write-Host "[4/7] 重新安装依赖 (可能需要几分钟)..." -ForegroundColor Yellow
pnpm install

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 依赖安装失败，请检查错误信息" -ForegroundColor Red
    exit 1
}
Write-Host "✅ 依赖安装完成" -ForegroundColor Green

# 步骤5: 验证Mock是否生效
Write-Host ""
Write-Host "[5/7] 验证配置..." -ForegroundColor Yellow
$lockContent = Get-Content "pnpm-lock.yaml" -Raw
if ($lockContent -match "workspace:packages/libs/plus-core-mock") {
    Write-Host "✅ Mock模块已正确配置" -ForegroundColor Green
} else {
    Write-Host "⚠️  警告: Mock模块可能未正确配置，请手动检查" -ForegroundColor Yellow
}

# 步骤6: 构建项目
Write-Host ""
Write-Host "[6/7] 构建项目..." -ForegroundColor Yellow
pnpm run init

if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  警告: 项目构建出现错误，但可以尝试运行" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "✅ 设置完成！" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "现在可以启动项目了：" -ForegroundColor White
Write-Host "  cd packages\ui\certd-server" -ForegroundColor Gray
Write-Host "  npm start" -ForegroundColor Gray
Write-Host ""
Write-Host "启动后查看日志，如果看到以下内容说明成功：" -ForegroundColor White
Write-Host "  [MOCK] Verifying license: ..." -ForegroundColor Gray
Write-Host "  授权信息:permanent,2099-12-31" -ForegroundColor Gray
Write-Host ""
Write-Host "⚠️  注意: 此修改仅供学习研究，建议购买正版支持作者" -ForegroundColor Yellow
Write-Host ""

