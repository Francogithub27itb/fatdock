#!/bin/bash

set -e

if [[ -z "$RESOURCES_PATH" ]]; then
                RESOURCES_PATH=/resources
fi

#### RUN HOOKS ####
run-hooks () {
    # Source scripts or run executable files in a directory
    if [[ ! -d "$1" ]] ; then
        return
    fi
    echo "$0: running hooks in $1"
    for f in "$1/"*; do
        case "$f" in
            *.sh)
                echo "$0: running $f"
                # shellcheck disable=SC1090
                source "$f"
                ;;
            *)
                if [[ -x "$f" ]] ; then
                    echo "$0: running $f"
                    "$f"
                else
                    echo "$0: ignoring $f"
                fi
                ;;
        esac
    done
    echo "$0: done running hooks in $1"
}


#### CHOWN HOME DIR ONLY FIRST TIME #####
if [[ ! -f /home/$NB_USER/.chown ]]
then
    IS_FIRST_RUN=true
    chown -R $NB_USER:$NB_GROUP /home/$NB_USER
    touch /home/$NB_USER/.chown
fi


#### my_notebooks .jupyter DIRS ####
NOTEBOOK_DIR_RELATIVE=my_notebooks
export NOTEBOOK_DIR="/home/$NB_USER/${NOTEBOOK_DIR_RELATIVE}"
su $NB_USER -c "mkdir -p /home/${NB_USER}/.jupyter"
su $NB_USER -c "mkdir -p ${NOTEBOOK_DIR}"



if [ -z "$IS_INSTRUCTOR" ]
then
      export IS_INSTRUCTOR=false
fi


####### SUDOERS START #########
set_sudo() {
    msg=`sudo -l -U "$NB_USER"`
    substr='not allowed'
    if [ $? -eq 0 ]; then
      if [[ "$msg" == *"$substr"* ]]; then
          echo "$NB_USER  ALL=(ALL)       NOPASSWD: ALL" | sudo tee --append /etc/sudoers
      fi
    fi
}

if [[ "${SUDOERS_ALL}" == "true" ]]; then
    ## all users are sudoers
    set_sudo
else
    ## instructors are sudoers ##
    if [[ "${IS_INSTRUCTOR}" == "true" ]]; then
        set_sudo
    fi
fi
####### SUDOERS END #########

function make_exec() { \
  files=$(shopt -s nullglob dotglob; echo $1/*); \
  if (( ${#files} )); \
  then \
  chmod +x $1/*; \
  fi \
}

function move_files() { \
  files=$(shopt -s nullglob dotglob; echo $1/*); \
  if (( ${#files} )); \
  then \
  mv $1/* $2/; \
  fi \
}

## Instructors vs students

### only instructors can create assignments
JUPYTER_HOME=/opt/conda/bin
if [[ "${IS_INSTRUCTOR}" == "true" ]]; then
     $JUPYTER_HOME/jupyter labextension enable --level=sys_prefix nbgrader/create-assignment 
     $JUPYTER_HOME/jupyter labextension enable --level=sys_prefix nbgrader/formgrader
     $JUPYTER_HOME/jupyter labextension enable --level=sys_prefix nbgrader/course-list
fi

## bootstrap hooks and resources for instructors / students
USER_LOCAL_BIN_DIR=/home/$NB_USER/.local/bin

if [[ "${IS_INSTRUCTOR}" == "true" ]] ; then
  USER_HOOKS_DIR=$USER_LOCAL_BIN_DIR/before-custom.d
  su $NB_USER -c "mkdir -p $USER_HOOKS_DIR"
  [ -d $RESOURCES_PATH/bin-user-hooks ] && move_files $RESOURCES_PATH/bin-user-hooks $USER_HOOKS_DIR
  [ -d $RESOURCES_PATH/bin-user-instructor ] && move_files $RESOURCES_PATH/bin-user-instructor $USER_LOCAL_BIN_DIR
  [ -d $RESOURCES_PATH/bin-user-student ] && move_files $RESOURCES_PATH/bin-user-student $USER_LOCAL_BIN_DIR
  chown -R $NB_UID:$NB_GID $USER_LOCAL_BIN_DIR
  run-hooks $USER_HOOKS_DIR
else
  su $NB_USER -c "mkdir -p $USER_LOCAL_BIN_DIR"
  [ -d $RESOURCES_PATH/bin-user-student ] && move_files $RESOURCES_PATH/bin-user-student $USER_LOCAL_BIN_DIR && chown -R $NB_UID:$NB_GID $USER_LOCAL_BIN_DIR
  [ -d $RESOURCES_PATH/bin-user-instructor ] && rm -rf $RESOURCES_PATH/bin-user-instructor
fi

#### fix npm config file
if [[ $IS_FIRST_RUN == "true" ]]; then
    if [ -f "/home/$NB_USER/.npmrc" ]; then
        sed -i "s/jovyan/$NB_USER/g" /home/$NB_USER/.npmrc
    fi
fi

## jetty
if [ "$JETTY" == "true" ]; then
  if [ ! -d "/home/$NB_USER/webapps" ]; then
      mkdir -p /home/$NB_USER/webapps
      tar xzf /resources/examples/jsp-servlet/examples.tar.gz -C /home/$NB_USER/webapps/
      chown $NB_USER:$NB_GID -R /home/$NB_USER/webapps
  fi
fi

## fix scala kernel
if [ -e "/opt/conda/share/jupyter/kernels/scala/kernel.json" ]; then
    sed -i "s|jovyan|$NB_USER|g" /opt/conda/share/jupyter/kernels/scala/kernel.json
fi

#### CLEAN UP SOME DIRS ####
if [ -d "/home/$NB_USER/node_modules" ]; then
        rm -rf /home/$NB_USER/node_modules
fi

if [ -f "/home/$NB_USER/.npmrc.bak" ]; then
        rm -f /home/$NB_USER/.npmrc.bak
fi

### Fixing envs
if [[ -f /home/$NB_USER/.ssh/environment ]]; then
    sed -i "s/jovyan/$NB_USER/g" /home/$NB_USER/.ssh/environment
fi
if [[ -f /home/$NB_USER/.profile ]]; then
    sed -i "s/jovyan/$NB_USER/g" /home/$NB_USER/.profile
fi

# setting classic notebook customized css
mkdir -p /home/${NB_USER}/.jupyter/custom/;\
cp $RESOURCES_PATH/config/custom.css /home/$NB_USER/.jupyter/custom/custom.css

# setting lab themes
if [ -d "$RESOURCES_PATH/scripts" ]; then
   if [ -f "$RESOURCES_PATH/scripts/set-lab-themes.sh" ]; then
        $RESOURCES_PATH/scripts/set-lab-themes.sh
   fi
fi

# copying sample dbs
if [ ! -d "/opt/dbdata-$NB_USER/sampledb" ]; then
	cp -r "$RESOURCES_PATH/sampledb" /opt/dbdata-$NB_USER
	chown $NB_USER -R /opt/dbdata-$NB_USER/sampledb
fi

# finishing SDKMAN dir setup
if [ -d "/opt/apps/sdkman" ]; then
	chown $NB_USER:$NB_GID -R /opt/apps/sdkman
fi

# config of DB directories
mkdir_dbdata(){
if [ ! -d "$1" ]; then
	mkdir -p $1
	chown $NB_USER -R $1
fi
}
mkdir_dbdata /opt/dbdata-$NB_USER/mongodb
mkdir_dbdata /opt/dbdata-$NB_USER/mysql
mkdir_dbdata /opt/dbdata-$NB_USER/postgres

mountbind(){
origin=/var/lib/docker/volumes/$1_data/_data/
target=/opt/dbdata-$NB_USER/$1/
if [ -d "$origin" ] && [ -d "$target" ]; then
	mount --bind $origin $target
fi
}
mountbind postgres
mountbind mysql
mountbind mongodb

#if [ ! -e "/home/$NB_USER/.dbdata" ]; then
#	ln -s /opt/dbdata-$NB_USER /home/$NB_USER/.dbdata
#fi

## mysql workbench (to be accessible from host via X server)
if [ -e "/home/$NB_USER/.local/bin/mysql-workbench" ]; then
    echo "File exists"
    if [ ! -L "/home/$NB_USER/.local/bin/mysql-workbench" ]; then
        echo "File exists but is not a symbolic link"
        # You can choose to remove it or handle it differently
        rm /home/$NB_USER/.local/bin/mysql-workbench
        ln -s /usr/bin/mysql-workbench /home/$NB_USER/.local/bin/mysql-workbench
        echo "Symbolic link created"
    else
        echo "File is already a symbolic link"
    fi
else
    ln -s /usr/bin/mysql-workbench /home/$NB_USER/.local/bin/mysql-workbench
    echo "Symbolic link created"
fi

if [ -e "/home/$NB_USER/.local/bin/workbench" ]; then
    echo "File exists"
    if [ ! -L "/home/$NB_USER/.local/bin/workbench" ]; then
        echo "File exists but is not a symbolic link"
        # You can choose to remove it or handle it differently
        rm /home/$NB_USER/.local/bin/workbench
        ln -s /usr/bin/mysql-workbench /home/$NB_USER/.local/bin/workbench
        echo "Symbolic link created"
    else
        echo "File is already a symbolic link"
    fi
else
    ln -s /usr/bin/mysql-workbench /home/$NB_USER/.local/bin/workbench
    echo "Symbolic link created"
fi

mysql_workbench_desktop="/home/$NB_USER/Desktop/mysql-workbench.desktop"
if [ ! -f "$mysql_workbench_desktop" ]; then
	mkdir -p /home/$NB_USER/Desktop
	\cp /usr/share/applications/mysql-workbench.desktop $mysql_workbench_desktop
	chown $NB_USER:$NB_GID -R /home/$NB_USER/Desktop
	chmod +x $mysql_workbench_desktop
fi

## ansible
if [ "$DEVOPS" == "true" ]; then
	mkdir -p /home/$NB_USER/my_notebooks/ansible
	chown $NB_USER:$NB_GID -R /home/$NB_USER/my_notebooks/ansible
fi

#
mkdir -p  /home/${NB_USER}/.local/share/applications
chown -R $NB_USER:$NB_GID /home/${NB_USER}/.local/share/applications

# Desktop appearance config
xfce4_config_user_dir=/home/$NB_USER/.config/xfce4
mkdir -p $xfce4_config_user_dir 
if [ ! -f "$xfce4_config_user_dir/lock" ]; then
	\cp -r $RESOURCES_PATH/config/xfce4/* $xfce4_config_user_dir/ 
	chown $NB_USER:$NB_GID -R $xfce4_config_user_dir/
fi

cursors_dir=/home/$NB_USER/.icons
mkdir -p $cursors_dir
if [ ! -d "$cursors_dir/Simp1e-Dark" ]; then
        tar -xf $RESOURCES_PATH/config/icons/Simp1e-Dark.tgz --directory $cursors_dir/ 	
	chown $NB_USER:$NB_GID -R $cursors_dir/
fi

## Adding access to entorn in Desktop mode
if [ ! -f "/home/$NB_USER/Desktop/entorn.desktop" ]; then
	chmod +x $RESOURCES_PATH/apps/entorn/entorn-install.sh
	$RESOURCES_PATH/apps/entorn/entorn-install.sh
fi

## Adding access to VSCode in Desktop mode
if [ ! -f "/home/$NB_USER/Desktop/vscode.desktop" ]; then
        chmod +x $RESOURCES_PATH/apps/vscode/vscode-install.sh
        $RESOURCES_PATH/apps/vscode/vscode-install.sh
fi

# VNC server
vnc_config_user_dir=/home/$NB_USER/.vnc
mkdir -p $vnc_config_user_dir
if [ ! -f "$vnc_config_user_dir/passwd" ]; then
        \cp -r $RESOURCES_PATH/config/vnc/* $vnc_config_user_dir/
fi
chown $NB_USER:$NB_GID -R $vnc_config_user_dir/
chmod 600 $vnc_config_user_dir/passwd

#fix
chown $NB_USER:$NB_GID -R /opt/conda/share/gdb/auto-load

# start vnc server :2
su $NB_USER -c "/usr/bin/vncserver :2"

# start sshd service
service ssh start


