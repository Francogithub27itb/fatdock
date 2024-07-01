#!/bin/bash

echo
echo "Installing DB drivers for python (data science) ..."
echo


### PYTHON DRIVERS FOR DBs ####
# Database python drivers:
# https://superset.apache.org/docs/databases/installing-database-drivers
apt update 
apt install --no-install-recommends -y default-libmysqlclient-dev 
pip install ipython-sql pgspecial mysqlclient 
jupyter labextension update --all

exit 0

