#!/bin/bash

set -e

nb_version=$(curl https://netbeans.apache.org/front/main/download/index.html | grep "<h1>Apache NetBeans" | rev | cut -c 6,7 | rev)

netbeans_bin="#!/bin/sh
export NETBEANS_HOME='/opt/apps/netbeans'
\$NETBEANS_HOME/bin/netbeans \$* > /dev/null 2>&1"

netbeans_desktop="[Desktop Entry]
Encoding=UTF-8
Name=Netbeans
Comment=Netbeans IDE
Exec=/home/$NB_USER/.local/bin/netbeans
Icon=/opt/apps/netbeans/nb/netbeans.png
Terminal=false
Type=Application
Categories=GNOME;Application;Development;
StartupNotify=true"

cd /tmp

if [[ ! -f "/tmp/netbeans-${nb_version}-bin.zip" ]]; then
        echo "Downloading Netbeans ..."  
        wget https://dlcdn.apache.org/netbeans/netbeans/${nb_version}/netbeans-${nb_version}-bin.zip
fi

echo "Installing Netbeans ${nb_version} ..."

unzip -oqu /tmp/netbeans-${nb_version}-bin.zip -d /opt/apps/
sudo chown $NB_USER:$NB_GID -R /opt/apps/netbeans

sudo rm -f /tmp/netbeans-${nb_version}-bin.zip

mkdir -p  /home/${NB_USER}/.local/share/applications

mkdir -p  /home/${NB_USER}/Desktop

touch /home/$NB_USER/.local/bin/netbeans
chmod 755 /home/$NB_USER/.local/bin/netbeans
touch /home/$NB_USER/Desktop/netbeans.desktop
chmod 755 /home/$NB_USER/Desktop/netbeans.desktop
echo -e "$netbeans_bin" | sudo tee /home/$NB_USER/.local/bin/netbeans
echo -e "$netbeans_desktop" | sudo tee /home/$NB_USER/Desktop/netbeans.desktop
cp /home/$NB_USER/Desktop/netbeans.desktop /home/${NB_USER}/.local/share/applications/netbeans.desktop

echo "NetBeans ${nb_version} successfully installed !"

exit 0




