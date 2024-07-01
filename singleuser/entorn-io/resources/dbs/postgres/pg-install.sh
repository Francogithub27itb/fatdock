#!/bin/bash

workdir=/resources/docker

mkdir -p /home/$NB_USER/.docker/postgres
cp -r $workdir/compose/postgres /home/$NB_USER/.docker/
cp -r $workdir/bin/pg* /home/$NB_USER/.local/bin/
cp -r $workdir/bin/postgres* /home/$NB_USER/.local/bin/
chmod +x /home/$NB_USER/.local/bin/pg*
chown $NB_USER:$NB_GID -R /home/$NB_USER/.local/bin

apt update && apt install --no-install-recommends -y postgresql-client && \
    curl https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo apt-key add && \
    echo "deb https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/focal pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list && \
    apt update && apt upgrade -y 
exit 0
