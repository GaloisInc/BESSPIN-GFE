#!/bin/bash
set -e
cd "$(dirname "$0")"
chroot_dir="riscv64-chroot"

if [[ $1 == "stage1" ]]; then
    echo "build_stage1_initramfs.sh: stage1"
	./create_chroot.sh stage0
    ./create_chroot.sh stage1
    ./create_chroot.sh as_fake_root tar -cvf "$chroot_dir".tar "$chroot_dir"
else
    echo "build_stage1_initramfs.sh: create cpio"
    ./create_chroot.sh as_fake_root cp stage1-init "$chroot_dir/init"
    touch "$chroot_dir".tar

    # The copy of `debootstrap` installed into the chroot may have a Nix shebang
    # line.  Reset it to the normal /bin/bash.
    cp "$chroot_dir/debootstrap/debootstrap" "$chroot_dir/debootstrap/debootstrap.old"
    sed -e '1s,/nix/store/[^/]*/,/,' "$chroot_dir/debootstrap/debootstrap.old" \
        >"$chroot_dir/debootstrap/debootstrap"
    rm "$chroot_dir/debootstrap/debootstrap.old"

    cd "$chroot_dir"
    find . -print0 | \
        ../create_chroot.sh as_fake_root cpio --null --create --format=newc | \
        gzip --best >../stage1-initramfs.cpio.gz
fi
