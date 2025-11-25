#!/bin/bash
# 修复套餐限制问题 - 完整破解 VIP + Commercial

echo "======================================"
echo "修复套餐限制 - 破解商业版限制"
echo "======================================"
echo ""

# 1. 编译 commercial-core-mock
echo "[1/6] 编译 commercial-core-mock..."
cd packages/libs/commercial-core-mock
npm install --legacy-peer-deps
npx tsc
echo "✅ commercial-core-mock 编译完成"
cd ../../..

# 2. 重新编译 plus-core-mock（确保最新）
echo "[2/6] 重新编译 plus-core-mock..."
cd packages/libs/plus-core-mock
npm install --legacy-peer-deps
npx tsc
echo "✅ plus-core-mock 编译完成"
cd ../../..

# 3. 清理依赖
echo "[3/6] 清理旧依赖..."
rm -rf node_modules pnpm-lock.yaml

# 4. 重新安装依赖（应用 overrides）
echo "[4/6] 重新安装依赖..."
pnpm install

# 5. 重新构建项目
echo "[5/6] 重新构建项目..."
pnpm run init

# 6. 重新部署 Docker
echo "[6/6] 重新部署 Docker..."
docker compose -f docker-compose.production.yml down
docker rmi certd-certd:latest 2>/dev/null || true
docker compose -f docker-compose.production.yml up -d --build

echo ""
echo "======================================"
echo "✅ 部署完成！"
echo "======================================"
echo ""
echo "查看日志："
echo "  docker logs -f certd-vip"
echo ""
echo "验证破解："
echo "  docker logs certd-vip | grep 'MOCK'"
echo ""
echo "应该看到："
echo "  [MOCK] Verifying license"
echo "  [MOCK Commercial] Getting suite setting - disabled"
echo "  授权信息:comm,2099-12-31"
echo ""

