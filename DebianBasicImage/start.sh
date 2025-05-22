bin/bash

service mysql start
# mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'your_password'; FLUSH PRIVILEGES;"
mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "CREATE DATABASE IF NOT EXISTS app_db;"

service php7.4-fpm start
service php8.0-fpm start
service php8.2-fpm start

service redis-server start

nginx -g "daemon off;"
