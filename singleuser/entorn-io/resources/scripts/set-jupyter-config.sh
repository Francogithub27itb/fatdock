#!/bin/bash

RESOURCES_PATH=/resources
JUPYTERLAB_SETTINGS_DIR=/home/$NB_USER/.jupyter/lab/user-settings/@jupyterlab
TERMINAL_DIR=$JUPYTERLAB_SETTINGS_DIR/terminal-extension

\cp $RESOURCES_PATH/scripts/terminal-customize.sh /usr/bin/
\cp $RESOURCES_PATH/scripts/jpy-customize.sh  /usr/bin/

mkdir -p $TERMINAL_DIR
chown $NB_USER:$NB_GID -R /home/$NB_USER/.jupyter
\cp $RESOURCES_PATH/config/plugin.jupyterlab-settings $TERMINAL_DIR/

DESK_TERM_USER_CONF_DIR=/home/$NB_USER/.config/dconf
mkdir -p $DESK_TERM_USER_CONF_DIR
chown $NB_USER:$NB_GID -R /home/$NB_USER/.config
\cp $RESOURCES_PATH/config/user $DESK_TERM_USER_CONF_DIR/

