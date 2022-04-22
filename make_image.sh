#!/bin/sh

# Clean up stale data
rm -f /output/image.img /output/image.tmp

# Exit on error
set -e

# Guestfish can't setup the partitions correctly so do that first
# Undersize the image for 2GB as SD cards can be weird sizes
guestfish -x <<_EOF_
allocate /output/image.tmp 2000M
run
exit
_EOF_

sfdisk /output/image.tmp < partitions.sfdisk

# Use guestfish script to setup the rest of the image
./setup_image.gf

# Move the tmp file to
mv /output/image.tmp /output/image.img
