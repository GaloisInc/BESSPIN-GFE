#!/bin/bash

# Create systemd symlink
if [ -f /lib/systemd/systemd ]; then

    ln -s /lib/systemd/systemd /init
    # Fixup serial service for slower processors
    echo "DefaultTimeoutStartSec=300s" >> /etc/systemd/system.conf
    
    # Disable many services that are not required to boot to a shell
    # NOTE: Some of these may be required for your intended application or functionality
    systemctl disable cron.service
    systemctl disable dbus-org.freedesktop.timesync1.service
    systemctl disable e2scrub_reap.service
    systemctl disable networking.service
    systemctl disable systemd-timesyncd.service
    systemctl disable remote-fs.target
    systemctl disable apt-daily-upgrade.timer
    systemctl disable apt-daily.timer
    systemctl disable e2scrub_all.timer
    systemctl disable logrotate.timer
    systemctl mask network-online.target
    systemctl mask sys-fs-fuse-connections.mount
    systemctl mask apt-daily-upgrade.service
    systemctl mask apt-daily.service
    systemctl mask container-getty@.service
    systemctl mask dbus-org.freedesktop.hostname1.service
    systemctl mask dbus-org.freedesktop.locale1.service
    systemctl mask dbus-org.freedesktop.login1.service
    systemctl mask dbus-org.freedesktop.timedate1.service
    systemctl mask e2scrub@.service
    systemctl mask e2scrub_all.service
    systemctl mask e2scrub_fail@.service
    systemctl mask fstrim.service
    systemctl mask getty-static.service
    systemctl mask kmod.service
    systemctl mask logrotate.service
    systemctl mask module-init-tools.service
    systemctl mask systemd-bless-boot.service
    systemctl mask systemd-fsck-root.service
    systemctl mask systemd-fsck@.service
    systemctl mask systemd-fsckd.service
    systemctl mask systemd-journal-flush.service
    systemctl mask systemd-modules-load.service
    systemctl mask systemd-update-utmp-runlevel.service
    systemctl mask systemd-update-utmp.service
    systemctl mask systemd-fsckd.socket
    systemctl mask bluetooth.target
    systemctl mask time-sync.target
    systemctl mask systemd-tmpfiles-clean.timer
    systemctl mask sys-subsystem-net-devices-eth0.device
    systemctl set-default multi-user.target

    # Initialize random-seed
    dd if=/dev/urandom of=/var/lib/systemd/random-seed count=1 bs=512 
    chmod 600 /var/lib/systemd/random-seed
else
    ln -s /sbin/init /init

    echo "
id:3:initdefault:

si::sysinit:/etc/init.d/rcS

~:S:wait:/sbin/sulogin --force


l0:0:wait:/etc/init.d/rc 0
l1:1:wait:/etc/init.d/rc 1
l2:2:wait:/etc/init.d/rc 2
l3:3:wait:/etc/init.d/rc 3
l4:4:wait:/etc/init.d/rc 4
l5:5:wait:/etc/init.d/rc 5
l6:6:wait:/etc/init.d/rc 6
z6:6:respawn:/sbin/sulogin --force

ca:12345:ctrlaltdel:/sbin/shutdown -t1 -a -r now


pf::powerwait:/etc/init.d/powerfail start
pn::powerfailnow:/etc/init.d/powerfail now
po::powerokwait:/etc/init.d/powerfail stop


T0:2345:respawn:/sbin/getty -L console 115200 vt100" > /etc/inittab

    # Install busybox
    busybox --install -s

fi

# Common setup

# Set root password
yes riscv | passwd

# Modify network configuration
echo "
# Use DHCP to automatically configure eth0
auto eth0
allow-hotplug eth0
iface eth0 inet dhcp" >> /etc/network/interfaces


# Remove debconf internationalization for debconf
dpkg --remove debconf-i18n

# apt-get then cleanup
apt-get update

# Install packages here
apt-get install "$@" || exit $? 

/setup_scripts/clean_chroot.sh

# Remove chroot scripts
rm -rf /setup_scripts
