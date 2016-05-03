#!/bin/bash

# Analyse the target parameter
TARGET="common"

USE_PARTITION_IMAGE=false
if [ "$1" == "partition" ]; then
  USE_PARTITION_IMAGE=true
fi

UBUNTU_VERSION="trusty"
IMAGE_NAME="CC-Ubuntu14.04"
UBUNTU_RELEASE="$UBUNTU_VERSION"
BASE_IMAGE="$UBUNTU_VERSION-server-cloudimg-amd64-disk1.img"
QCOW2_IMAGE="$UBUNTU_VERSION-server-cloudimg-amd64-disk1.qcow2"
BUILD_DATE="20160323"
export DIB_RELEASE="$UBUNTU_VERSION"
export DIB_PASSWORD="root"

if [ "$USE_PARTITION_IMAGE" = true ]; then
  # Preparing a temporary folder that will store the Ubuntu image.
  rm -rf tmp
  mkdir tmp
  # Download a Ubuntu trusty image designed for partition images.
  export LIBGUESTFS_BACKEND=direct
  yum install -y libguestfs-tools-c
  # Getting the last Ubuntu trusty image
  wget "http://cloud-images.ubuntu.com/$UBUNTU_RELEASE/$BUILD_DATE/$BASE_IMAGE"
  mv $BASE_IMAGE tmp/$QCOW2_IMAGE
  export DIB_LOCAL_IMAGE="$PWD/tmp/$QCOW2_IMAGE"
fi

OUTPUT_FOLDER="$1"

if [ "$USE_PARTITION_IMAGE" = true ]; then
  export FORCE_PARTITION_IMAGE=true
else
  export FORCE_PARTITION_IMAGE=false
fi

IMAGE_PATH=$(bash create-image.sh $OUTPUT_FOLDER | grep "Image built in" | sed 's/Image built in //g')
IMAGE_QCOW_PATH="$IMAGE_PATH"
IMAGE_VMLINUZ_PATH="$IMAGE_PATH.vmlinuz"
IMAGE_INITRD_PATH="$IMAGE_PATH.initrd"

IMAGE_VMLINUZ_NAME="$IMAGE_NAME-kernel"
IMAGE_INITRD_NAME="$IMAGE_NAME-initrd"

if [ "$TARGET" == "kvm" ]; then
  echo "to add the image, run the following command:"
  CMD="glance image-create --name \"$IMAGE_NAME\" --disk-format qcow2 --container-format bare --file $IMAGE_QCOW_PATH"
  echo "$CMD"
else
  if [ "$USE_PARTITION_IMAGE" = true ]; then
    echo "/!\ Warning: be sure to have configured the OpenStack credentials"
    echo "by running 'source Chameleon-openrc.sh'"
    sleep 2

    echo "to add the image, run the following commands:"
    CMD="glance image-create --name \"$IMAGE_VMLINUZ_NAME\" --disk-format aki --container-format bare --file $IMAGE_VMLINUZ_PATH"
    echo "$CMD"

    CMD="glance image-create --name \"$IMAGE_INITRD_NAME\" --disk-format ari --container-format bare --file $IMAGE_INITRD_PATH"
    echo "$CMD"

    CMD="IMAGE_VMLINUZ_UUID=\$(glance image-list | grep \" $IMAGE_VMLINUZ_NAME \" | awk '{print \$2}')"
    echo $CMD

    CMD="IMAGE_INITRD_UUID=\$(glance image-list | grep \" $IMAGE_INITRD_NAME \" | awk '{print \$2}')"
    echo $CMD

    CMD="glance image-create --name \"$IMAGE_NAME.partition\" --disk-format qcow2 --container-format bare --property kernel_id=\$IMAGE_VMLINUZ_UUID --property ramdisk_id=\$IMAGE_INITRD_UUID --file $IMAGE_QCOW_PATH"
    echo "$CMD"
  else
    echo "to add the image, run the following command:"
    CMD="glance image-create --name \"$IMAGE_NAME\" --disk-format qcow2 --container-format bare --file $IMAGE_QCOW_PATH"
    echo "$CMD"
  fi
fi
