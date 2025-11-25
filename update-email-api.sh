#!/bin/bash
# 更新邮件 API 配置并重新部署

echo "======================================"
echo "更新邮件 API 配置"
echo "======================================"

# 1. 重新编译 Mock 模块
echo "[1/4] 重新编译 Mock 模块..."
cd packages/libs/plus-core-mock
npm install --legacy-peer-deps
npx tsc
cd ../../..

echo "✅ Mock 模块编译完成"

# 2. 停止旧容器
echo "[2/4] 停止旧容器..."
docker compose -f docker-compose.production.yml down

# 3. 清理旧镜像（可选）
echo "[3/4] 清理旧镜像..."
docker rmi certd-certd:latest 2>/dev/null || true

# 4. 重新构建并启动
echo "[4/4] 重新构建并启动..."
docker compose -f docker-compose.production.yml up -d --build

echo ""
echo "======================================"
echo "✅ 部署完成！"
echo "======================================"
echo ""
echo "查看日志："
echo "  docker logs -f certd-vip"
echo ""
echo "查看邮件发送日志（包含自定义 API）："
echo "  docker logs certd-vip | grep 'MOCK.*email'"
echo ""

