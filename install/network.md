# FPGA Network Configuration

The Linux and FreeRTOS tests expect the host PC to have a specific IP address.
We recommend that you don't connect the VCU118 to your LAN, but instead create
a separate one-cable network between the host and FPGA. These instructions show
how to reproduce the network configuration used by Galois GFE hosts.


## On the Host PC:

First, use the `ip link` command to identify the names (such as `eth0` or `eno1`
or `enp4s0`) and MAC addresses of the host's available network adapters.
Decide which will be used for which network.

Then, edit the `/etc/network/interfaces` to be the following:
```bash
auto lo
iface lo inet loopback

auto <LAN interface name> <FPGA interface name>
mapping <LAN interface name> <FPGA interface name>
    script /etc/network/mapAdaptors.sh
    map <LAN interface MAC> MAIN
    map <FGPA interface MAC> FPGA

iface MAIN inet dhcp

iface FPGA inet static
    address 10.88.88.1/24
```  

The `/etc/network/mapAdaptors.sh` mapping script is used because it's still
sometimes possible for the names to get mapped incorrectly on boot. It must be
created and given execution permissions. Here's the script:
```bash
#!/usr/bin/bash
if [ $# -lt 1 ]; then echo "Error in $0: Ethernet adaptor not passed."; exit 1; fi
IFS=' ' read -r -a array <<< $(ip -br link | grep $1)
maddress=${array[2]}
if [ "$maddress" == "<LAN interface MAC>" ]; then 
    echo "MAIN"
elif [ "$maddress" == "<FGPA interface MAC>" ]; then 
    echo "FPGA"
else
    echo "ERROR"
    exit 1
fi
exit 0
```

## On the FPGA Systems:

We'll assign guest systems the IP address `10.88.88.2/24`.

For a **Busybox** linux system, run these commands after boot:
```bash
ifconfig eth0 up
ip addr add 10.88.88.2/24 dev eth0
```

For a **Debian** linux system, edit `/etc/network/interfaces` to be:
```bash
auto eth0
iface eth0 inet static
address 10.88.88.2/24
```
After boot, run `ifup eth0`.

The **FreeRTOS** network configuration is hardcoded;
see [FreeRTOS-mirror/FreeRTOS/Demo/RISC-V_Galois_P1/FreeRTOSIPConfig.h](FreeRTOS-mirror/FreeRTOS/Demo/RISC-V_Galois_P1/FreeRTOSIPConfig.h).
