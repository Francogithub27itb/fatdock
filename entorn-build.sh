#!/bin/bash

ver="0.1.2"

echo 
echo "### Building images for Entorn ... ###"
echo

cd ./hub

if [ "$1" != "" ]; then
	auth=$1
else
	#auth="lti"
        auth="github"
fi

docker build -t entorn-io/hub-$auth:$ver -f Dockerfile.k8s.$auth .

cd ..
cd ./side/docker-dind

docker build -t entorn-io/dind:$ver .
exit 0
cd ../../
cd ./singleuser/entorn-io

#docker pull jupyter/minimal-notebook

docker pull jupyter/all-spark-notebook

./squash-data-base.sh

./build-entorn-io.sh full

echo
echo "All images built successfully."
echo

exit 0
