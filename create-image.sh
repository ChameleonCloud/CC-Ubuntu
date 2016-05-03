#!/bin/bash

# This script assumes the following dependencies are installed:
# * via Yum: git python-pip PyYAML qemu-img xz
# * via Pip: diskimage-builder

UBUNTU_VERSION="xenial"
IMAGE_NAME="CC-Ubuntu16.04"
UBUNTU_RELEASE="$UBUNTU_VERSION"
BASE_IMAGE="$UBUNTU_VERSION-server-cloudimg-amd64-disk1.img"
BUILD_DATE="20160429"
export DIB_RELEASE="$UBUNTU_VERSION"

if [ ! -f "$BASE_IMAGE" ]; then
  curl -L -O "http://cloud-images.ubuntu.com/$UBUNTU_RELEASE/$BUILD_DATE/$BASE_IMAGE"
fi

# Find programatively the sha256 of the selected image
IMAGE_SHA256=$(curl  http://cloud-images.ubuntu.com/$UBUNTU_RELEASE/$BUILD_DATE/SHA256SUMS 2>&1 \
               | grep "$BASE_IMAGE\$" \
               | awk '{print $1}')

# echo "will work with $BASE_IMAGE_XZ => $IMAGE_SHA256"
if ! sh -c "echo $IMAGE_SHA256 $BASE_IMAGE | sha256sum -c"; then
  echo "Wrong checksum for $BASE_IMAGE. Has the image changed?"
  exit 1
fi

export DIB_LOCAL_IMAGE=`pwd`/$BASE_IMAGE
export ELEMENTS_PATH=`pwd`/elements
export LIBGUESTFS_BACKEND=direct

OUTPUT_FILE="$1"
if [ "$OUTPUT_FILE" == "" ]; then
  TMPDIR=`mktemp -d`
  mkdir -p $TMPDIR/common
  OUTPUT_FILE="$TMPDIR/common/CC-Ubuntu14.04.qcow2"
fi


ELEMENTS="vm"
if [ "$FORCE_PARTITION_IMAGE" = true ]; then
  ELEMENTS="baremetal"
fi

if [ -f "$OUTPUT_FILE" ]; then
  echo "removing existing $OUTPUT_FILE"
  rm -f "$OUTPUT_FILE"
fi

/bin/disk-image-create chameleon-common $ELEMENTS -o $OUTPUT_FILE

if [ -f "$OUTPUT_FILE.qcow2" ]; then
  mv $OUTPUT_FILE.qcow2 $OUTPUT_FILE
fi

COMPRESSED_OUTPUT_FILE="$OUTPUT_FILE-compressed"
qemu-img convert $OUTPUT_FILE -O qcow2 -c $COMPRESSED_OUTPUT_FILE
echo "mv $COMPRESSED_OUTPUT_FILE $OUTPUT_FILE"
mv $COMPRESSED_OUTPUT_FILE $OUTPUT_FILE

if [ $? -eq 0 ]; then
  echo "Image built in $OUTPUT_FILE"
  if [ -f "$OUTPUT_FILE" ]; then
    echo "to add the image in glance run the following command:"
    echo "glance image-create --name \"$IMAGE_NAME\" --disk-format qcow2 --container-format bare --file $OUTPUT_FILE"
  fi
else
  echo "Failed to build image in $OUTPUT_FOLDER"
  exit 1
fi
