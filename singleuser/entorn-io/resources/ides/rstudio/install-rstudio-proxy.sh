#!/bin/bash

set -ex

echo "Installing R Studio Proxy ..."
echo


export RSESSION_PROXY_RSTUDIO_1_4=true

mamba install -c conda-forge jupyter-rsession-proxy --yes

# config:

echo "provider=postgresql" >> /etc/rstudio/database.conf
echo "host=localhost" >> /etc/rstudio/database.conf
echo "database=rstudio"  >> /etc/rstudio/database.conf
echo "port=5432" >> /etc/rstudio/database.conf
echo "username=postgres" >> /etc/rstudio/database.conf
echo "password=postgres" >> /etc/rstudio/database.conf
echo "auth-none=1" > /etc/rstudio/rserver.conf
echo "www-address=127.0.0.1"  >> /etc/rstudio/rserver.conf
echo "database-config-file=/etc/rstudio/database.conf" >> /etc/rstudio/rserver.conf
#echo "server-working-dir=~/rstudio" >> /etc/rstudio/rserver.conf
echo "session-timeout-minutes=30" > /etc/rstudio/rsession.conf
echo "session-default-working-dir=~/rstudio" >> /etc/rstudio/rsession.conf
#sed -i "s/agent=0'/agent=0', f'--server-user={os.getenv(\"NB_USER\")}'/g" /opt/conda/lib/python${PYTHON_VERSION_MAJOR}/site-packages/jupyter_rsession_proxy/__init__.py

mkdir -p /home/$NB_USER/rstudio/projects
echo
echo "R Studio Proxy successfully installed !"
echo

exit 0


