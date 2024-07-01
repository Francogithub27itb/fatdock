#!/bin/bash

RESOURCES_PATH=/resources

chmod +x $RESOURCES_PATH/apps/eclipse/eclipse-*install.sh $RESOURCES_PATH/apps/netbeans/netbeans-*install.sh $RESOURCES_PATH/apps/modelio/modelio-*install.sh $RESOURCES_PATH/apps/jetbrains-toolbox/jetbrains-toolbox-*install.sh $RESOURCES_PATH/apps/pencil/pencil-*install.sh $RESOURCES_PATH/apps/postman/postman-*install.sh $RESOURCES_PATH/apps/git-it/git-it-*install.sh $RESOURCES_PATH/apps/vscode/vscode-*install.sh $RESOURCES_PATH/apps/entorn/entorn-*install.sh

# adding install scripts to $PATH
ln -s $RESOURCES_PATH/apps/eclipse/eclipse-install.sh /home/$NB_USER/.local/bin/ 
ln -s $RESOURCES_PATH/apps/netbeans/netbeans-install.sh /home/$NB_USER/.local/bin/ 
ln -s $RESOURCES_PATH/apps/modelio/modelio-install.sh /home/$NB_USER/.local/bin/ 
ln -s $RESOURCES_PATH/apps/jetbrains-toolbox/jetbrains-toolbox-install.sh /home/$NB_USER/.local/bin/ 
ln -s $RESOURCES_PATH/apps/pencil/pencil-install.sh /home/$NB_USER/.local/bin/
ln -s $RESOURCES_PATH/apps/postman/postman-install.sh /home/$NB_USER/.local/bin/
ln -s $RESOURCES_PATH/apps/git-it/git-it-install.sh /home/$NB_USER/.local/bin/
ln -s $RESOURCES_PATH/apps/vscode/vscode-install.sh /home/$NB_USER/.local/bin/
ln -s $RESOURCES_PATH/apps/entorn/entorn-install.sh /home/$NB_USER/.local/bin/


# adding uninstall scripts to $PATH
ln -s $RESOURCES_PATH/apps/eclipse/eclipse-uninstall.sh /home/$NB_USER/.local/bin/
ln -s $RESOURCES_PATH/apps/netbeans/netbeans-uninstall.sh /home/$NB_USER/.local/bin/ 
ln -s $RESOURCES_PATH/apps/modelio/modelio-uninstall.sh /home/$NB_USER/.local/bin/ 
ln -s $RESOURCES_PATH/apps/jetbrains-toolbox/jetbrains-toolbox-uninstall.sh /home/$NB_USER/.local/bin/ 
ln -s $RESOURCES_PATH/apps/pencil/pencil-uninstall.sh /home/$NB_USER/.local/bin/ 
ln -s $RESOURCES_PATH/apps/postman/postman-uninstall.sh /home/$NB_USER/.local/bin/
ln -s $RESOURCES_PATH/apps/git-it/git-it-uninstall.sh /home/$NB_USER/.local/bin/





