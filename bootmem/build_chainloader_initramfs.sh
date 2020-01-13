#!/bin/sh
set -e
cd "$(dirname "$0")"

die() {
    echo "$@" 1>&2
    exit 1
}

[ -z "$BUSYBOX_PREFIX" ] && die "must set \$BUSYBOX_PREFIX (busybox _install dir)"
: ${SOURCE_DATE_EPOCH:=$(date +%s)}

cat >chainloader-initramfs.files <<EOF
file /init chainloader-init 0755 0 0
EOF

# Busybox components, all squashed to owner 0:0
gen_initramfs_list.sh -u squash -g squash $BUSYBOX_PREFIX >>chainloader-initramfs.files
# Default minimum file list
gen_initramfs_list.sh -d >>chainloader-initramfs.files

gen_init_cpio -t $SOURCE_DATE_EPOCH chainloader-initramfs.files | \
    gzip --best >chainloader-initramfs.cpio.gz
