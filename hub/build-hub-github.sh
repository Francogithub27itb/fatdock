#!/bin/bash
TAG=0.1.1
if [ -z "$1" ]
then
      echo "Building default jupyterhub image with tag $TAG"
else
      echo "Building jupyterhub image with tag $1"
      TAG=$1
fi


docker build -t pluralcamp/entorn-io-hub-github:$TAG -f ./Dockerfile.k8s.github .
docker tag pluralcamp/entorn-io-hub-github:$TAG entorn-io/hub-github:$TAG
#docker push pluralcamp/entorn-io-hub-github:$TAG

