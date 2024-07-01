FROM mysql:latest

RUN mkdir -p /var/lib/mysqld && \
    chmod 777 /var/lib/mysqld

COPY ./initdb/* /docker-entrypoint-initdb.d/
