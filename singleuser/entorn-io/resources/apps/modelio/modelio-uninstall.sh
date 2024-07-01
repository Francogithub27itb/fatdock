#!/bin/bash

set -e

modelio_ver="4.1"

rm -f /home/${NB_USER}/.local/bin/modelio
rm -f /home/${NB_USER}/.local/share/applications/modelio.desktop
rm -f /home/${NB_USER}/Desktop/modelio.desktop
home_dir=/opt/apps/modelio-open-source$modelio_ver
if [ -d "$home_dir" ]; then
        rm -rf $home_dir
        echo "Modelio successfully uninstalled !"
else
        echo "Modelio is not installed in this Entorn"
fi

exit 0

