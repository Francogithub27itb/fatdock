#!/bin/bash

# Disable exit on error
set +e
# Show all commands
set -x

echo "Installing scala kernel ..."
echo ""

curl -Lo coursier https://git.io/coursier-cli
chmod +x coursier
mkdir -p /opt/conda/share/coursier/cache
./coursier launch --fork almond:0.13.0 --scala 3.0.1 -M almond.ScalaKernel -- --install --jupyter-path /opt/conda/share/jupyter/kernels/
rm -f coursier

chgrp -R $NB_GID /opt/conda/share/coursier
chmod -R g+rwxs /opt/conda/share/coursier
chmod -R +r /opt/conda/share/jupyter/kernels/

exit 0	
