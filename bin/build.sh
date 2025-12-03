#!/bin/bash
# 镜像构建脚本

set -e

IMAGE_NAME="trendradar:local"

echo "🔨 开始构建镜像..."

# 删除旧镜像（如果存在）
if docker images | grep -q "^trendradar.*local"; then
    echo "🗑️  删除旧镜像..."
    docker rmi -f $IMAGE_NAME || true
fi

# 构建新镜像
echo "📦 构建新镜像: $IMAGE_NAME"
docker build -t $IMAGE_NAME -f docker/Dockerfile .

echo "✅ 镜像构建完成: $IMAGE_NAME"
docker images | grep trendradar
