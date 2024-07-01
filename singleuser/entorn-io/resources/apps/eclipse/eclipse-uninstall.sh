#!/bin/bash

set -e

rm -f /home/${NB_USER}/.local/bin/eclipse
rm -f /home/${NB_USER}/.local/share/applications/eclipse.desktop
rm -f /home/${NB_USER}/Desktop/eclipse.desktop
if [ -d "/opt/apps/eclipse" ]; then
        rm -rf /opt/apps/eclipse
        echo "Eclipse successfully uninstalled !"
else
        echo "Eclipse is not installed in this Entorn"
fi

exit 0

