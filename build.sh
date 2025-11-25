#!/bin/bash
# Certd VIP版本 构建脚本

set -e

echo "=========================================="
echo "构建 Certd VIP 破解版 Docker 镜像"
echo "=========================================="
echo ""

# 配置
IMAGE_NAME="certd-vip"
TAG="${1:-latest}"
FULL_IMAGE_NAME="${IMAGE_NAME}:${TAG}"

echo "[1/4] 检查环境..."
command -v docker >/dev/null 2>&1 || { echo "❌ Docker 未安装"; exit 1; }
echo "✅ Docker 版本: $(docker --version)"
echo ""

echo "[2/4] 清理旧镜像..."
docker rmi ${FULL_IMAGE_NAME} 2>/dev/null || true
echo "✅ 清理完成"
echo ""

echo "[3/4] 构建镜像..."
docker build \
  -t ${FULL_IMAGE_NAME} \
  -f Dockerfile.production \
  --no-cache \
  .

if [ $? -ne 0 ]; then
  echo "❌ 构建失败"
  exit 1
fi
echo "✅ 构建成功"
echo ""

echo "[4/4] 验证镜像..."
docker images ${IMAGE_NAME}
echo ""

echo "=========================================="
echo "✅ 构建完成！"
echo "=========================================="
echo ""
echo "镜像名称: ${FULL_IMAGE_NAME}"
echo "镜像大小: $(docker images ${FULL_IMAGE_NAME} --format '{{.Size}}')"
echo ""
echo "快速启动:"
echo "  docker run -d \\"
echo "    --name certd-vip \\"
echo "    -p 7001:7001 \\"
echo "    -p 7002:7002 \\"
echo "    -v \$(pwd)/data:/app/data \\"
echo "    ${FULL_IMAGE_NAME}"
echo ""
echo "或使用 Docker Compose:"
echo "  docker-compose -f docker-compose.production.yml up -d"
echo ""

