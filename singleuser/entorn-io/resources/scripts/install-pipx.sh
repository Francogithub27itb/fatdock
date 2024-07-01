#!/bin/bash

# Enable exit on error
set -e
# Show all commands
set -x

echo "Installing pipx..."

apt-get update
apt-get -y install python3-pip
python3 -m pip install pipx
#pip install pipx
# Configure pipx
python3 -m pipx ensurepath

exit 0	
