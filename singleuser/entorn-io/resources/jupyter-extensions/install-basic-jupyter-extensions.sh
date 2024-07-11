#!/bin/bash

set -ex

echo "Installing basic jupyter extensions ..."
echo

mamba install -c conda-forge --yes \
  jupyter-server-proxy \
  jupyter_server \
  diff-match-patch \
  jupyterlab-git==0.50.1
# jupyterlab-github \
#  jupyter_nbextensions_configurator 
#  jupyterlab-pullrequests 
#  jupyter_contrib_nbextensions 
#  jupyterlab-drawio 
#  jupyter-videochat 
#  jupyterlab=3.5.3

#jupyter labextension install @jupyterlab/server-proxy 

#jupyter server extension enable --sys-prefix --py jupyter_videochat 

pip install nbgitpuller

#pip install jupyter_contrib_nbextensions

# jupyter contrib nbextension install --sys-prefix

# Git and Pull Requests basic default config
jupyter_config_file_user="/home/$NB_USER/.jupyter/jupyter_notebook_config.py"

echo "" >> $jupyter_config_file_user
echo "### Pull Requests config:" >> $jupyter_config_file_user
echo "#---#" >> $jupyter_config_file_user
echo "# c.PRConfig.access_token = '<YOUR_ACCESS_TOKEN>'" >> $jupyter_config_file_user
echo "# c.PRConfig.provider = 'github' (default) or 'gitlab'" >> $jupyter_config_file_user 
echo "# c.PRConfig.api_base_url = '<Provider API base url>'"
echo "## (defaults to https://api.github.com except if provider is gitlab then it defaults to https://gitlab.com/api/v4/)"  >> $jupyter_config_file_user 

echo "" >> $jupyter_config_file_user
echo "" >> $jupyter_config_file_user

echo "### Git:" >> $jupyter_config_file_user
echo "#---#" >> $jupyter_config_file_user
echo "## JupyterLabGit.actions.post_init: Set post git init actions. It is possible to provide a list of commands to be executed in a folder after it is initialized as Git repository." >> $jupyter_config_file_user 
echo "" >> $jupyter_config_file_user
echo "# c.JupyterLabGit.actions = {"post_init": ["touch dummy_init.dat"]}"  >> $jupyter_config_file_user
echo "" >> $jupyter_config_file_user
echo "## JupyterLabGit.credential_helper: Git credential helper to set to cache the credentials. The default value is cache --timeout=3600 to cache the credentials for an hour." >> $jupyter_config_file_user
echo "" >> $jupyter_config_file_user
echo "c.JupyterLabGit.credential_helper = 'cache --timeout=36000'" >> $jupyter_config_file_user 
echo "" >> $jupyter_config_file_user
echo "## JupyterLabGit.excluded_paths: Set path patterns to exclude from this extension. You can use wildcard and interrogation mark for respectively everything or any single character in the pattern." >> $jupyter_config_file_user

exit 0
