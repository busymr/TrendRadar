#!/bin/bash
# 容器启动脚本

set -e

CONTAINER_NAME="trend-radar-local"
IMAGE_NAME="trendradar:local"
DINGTALK_WEBHOOK_URL="https://oapi.dingtalk.com/robot/send?access_token=22b4fee2b5b28e5c3be90f72645c5526b22e96caa69a3ba61b02eeeecc34fa38"

echo "🚀 启动容器..."

# 停止并删除旧容器（如果存在）
if docker ps -a | grep -q $CONTAINER_NAME; then
    echo "🛑 停止旧容器..."
    docker stop $CONTAINER_NAME || true
    echo "🗑️  删除旧容器..."
    docker rm -f $CONTAINER_NAME || true
fi

# 获取项目根目录（脚本在 bin/ 下）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# 转换为 Windows 路径格式（Docker Desktop 需要）
if [[ "$PROJECT_DIR" =~ ^/([a-z])/ ]]; then
    DRIVE="${BASH_REMATCH[1]}"
    PROJECT_DIR="$(echo "$PROJECT_DIR" | sed "s|^/[a-z]/|${DRIVE^^}:/|")"
fi

echo "📁 项目目录: $PROJECT_DIR"

# 启动新容器
echo "▶️  启动新容器: $CONTAINER_NAME"
docker run -d \
  --name $CONTAINER_NAME \
  -v "$PROJECT_DIR/config:/app/config:ro" \
  -v "$PROJECT_DIR/output:/app/output" \
  -e DINGTALK_WEBHOOK_URL="$DINGTALK_WEBHOOK_URL" \
  -e CRON_SCHEDULE="0 8,20 * * *" \
  -e RUN_MODE="cron" \
  -e IMMEDIATE_RUN="true" \
  $IMAGE_NAME

echo "✅ 容器启动成功"
echo ""
echo "📊 容器状态:"
docker ps | grep $CONTAINER_NAME

echo ""
echo "📝 查看日志: docker logs -f $CONTAINER_NAME"
echo "🛑 停止容器: docker stop $CONTAINER_NAME"
echo "🔄 重启容器: docker restart $CONTAINER_NAME"
