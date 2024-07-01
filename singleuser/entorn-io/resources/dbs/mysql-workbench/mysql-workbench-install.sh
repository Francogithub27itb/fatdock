#!/bin/bash

set -e

if [ "$NB_USER" == "" ]; then
	NB_USER=$USER
fi

mwb_ver="8.0.36-1"

mysql_workbench_file="mysql-workbench-community_${mwb_ver}ubuntu22.04_amd64.deb"
mysql_workbench_url="https://dev.mysql.com/get/Downloads/MySQLGUITools/$mysql_workbench_file"

echo
echo "Installing mysql-workbench community ..."
echo

cd /tmp

apt_ver="0.8.30-1"

wget https://dev.mysql.com/get/mysql-apt-config_${apt_ver}_all.deb

sudo DEBIAN_FRONTEND="noninteractive" dpkg -i mysql-apt-config_${apt_ver}_all.deb

rm -f mysql-apt-config_${apt_ver}_all.deb

sudo apt update

## Dependencies
sudo apt install -y libpcrecpp0v5 libproj-dev libzip-dev proj-data proj-bin
#apt install -y mysql-workbench-community libpcrecpp0v5 libproj22 libzip4 proj-data
sudo apt install -y libzip4 libstdc++6 libssl3 libsasl2-2 libpython3.10 libproj22  libgtkmm-3.0-1v5 libglibmm-2.4-1v5 libglib2.0-0 libgdk-pixbuf-2.0-0 libdeflate0 libc6 libatkmm-1.6-1v5

# mysql-workbench-community
wget $mysql_workbench_url
sudo dpkg -i $mysql_workbench_file
rm -f $mysql_workbench_file

if [ -e "/home/$NB_USER/.local/bin/mysql-workbench" ]; then
    echo "File exists"
    if [ ! -L "/home/$NB_USER/.local/bin/mysql-workbench" ]; then
        echo "File exists but is not a symbolic link"
        # You can choose to remove it or handle it differently
        rm /home/$NB_USER/.local/bin/mysql-workbench
        ln -s /usr/bin/mysql-workbench /home/$NB_USER/.local/bin/mysql-workbench
        echo "Symbolic link created"
    else
        echo "File is already a symbolic link"
    fi
else
    ln -s /usr/bin/mysql-workbench /home/$NB_USER/.local/bin/mysql-workbench
    echo "Symbolic link created"
fi

if [ -e "/home/$NB_USER/.local/bin/workbench" ]; then
    echo "File exists"
    if [ ! -L "/home/$NB_USER/.local/bin/workbench" ]; then
        echo "File exists but is not a symbolic link"
        # You can choose to remove it or handle it differently
        rm /home/$NB_USER/.local/bin/workbench
        ln -s /usr/bin/mysql-workbench /home/$NB_USER/.local/bin/workbench
        echo "Symbolic link created"
    else
        echo "File is already a symbolic link"
    fi
else
    ln -s /usr/bin/mysql-workbench /home/$NB_USER/.local/bin/workbench
    echo "Symbolic link created"
fi

sed -i '2i\export LANG=en_US.UTF-8\nexport LANGUAGE=en_US:en\nexport LC_ALL=en_US.UTF-8' /usr/bin/mysql-workbench

mkdir -p /home/$NB_USER/Desktop

cp /usr/share/applications/mysql-workbench.desktop /home/$NB_USER/Desktop/mysql-workbench.desktop

chown $NB_USER:$NB_GID -R /home/$NB_USER/Desktop

echo "Finished !"
echo

