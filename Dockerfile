FROM alpine:3.15 as files

# Cache the files we need in later steps
WORKDIR /downloads/
RUN apk add --no-cache --virtual .bootstrap-deps wget ca-certificates \
    && wget --quiet https://downloads.raspberrypi.org/raspios_lite_armhf/root.tar.xz  \
    && wget --quiet https://downloads.raspberrypi.org/raspios_lite_armhf/boot.tar.xz  \
    && apk del .bootstrap-deps

FROM debian:bullseye-slim as base

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
    proot \
    && rm -rf /var/lib/apt/lists/*

FROM base as make_bootfs
# Extract the fs so we can modify it
COPY --from=files /downloads/boot.tar.xz /files/
RUN mkdir /files/boot \
    && tar --extract --file=/files/boot.tar.xz --preserve-permissions --directory /files/boot \
    && rm /files/boot.tar.xz

COPY extra-boot-files/* /files/boot/

# Repack the fs to preserve permissions when copying into the image
RUN tar --directory /files/boot --create --preserve-permissions --gz --file /files/boot.tar.gz .

FROM base as make_rootfs
# Extract the fs so we can modify it
COPY --from=files /downloads/root.tar.xz /files/
RUN mkdir /files/root \
    && tar --extract --file=/files/root.tar.xz --preserve-permissions --directory /files/root \
    && rm /files/root.tar.xz

# Run custom setup if a script is present.
COPY custom-root-files/* /files/
RUN test ! -f "/files/custom-root-setup.sh" || proot -S /files/root -q /usr/bin/qemu-arm-static /bin/bash -c "\
    cd /host-rootfs/files/ \
    && chmod +x ./custom-root-setup.sh \
    && ./custom-root-setup.sh \
    "

# Repack the fs to preserve permissions when copying into the image
RUN tar --directory /files/root --create --preserve-permissions --gz --file /files/root.tar.gz .

FROM base as make_image
COPY --from=make_bootfs /files/boot.tar.gz /files/
COPY --from=make_rootfs /files/root.tar.gz /files/
COPY scripts/make_image.sh scripts/setup_image.gf /files/

WORKDIR /files
CMD ["./make_image.sh"]
