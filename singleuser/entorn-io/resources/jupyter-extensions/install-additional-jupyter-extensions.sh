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
    jupyterlab-fasta
    #jupyterlab-unfold 
    #voila
#    jupyter_server=2.3.0 

pip install jupyterlab-hide-code

pip install jupyter_ai 

#langchain_anthropic langchain_openai langchain_cohere langchain_google_genai langchain_mistralai langchain_nvidia_ai_endpoints

#pip install jupyter_ai langchain_anthropic langchain_openai langchain_cohere langchain_google_genai langchain_mistralai langchain_nvidia_ai_endpoints

#pip install jupyterlab-code-formatter #outdated

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


mamba install -c conda-forge python-lsp-server r-languageserver -y

npm install --save-dev bash-language-server \
dockerfile-language-server-nodejs \
typescript-language-server \
sql-language-server \
vscode-css-languageserver-bin \
vscode-html-languageserver-bin \
vscode-json-languageserver-bin \
yaml-language-server

mamba install --channel conda-forge tectonic texlab chktex -y


exit 0
