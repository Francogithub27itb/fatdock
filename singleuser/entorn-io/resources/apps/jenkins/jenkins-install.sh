#!/bin/bash
  
workdir=/resources/docker

mkdir -p /home/$NB_USER/.docker/jenkins
cp -r $workdir/compose/jenkins /home/$NB_USER/.docker/
cp -r $workdir/bin/jenkins* /home/$NB_USER/.local/bin/
chmod +x /home/$NB_USER/.local/bin/jenkins*
chown $NB_USER:$NB_GID -R /home/$NB_USER/.local/bin
