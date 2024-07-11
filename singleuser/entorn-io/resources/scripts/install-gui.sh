#!/bin/bash

# Enable exit on error
set -e
# Show all commands
set -x

echo ""
echo "Installing GUI ..."
echo ""


# Install xfce4 & gui tools

# Use staging channel to get newest xfce4 version (4.16)
add-apt-repository -y ppa:xubuntu-dev/staging

apt-get update

apt-get install -y --no-install-recommends \
    xclip \
    xfce4 \
    xfce4-panel \
    xfce4-session \
    xfce4-settings \
    xorg \
    xubuntu-icon-theme \
    fonts-dejavu

apt-get install -y --no-install-recommends \
    gconf2 \
    xfce4-terminal \
    xfce4-clipman \
    xterm 

apt-get install -y --no-install-recommends --allow-unauthenticated \
    xfce4-taskmanager

# Install dependencies to enable vncserver
apt-get install -y --no-install-recommends xauth xinit dbus-x11 

# install audio
apt install pulseaudio alsa-utils pavucontrol -y

# Install gdebi deb installer
apt-get install -y --no-install-recommends gdebi

# Search for files
apt-get install -y --no-install-recommends catfish
apt-get install -y --no-install-recommends font-manager

# vs support for thunar
apt-get install -y thunar-vcs-plugin

# Streaming text editor for large files - klogg is alternative to glogg
apt-get install -y --no-install-recommends libqt5concurrent5 libqt5widgets5 libqt5xml5 
wget --no-verbose https://github.com/variar/klogg/releases/download/v22.06/klogg-22.06.0.1289-Linux-amd64-jammy.deb -O $RESOURCES_PATH/klogg.deb 
dpkg -i $RESOURCES_PATH/klogg.deb 
rm -f $RESOURCES_PATH/klogg.deb

# Disk Usage Visualizer
apt-get install -y --no-install-recommends baobab 

# Lightweight text editor
apt-get install -y --no-install-recommends mousepad 
apt-get install -y --no-install-recommends vim

# Process monitoring
apt-get install -y --no-install-recommends htop 

# Install Archive/Compression Tools: https://wiki.ubuntuusers.de/Archivmanager/
apt-get install -y p7zip p7zip-rar 
apt-get install -y --no-install-recommends thunar-archive-plugin 
apt-get install -y xarchiver 

# DB Utils
apt-get install -y --no-install-recommends sqlitebrowser

# Install nautilus and support for sftp mounting
apt-get install -y --no-install-recommends nautilus gvfs-backends

# Install gigolo - Access remote systems
apt-get install -y --no-install-recommends gigolo gvfs-common 

# xfce systemload panel plugin - needs to be activated
apt-get update && apt-get install -y --no-install-recommends xfce4-systemload-plugin

# Leightweight ftp client that supports sftp, http, ...
apt-get install -y --no-install-recommends gftp 

# Remove light-locker to prevent screen lock
apt-get remove -y -q light-locker 
apt-get update
apt install --no-install-recommends -y libgbm1 apt-transport-https curl

#firefox
#apt-get install -y --no-install-recommends firefox

#chrome:
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - 
sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
apt-get -y update
apt-get install -y --no-install-recommends google-chrome-stable

# Cleanup
apt-get -y -qq remove xfce4-screensaver
apt-get purge -y pm-utils xscreensaver* 

# Large package: gnome-user-guide 50MB app-install-data 50MB
apt-get remove -y app-install-data gnome-user-guide

exit 0

