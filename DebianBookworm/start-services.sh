#!/bin/bash

# 设置MySQL数据目录权限
chown -R mysql:mysql /var/lib/mysql/
chown -R mysql:mysql /etc/mysql/

# 启动MySQL
service mysql start

# 初始化MySQL数据库和用户
if [ -n "$MYSQL_ROOT_PASSWORD" ] && [ -n "$MYSQL_DATABASE" ] && [ -n "$MYSQL_USER" ] && [ -n "$MYSQL_PASSWORD" ]; then
    mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';"
    mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"
    mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
    mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';"
    mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "FLUSH PRIVILEGES;"
fi

# 启动MongoDB
service mongod start

# 设置Redis配置
if [ -n "$REDIS_PASSWORD" ]; then
    sed -i "s/# requirepass .*/requirepass ${REDIS_PASSWORD}/" /etc/redis/redis.conf
fi

# 设置Redis数据目录权限
mkdir -p /var/lib/redis
chown -R redis:redis /var/lib/redis

# 启动Redis
service redis-server start

# 启动各版本PHP-FPM
for version in 7.4 8.0 8.3; do
    service php${version}-fpm start
done

# 设置Nginx目录权限
chown -R www-data:www-data /var/www/html

# 启动Nginx
nginx -g "daemon off;"