#!/bin/bash

# set -e
set -ex

DIR="$(dirname $0)" # http://stackoverflow.com/a/59916/194586

# This script assumes the following dependencies are installed:
# * via Yum: git python-pip PyYAML qemu-img xz
# * via Pip: diskimage-builder
# * patch diskimage-builder for the lack of Python in the Ubuntu image:
#   add "apt-get -y install python" to /usr/share/diskimage-builder/elements/dpkg/pre-install.d/99-apt-get-update

### FIXME: The 'ubuntu' element ignores DIB_LOCAL_IMAGE (it's used by centos)
### see https://github.com/openstack/diskimage-builder/blob/master/diskimage_builder/elements/ubuntu/root.d/10-cache-ubuntu-tarball#L23
# # see https://cloud-images.ubuntu.com/releases/16.04/ for releases
# BUILD_DATE="release-20161214"
#
# BASE_IMAGE="ubuntu-$UBUNTU_VERSION-server-cloudimg-amd64-disk1.img"
export DIB_RELEASE="$UBUNTU_ADJECTIVE"
#
# URL_ROOT="https://cloud-images.ubuntu.com/releases/$UBUNTU_VERSION/$BUILD_DATE"
# if [ ! -f "$BASE_IMAGE" ]; then
#     curl -L -O "$URL_ROOT/$BASE_IMAGE"
# fi
#
# # Check checksum
# IMAGE_SHA256=$(curl $URL_ROOT/SHA256SUMS | grep "$BASE_IMAGE\$" | awk '{print $1}' | xargs echo)
# echo "SHA256: $IMAGE_SHA256"
# if ! sh -c "echo $IMAGE_SHA256 $BASE_IMAGE | sha256sum -c"; then
#     echo "Wrong checksum for $BASE_IMAGE. Has the image changed?"
#     exit 1
# fi
#
# export DIB_LOCAL_IMAGE=`pwd`/$BASE_IMAGE
export ELEMENTS_PATH=$DIR/elements
export LIBGUESTFS_BACKEND=direct

TMPDIR=`mktemp -d`
mkdir -p $TMPDIR/common
OUTPUT_FILE="$TMPDIR/common/$IMAGE_NAME.qcow2"


ELEMENTS="vm"
if [ "$FORCE_PARTITION_IMAGE" = true ]; then
  ELEMENTS="baremetal"
fi

if [ -f "$OUTPUT_FILE" ]; then
  echo "removing existing $OUTPUT_FILE"
  rm -f "$OUTPUT_FILE"
fi

disk-image-create chameleon-common cc-metrics $ELEMENTS $EXTRA_ELEMENTS -o $OUTPUT_FILE

if [ -f "$OUTPUT_FILE.qcow2" ]; then
  mv $OUTPUT_FILE.qcow2 $OUTPUT_FILE
fi

COMPRESSED_OUTPUT_FILE="$OUTPUT_FILE-compressed"
qemu-img convert $OUTPUT_FILE -O qcow2 -c $COMPRESSED_OUTPUT_FILE
echo "mv $COMPRESSED_OUTPUT_FILE $OUTPUT_FILE"
mv $COMPRESSED_OUTPUT_FILE $OUTPUT_FILE

if [ $? -eq 0 ]; then
  # The below line echoed to stdout is used by Abracadabra, do not change alone!
  echo "Image built in $OUTPUT_FILE"
  if [ -f "$OUTPUT_FILE" ]; then
    echo "to add the image in glance run the following command:"
    echo "glance image-create --name \"$IMAGE_NAME\" --disk-format qcow2 --container-format bare --file $OUTPUT_FILE"
  fi
else
  echo "Failed to build image in $OUTPUT_FOLDER"
  exit 1
fi
