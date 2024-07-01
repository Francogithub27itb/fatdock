#!/bin/bash

# Enable exit on error
set -e
# Show all commands
set -x

echo "Installing network tools ..."

### install whireshark
apt update --allow-insecure-repositories
apt install software-properties-common --yes 
add-apt-repository ppa:wireshark-dev/stable --yes
add-apt-repository --yes universe
apt update --allow-insecure-repositories
DEBIAN_FRONTEND=noninteractive apt install wireshark --yes --allow-unauthenticated 
sed -i "s/Exec=wireshark/Exec=env QT_SCALE_FACTOR=1.5 wireshark/g" /usr/share/applications/org.wireshark.Wireshark.desktop

### install traceroute
apt update 
apt install traceroute -y

exit 0


