# Chameleon-SAGE Image Builder

This directory contains the scripts used to generate the Chameleon KVM and
bare-metal Ubuntu image, including Ubuntu14.04, Ubuntu16.04, and Ubuntu18.04. It relies on diskimage-builder.

## Requirements

Install on Ubuntu or CentOS with `install-reqs.sh`. It installs

* QEMU utilities
* pip
* [disk-image-builder](http://docs.openstack.org/developer/diskimage-builder)

## Usage

The main script takes an output variant as a single input parameter:
```
python create-image.py <output_variant> [--release {trusty, xenial}]
```

For this image, the current supported variants are:

* `base`: General Ubuntu image
* `gpu`: includes CUDA 8 driver, only supported with 16.04 Xenial.
  * *Needs to be built from another Ubuntu image with the **same kernel*** as it grabs the kernel info to install headers, and also on a GPU node so the NVidia installer doesn't abort.
* `arm64`: Creates post-processed kernel and ramdisk, and bootscript for U-Boot
  * Can only be built on an ARM64 node, currently

The `.py` script does some parameter parsing, configures then environment, then
`exec`'s the `.sh` script. Calling the `.sh` directly requires a few envvars
to be set

At the end of its execution, the script provides the Glance command that can be
used to upload the image to an existing OpenStack infrastructure.

This script does the following:

* Download an Ubuntu cloud image from upstream
* Customize it for Chameleon (see `elements` directory for details)
* Generate an image compatible with OpenStack KVM and bare-metal

The image must then be uploaded and registered with Glance (currently done
manually, by running the Glance command given at the end of execution).

## Automated/Jenkins

Cloned/run by Jenkins with https://github.com/ChameleonCloud/abracadabra

If the script is run by Abracadabra, it looks for the magic line "Image built
in (path)", so don't change that (without changing the other).

## Sage Users
Follow these steps in order to create an image to use on a Chameleon instance This image will contain a Docker group that allows a user cc to run Docker commands without ```sudo``` .

Create an instance on Chameleon using the 18.04 Ubuntu Image.
Link to Chameleon: http://chi.uc.chameleoncloud.org/

For the sake of this process also create a private and public key on your local machine. Import the public key to create the key pair for the Chameleon instance.

To create public and private ssh key
```
cd ~/.ssh/
ssh-keygen
cat ~/.ssh/id_rsa.pub | pbcopy
```

```cat ~/.ssh/id_rsa.pub | pbcopy``` will save a copy public key to your dashboard, which can then be pasted to Chameleon.

ssh into Chemeleon instance:```ssh -i ~/.ssh/private_key cc@public_floating_ip ```

NOTE: If you recieve the following error: ```cc@public_floating_ip Permission denied (publickey).``` Be sure to check that you are using the correct private key that matches the pulbic key used in your Chameleon key pair. Or delete the pulbic floating ip from the ``` ~/.ssh/known_hosts ``` and try it again

Obtain OpenStack RC File from Chameleon and put a copy into Chameleon instance.

This command will create a copy of OpenStack Rc file from your local machine onto the Chameleon instance.
```
scp -i ~/.ssh/private_key /path/to/openrc.sh cc@public_floating_ip:/home/cc
```

Set RC file as source
```
source /path/to/rc_file
```

Install the requirements for the image building process.
```
sudo ./install-reqs.sh
```

Then make sure you checkout the Sage branch
```
git fetch && git checkout sage;
```

Run create-image.py
```
python create-image.py --release bionic --variant sage --region CHI@UC
```
After running this command, you must upload the image created to the OpenStack infrastructure. The command will show up after the completion of create-image.py. It will look similar to the command shown below.
```
glance image-create --name "Sage-VIRTUAL-WAGGLE" --disk-format qcow2 --container-format bare --file /tmp/tmp.R0Ko9o7lBc/common/Sage18.04-VIRTUAL-WAGGLE.qcow2
