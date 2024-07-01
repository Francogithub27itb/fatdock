#!/bin/bash

set -e

password=pluralcamp

vscode_desktop="[Desktop Entry]
Encoding=UTF-8
Name=VSCode
Comment=Visual Studio Code
Exec=/home/$NB_USER/.local/bin/entorn-vscode
Icon=/resources/icons/vscode.svg
Terminal=false
Type=Application
Categories=GNOME;Application;Development;
StartupNotify=true"

mkdir -p  /home/${NB_USER}/.local/share/applications

mkdir -p  /home/${NB_USER}/Desktop

vscode_exec="$RESOURCES_PATH/bin-user-student/entorn-vscode"
if [ -f "$vscode_exec" ]; then
	\cp "$vscode_exec" /home/$NB_USER/.local/bin/
	chown $NB_USER:$NB_GID /home/$NB_USER/.local/bin/entorn-vscode
	chmod +x /home/$NB_USER/.local/bin/entorn-vscode
fi
desk_file="/home/$NB_USER/Desktop/vscode.desktop"
touch $desk_file
chmod 755 $desk_file
chown $NB_USER:$NB_GID $desk_file
echo -e "$vscode_desktop" | sudo tee $desk_file
cp $desk_file /home/${NB_USER}/.local/share/applications/vscode.desktop

echo
echo "Visual Studio Code is now here available !"
echo "If required:"
echo "Username is $NB_USER"
echo "Password is $password"
echo

exit 0




