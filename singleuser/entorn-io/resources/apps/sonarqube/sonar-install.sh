#!/bin/bash

RESOURCES_PATH=/resources
workdir=$RESOURCES_PATH/docker

mkdir -p /home/$NB_USER/.docker/sonarqube /home/$NB_USER/.config/
cp -r $workdir/compose/sonarqube /home/$NB_USER/.docker/
cp -r $workdir/bin/sq* /home/$NB_USER/.local/bin/
cp -r $workdir/bin/sonar* /home/$NB_USER/.local/bin/
chmod +x /home/$NB_USER/.local/bin/sq*
chmod +x /home/$NB_USER/.local/bin/sonar*
cp -r $RESOURCES_PATH/config/sonar.properties /home/$NB_USER/.config/
chown $NB_USER:$NB_GID -R /home/$NB_USER/.local/bin
chown $NB_USER:$NB_GID /home/$NB_USER/.config/sonar.properties

sysctl -w vm.max_map_count=524288
sysctl -w fs.file-max=131072
ulimit -n 131072
ulimit -u 8192

exit 0
