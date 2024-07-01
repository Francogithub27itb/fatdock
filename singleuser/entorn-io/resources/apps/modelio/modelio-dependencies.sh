#!/bin/bash

set -e

### MODELIO 4.1 ####
#modelio_version=4.1.0
#modelio_ver=4.1

#cd /tmp 
#wget -c http://archive.ubuntu.com/ubuntu/pool/universe/w/webkitgtk/libwebkitgtk-1.0-0_2.4.11-3ubuntu3_amd64.deb 

#wget -c http://archive.ubuntu.com/ubuntu/pool/universe/w/webkitgtk/libjavascriptcoregtk-1.0-0_2.4.11-3ubuntu3_amd64.deb

#wget -c http://security.ubuntu.com/ubuntu/pool/main/i/icu/libicu60_60.2-3ubuntu3.2_amd64.deb 

#apt update && apt install -y libegl1 libenchant1c2a libwebkit2gtk-4.0-37 
#apt update && apt install -y libegl1 libwebkit2gtk-4.0-37

# libenchant1c2a not found in ubuntu 22.04
#wget http://uz.archive.ubuntu.com/ubuntu/ubuntu/pool/universe/e/enchant/libenchant1c2a_1.6.0-11.4_amd64.deb
#wget https://old.kali.org/kali/pool/main/e/enchant/libenchant1c2a_1.6.0-11.4_amd64.deb
#wget http://uz.archive.ubuntu.com/ubuntu/ubuntu/pool/universe/e/enchant/libenchant1c2a_1.6.0-11.3build1_amd64.deb

#file=libenchant1c2a_1.6.0-11.3build1_amd64.deb
#file=libenchant1c2a_1.6.0-11.4_amd64.deb

#dpkg -i $file
#rm -f $file

# libwebp6 not found in ubuntu 22.04
#wget http://security.ubuntu.com/ubuntu/pool/main/libw/libwebp/libwebp6_0.6.1-2ubuntu0.18.04.1_amd64.deb
#dpkg -i libwebp6_0.6.1-2ubuntu0.18.04.1_amd64.deb
#rm -f libwebp6_0.6.1-2ubuntu0.18.04.1_amd64.deb

#apt-get install --no-install-recommends -y ./libwebkitgtk-1.0-0_2.4.11-3ubuntu3_amd64.deb ./libjavascriptcoregtk-1.0-0_2.4.11-3ubuntu3_amd64.deb ./libicu60_60.2-3ubuntu3.2_amd64.deb 

#rm -f ./libwebkitgtk-1.0-0_2.4.11-3ubuntu3_amd64.deb ./libjavascriptcoregtk-1.0-0_2.4.11-3ubuntu3_amd64.deb ./libicu60_60.2-3ubuntu3.2_amd64.deb 

#apt update && apt install -y --no-install-recommends libcanberra-gtk3-module libcanberra-gtk-module 



#### MODELIO 5.3  prerequisits #####

echo 'deb http://fr.archive.ubuntu.com/ubuntu bionic main universe' > /etc/apt/sources.list.d/modelio.list

apt-get update --allow-insecure-repositories 
apt-get install libwebkitgtk-3.0-0 --yes --allow-unauthenticated

rm -f /etc/apt/sources.list.d/modelio.list

mkdir -p /etc/modelio-open-source${MODELIO_VER}/ $RESOURCES_PATH/config

cp $RESOURCES_PATH/config/modelio.config /etc/modelio-open-source${MODELIO_VER}/

exit 0

