# 使用Debian 12作为基础镜像
FROM debian:stable-backports

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive \
    PHP_VERSIONS="7.4 8.0 8.2 8.3"

# 安装基本依赖
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    gnupg \
    ca-certificates \
    lsb-release \
    apt-transport-https \
    software-properties-common \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# 添加PHP仓库 (Sury)
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list

# 添加MySQL仓库
RUN wget -O /etc/apt/trusted.gpg.d/mysql.gpg https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
RUN echo "deb http://repo.mysql.com/apt/debian/ $(lsb_release -sc) mysql-8.0" > /etc/apt/sources.list.d/mysql.list

# 添加MongoDB仓库
RUN wget -O /usr/share/keyrings/mongodb-archive-keyring.gpg https://pgp.mongodb.com/server-6.0.asc
RUN echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-archive-keyring.gpg ] https://repo.mongodb.org/apt/debian bookworm/mongodb-org/6.0 main" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list

# 添加Redis仓库
RUN curl -fsSL https://packages.redis.io/gpg | gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/redis.list

# 更新并安装所有服务
RUN apt-get update && apt-get install -y \
    nginx \
    mysql-server \
    mongodb-org \
    redis-server \
    && for version in $PHP_VERSIONS; do \
    apt-get install -y \
    php${version} \
    php${version}-fpm \
    php${version}-cli \
    php${version}-common; \
    done

# 定义PHP常用扩展列表
ENV PHP_COMMON_EXTENSIONS=" \
    bcmath \
    bz2 \
    calendar \
    ctype \
    curl \
    dba \
    dom \
    enchant \
    exif \
    fileinfo \
    ftp \
    gd \
    gettext \
    gmp \
    iconv \
    imap \
    intl \
    json \
    ldap \
    mbstring \
    mysqli \
    opcache \
    pcntl \
    pdo \
    pdo_mysql \
    pdo_pgsql \
    pdo_sqlite \
    pgsql \
    phar \
    posix \
    pspell \
    readline \
    shmop \
    simplexml \
    snmp \
    soap \
    sockets \
    sqlite3 \
    sysvmsg \
    sysvsem \
    sysvshm \
    tidy \
    tokenizer \
    xml \
    xmlreader \
    xmlrpc \
    xmlwriter \
    xsl \
    zip"

# 安装各版本PHP扩展
RUN for version in $PHP_VERSIONS; do \
    # 安装常用扩展
    for ext in $PHP_COMMON_EXTENSIONS; do \
    if apt-cache search --names-only "php${version}-${ext}" | grep -q "php${version}-${ext}"; then \
    apt-get install -y "php${version}-${ext}"; \
    fi; \
    done; \
    \
    # 安装特殊扩展
    apt-get install -y \
    php${version}-mongodb \
    php${version}-redis \
    php${version}-memcached \
    php${version}-xdebug \
    php${version}-imagick; \
    done

# 创建必要的目录
RUN mkdir -p /var/run/php && \
    mkdir -p /var/log/nginx && \
    mkdir -p /var/log/mysql && \
    mkdir -p /var/log/mongodb && \
    mkdir -p /var/log/redis && \
    mkdir -p /var/www/html && \
    mkdir -p /data/db

# 配置PHP各版本
RUN for version in $PHP_VERSIONS; do \
    # 配置FPM池
    sed -i "s/;listen\.owner.*/listen.owner = www-data/" /etc/php/${version}/fpm/pool.d/www.conf && \
    sed -i "s/;listen\.group.*/listen.group = www-data/" /etc/php/${version}/fpm/pool.d/www.conf && \
    sed -i "s/;listen\.mode.*/listen.mode = 0660/" /etc/php/${version}/fpm/pool.d/www.conf && \
    \
    # 增加PHP配置
    echo "upload_max_filesize = 128M" >> /etc/php/${version}/fpm/php.ini && \
    echo "post_max_size = 128M" >> /etc/php/${version}/fpm/php.ini && \
    echo "memory_limit = 512M" >> /etc/php/${version}/fpm/php.ini && \
    echo "max_execution_time = 300" >> /etc/php/${version}/fpm/php.ini && \
    echo "max_input_time = 300" >> /etc/php/${version}/fpm/php.ini && \
    \
    # 启用OPCache
    echo "opcache.enable=1" >> /etc/php/${version}/fpm/php.ini && \
    echo "opcache.enable_cli=1" >> /etc/php/${version}/fpm/php.ini && \
    echo "opcache.memory_consumption=128" >> /etc/php/${version}/fpm/php.ini && \
    echo "opcache.interned_strings_buffer=8" >> /etc/php/${version}/fpm/php.ini && \
    echo "opcache.max_accelerated_files=10000" >> /etc/php/${version}/fpm/php.ini && \
    echo "opcache.revalidate_freq=2" >> /etc/php/${version}/fpm/php.ini && \
    echo "opcache.save_comments=1" >> /etc/php/${version}/fpm/php.ini; \
    done

# 复制启动脚本
COPY start-services.sh /usr/local/bin/start-services.sh
RUN chmod +x /usr/local/bin/start-services.sh

# 暴露端口
EXPOSE 80 3306 27017 6379

# 设置工作目录
WORKDIR /var/www/html

# 启动服务
CMD ["/usr/local/bin/start-services.sh"]