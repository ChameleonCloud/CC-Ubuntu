#!/bin/bash

set -x
set -e

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root."
  exit 1
fi

### OS-specific installs
function ubuntu_reqs() {
  apt-get update
  # install qemu-user-static and binfmt-support for building arm on x86_64
  # ref: https://wiki.debian.org/RaspberryPi/qemu-user-static
  apt-get -qq install -y qemu-utils python3-pip kpartx qemu-user-static binfmt-support u-boot-tools
}

python --version
ubuntu_reqs

# We install diskimage-builder directly from pip because we care about OpenStack's release
# cycle, not Ubuntu's
pip install diskimage-builder==3.26.0
