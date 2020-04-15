#!/bin/bash
set -eux

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
$SUDO docker exec -u 0 $CONTAINER_NAME /bin/bash -c "/gfe/install/deps.sh"

if [[ $1 == "--build-toolchains" ]]; then
	echo "Building toolchains"
  $SUDO docker exec -u 0 $CONTAINER_NAME /bin/bash -c "/gfe/install/build-llvm.sh"
  $SUDO docker exec -u 0 $CONTAINER_NAME /bin/bash -c "/gfe/install/build-frebsd-toolchain.sh"
  $SUDO docker exec -u 0 $CONTAINER_NAME /bin/bash -c "/gfe/install/build-toolchain.sh"
  $SUDO docker exec -u 0 $CONTAINER_NAME /bin/bash -c "tar -czf /gfe/install/riscv-gnu-toolchains.tar.gz /opt/riscv /opt/riscv-llvm /opt/riscv/riscv-freebsd"
else
	echo "Downloading toolchains"
  ./install/download_toolchains.sh
  $SUDO docker exec -u 0 $CONTAINER_NAME /bin/bash -c "tar -C / -xf /gfe/install/riscv-gnu-toolchains.tar.gz"
fi

# Default folder is /gfe
$SUDO docker exec -u 0 $CONTAINER_NAME /bin/bash -c "install/amend-bashrc.sh"

# Build and install OpenOCD
$SUDO docker exec -u 0 $CONTAINER_NAME /bin/bash -c "install/build-openocd.sh"

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
