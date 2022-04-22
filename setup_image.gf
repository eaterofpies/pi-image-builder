#!/usr/bin/guestfish -f
add /output/image.tmp
run

# Setup the root file system
mkfs ext4 /dev/sda2 label:root features:^huge_file
mount /dev/sda2 /
tar-in root.tar.xz / compress:xz xattrs:true selinux:true acls:true

# Guestfish doesn't seem to be able to setup the boot filesystem in the expected way
# Use qemu to run mkfs to set it up correctly
# Copy in qemu and setup the file system
copy-in /usr/bin/qemu-arm-static /
command "/qemu-arm-static /sbin/mkfs.fat -F 32 -n boot /dev/sda1"
rm /qemu-arm-static

# Add the boot files
mount /dev/sda1 /boot
tar-in boot.tar.xz /boot compress:xz xattrs:true selinux:true acls:true
exit
