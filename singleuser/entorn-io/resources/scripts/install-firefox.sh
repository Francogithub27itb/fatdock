#!/bin/bash

# Enable exit on error
set -e
# Show all commands
set -x

echo ""
echo "Installing Firefox browser ..."
echo ""

#  install firefox browser (ubuntu 22.04)
add-apt-repository ppa:mozillateam/ppa

echo '
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001
' | sudo tee /etc/apt/preferences.d/mozilla-firefox

apt update

apt install firefox -y --allow-downgrades

apt autoremove -y

exit 0
