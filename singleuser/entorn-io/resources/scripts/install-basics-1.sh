#!/bin/bash

# Enable exit on error
set -e
# Show all commands
set -x

echo "Installing system basics (part 1) ..."

apt update -y
apt-get install -y --no-install-recommends \
  apt-transport-https \
  gpg \
  gnupg-agent \
  gpg-agent \
  gnupg2 \
  ca-certificates \
  build-essential \
  gfortran \
  gcc \
  pkg-config \
  software-properties-common \
  lsof \
  net-tools \
  libcurl4 \
  curl \
  apt-utils \
  rsync \
  vim \
  iputils-ping \
  ssh \
  plantuml \
  fonts-dejavu \
  git \
  python${PYTHON_VERSION_MAJOR} \
  python3-tk \
  wget \
  cron \
  openssl \
  iproute2 \
  psmisc \
  tmux \
  dpkg-sig \
  uuid-dev \
  csh \
  xclip \
  clinfo \
  time \
  libssl-dev \
  libgdbm-dev \
  libncurses5-dev \
  libncursesw5-dev \
  gnome-keyring

  # required by mysql
apt-get install -y --no-install-recommends \
  libmysqlclient-dev 
  
exit 0
