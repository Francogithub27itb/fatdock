#!/bin/bash

echo
echo "Installing nbgrader ..."
echo 

mamba install -c conda-forge nbgrader --yes
#pip install nbgrader

/opt/conda/bin/jupyter server extension enable --sys-prefix --py nbgrader.server_extensions.formgrader
/opt/conda/bin/jupyter server extension enable --sys-prefix --py nbgrader.server_extensions.assignment_list 
/opt/conda/bin/jupyter server extension enable --sys-prefix --py nbgrader.server_extensions.course_list 
/opt/conda/bin/jupyter server extension enable --sys-prefix --py nbgrader.server_extensions.validate_assignment 

/opt/conda/bin/jupyter labextension disable --level=sys_prefix nbgrader/create-assignment 
/opt/conda/bin/jupyter labextension disable --level=sys_prefix nbgrader/formgrader 
/opt/conda/bin/jupyter labextension enable --level=sys_prefix nbgrader/assignment-list 
/opt/conda/bin/jupyter labextension disable --level=sys_prefix nbgrader/course-list 
/opt/conda/bin/jupyter labextension enable --level=sys_prefix nbgrader/validate-assignment

mkdir -p $RESOURCES_PATH/nbgrader /etc/jupyter
mkdir -p /srv/nbgrader/exchange 
mkdir -p /usr/local/share/nbgrader/exchange
cp $RESOURCES_PATH/nbgrader/nbgrader_config.py.global /etc/jupyter/nbgrader_config.py 

exit 0


