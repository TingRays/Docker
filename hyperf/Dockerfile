FROM hyperf/hyperf:8.0-alpine-v3.14-swoole
COPY /skel/.bash_logout /root/.bash_logout
COPY /skel/.bashrc /root/.bashrc
COPY /skel/.profile /root/.profile
ENTRYPOINT ["php", "/data/project/hyperf/bin/hyperf.php", "start"]