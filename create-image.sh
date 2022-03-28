#!/bin/bash

set -e
set -o xtrace
set -o errexit
set -o nounset

DIR="$(dirname $0)" # http://stackoverflow.com/a/59916/194586

export DIB_RELEASE="$UBUNTU_ADJECTIVE"
BIONIC=bionic
FOCAL=focal

export DIB_PYTHON_VERSION=3

#Clone the required repositories for Heat contextualization elements
git config --global http.sslverify false
if [ ! -d tripleo-image-elements ]; then
  git clone -b stable/train https://git.openstack.org/openstack/tripleo-image-elements.git
fi
if [ ! -d heat-agents ]; then
  git clone -b stable/train https://git.openstack.org/openstack/heat-agents.git
fi

export ELEMENTS_PATH=$DIR/elements
export LIBGUESTFS_BACKEND=direct
#required by disk-image-builder for heat
export ELEMENTS_PATH='elements:tripleo-image-elements/elements:heat-agents'
export DEPLOYMENT_BASE_ELEMENTS="heat-config heat-config-script"
export AGENT_ELEMENTS="os-collect-config os-refresh-config os-apply-config"

IFS=' ' read -ra ELEM <<< "$AGENT_ELEMENTS"
for i in "${ELEM[@]}"; do
  ELEM_FILE="tripleo-image-elements/elements/$i/install.d/$i-source-install/10-$i"
  PKG_FILE="tripleo-image-elements/elements/$i/package-installs.yaml"
  # virtualenv version >= 20.0.0 doesn't work with
  # https://github.com/openstack/tripleo-image-elements/blob/master/elements/os-apply-config/install.d/os-apply-config-source-install/10-os-apply-config#L6
  # virtualenv: error: too few arguments [--setuptools version]
  sed -i 's/virtualenv --setuptools/python3 -m venv/' $ELEM_FILE
  # error in anyjson setup command: use_2to3 is invalid
  # setuptools>=58 breaks support for use_2to3
  sed -i "s/'setuptools>=1.0'/'setuptools>=1.0,<58.0'/" $ELEM_FILE
  sed -i "s/python-dev://" $PKG_FILE
done

#install pip and virtualenv from distribution because of a conflict between pip version and PyYAML
#ref: https://stackoverflow.com/questions/49911550/how-to-upgrade-disutils-package-pyyaml
export DIB_INSTALLTYPE_pip_and_virtualenv=package

TMPDIR=`mktemp -d`
mkdir -p $TMPDIR/common
OUTPUT_FILE="$TMPDIR/common/$IMAGE_NAME.qcow2"
ARCH="amd64"

if [ "$VARIANT" = 'arm64' ]; then
  ARCH=$VARIANT
fi

if [ -f "$OUTPUT_FILE" ]; then
  echo "removing existing $OUTPUT_FILE"
  rm -f "$OUTPUT_FILE"
fi

ELEMENTS="vm block-device-efi dhcp-all-interfaces pip-and-virtualenv $AGENT_ELEMENTS $DEPLOYMENT_BASE_ELEMENTS"

disk-image-create \
  chameleon-common \
  $ELEMENTS \
  $EXTRA_ELEMENTS \
  -a $ARCH \
  -o $OUTPUT_FILE

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
    echo "openstack image create --disk-format qcow2 --container-format bare --file $OUTPUT_FILE \"$IMAGE_NAME\"" 
  fi
else
  echo "Failed to build image in $OUTPUT_FOLDER"
  exit 1
fi
