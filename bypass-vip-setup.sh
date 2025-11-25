#!/bin/bash
# VIP绕过设置脚本 - Linux/Mac版本

echo "======================================"
echo "Certd VIP 绕过设置脚本"
echo "======================================"
echo ""

# 步骤1: 编译Mock模块
echo "[1/5] 编译 Mock 模块..."
cd packages/libs/plus-core-mock || exit 1

echo "   安装依赖..."
npm install --legacy-peer-deps 2>/dev/null

echo "   编译 TypeScript..."
npx tsc

if [ ! -d "dist" ]; then
    echo "❌ Mock模块编译失败，请检查错误信息"
    exit 1
fi
echo "✅ Mock模块编译成功"
cd ../../..

# 步骤2: 清理依赖
echo ""
echo "[2/5] 清理旧依赖..."
rm -rf node_modules
rm -rf packages/*/node_modules
rm -rf packages/*/*/node_modules
rm -f pnpm-lock.yaml
echo "✅ 依赖清理完成"

# 步骤3: 重新安装依赖
echo ""
echo "[3/5] 重新安装依赖 (可能需要几分钟)..."
pnpm install

if [ $? -ne 0 ]; then
    echo "❌ 依赖安装失败，请检查错误信息"
    exit 1
fi
echo "✅ 依赖安装完成"

# 步骤4: 验证Mock是否生效
echo ""
echo "[4/5] 验证配置..."
if grep -q "workspace:packages/libs/plus-core-mock" pnpm-lock.yaml; then
    echo "✅ Mock模块已正确配置"
else
    echo "⚠️  警告: Mock模块可能未正确配置，请手动检查"
fi

# 步骤5: 构建项目
echo ""
echo "[5/5] 构建项目..."
pnpm run init

if [ $? -ne 0 ]; then
    echo "⚠️  警告: 项目构建出现错误，但可以尝试运行"
fi

echo ""
echo "======================================"
echo "✅ 设置完成！"
echo "======================================"
echo ""
echo "现在可以启动项目了："
echo "  cd packages/ui/certd-server"
echo "  npm start"
echo ""
echo "启动后查看日志，如果看到以下内容说明成功："
echo "  [MOCK] Verifying license: ..."
echo "  授权信息:permanent,2099-12-31"
echo ""
echo "⚠️  注意: 此修改仅供学习研究，建议购买正版支持作者"
echo ""

