#!/bin/bash
set -e
cd "$(dirname "$0")"

die() {
    echo "$@" 1>&2
    exit 1
}

[ -z "$BUSYBOX_PREFIX" ] && die "must set \$BUSYBOX_PREFIX (busybox _install dir)"
: ${SOURCE_DATE_EPOCH:=$(date +%s)}

if [[ $1 == "network" ]]; then

echo "Building networking chainloader initramfs"

cat >chainloader-initramfs-network.files <<EOF
file /init chainloader-init-network 0755 0 0
EOF

# Busybox components, all squashed to owner 0:0
"$CPIO_UTILS_PREFIX"gen_initramfs_list.sh -u squash -g squash $BUSYBOX_PREFIX >>chainloader-initramfs-network.files
# Default minimum file list
"$CPIO_UTILS_PREFIX"gen_initramfs_list.sh -d >>chainloader-initramfs-network.files

"$CPIO_UTILS_PREFIX"gen_init_cpio -t $SOURCE_DATE_EPOCH chainloader-initramfs-network.files | \
    gzip --best >chainloader-initramfs-network.cpio.gz

else

echo "Building regular chainloader initramfs"

cat >chainloader-initramfs.files <<EOF
file /init chainloader-init 0755 0 0
EOF

# Busybox components, all squashed to owner 0:0
"$CPIO_UTILS_PREFIX"gen_initramfs_list.sh -u squash -g squash $BUSYBOX_PREFIX >>chainloader-initramfs.files
# Default minimum file list
"$CPIO_UTILS_PREFIX"gen_initramfs_list.sh -d >>chainloader-initramfs.files

"$CPIO_UTILS_PREFIX"gen_init_cpio -t $SOURCE_DATE_EPOCH chainloader-initramfs.files | \
    gzip --best >chainloader-initramfs.cpio.gz

fi
