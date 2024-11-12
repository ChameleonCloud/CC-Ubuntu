*this repo is now archived, current build-defs can be found in https://github.com/ChameleonCloud/cc-images*

# CC-Ubuntu

This directory contains the scripts used to generate the Chameleon KVM and
bare-metal Ubuntu images. It relies on diskimage-builder.

## Requirements

Install on Ubuntu or CentOS with `install-reqs.sh`. It installs

* QEMU utilities
* pip
* [disk-image-builder](http://docs.openstack.org/developer/diskimage-builder)

## Usage

The main script takes an output variant as a single input parameter:
```
python create-image.py <output_variant> [--release <release>]
```

For this image, the current supported variants are:

* `base`: General Ubuntu image
* `gpu`: includes CUDA driver
  * *Needs to be built from another Ubuntu image with the **same kernel*** as it grabs the kernel info to install headers, and also on a GPU node so the NVidia installer doesn't abort.
* `arm64`: Creates post-processed kernel and ramdisk
  * Can be built on an ARM64 node or x86 node

The `.py` script does some parameter parsing, configures then environment, then
`exec`'s the `.sh` script. Calling the `.sh` directly requires a few envvars
to be set.

At the end of its execution, the script provides the OpenStack command that can be
used to upload the image to an existing OpenStack infrastructure.

This script does the following:

* Download an Ubuntu cloud image from upstream
* Customize it for Chameleon (see `elements` directory for details)
* Generate an image compatible with OpenStack KVM and bare-metal

The image must then be uploaded and registered with Glance (currently done
manually, by running the OpenStack command given at the end of execution).

## Automated/Jenkins

Cloned/run by Jenkins with https://github.com/ChameleonCloud/abracadabra

If the script is run by Abracadabra, it looks for the magic line "Image built
in (path)", so don't change that (without changing the other).
