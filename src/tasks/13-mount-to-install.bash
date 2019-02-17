#Title: Mount for install
#Description: Create necessary directories and mounts for installation
# Filesystems/Partions must be prepared beforehand
# choose SHELL option to from tools list to do it
#Default-Description: NO DEFAULT - MUST EDIT FILE
#-------------------------------------------------
#!/bin/bash


boot_vol=/dev/---
root_vol=/dev/---
#home_part=/dev/--- # optional
#------------------------------------------------------------

mount $root_vol /mnt
mkdir /mnt/boot
mount $boot_vol /mnt/boot

if [[ ! -z "$home_vol" ]] ; then
    mkdir /mnt/home
    mount $home_vol /mnt/home
fi
#
lsblk

