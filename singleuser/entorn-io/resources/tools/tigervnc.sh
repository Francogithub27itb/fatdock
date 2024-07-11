#!/bin/bash

# Stops script execution if a command has an error
set -e


echo "Installing TigerVNC"
apt-get -y -qq update
apt-get -y -qq install \
            tigervnc-standalone-server \
            tigervnc-xorg-extension

echo ""
exit 0
