#!/bin/sh
set -e
cd "$(dirname "$0")"

die() {
    echo "$@" 1>&2
    exit 1
}

[ -z "$BUSYBOX_PREFIX" ] && die "BUSYBOX_PREFIX must be set to the busybox _install dir"
: ${SOURCE_DATE_EPOCH:=$(date +%s)}

cp initramfs.files busybox-initramfs.files
# Add busybox components, all squashed to owner 0:0
gen_initramfs_list.sh -u squash -g squash $BUSYBOX_PREFIX >>busybox-initramfs.files
gen_initramfs_list.sh -u squash -g squash _rootfs >>busybox-initramfs.files

gen_init_cpio -t $SOURCE_DATE_EPOCH busybox-initramfs.files | \
  gzip --best >busybox-initramfs.cpio.gz
