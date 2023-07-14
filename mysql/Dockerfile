FROM mysql:5.7.42
COPY /setup.sh /home/setup.sh
RUN chmod 777 /home/setup.sh
EXPOSE 3306 3306
ENTRYPOINT ["/home/setup.sh"]