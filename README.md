# ARM-CC-Ubuntu16.04

This directory contains the scripts used to generate the bare-metal Ubuntu
images for ARM64. It relies on diskimage-builder.

## Installation

Images are created with the *diskimage-builder*:
http://docs.openstack.org/developer/diskimage-builder

Requirements:
- *qemu-utils* (ubuntu/debian) or *qemu* (Fedora/RHEL/opensuse).

To install dependencies on Centos, please run the following commands:

```
sudo yum install epel-release
yum install qemu-img # or apt-get install qemu-disk
```
## Usage

git clone https://github.com/openstack/diskimage-builder.git
git clone https://github.com/openstack/dib-utils.git
git clone https://github.com/ChameleonCloud/CC-Ubuntu16.04.git
export PATH=$PATH:$(pwd)/diskimage-builder/bin:$(pwd)/dib-utils/bin
cd CC-Ubuntu16.04/
ELEMENTS_PATH=`pwd`/elements DIB_RELEASE="xenial" DIB_REPOREF_ironic_agent="stable/newton" disk-image-create -p u-boot-tools,grub2-common ubuntu uboot baremetal chameleon-common -o ARM64-CC-Ubuntu16.04
