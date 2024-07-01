#!/bin/bash

# Enable exit on error
set -e
# Show all commands
set -x

echo "Installing gcloud cli ..."

apt-get install -y apt-transport-https ca-certificates gnupg

echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list 
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | tee /usr/share/keyrings/cloud.google.gpg  
apt-get update ---allow-insecure-repositories -y && apt-get install google-cloud-sdk -y --allow-unauthenticated

rm -f /etc/apt/sources.list.d/google-cloud-sdk.list

exit 0
      

