# 创建必要的子目录
mkdir -p nginx/conf.d mysql redis www php7.4 php8.0 php8.2 php8.3
# 确保启动脚本有执行权限
chmod +x start-services.sh
# 构建并启动容器
docker compose up -d --build -t debian-bookworm
# 访问 http://localhost 查看PHP信息页面