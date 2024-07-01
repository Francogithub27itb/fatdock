#!/bin/bash

set -e

rm -f /home/${NB_USER}/.local/bin/git-it
rm -f /home/${NB_USER}/.local/share/applications/git-it.desktop
rm -f /home/${NB_USER}/Desktop/git-it.desktop
if [ -d "/opt/apps/Git-it-Linux-x64" ]; then
        rm -rf /opt/apps/Git-it-Linux-x64
        echo "git-it successfully uninstalled !"
else
        echo "git-it is not installed in this Entorn"
fi

exit 0

