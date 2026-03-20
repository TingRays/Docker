#!/bin/bash
set -e

# 确保MySQL所有必要的目录存在且权限正确
mkdir -p /var/run/mysqld
mkdir -p /var/lib/mysql
mkdir -p /var/log/mysql
chown -R mysql:mysql /var/run/mysqld /var/lib/mysql /var/log/mysql

chmod 644 /etc/mysql/conf.d/mysql.cnf 2>/dev/null || true
chmod 644 /etc/mysql/mysql.conf.d/mysqld.cnf 2>/dev/null || true

sleep 5

# 初始化Mysql（仅在数据目录为空时）
if [ ! -d "/var/lib/mysql/mysql" ]; then
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
if [ ! -f "/var/lib/mysql/user_configured" ]; then
    if [ -n "$MYSQL_ROOT_PASSWORD" ] && [ -n "$MYSQL_DATABASE" ] && [ -n "$MYSQL_USER" ] && [ -n "$MYSQL_PASSWORD" ]; then 
        echo "Configuring MySQL users..."
        # 临时关闭 set -e 以便在 mysqld 启动失败时能打印日志
        set +e
        mysqld --user=mysql --skip-networking --daemonize
        MYSQL_START_EXIT_CODE=$?
        set -e

        if [ $MYSQL_START_EXIT_CODE -ne 0 ]; then
            echo "CRITICAL: MySQL failed to start with exit code $MYSQL_START_EXIT_CODE. Checking error log:"
            [ -f /var/log/mysql/error.log ] && cat /var/log/mysql/error.log || echo "Error log not found."
            exit 1
        fi
        
        # 等待MySQL启动
        max_attempts=30
        attempt=0
        until mysqladmin ping >/dev/null 2>&1 || [ $attempt -eq $max_attempts ]; do
            sleep 2
            attempt=$((attempt + 1))
        done

        if [ $attempt -eq $max_attempts ]; then
            echo "CRITICAL: MySQL failed to start within timeout. Checking error log:"
            [ -f /var/log/mysql/error.log ] && cat /var/log/mysql/error.log || echo "Error log not found."
            exit 1
        fi

        # 配置账户
        mysql -u root -e "FLUSH PRIVILEGES;" || true
        mysql -u root -e "ALTER USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';" || true
        mysql -u root -e "DROP USER IF EXISTS root@'localhost';" || true
        mysql -u root -e "FLUSH PRIVILEGES;" || true

        mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown

        touch /var/lib/mysql/user_configured
        echo "MySQL basic configuration completed."
    fi
fi

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