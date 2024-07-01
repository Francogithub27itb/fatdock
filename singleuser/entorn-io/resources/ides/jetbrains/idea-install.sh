#!/bin/bash

## IDEA Jetbrains via projector-docker and scripts
workdir=/resources/docker

mkdir -p /home/$NB_USER/.docker/idea
cp -r $workdir/compose/idea /home/$NB_USER/.docker/
cp -r $workdir/bin/idea* /home/$NB_USER/.local/bin/
chmod +x /home/$NB_USER/.local/bin/idea* 
chown $NB_USER:$NB_GID -R /home/$NB_USER/.local/bin

