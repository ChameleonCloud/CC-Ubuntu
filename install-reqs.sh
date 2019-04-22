#!/bin/bash

set -e

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root."
  exit 1
fi

### OS-specific installs

function centos_reqs() {
  yum makecache fast
  yum install -y epel-release
  yum install -y qemu-img python-pip kpartx uboot-tools
}

function ubuntu_reqs() {
  apt-get update
  apt-get -qq install -y qemu-utils python-pip kpartx u-boot-tools
}

source /etc/os-release
if [[ $ID = 'ubuntu' ]]; then
  ubuntu_reqs
else
  if [[ $ID = 'centos' ]]; then
    centos_reqs
  else
    echo 'Unknown distribution (not CentOS or Ubuntu?), aborting.'
    exit 1
  fi
fi

### Generic installs

# pip install --upgrade pip
pip install networkx==2.2
pip install diskimage-builder
