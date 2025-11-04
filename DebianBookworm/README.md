# 拉取代码到本地宿主机
git clone https://github.com/tingrays/xxxxxx.git 
# 进入目录下
cd /xxxx/Docker/DebianBookworm/
# 构建并启动容器
docker compose up -d --build
# 访问 http://localhost 查看PHP信息页面

# 进入已运行的容器
docker exec -it php-multi-app /bin/bash

# 查看服务状态
supervisorctl status
# 重启特定服务
supervisorctl restart nginx
# 查看所有服务日志
tail -f /var/log/supervisor/supervisord.log

# 复制容器内文件到宿主机
docker cp php-multi-app:/etc/php/8.3/. ./php/8.3/
# 复制宿主机文件到容器内
docker cp ./mysql-apt-config_0.8.35-1_all.deb debian-test:/usr/local/bin/mysql-apt-config_0.8.35-1_all.deb
# 创建一个测试容器
docker run -it -d --name debian-test debian:bookworm

# 镜像源：
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json << 'EOF'
{
  "features": {
    "buildkit": true
  },
  "live-restore": true,
  "registry-mirrors": [
    "https://docker.1ms.run",
    "https://docker-0.unsee.tech",
    "https://docker.m.daocloud.io",
    "https://registry.docker.io"
  ]
}
EOF

sudo systemctl daemon-reload
sudo systemctl restart docker
