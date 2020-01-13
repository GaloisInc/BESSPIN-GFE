# Docker for GFE
The purpose of this docker container is to provide GFE tools for non-Debian platforms (for example MacOS). **NOTE: This is not officially supported and hence you are using it ar your own risk.**

The docker container is hosted at https://hub.docker.com/r/galoisinc/besspin and can be pulled by `docker pull galoisinc/besspin:gfe`

Below an example of a docker workflow with GFE. This container can be used for compiling and debugging, even for flashing bitstreams, should you install `vivado lab` in it.


## Test the galoisinc/besspin:gfe

1.	[Install](<https://docs.docker.com/install/linux/docker-ce/ubuntu/>) docker on your machine.
2.  `sudo docker pull galoisinc/besspin:gfe`
3.  Make sure you have the docker branch of the voting system repo.
4.  Make sure you have the right image downloaded:

    ```
    $ docker images
	  REPOSITORY          TAG                  IMAGE ID            CREATED             SIZE
	  galoisinc/besspin   gfe   48a07c86a2a4        3 days ago          12.5GB
    ```

5. Run it using `IMAGE_ID` or `REPOSITORY:TAG` and instead of `$PATH_TO_YOUR_GFE_REPO` put the absolute path to your voting system repo:

    ```
    sudo docker run -v $PATH_TO_YOUR_GFE_REPO:/gfe -it galoisinc/besspin:gfe
    ```
    
6. In docker do:

    ```
    #cd /gfe
    #./test_simulator.sh chisel_p1
    ```
7. If everything went well, you will see the simulation test passing.

8. Type `exit` to get out of the container


## Development with docker image

### Code compilation
A good development workflow is following:

1. Open the `gfe` code in your editor of choice
2. In new terminal, run the docker container interactively. 
 
    ```
    sudo docker run -v $PATH_TO_YOUR_GFE_REPO:/gfe -it galoisinc/besspin:gfe
    ```
    Compile / inspect the code from within the container.
3. In another terminal, you can access `gfe` repo you shared with the docker container. So for example changes in source code can be committed to github etc. while the docker container is still running.

### Code deployment / debugging
We will need one container running the `openocd` server, and a second container running the `gdb` instance. Indeed you need a properly connected FPGA, and your host needs to have all the Xilinx drivers installed as well.

To actually upload and debug the code, you need to run the container in `priviledged` mode. That way the container has access to the USB devices on the host. See [Docker Documentation](https://docs.docker.com/engine/reference/run/#runtime-privilege-and-linux-capabilities) for more info.

We also have to connect the container to host network, so we can communicate between the two containers. Use `--network host` for that.

Now, the actual instructions.

1. Start up `galoisinc/besspin:gfe` container that will run `openocd` server. Note, you will need the [gfe](https://gitlab-ext.galois.com/ssith/gfe) repository.
    ```
    sudo docker run --privileged --hostname="gfe" -p 3333:3333 --network host -it -v $PATH_TO_GFE:/gfe galoisinc/besspin:gfe

    ```
2. Start `openocd`:
    ```
    root@gfe:/gfe# openocd -f testing/targets/ssith_gfe.cfg
    ```
    You will see output like this:
    ```
    root@gfe:/gfe# openocd -f testing/targets/ssith_gfe.cfg 
    Open On-Chip Debugger 0.10.0+dev-00617-g27c0fd7a7 (2019-09-24-00:09)
    Licensed under GNU GPL v2
    For bug reports, read
      http://openocd.org/doc/doxygen/bugs.html
    adapter speed: 2000 kHz
    ftdi samples TDO on falling edge of TCK
    none separate
    Info : clock speed 2000 kHz
    Info : JTAG tap: riscv.cpu tap/device found: 0x14b31093 (mfg: 0x049 (Xilinx), part: 0x4b31, ver: 0x1)
    Info : datacount=1 progbufsize=16
    Info : Disabling abstract command reads from CSRs.
    Info : Examined RISC-V core; found 1 harts
    Info :  hart 0: XLEN=32, misa=0x40001105
    Info : Listening on port 3333 for gdb connections
    Info : JTAG tap: riscv.cpu tap/device found: 0x14b31093 (mfg: 0x049 (Xilinx), part: 0x4b31, ver: 0x1)
    Info : Listening on port 6666 for tcl connections
    Info : Listening on port 4444 for telnet connections
    Info : accepting 'gdb' connection on tcp/3333
    Info : dropped 'gdb' connection
    Info : accepting 'gdb' connection on tcp/3333
    Info : Hart 0 unexpectedly reset!
    Info : dropped 'gdb' connection
    Info : accepting 'gdb' connection on tcp/3333
    Info : Disabling abstract command writes to CSRs.
        ```
3. Start `galoisinc/besspin:gfe` container:
    ```
    sudo docker run --privileged --hostname="gfe" --network host -it -v $PATH_TO_gfe_REPO:/gfe galoisinc/besspin:gfe
    ```
    Compile your code and start `gdb`:
    ```
    # make clean_all
    # make sim
    # # riscv64-unknown-elf-gdb -x startup.gdb default_ballot_box_sim.elf
    ```
    You should see:
    ```
    # riscv64-unknown-elf-gdb -x startup.gdb default_ballot_box_sim.elf 
    GNU gdb (GDB) 8.3.0.20190516-git
    Copyright (C) 2019 Free Software Foundation, Inc.
    License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
    This is free software: you are free to change and redistribute it.
    There is NO WARRANTY, to the extent permitted by law.
    Type "show copying" and "show warranty" for details.
    This GDB was configured as "--host=x86_64-pc-linux-gnu --target=riscv64-unknown-elf".
    Type "show configuration" for configuration details.
    For bug reporting instructions, please see:
    <http://www.gnu.org/software/gdb/bugs/>.
    Find the GDB manual and other documentation resources online at:
        <http://www.gnu.org/software/gdb/documentation/>.

    For help, type "help".
    Type "apropos word" to search for commands related to "word"...
    Reading symbols from default_ballot_box_sim.elf...
    boot () at ../FreeRTOS-mirror/FreeRTOS/Demo/RISC-V_Galois_P1/bsp/boot.S:76
    76	    li t6, 0x1800
    $1 = "Reseting the CPU"
    0x44000000 in ?? ()
    $2 = "Loading binary"
    Loading section .text, size 0x68004 lma 0xc0000000
    Loading section .rodata, size 0x78f0 lma 0xc0080000
    Loading section .eh_frame, size 0x3c lma 0xc00878f0
    Loading section .sdata, size 0x228 lma 0xc0087978
    Loading section .data, size 0xfe4 lma 0xc0087ba0
    Start address 0xc0000000, load size 461628
    Transfer rate: 103 KB/sec, 13988 bytes/write.
    (gdb) 
    ```
4. Start debugging! 