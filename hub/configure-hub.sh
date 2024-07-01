#!/bin/bash


rm -rf zero-to-jupyterhub-k8s/
git clone https://github.com/jupyterhub/zero-to-jupyterhub-k8s.git
#rm -f ./Dockerfile.k8s.bak
mv ./Dockerfile.k8s ./Dockerfile.k8s.bak
cp ./zero-to-jupyterhub-k8s/images/hub/Dockerfile ./Dockerfile.k8s
#rm -f ./requirements.txt.bak
mv ./requirements.txt ./requirements.txt.bak
cp ./zero-to-jupyterhub-k8s/images/hub/requirements.txt ./
echo "COPY page.html /usr/local/share/jupyterhub/templates/" >> ./Dockerfile.k8s
