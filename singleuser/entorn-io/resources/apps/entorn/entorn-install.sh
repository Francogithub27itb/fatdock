#!/bin/bash

set -e

password=pluralcamp

entorn_desktop="[Desktop Entry]
Encoding=UTF-8
Name=Entorn
Comment=Entorn 0.1.0
Exec=/home/$NB_USER/.local/bin/entorn-web
Icon=/resources/icons/coding.svg
Terminal=false
Type=Application
Categories=GNOME;Application;Development;
StartupNotify=false"

mkdir -p  /home/${NB_USER}/.local/share/applications

mkdir -p  /home/${NB_USER}/Desktop

entorn_exec="$RESOURCES_PATH/bin-user-student/entorn-web"
if [ -f "$entorn_exec" ]; then
	\cp "$entorn_exec" /home/$NB_USER/.local/bin/
	chown $NB_USER:$NB_GID /home/$NB_USER/.local/bin/entorn-web
	chmod +x /home/$NB_USER/.local/bin/entorn-web
fi
desk_file="/home/$NB_USER/Desktop/entorn.desktop"
touch $desk_file
chmod 755 $desk_file
echo -e "$entorn_desktop" | sudo tee $desk_file
chown $NB_USER:$NB_GID $desk_file
cp $desk_file /home/${NB_USER}/.local/share/applications/entorn.desktop

echo
echo "Entorn Web is now here available !"
echo "If required:"
echo "Username is $NB_USER"
echo "Password is $password"
echo

exit 0




