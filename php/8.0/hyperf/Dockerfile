FROM hyperf/hyperf:8.0-alpine-v3.14-swoole
COPY /skel/.bash_logout /root/.bash_logout
COPY /skel/.bashrc /root/.bashrc
COPY /skel/.profile /root/.profile
# apk update 更新存储库索引
# apk upgrade 升级当前安装的程序包以匹配存储库
RUN apk upgrade; \
    apk add epel-release; \
    apk add supervisor; \
    mkdir /etc/supervisor.d;
COPY /skel/hyperf.ini /ect/supervisor.d/
RUN supervisord -c /etc/supervisord.conf
ENTRYPOINT ["php", "/data/project/hyperf/bin/hyperf.php", "start"]