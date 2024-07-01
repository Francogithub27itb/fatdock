#!/bin/bash

# Enable exit on error
set -e
# Show all commands
set -x

echo "Installing pyenv..."

echo "Major python version = ${PYTHON_VERSION_MAJOR}"

git clone https://github.com/pyenv/pyenv.git $RESOURCES_PATH/.pyenv

# Install pyenv plugins based on pyenv installer
git clone https://github.com/pyenv/pyenv-virtualenv.git $RESOURCES_PATH/.pyenv/plugins/pyenv-virtualenv 

git clone https://github.com/pyenv/pyenv-doctor.git $RESOURCES_PATH/.pyenv/plugins/pyenv-doctor 

git clone https://github.com/pyenv/pyenv-update.git $RESOURCES_PATH/.pyenv/plugins/pyenv-update 

git clone https://github.com/pyenv/pyenv-which-ext.git $RESOURCES_PATH/.pyenv/plugins/pyenv-which-ext

apt-get update -y

# TODO: lib might contain high vulnerability

# Required by pyenv
if [[  "${PYTHON_VERSION_MAJOR}" == "3.9" ]]; then
   apt-get install -y --no-install-recommends libffi-dev \
     python3-venv \
     python3.9-venv    
else
   apt-get install -y --no-install-recommends libffi-dev \
     python3-venv
    # python3.11-venv
fi

exit 0
