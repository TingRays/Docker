# 创建必要的子目录
mkdir -p nginx/conf.d mysql redis www php7.4 php8.0 php8.2 php8.3
# 确保启动脚本有执行权限
chmod +x start-services.sh
# 构建并启动容器
docker compose up -d --build
# 访问 http://localhost 查看PHP信息页面

# 进入已运行的容器
docker exec -it php-multi-app /bin/bash
# 复制容器内文件到宿主机
docker cp php-multi-app:/etc/php/8.3/. ./php/8.3/


# 镜像源：
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json << 'EOF'
{
  "registry-mirrors": [
    "https://docker.mirrors.tuna.tsinghua.edu.cn",
    "https://hub-mirror.c.163.com",
    "https://docker.mirrors.ustc.edu.cn",
    "https://docker.1panel.live/",
    "https://dytt.online",
    "https://registry-1.docker.io"
  ]
}
EOF

sudo systemctl daemon-reload
sudo systemctl restart docker
