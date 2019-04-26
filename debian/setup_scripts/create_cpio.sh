#!/usr/bin/env bash

# Get User
GFE_USER=$1

cd /
find . ! -name debian.cpio.gz ! -name setup_scripts -print0 | cpio --null --create --format=newc | gzip --best > debian.cpio.gz 

chown $GFE_USER:$GFE_USER debian.cpio.gz

rm -rf /setup_scripts
