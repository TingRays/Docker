# 使用Debian 12作为基础镜像
FROM debian:bookworm

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive \
    PHP_VERSIONS="7.4 8.0 8.3"

# === 修复关键：拆分安装步骤，避免内存峰值 ===
# 第一步：只更新包索引（内存需求低）
RUN apt-get update

# 安装基本依赖
RUN apt-get install -y \
    curl \
    wget \
    gnupg \
    ca-certificates \
    lsb-release \
    apt-transport-https \
    gpg \
    debian-archive-keyring \
    sudo \
    dirmngr

# 在安装基本依赖后立即清理缓存
RUN apt-get clean

# /etc/php/ PHP目录
# /etc/nginx/ Nginx相关配置文件目录
# /etc/mysql/ MySQL配置文件目录
# /var/lib/mysql/ MySQL数据目录
# /var/lib/mongodb/ MongoDB数据文件
# /var/log/mongodb/ MongoDB日志文件
# /etc/mongod.conf  MongoDB配置文件
# /etc/redis/  Redis配置文件目录
# 创建必要的目录
RUN mkdir -p /etc/php/ && \
    mkdir -p /etc/nginx/ && \
    mkdir -p /etc/mysql/ && \
    mkdir -p /var/lib/mysql/ && \
    mkdir -p /var/lib/mongodb/ && \
    mkdir -p /var/log/mongodb/ && \
    mkdir -p /var/www/html/ && \
    mkdir -p /etc/redis/

# 添加Bullseye安全仓库解决libssl依赖
RUN echo "deb http://security.debian.org/debian-security bullseye-security main" | sudo tee /etc/apt/sources.list.d/bullseye-security.list

# MongoDB GPG密钥
RUN curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
    sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg \
    --dearmor

# MySQL GPG密钥
RUN curl -sSL https://repo.mysql.com/RPM-GPG-KEY-mysql-2023 -o /tmp/mysql.gpg && \
    gpg --dearmor --output /usr/share/keyrings/mysql-archive-keyring.gpg /tmp/mysql.gpg && \
    rm /tmp/mysql.gpg

# Redis GPG密钥
RUN curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
RUN sudo chmod 644 /usr/share/keyrings/redis-archive-keyring.gpg

# 添加Nginx GPG密钥
RUN curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null && \
    gpg --dry-run --quiet --no-keyring --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg

# 添加PHP仓库 (Sury)
# https://deb.sury.org/ 是Debian官方的PHP构建者维护的PHP源
# https://packages.sury.org/php/README.txt 的步骤可以直接添加最新的PHP源到apt source
RUN curl -sSLo /tmp/debsuryorg-archive-keyring.deb https://packages.sury.org/debsuryorg-archive-keyring.deb && \
    dpkg -i /tmp/debsuryorg-archive-keyring.deb && \
    sh -c 'echo "deb [signed-by=/usr/share/keyrings/debsuryorg-archive-keyring.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'

# 添加MySQL仓库
RUN echo "deb [ signed-by=/usr/share/keyrings/mysql-archive-keyring.gpg ] http://repo.mysql.com/apt/debian/ $(lsb_release -sc) mysql-8.0" | tee /etc/apt/sources.list.d/mysql.list

# 添加MongoDB仓库
RUN echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] http://repo.mongodb.org/apt/debian bookworm/mongodb-org/8.0 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list

# 添加Redis仓库
RUN echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list

# 添加Nginx仓库
RUN echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/debian `lsb_release -cs` nginx" | sudo tee /etc/apt/sources.list.d/nginx.list

# 更新并安装所有服务
RUN apt-get update

RUN apt-get install -y \
    nginx \
    mysql-server \
    mongodb-org \
    redis \
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
    mysql \
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

## 配置PHP各版本
#RUN for version in $PHP_VERSIONS; do \
#    # 配置FPM池
#    sed -i "s/;listen\.owner.*/listen.owner = www-data/" /etc/php/${version}/fpm/pool.d/www.conf && \
#    sed -i "s/;listen\.group.*/listen.group = www-data/" /etc/php/${version}/fpm/pool.d/www.conf && \
#    sed -i "s/;listen\.mode.*/listen.mode = 0660/" /etc/php/${version}/fpm/pool.d/www.conf && \
#    \
#    # 增加PHP配置
#    echo "upload_max_filesize = 128M" >> /etc/php/${version}/fpm/php.ini && \
#    echo "post_max_size = 128M" >> /etc/php/${version}/fpm/php.ini && \
#    echo "memory_limit = 512M" >> /etc/php/${version}/fpm/php.ini && \
#    echo "max_execution_time = 300" >> /etc/php/${version}/fpm/php.ini && \
#    echo "max_input_time = 300" >> /etc/php/${version}/fpm/php.ini && \
#    \
#    # 启用OPCache
#    echo "opcache.enable=1" >> /etc/php/${version}/fpm/php.ini && \
#    echo "opcache.enable_cli=1" >> /etc/php/${version}/fpm/php.ini && \
#    echo "opcache.memory_consumption=128" >> /etc/php/${version}/fpm/php.ini && \
#    echo "opcache.interned_strings_buffer=8" >> /etc/php/${version}/fpm/php.ini && \
#    echo "opcache.max_accelerated_files=10000" >> /etc/php/${version}/fpm/php.ini && \
#    echo "opcache.revalidate_freq=2" >> /etc/php/${version}/fpm/php.ini && \
#    echo "opcache.save_comments=1" >> /etc/php/${version}/fpm/php.ini; \
#    done

# 复制启动脚本
COPY start-services.sh /usr/local/bin/start-services.sh
RUN chmod +x /usr/local/bin/start-services.sh

# 暴露端口
EXPOSE 80 3306 27017 6379

# 设置工作目录
WORKDIR /var/www/html

# 启动服务
CMD ["/usr/local/bin/start-services.sh"]