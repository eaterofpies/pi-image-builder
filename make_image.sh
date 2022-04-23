#!/bin/bash

# Clean up stale data
rm -f /output/image.img /output/image.tmp

# Exit on error
set -e

# Use a guestfish script to setup the rest of the image
./setup_image.gf

# Overwrite the disk id
# TODO figure out why this is necessary. (the pi won't boot if it's not set)
printf '\x70\x28\x5A\x7D' | dd of=/output/image.tmp conv=notrunc bs=1 seek=$((0x1b8))

# Move the tmp file to
mv /output/image.tmp /output/image.img
