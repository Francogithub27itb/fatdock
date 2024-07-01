#!/bin/bash

set -e

dir_name=pencil

PENCIL_HOME=/opt/apps/$dir_name


rm -f /home/${NB_USER}/.local/bin/pencil
rm -f /home/${NB_USER}/.local/share/applications/pencil.desktop
rm -f /home/${NB_USER}/Desktop/pencil.desktop
if [ -d "$PENCIL_HOME" ]; then
        rm -rf $PENCIL_HOME
        echo "Pencil Project successfully uninstalled !"
else
        echo "Pencil Project is not installed in this Entorn"
fi

exit 0

