#!/bin/bash
TAG=0.0.42
if [ -z "$1" ]
then
      echo "Building default jupyterhub image with tag $TAG"
else
      echo "Building jupyterhub image with tag $1"
      TAG=$1
fi


docker build -t registry.pluralcamp.com/jupyterhub_img_pc:$TAG -f ./Dockerfile.k8s .
docker push registry.pluralcamp.com/jupyterhub_img_pc:$TAG
