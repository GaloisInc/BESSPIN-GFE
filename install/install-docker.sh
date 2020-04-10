#!/bin/bash
# This script installs Docker engine on Debian 10.
set -eux

# Install docker engine
apt-get -y install \
    apt-transport-https \
    ca-certificates \
    gnupg2 \
    software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -

add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io
