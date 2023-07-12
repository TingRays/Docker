FROM php:8.1.21-fpm-bullseye
ADD /skel/xdebug-3.2.1.tgz /home/
RUN set -eux; \
	&& apt-get update \
	&& apt-get install php-dev autoconf automake \
    && cd /home \
    && tar -xvzf xdebug-3.2.1.tgz \
    && cd xdebug-3.2.1 \
    && phpize phpize \
    && ./configure \
    && make \
    && cp modules/xdebug.so /usr/local/lib/php/extensions/no-debug-non-zts-20210902
ADD /skel/99-xdebug.ini /usr/local/etc/php/conf.d/
#ENTRYPOINT ["php", "/data/project/hyperf/bin/hyperf.php", "start"]