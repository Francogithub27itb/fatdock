#!/bin/bash

if [ "$PYTHON_VERSION_MAJOR" == "" ]; then
        PYTHON_VERSION_MAJOR="3.11"
fi

if [ "$NB_USER" == "" ]; then
        if [ "$1" != "" ]; then
                NB_USER="$1"
        else
                NB_USER=entorn
        fi
fi

set -ex

echo "Installing R Studio ..."
echo


pip install ipyparallel
apt update -qq
apt install -y --no-install-recommends software-properties-common dirmngr
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" -y
apt install -y --no-install-recommends r-base

apt-get install --no-install-recommends -y gdebi-core
if [[ "$RSVERSION" == "" ]]; then
    #RSVERSION="2022.07.1-554" ## get the latest dayly instead
    RSVERSION="2022.12.0-353"
fi
export RSVERSION
cd /tmp

wget https://download2.rstudio.org/server/jammy/amd64/rstudio-server-$RSVERSION-amd64.deb

DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y libclang-dev
gdebi -n rstudio-server-$RSVERSION-amd64.deb

echo $NB_USER

# runuser -l $NB_USER -c "NB_GID=100 fix-permissions /home/$NB_USER"

NB_GID=100 fix-permissions /home/$NB_USER

rm -f /tmp/rstudio-server-$RSVERSION-amd64.deb


exit 0


