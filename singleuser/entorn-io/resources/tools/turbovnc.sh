#!/bin/bash

# Stops script execution if a command has an error
set -e

echo ""
echo "Installing TurboVNC"
# Install instructions from https://turbovnc.org/Downloads/YUM
wget -q -O- https://packagecloud.io/dcommander/turbovnc/gpgkey | \
        gpg --dearmor >/etc/apt/trusted.gpg.d/TurboVNC.gpg; 
wget -O /etc/apt/sources.list.d/TurboVNC.list https://raw.githubusercontent.com/TurboVNC/repo/main/TurboVNC.list
apt-get -y -qq update
apt-get -y -qq install turbovnc

apt-get remove -y -q light-locker

apt update && apt install -y at-spi

exit 0

