#!/bin/bash

# Disable exit on error
set +e
# Show all commands
set -x

echo "Installing java kernel ..."
echo ""

cd /tmp
wget -O ijava-${IJAVA_VERSION}.zip https://github.com/SpencerPark/IJava/releases/download/v${IJAVA_VERSION}/ijava-${IJAVA_VERSION}.zip 
unzip -o ./ijava-${IJAVA_VERSION}.zip
python3 install.py --sys-prefix --startup-scripts-path /opt/jshell/printing.jshell
rm -f /tmp/ijava-${IJAVA_VERSION}.zip && rm -f /tmp/install.py && rm -rf /tmp/ijava

# Customizing java kernel
cp $RESOURCES_PATH/config/ijava/kernel.json /opt/conda/share/jupyter/kernels/java/kernel.json

# Adding startup-script for java kernel
mkdir -p /opt/jshell
cp $RESOURCES_PATH/config/ijava/printing.jshell /opt/jshell/

exit 0	
