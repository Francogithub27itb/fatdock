#!/bin/bash

set -e


rm -f /home/${NB_USER}/.local/bin/jetbrains-toolbox
rm -f /home/${NB_USER}/.local/bin/toolbox

rm -f /home/${NB_USER}/.local/share/applications/toolbox.desktop
rm -f /home/${NB_USER}/Desktop/toolbox.desktop
if [ -d "/opt/apps/jetbrains-toolbox" ]; then
        rm -rf /opt/apps/jetbrains-toolbox
        echo "Jetbrains Toolbox successfully uninstalled !"
else
        echo "Jetbrains Toolbox is not installed in this Entorn"
fi

exit 0

