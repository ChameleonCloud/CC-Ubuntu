#!/bin/bash

if [ ${DIB_DEBUG_TRACE:-0} -gt 0 ]; then
    set -x
fi
set -eu
set -x
set -o pipefail

# pci=realloc=off is a fix for A100 nodes which fail to load Nvidia drivers
# if 4 or more GPUs are installed
cat > '/etc/default/grub.d/99-pci-settings.cfg' <<- EOM
GRUB_CMDLINE_LINUX_DEFAULT="$GRUB_CMDLINE_LINUX_DEFAULT pci=realloc=off"
EOM

cp /boot/grub/grub.cfg /boot/grub/grub.cfg.bak
grub-mkconfig > /boot/grub/grub.cfg
