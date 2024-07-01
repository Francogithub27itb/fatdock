#!/bin/sh
  
RESOURCES_PATH=/resources

dir=/sampledb/mongodb/training

mgimport(){
for file in $1/*; do
    mongoimport --drop --db training --collection "$(basename $file .json)" --file $file
done
}

mgimport $dir


