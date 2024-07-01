#!/bin/bash

git_it_bin='#!/bin/bash
export GIT_IT_HOME="/opt/apps/Git-it-Linux-x64"
$GIT_IT_HOME/Git-it > /dev/null 2>&1'

git_it_desktop="[Desktop Entry]
Encoding=UTF-8
Name=Git-it
Comment=Git it electron
Exec=/home/$NB_USER/.local/bin/git-it
Icon=$RESOURCES_PATH/icons/git-it.svg
Terminal=false
Type=Application
Categories=GNOME;Application;Development;
StartupNotify=true"

url="https://www.googleapis.com/drive/v3/files/1EYkA_TpGpBnhHsLKX-3ttSyS4xguCWU0?alt=media&key=AIzaSyAeVXfrFkPSAFhts1jApTY3BuNq9CqIZBA"

output=/tmp/git-it.zip

if [ ! -f "$output" ]; then
	wget -v -O $output $url
fi

mkdir -p /opt/apps

unzip -o $output -d /opt/apps

rm -f $output

touch /home/$NB_USER/.local/bin/git-it
chmod 755 /home/$NB_USER/.local/bin/git-it
touch /home/$NB_USER/Desktop/git-it.desktop
chmod 755 /home/$NB_USER/Desktop/git-it.desktop
echo -e "$git_it_bin" | sudo tee /home/$NB_USER/.local/bin/git-it
echo -e "$git_it_desktop" | sudo tee /home/$NB_USER/Desktop/git-it.desktop
cp /home/$NB_USER/Desktop/git-it.desktop /home/${NB_USER}/.local/share/applications/git-it.desktop
echo
echo "Git-it successfully installed"
echo
exit 0 

