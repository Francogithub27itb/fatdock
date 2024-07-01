#!/bin/bash

set -e

postman_bin="#!/bin/sh
export POSTMAN_HOME='/opt/apps/postman'
\$POSTMAN_HOME/Postman \$* > /dev/null 2>&1"

postman_desktop="[Desktop Entry]
Encoding=UTF-8
Name=Postman
Comment=Postman
Exec=/home/$NB_USER/.local/bin/postman
Icon=/opt/apps/postman/app/icons/icon_128x128.png
Terminal=false
Type=Application
Categories=GNOME;Application;Development;
StartupNotify=true"

echo
echo "Downloading the latest postman desktop app ..."
echo

postman_file=Postman-linux-latest.tar.gz
install_dir=/opt/apps

cd /tmp
wget -O $postman_file https://dl.pstmn.io/download/latest/linux64

echo "Installing postman desktop app ..."
echo

sudo tar -xzf $postman_file
sudo rm -f $postman_file

if [ -d "$install_dir/Postman" ]; then
        sudo rm -rf $install_dir/Postman
        if [ -L "$install_dir/postman" ]; then
               sudo rm -f $install_dir/postman
        fi
fi

sudo mv Postman $install_dir/
sudo ln -sf $install_dir/Postman $install_dir/postman
sudo chown $NB_USER:$NB_GID -R $install_dir/Postman

mkdir -p  /home/${NB_USER}/.local/share/applications /home/${NB_USER}/Desktop

touch /home/$NB_USER/.local/bin/postman
chmod 755 /home/$NB_USER/.local/bin/postman
touch /home/$NB_USER/Desktop/postman.desktop
chmod 755 /home/$NB_USER/Desktop/postman.desktop
echo -e "$postman_bin" | sudo tee /home/$NB_USER/.local/bin/postman
echo -e "$postman_desktop" | sudo tee /home/$NB_USER/Desktop/postman.desktop
cp /home/$NB_USER/Desktop/postman.desktop /home/${NB_USER}/.local/share/applications/postman.desktop

echo "Finished !"
echo

exit 0


