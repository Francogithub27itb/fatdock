#!/bin/bash

set -ex

echo
echo "Installing portainer ..."
echo

workdir=/resources/docker

mkdir -p /home/$NB_USER/.docker/portainer
cp -r $workdir/compose/portainer /home/$NB_USER/.docker/
cp -r $workdir/bin/portainer* /home/$NB_USER/.local/bin/
cp -r $workdir/bin/pt* /home/$NB_USER/.local/bin/
chmod +x /home/$NB_USER/.local/bin/pt*
chown $NB_USER:$NB_GID -R /home/$NB_USER/.local/bin

exit 0
