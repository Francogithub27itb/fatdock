#!/bin/bash

set -ex

basic_ext_file=install-basic-jupyter-extensions.sh

if [[ -e "./$basic_ext_file" ]]; then
	chmod +x ./$basic_ext_file
	./$basic_ext_file
fi

echo "Installing additional jupyter extensions ..."
echo 

mamba install -c conda-forge -y \
    ipyleaflet \
    jupyter-resource-usage \
    ipywidgets \
    jupyter-packaging \
    cookiecutter \
    jupyterlab_execute_time \
    fuzzywuzzy \
    jupyterthemes \
    autopep8 \
    yapf \
    jupyterlab_iframe \
    jupyterlab-latex \
    jupyterlab-unfold \
    jupyterlab-fasta
    #voila
#    jupyter_server=2.3.0 

pip install jupyterlab-hide-code
pip install jupyter_ai
pip install jupyterlab-code-formatter

#mamba install rise --no-deps -y

#pip3 install python-uinput
#pip3 install jupyterlab_autorun_cells 
#jupyter labextension install jupyterlab_iframe
#jupyter serverextension enable --py jupyterlab_iframe
#jupyter serverextension enable --sys-prefix jupyter_server_proxy
#jupyter labextension install jupyterlab-launcher-shortcuts
#pip install jupyter-launcher-shortcuts
#jupyter serverextension enable voila
#jupyter server extension enable voila 

exit 0
