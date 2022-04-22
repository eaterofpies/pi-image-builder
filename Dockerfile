FROM alpine:3.15 as files

# Cache the files we need in later steps
WORKDIR /downloads/
RUN apk add --no-cache --virtual .bootstrap-deps wget ca-certificates \
    && wget --quiet https://downloads.raspberrypi.org/raspios_lite_armhf/root.tar.xz  \
    && wget --quiet https://downloads.raspberrypi.org/raspios_lite_armhf/boot.tar.xz  \
    && apk del .bootstrap-deps

FROM debian:bullseye-slim as make_image

# Get the tools we need to create the new image
# guestfish for building the image
# linux-image-generic for running guestfish
# xz for decompressing the rootfs
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    libguestfs-tools \
    linux-image-generic \
    qemu-user-static \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /files/rootfs/
COPY --from=files /downloads/root.tar.xz /files
#RUN tar -xf ../root.tar.xz && rm ../root.tar.xz

WORKDIR /files
COPY --from=files /downloads/boot.tar.xz /files
COPY make_image.sh partitions.sfdisk setup_image.gf /files/
WORKDIR /files
#RUN ls && /bin/false
CMD ["./make_image.sh"]
