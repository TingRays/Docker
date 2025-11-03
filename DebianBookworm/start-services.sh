#!/bin/bash
set -e

chmod 644 /etc/mysql/conf.d/mysql.cnf 2>/dev/null || true
chmod 644 /etc/mysql/mysql.conf.d/mysqld.cnf 2>/dev/null || true

# 初始化Mysql（仅在数据目录为空时）
if [ ! -d "var/lib/mysql/mysql" ]; then
    if [ -z "$(ls -A /var/lib/mysql 2>/dev/null)" ]; then
        echo "Initializing MySQL data directory..."
        mysqld --initialize-insecure --user=mysql
    else
        echo "MySQL data directory is not empty, skipping initialization..."
    fi
else
    echo "MySQL data directory is not empty, skipping initialization..."
fi

# 设置MySQL账户
if [ ! -f "/var/lib/mysql/.user_configured" ]; then
    if [ -n "$MYSQL_ROOT_PASSWORD" ] && [ -n "$MYSQL_DATABASE" ] && [ -n "$MYSQL_USER" ] && [ -n "$MYSQL_PASSWORD" ]; then 
        echo "Configuring MySQL users..."
        mysqld_safe --user=mysql --skip-networking &
        pid="$!"

        # 等待MySQL启动
        until mysqladmin ping >/dev/null 2>&1; do
            sleep 1
        done

        # MySQL 8.4 不再支持 mysql_native_password 插件。MySQL 8.4 默认使用 caching_sha2_password 认证插件。
        # mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';"
        mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
        mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"
        mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
        mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';"
        mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "FLUSH PRIVILEGES;"

        kill "$pid"
        wait "$pid" 2>/dev/null || true
    fi
fi

chown -R mysql:mysql /var/run/mysqld
chown -R mysql:mysql /var/lib/mysqld
chown -R mysql:mysql /var/lib/mysql

# 启动supervisord
echo "Starting Supervisor..."
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf

# --------------------------------------------------------- OLD BEGIN ---------------------------------------------------------

# #!/bin/bash

# # 启动MySQL
# exec su -s /bin/bash mysql -c "mysqld"
# # service mysql start

# # 初始化MySQL数据库和用户
# if [ -n "$MYSQL_ROOT_PASSWORD" ] && [ -n "$MYSQL_DATABASE" ] && [ -n "$MYSQL_USER" ] && [ -n "$MYSQL_PASSWORD" ]; then
#     mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';"
#     mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"
#     mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
#     mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';"
#     mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "FLUSH PRIVILEGES;"
# fi


# # 启动MongoDB
# exec su -s /bin/bash mongodb -c "mongod"
# # ervice mongod start

# # 设置Redis配置
# if [ -n "$REDIS_PASSWORD" ]; then
#     sed -i "s/# requirepass .*/requirepass ${REDIS_PASSWORD}/" /etc/redis/redis.conf
# fi

# # 启动Redis
# exec su -s /bin/bash redis -c "redis-server"
# # service redis-server start

# # 启动各版本PHP-FPM
# for version in 7.4 8.0 8.3; do
#     exec /etc/init.d/php${version}-fpm start
#     # service php${version}-fpm start
# done


# # 启动Nginx
# exec nginx -g "daemon off;"