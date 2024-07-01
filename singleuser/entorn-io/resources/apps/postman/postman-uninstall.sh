#!/bin/bash

set -e

dir_name=Postman

ln_name=postman

POSTMAN_HOME=/opt/apps/$dir_name


rm -f /home/${NB_USER}/.local/bin/postman
rm -f /home/${NB_USER}/.local/share/applications/postman.desktop
rm -f /home/${NB_USER}/Desktop/postman.desktop
if [ -d "$POSTMAN_HOME" ]; then
        rm -rf $POSTMAN_HOME
	rm -f /opt/apps/$ln_name
        echo "Postman successfully uninstalled !"
else
        echo "Postman is not installed in this Entorn"
fi

exit 0

