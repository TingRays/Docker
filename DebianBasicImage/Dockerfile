FROM debian:stable-backports

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y wget gnupg ca-certificates && \
    wget -qO- https://packages.sury.org/php/apt.gpg | apt-key add - && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list && \
    wget -qO- https://repo.mysql.com/RPM-GPG-KEY-mysql-2022 | apt-key add - && \
    echo "deb http://repo.mysql.com/apt/debian/ $(lsb_release -sc) mysql-8.0" > /etc/apt/sources.list.d/mysql.list

RUN apt-get update && \
    apt-get install -y \
    nginx \
    mysql-server \
    php7.4-fpm php7.4-mysql php7.4-redis \
    php8.0-fpm php8.0-mysql php8.0-redis \
    php8.2-fpm php8.2-mysql php8.2-redis \
    redis-server \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY nginx.conf /etc/nginx/nginx.conf
COPY php-fpm.conf /etc/nginx/conf.d/
COPY start.sh /start.sh

RUN chmod +x /start.sh && \
    mkdir -p /var/run/php && \
    mkdir -p /var/run/mysqld && \
    chown -R mysql:mysql /var/run/mysqld && \
    chown -R www-data:www-data /var/www/html

EXPOSE 80 3306 6379

CMD ["/start.sh"]
