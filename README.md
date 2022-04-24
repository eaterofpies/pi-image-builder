# pi-image-builder
Build customised sd card images for raspberry pi boards in docker.

## Building
Run `docker-compose up --build`. When it finishes there should be a file called `images/image.img` which you can write to a SD card.

## Customisation
Put any files you want in the boot partition in the extra-boot-files directory.
See the [official docs](https://www.raspberrypi.com/documentation/computers/configuration.html#setting-up-a-headless-raspberry-pi)
for details.

Set the IMAGE_HOSTNAME environment variable to set the hostname used on the device.

## Why?
I wanted to be able to create SD card images with a record of the changes between versions in git.

A lot of the tooling for building SD card images
- Leaves stale loopback devices on failure.
- Leaves stale bind mounts on failure.
- Is not safe (eg. requires running random scripts as sudo).
- Make it hard to compare different revisions of the output image.
- Requires a specific host OS to make the image.
