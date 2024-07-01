#!/bin/bash

echo
echo "Installing DB drivers for python (data science) ..."
echo


### PYTHON DRIVERS FOR DBs ####
# Database python drivers:
# https://superset.apache.org/docs/databases/installing-database-drivers
apt update && apt upgrade -y
apt install --no-install-recommends -y default-libmysqlclient-dev libpq-dev python3-dev 
pip install ipython-sql psycopg2 pgspecial mysqlclient \
	pyhive pybigquery 
jupyter labextension update --all

exit 0

