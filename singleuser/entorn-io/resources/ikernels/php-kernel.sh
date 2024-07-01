#!/bin/bash

CONDA_BASE_PATH=/opt/conda

# Disable exit on error
set +e
# Show all commands
set -x

echo "Installing php kernel ..."
echo ""

apt update -y && apt install --no-install-recommends php php-zmq -y 

cd /bin 

php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"

#php -r "if (hash_file('sha384', 'composer-setup.php') === '906a84df04cea2aa72f40b5f787e49f22d4c2f19492ac310e8cba5b96ac8b64115ac402c8cd292b8a03482574915d1a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" 

php composer-setup.php --1 
php -r "unlink('composer-setup.php');" 
cd /tmp 

wget https://litipk.github.io/Jupyter-PHP-Installer/dist/jupyter-php-installer.phar 

php ./jupyter-php-installer.phar install -vvv 
mv /usr/local/share/jupyter/kernels/jupyter-php $CONDA_BASE_PATH/share/jupyter/kernels/php 
chown $NB_USER:$NB_GID -R $CONDA_BASE_PATH/share/jupyter/kernels
rm -f /tmp/jupyter-php-installer.phar

exit 0
