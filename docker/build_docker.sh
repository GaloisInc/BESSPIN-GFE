#!/bin/bash
IMAGE_NAME=galoisinc/besspin
IMAGE_TAG=gfe
CONTAINER_NAME=besspin_gfe

# Linux and OS X ?
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     SUDO=sudo;;
    Darwin*)    SUDO=;;
    *)          echo "Unknown machine. "; exit 1;;
esac

# Assume we are running from /gfe/docker directory
GFE_PATH=`pwd`/../

echo "GFE_PATH=$GFE_PATH"

# The existence of `riscv-gnu-toolchains.tar.gz` is dependent upon the
# `download-toolchains.sh` shell script having been run successfully.
(cd ../install; ./download-toolchains.sh)
# Prepare build context
rm -f riscv-gnu-toolchains.tar.gz
cp ../install/riscv-gnu-toolchains.tar.gz .

DATETIME=$(date +"%Y-%m-%d %T")

echo "[$DATETIME] Start building $CONTAINER_NAME Image."

echo "[$DATETIME] Create image locally."
$SUDO docker build -t "master_image" .
if [[ $? -ne 0 ]]
then
  echo "Error: Create image locally."
  exit 1
fi

echo "[$DATETIME] Create container $CONTAINER_NAME."
$SUDO docker run -t -d -P -v $GFE_PATH:/gfe --name=$CONTAINER_NAME  --privileged master_image
if [[ $? -ne 0 ]]
then
  echo "Error: Create container $CONTAINER_NAME."
  exit 1
fi

echo "[$DATETIME] deps installation in progress."
$SUDO docker exec -u 0 $CONTAINER_NAME /bin/sh -c "ssh-keyscan gitlab-ext.galois.com >> /root/.ssh/known_hosts"
# Build and install OpenOCD
$SUDO docker exec -u 0 $CONTAINER_NAME /bin/bash -c "cd /gfe/riscv-openocd && ./bootstrap"
$SUDO docker exec -u 0 $CONTAINER_NAME /bin/bash -c "cd /gfe/riscv-openocd && ./configure --enable-remote-bitbang --enable-jtag_vpi --enable-ftdi && make && make install"

if [[ $? -ne 0 ]]
then
  echo "Error: deps installation"
  exit 1
fi

echo "[$DATETIME] Commit and tag docker container."
$SUDO docker commit $($SUDO docker ps -aqf "name=$CONTAINER_NAME") $IMAGE_NAME:$IMAGE_TAG
$SUDO docker container stop $CONTAINER_NAME
$SUDO docker container rm $CONTAINER_NAME
if [[ $? -ne 0 ]]
then
  echo "Error: Commit and tag docker container."
  exit 1
fi

echo "[$DATETIME] Publish and clean the image."
$SUDO docker push $IMAGE_NAME:$IMAGE_TAG
if [[ $? -ne 0 ]]
then
  echo "Error: Publish the image."
  exit 1
fi

echo "[$DATETIME] Docker $CONTAINER_NAME container installed successfully."
