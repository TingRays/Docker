FROM php:7.4.33-fpm-bullseye
COPY /skel/xdebug-3.1.6.tgz /home/
RUN set -eux; \
    cd /home; \
    tar -xvzf xdebug-3.1.6.tgz; \
    cd xdebug-3.1.6; \
    phpize phpize; \
    ./configure; \
    make; \
    cp modules/xdebug.so /usr/local/lib/php/extensions/no-debug-non-zts-20190902;
COPY /skel/99-xdebug.ini /usr/local/etc/php/conf.d/