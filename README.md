# CC-Ubuntu16.04

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
./create-image.sh <output_variant>
```

For this image, the current supported variants are:

* `base`: General Ubuntu image
* `gpu`: includes CUDA 8 driver
  * *Needs to be built from another Ubuntu image with the **same kernel*** as it grabs the kernel info to install headers, and also on a GPU node so the NVidia installer doesn't abort.

```
$ ./create-image.sh image_ubuntu.qcow2
[...lots of output...]

to add the image in glance run the following command:
glance image-create --name "CC-Ubuntu16.04" --disk-format qcow2 --container-format bare --file base
```

At the end of its execution, the script provides the Glance command that can be
used to upload the image to an existing OpenStack infrastructure.

This script does the following:

* Download an Ubuntu cloud image from upstream
* Customize it for Chameleon (see `elements` directory for details)
* Generate an image compatible with OpenStack KVM and bare-metal

The image must then be uploaded and registered with Glance (currently done
manually, by running the Glance command given at the end of execution).
