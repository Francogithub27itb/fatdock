#!/bin/bash

set -e

rm -f /home/${NB_USER}/.local/bin/netbeans
rm -f /home/${NB_USER}/.local/share/applications/netbeans.desktop
rm -f /home/${NB_USER}/Desktop/netbeans.desktop
if [ -d "/opt/apps/netbeans" ]; then
        rm -rf /opt/apps/netbeans
        echo "NetBeans successfully uninstalled !"
else
        echo "Netbeans is not installed in this Entorn"
fi

exit 0

