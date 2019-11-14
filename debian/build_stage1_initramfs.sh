#!/bin/sh
set -e
cd "$(dirname "$0")"
chroot_dir="riscv64-chroot"

./create_chroot.sh stage0
./create_chroot.sh stage1 # tar this as_fake_root ?

./create_chroot.sh as_fake_root cp stage1-init "$chroot_dir/init"

# The copy of `debootstrap` installed into the chroot may have a Nix shebang
# line.  Reset it to the normal /bin/bash.
cp "$chroot_dir/debootstrap/debootstrap" "$chroot_dir/debootstrap/debootstrap.old"
sed -e '1s,/nix/store/[^/]*/,/,' "$chroot_dir/debootstrap/debootstrap.old" \
    >"$chroot_dir/debootstrap/debootstrap"
rm "$chroot_dir/debootstrap/debootstrap.old"

cd "$chroot_dir"
find . -print0 | \
    ../create_chroot.sh as_fake_root cpio --null --create --format=newc | \
    xz -c --best >../stage1-initramfs.cpio.xz
