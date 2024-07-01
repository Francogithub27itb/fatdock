#!/bin/bash

# Stops script execution if a command has an error
set -e

if ! hash ungit 2>/dev/null; then
    echo "Installing Ungit. Please wait..."
    npm install -g npm@8.14.0
    npm install -g ungit@1.5.21
else
    echo "Ungit is already installed"
fi

