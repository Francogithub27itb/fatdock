#!/bin/bash

# Enable exit on error
set -e
# Show all commands
set -x

echo ""
echo "Installing docker clients ..."
echo ""

apt-get update 
apt-get install -y --no-install-recommends \
  apt-transport-https \
  ca-certificates \
  openssh-client \
  curl \
  wget \
  iputils-ping \
  iptables 

arch="$(uname --m)"
case "$arch" in \
      # amd64
      x86_64) dockerArch='x86_64' ;; \
      # arm32v6
      armhf) dockerArch='armel' ;; \
      # arm32v7
      armv7) dockerArch='armhf' ;; \
      # arm64v8
      aarch64) dockerArch='aarch64' ;; \
      *) echo >&2 "error: unsupported architecture ($arch)"; exit 1 ;;\
esac 
if ! wget -O docker.tgz "https://download.docker.com/linux/static/${DOCKER_CHANNEL}/${dockerArch}/docker-${DOCKER_VERSION}.tgz"; then 
   echo >&2 "error: failed to download 'docker-${DOCKER_VERSION}' from '${DOCKER_CHANNEL}' for '${dockerArch}'"
   exit 1
fi
tar --extract --file docker.tgz --strip-components 1 --directory /usr/local/bin/ 
rm docker.tgz

dockerd --version
docker --version 

apt-get install -y docker-buildx

echo ""
echo ">>>>>>>>>>>>>>>>>>>> adding docker group <<<<<<<<<<<<<<<<<<<<<<"
echo ""

GROUP_NAME="docker"

# Check if the group exists
if grep -q "^$GROUP_NAME:" /etc/group; then
    echo "Group $GROUP_NAME already exists."
else
    echo "Group $GROUP_NAME does not exist. Creating..."
    groupadd $GROUP_NAME
    echo "Group $GROUP_NAME created."
fi

usermod -aG docker $NB_USER 

mkdir -p /var/lib/docker

echo ""
echo "Installing docker-compose ..."
echo ""

## docker compose
curl -L "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose 
chmod +x /usr/local/bin/docker-compose 
chmod 755 /var/lib/docker

docker-compose version

exit 0
