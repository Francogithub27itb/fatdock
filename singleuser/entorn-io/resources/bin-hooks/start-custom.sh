#!/bin/bash

copy_dir_if_missing(){
  if [[ -d /home/jovyan && "$NB_USER" != "jovyan" ]]; then
    if [[ ! -d /home/$NB_USER/$1 ]]
    then
        if [[ -d /home/jovyan/$1 ]]; then
            cp -r /home/jovyan/$1 /home/$NB_USER/
            chown -R $NB_UID:$NB_GID /home/$NB_USER/$1
        fi
    fi
  fi
}

copy_dir_force(){
  if [[ -d /home/jovyan && "$NB_USER" != "jovyan" ]]; then
      if [[ -d /home/jovyan/$1 ]]; then
          rm -rf /home/$NB_USER/$1
          cp -r /home/jovyan/$1 /home/$NB_USER/
          chown -R $NB_UID:$NB_GID /home/$NB_USER/$1
      fi
  fi
}

copy_subdir_if_missing(){
  if [[ -d /home/jovyan && "$NB_USER" != "jovyan" ]]; then
    if [[ ! -d /home/$NB_USER/$1 ]]
    then
        if [[ -d /home/jovyan/$1 ]]; then
	    mkdir -p /home/$NB_USER/$2
            cp -r /home/jovyan/$1 /home/$NB_USER/$2/
            chown -R $NB_UID:$NB_GID /home/$NB_USER/$2
        fi
    fi
  fi
}

copy_file_force(){
  if [[ -d /home/jovyan && "$NB_USER" != "jovyan" ]]; then
     if [[ -f /home/jovyan/$1 ]]; then
        \cp /home/jovyan/$1 /home/$NB_USER/
        chown $NB_UID:$NB_GID /home/$NB_USER/$1
     fi
  fi
}

copy_file_if_missing(){
  if [[ -d /home/jovyan && "$NB_USER" != "jovyan" ]]; then
    if [[ ! -f /home/$NB_USER/$1 ]]
    then
        if [[ -f /home/jovyan/$1 ]]; then
            cp /home/jovyan/$1 /home/$NB_USER/
            chown $NB_UID:$NB_GID /home/$NB_USER/$1
        fi
    fi
  fi
}

if [[ ! -f /home/$NB_USER/.chown ]]
then
   copy_dir_if_missing .conda
   copy_dir_if_missing .config
   copy_dir_force .docker
   copy_dir_if_missing .jupyter
   copy_dir_if_missing .node
   copy_dir_if_missing .local
   copy_dir_if_missing .npm
   copy_dir_if_missing .sdkman
   copy_dir_if_missing .yarn
   copy_dir_if_missing .ssh
   copy_dir_if_missing .vnc
   copy_dir_if_missing .vscode
   copy_dir_if_missing workspaces
   copy_file_force .bashrc
   copy_file_if_missing .gitconfig
   copy_file_if_missing .gitignore
   copy_file_if_missing .npmrc
   copy_file_if_missing .wget-hsts
   copy_file_force .profile
   copy_file_if_missing .zshrc
fi

## copy mongodb sample db
copy_subdir_if_missing .mongodb/db .mongodb

# copy portainer dir
copy_subdir_if_missing .docker/portainer .docker

copy_bin_files_if_missing(){
  if [[ -d /home/jovyan/.local/bin && "$NB_USER" != "jovyan" ]]; then
      if [[ ! -f /home/$NB_USER/.local/bin/$1 ]]
      then
          if compgen -G "/home/jovyan/.local/bin/*$1" > /dev/null; then          
              \cp -a /home/jovyan/.local/bin/*$1 /home/$NB_USER/.local/bin/
              chown $NB_UID:$NB_GID /home/$NB_USER/.local/bin/*$1
              chmod +x /home/$NB_USER/.local/bin/*$1
          fi
      fi
  fi
}

mkdir -p /home/$NB_USER/.local/bin

copy_bin_files_if_missing start
copy_bin_files_if_missing stop
copy_bin_files_if_missing status
copy_bin_files_if_missing jenkins
copy_bin_files_if_missing jk
copy_bin_files_if_missing jetty
copy_bin_files_if_missing jty
copy_bin_files_if_missing mg
copy_bin_files_if_missing mongod
copy_bin_files_if_missing my
copy_bin_files_if_missing pg
copy_bin_files_if_missing postgres
copy_bin_files_if_missing pt
copy_bin_files_if_missing portainer
copy_bin_files_if_missing psql
copy_bin_files_if_missing sq
copy_bin_files_if_missing sonar

copy_bin_files_force(){
  if [[ -d /home/jovyan/.local/bin && "$NB_USER" != "jovyan" ]]; then
    if compgen -G "/home/jovyan/.local/bin/*$1*" > /dev/null; then
          \cp -a /home/jovyan/.local/bin/*$1* /home/$NB_USER/.local/bin/
          chown $NB_UID:$NB_GID /home/$NB_USER/.local/bin/*$1*
          chmod +x /home/$NB_USER/.local/bin/*$1*
    fi
  fi
}

copy_bin_files_force entorn
copy_bin_files_force install

if [ -d "/opt/sdkman" ]; then
	mkdir -p /opt/apps/sdkman
	\cp -r /opt/sdkman/* /opt/apps/sdkman/
fi

