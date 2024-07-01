#!/bin/bash
  
# Stops script execution if a command has an error
set -e

echo
echo "Installing Google Drive desktop (google-drive-ocamlfuse). Please wait..."
echo

add-apt-repository ppa:alessandro-strada/ppa
apt update
apt install -y google-drive-ocamlfuse

echo
echo "google-drive-ocamlfuse successfully installed"
echo 


