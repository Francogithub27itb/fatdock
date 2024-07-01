#!/bin/bash

# Stops script execution if a command has an error
set -e

echo "Installing selenium and related tooling..."
echo ""

# web scrappers / testers
mamba install --quiet --yes \
  'beautifulsoup4' \
  'requests' \
  'selenium' \
  'schedule'			    

# install chromedriver
wget -O /tmp/chromedriver.zip http://chromedriver.storage.googleapis.com/`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE`/chromedriver_linux64.zip
unzip /tmp/chromedriver.zip chromedriver -d /usr/local/bin/

exit 0
