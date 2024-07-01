#!/bin/bash


squash_base_image() {
   base_image=jupyter/all-spark-notebook
   docker build --squash -t entorn/base:squashed -f Dockerfile.squash \
                --build-arg BASE_CONTAINER=$base_image \
	        .
}
squash_base_image



