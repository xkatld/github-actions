#!/bin/bash

echo "正在安装 ttyd 和 Cloudflared..."

# 安装 ttyd
sudo apt update -y
sudo apt install snapd -y
sudo snap install ttyd --classic

# 安装 Cloudflared
ARCH=$(uname -m)
if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    wget -q https://github.com/cloudflare/cloudflared/releases/download/2025.10.1/cloudflared-linux-arm64 -O cloudflared
else
    wget -q https://github.com/cloudflare/cloudflared/releases/download/2025.10.1/cloudflared-linux-amd64 -O cloudflared
fi
chmod +x cloudflared
sudo mv cloudflared /usr/local/bin/

# 停止可能存在的进程
pkill -f ttyd 2>/dev/null || true
pkill -f cloudflared 2>/dev/null || true

# 启动 ttyd（关键：-W 允许写入，直接运行 bash）
echo "启动 ttyd..."
ttyd -p 7681 -W bash &
TTYD_PID=$!

# 等待启动
sleep 3

# 检查 ttyd 是否运行
if ps -p $TTYD_PID > /dev/null; then
    echo "✓ ttyd 启动成功 (PID: $TTYD_PID)"
else
    echo "✗ ttyd 启动失败，尝试重新启动..."
    ttyd -p 7681 -W bash &
    TTYD_PID=$!
    sleep 2
fi

# 检查端口
if netstat -tuln | grep -q ":7681"; then
    echo "✓ ttyd 正在监听端口 7681"
else
    echo "✗ ttyd 未监听端口 7681"
    exit 1
fi

# 启动 Cloudflared 隧道
echo "启动 Cloudflared 隧道..."
nohup cloudflared tunnel --url http://localhost:7681 > cloudflared.log 2>&1 &
CLOUDFLARED_PID=$!

# 等待隧道建立
echo "等待隧道建立..."
sleep 10

# 获取公共 URL
PUBLIC_URL=""
for i in {1..10}; do
    if [ -f cloudflared.log ]; then
        PUBLIC_URL=$(grep -o "https://[a-zA-Z0-9.-]*\.trycloudflare\.com" cloudflared.log | head -1)
        if [ -n "$PUBLIC_URL" ]; then
            break
        fi
    fi
    sleep 2
done

# 显示访问信息
IP=$(hostname -I | awk '{print $1}')
echo ""
echo "=================================================="
echo "安装完成！"
echo "=================================================="
echo "本地访问: http://$IP:7681"
if [ -n "$PUBLIC_URL" ]; then
    echo "外网访问: $PUBLIC_URL"
else
    echo "外网访问: 正在生成... (查看: cat cloudflared.log)"
fi
echo ""
echo "现在应该可以直接在网页终端中输入命令了！"
echo "=================================================="

# 保存进程信息
echo $TTYD_PID > ttyd.pid
echo $CLOUDFLARED_PID > cloudflared.pid
