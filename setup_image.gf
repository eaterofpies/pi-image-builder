#!/usr/bin/guestfish -f
allocate /output/image.tmp 1924M
run

# Create boot and root partitions
part-init /dev/sda msdos
sfdisk-N /dev/sda 1 0 0 0 "4M,256M,c"
sfdisk-N /dev/sda 2 0 0 0 "260M"

# Setup the root file system
mkfs ext4 /dev/sda2 label:root features:^huge_file
mount /dev/sda2 /
tar-in root.tar / xattrs:true selinux:true acls:true

# Add the boot files system
mkfs fat /dev/sda1 label:boot
mount /dev/sda1 /boot
tar-in boot.tar /boot xattrs:true selinux:true acls:true
exit
