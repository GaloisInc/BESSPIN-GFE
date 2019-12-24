# Benchmarks
A list of available benchmarks. For results, see `RESULTS.md` and `./logs` folder

## Coremark
We have a [Galois fork of coremark](https://github.com/GaloisInc/coremark) which supports ~~both P1 and~~ P2 CPUs.

### Coremark on P1

TBD

### Coremark on P2

To compile coremark executable for P2, install [GFE dependencies](https://gitlab-ext.galois.com/ssith/gfe#update-dependencies). Then do:

* ```bash
  cd coremark
  make PORT_DIR=linux64
  cp coremark.elf ../../bootmem/.
  ```
* the make will end with error because you are trying to run a RISCV binary on a (likely x86) host. What we want is the `coremark.elf` executable and we need it in the `gfe/bootmem` directory.
* Reset the PCIe bus of the FPGA (use `FPGA3` or `FPGA4`) with:
  ```
  socat stdio tcp4-connect:besspin-fpga-3.proj.galois.com:7654<<<$YOUR_FPGA
  ```
* Load the bitstream from a terminal (`chisel_p2|bluespec_p2`):
  ```
  ./program_fpga.sh $MY_CPU
  ```
* start `openocd` in the same terminal:
  ```
  openocd -f testing/targets/ssith_gfe.cfg
  ```
* in another terminal, build debian executable:
  ```
  cd bootmem
  make debian
  make serve-cpio-archive
  ```
  Note this takes around 18-20min depending on your machine. The last command sets up a HTTP server, providing the debian cpio archive over the network.
* in another terminal, load the executable:
  ```
  riscv64-unknown-elf-gdb build-debian-bbl/bbl
  $ target remote :3333
  # do this is you are running bluespec P2
  # set $a0 = 0
  # set $a1 = 0x70000020
  $ load
  $ continue
  ```
* in yet another terminal, open `minicom`:
  ```
  ls /dev/ttyUSB*
  # see which ttyUSBs are available
  # use the highest number 
  # (typically ttyUSB1 or ttyUSB2)
  minicom -D /dev/ttyUSB1 -b 115200
  ```
  and wait for debian to boot.
  * note you might have to configure minicom and **disable hardware flow control**
  1. Ctrl+a+z 
  2. press `o`
  3. select `Serial Port setup` and make sure hardware flow control is disabled
* in your minicom, log into debian (uname: root, pwd: riscv)
* get the coremark executable:
  ```
  wget 10.88.88.1:8000/coremark.elf
  chmod +x coremark.elf
  ```
* run and enjoy the results:
  ```
  ./coremark.elf
  ```
* you should see something like this:
  ```
    2K performance run parameters for coremark.
    CoreMark Size    : 666
    Total ticks      : 14223
    Total time (secs): 14.223000
    Iterations/Sec   : 210.925965
    Iterations       : 3000
    Compiler version : GCC9.2.0
    Compiler flags   : -O2 -DPERFORMANCE_RUN=1  -lrt
    Memory location  : Please put data memory location here
                            (e.g. code in flash, data on heap etc)
    seedcrc          : 0xe9f5
    [0]crclist       : 0xe714
    [0]crcmatrix     : 0x1fd7
    [0]crcstate      : 0x8e3a
    [0]crcfinal      : 0xcc42
    Correct operation validated. See README.md for run and reporting rules.
    CoreMark 1.0 : 210.925965 / GCC9.2.0 -O2 -DPERFORMANCE_RUN=1  -lrt / Heap
  ```
* copy-paste it into a log file, and save it in `logs` directory




## Mibench
Another suitable benchmark: 
https://github.com/embecosm/mibench

## Dhrystone
Everybone says how bad Dryhstone is, but if it is easy to get it running, why not?

https://github.com/sifive/benchmark-dhrystone/tree/8ff0ab1db77b134b56815905bf694eb8a767285b
