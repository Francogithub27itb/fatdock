#!/bin/bash

# Enable exit on error
set -e
# Show all commands
set -x

echo ""
echo "Installing node..."
echo ""


apt-get update && apt-get install -y ca-certificates curl gnupg
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
NODE_MAJOR=20
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
apt-get update && apt-get install nodejs -y


# As conda is first in path, the commands 'node' and 'npm' reference to the version of conda.
# Replace those versions with the newly installed versions of node
rm -f /opt/conda/bin/node && ln -s /usr/bin/node /opt/conda/bin/node
rm -f /opt/conda/bin/npm && ln -s /usr/bin/npm /opt/conda/bin/npm
# Fix permissions
chmod a+rwx /usr/bin/node 
chmod a+rwx /usr/bin/npm 
# Fix node versions - put into own dir and before conda:
mkdir -p /opt/node/bin
if [[ ! -e /opt/node/bin/node ]]; then
   ln -s /usr/bin/node /opt/node/bin/node
fi
if [[ ! -e /opt/node/bin/npm ]]; then 
   ln -s /usr/bin/npm /opt/node/bin/npm 
fi
# Update npm
/usr/bin/npm install -g npm
# Install Yarn
/usr/bin/npm install -g yarn
# Install typescript
/usr/bin/npm install -g typescript 
# Install webpack - 32 MB
/usr/bin/npm install -g webpack
# Install node-gyp
/usr/bin/npm install -g node-gyp
# Update all packages to latest version
/usr/bin/npm update -g

exit 0


