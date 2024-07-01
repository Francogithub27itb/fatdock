#!/bin/bash

workdir=/resources/docker

mkdir -p /home/$NB_USER/.docker/mongodb
cp -r $workdir/compose/mongodb /home/$NB_USER/.docker/
cp -r $workdir/bin/mg* /home/$NB_USER/.local/bin/
chmod +x /home/$NB_USER/.local/bin/mg*
chown $NB_USER:$NB_GID -R /home/$NB_USER/.local/bin

MONGO_VER=5

if [ "$1" == "4" ]; then
	MONGO_VER=4
fi

if [ "$MONGO_VER" == "4" ]; then
	asc_ver=4.4
	shell_ver=4.4.8
else
	asc_ver=5.0
	shell_ver=5.0.8
fi

# mongodb dependency for Ubuntu 22.04
cd /tmp
wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb
dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb
rm  libssl1.1_1.1.1f-1ubuntu2_amd64.deb
#

apt update && curl -fsSL https://www.mongodb.org/static/pgp/server-${asc_ver}.asc | sudo apt-key add - 
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/${asc_ver} multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-${asc_ver}.list 
apt update -y 
apt install --no-install-recommends -y mongodb-org-shell=${shell_ver} mongodb-org-mongos=${shell_ver} mongodb-org-tools=${shell_ver} mongodb-mongosh 
mkdir -p /home/$NB_USER/.mongodb/db && chown $NB_USER:$NB_GID -R /home/$NB_USER/.mongodb 
mkdir -p /data && mkdir -p /app

mamba install -c anaconda pymongo dnspython -y && \	
mamba install -c conda-forge -c plotty plotly jupyter-dash cufflinks-py -y && \
jupyter lab build

cd  /resources/dbs/mongodb/imongo/ && python setup.py install
exit 0
