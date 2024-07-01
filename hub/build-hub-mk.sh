#!/bin/bash
TAG=0.0.1
if [ -z "$1" ]
then
      echo "Building default jupyterhub image with tag $TAG"
else
      echo "Building jupyterhub image with tag $1"
      TAG=$1
fi


docker build -t registry.pluralcamp.com/jupyterhub_img_mk:$TAG -f ./Dockerfile.k8s.mk .
docker push registry.pluralcamp.com/jupyterhub_img_mk:$TAG
