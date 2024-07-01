#!/bin/bash


# Stops script execution if a command has an error
set -e

if [ ! -f "/usr/local/bin/code-server"  ]; then
    echo "Installing VS Code Server. Please wait..."
    npm install -g npm@10.0.0
    #/bin/bash /usr/bin/install-node.sh
    cd ${RESOURCES_PATH}
    VS_CODE_VERSION=${CODESERVER_VER}
    # Install Yarn
    /usr/bin/npm install -g yarn
    /usr/bin/npm install -g npm@${NPM_VER}
    #ls -lah /home/$NB_USER/.cache/node/corepack/yarn/1.22.19
    #echo "ls /usr/local/lib/node_modules/yarn/bin/"
    #ls -lah /opt/conda/node/lib/node_modules/yarn/bin/
     
    #ln -s /opt/conda/node/lib/node_modules/yarn/bin/yarn.js /home/$NB_USER/.cache/node/corepack/yarn/1.22.19/bin/yarn.js

    #ls -lah /home/$NB_USER/.cache/node/corepack/yarn/1.22.19/bin
    # Use yarn install since it is smaller
    #yarn --production --frozen-lockfile global add code-server@"$VS_CODE_VERSION"
    curl -fsSL https://code-server.dev/install.sh | sh
    #yarn cache clean
    mkdir -p /home/$NB_USER/workspaces && chown $NB_USER:$NB_GID -R /home/$NB_USER/workspaces
    mkdir -p /home/$NB_USER/.config/Code/ && chown $NB_USER:$NB_GID -R /home/$NB_USER/.config
    mkdir -p /home/$NB_USER/.vscode/extensions/ && chown $NB_USER:$NB_GID -R /home/$NB_USER/.vscode
    if [[ ! -e /usr/bin/code-server ]]; then 
        ln -s /opt/conda/share/npm-packages/bin/code-server /usr/bin/code-server
    fi 
else
    echo "VS Code Server is already installed"
fi

