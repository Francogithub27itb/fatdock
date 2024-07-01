#!/bin/bash

# Stops script execution if a command has an error
set -e

echo "Installing turbovnc ..."
echo ""

wget -q "https://sourceforge.net/projects/turbovnc/files/${TURBOVNC_VERSION}/turbovnc_${TURBOVNC_VERSION}_amd64.deb/download" -O turbovnc_${TURBOVNC_VERSION}_amd64.deb 

apt-get install -y -q ./turbovnc_${TURBOVNC_VERSION}_amd64.deb 

apt-get remove -y -q light-locker

rm ./turbovnc_${TURBOVNC_VERSION}_amd64.deb

ln -s /opt/TurboVNC/bin/* /usr/local/bin/ 

apt update && apt install -y at-spi

exit 0

