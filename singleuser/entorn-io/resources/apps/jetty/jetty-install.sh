#!/bin/bash
  
workdir=/resources/docker

mkdir -p /home/$NB_USER/.docker/jetty
cp -r $workdir/compose/jetty /home/$NB_USER/.docker/
cp -r $workdir/bin/jetty* /home/$NB_USER/.local/bin/
cp -r $workdir/bin/jty* /home/$NB_USER/.local/bin/
chmod +x /home/$NB_USER/.local/bin/jetty*
chown $NB_USER:$NB_GID -R /home/$NB_USER/.local/bin
