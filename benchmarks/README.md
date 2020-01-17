# Benchmarks
A list of available benchmarks. For results, see `RESULTS.md` and `./logs` folder

## Coremark
We have a [Galois fork of coremark](https://github.com/GaloisInc/coremark) which supports both P1 and P2 CPUs.

To compile coremark executable, you need to install [GFE dependencies](https://gitlab-ext.galois.com/ssith/gfe#update-dependencies).

### Coremark on P1

First upload desired bitstream on the FPGA and start `openocd`, then:

* Build coremark for P1:
  ```bash
  cd coremark
  make PORT_DIR=p1 clean
  make PORT_DIR=p1 link
  ```
* Start minicom
* Load and run coremark with `riscv64-unknown-elf-gdb`
* After around 30 seconds you will see the test results in minicom
* You should see something like this:
  ```
  2K performance run parameters for coremark.
  CoreMark Size    : 666
  Total ticks      : 668337251
  Total time (secs): 13
  Iterations/Sec   : 46
  Iterations       : 600
  Compiler version : GCC9.2.0
  Compiler flags   : -O0 -g -march=rv32im -mabi=ilp32   
  Memory location  : STATIC
  seedcrc          : 0xe9f5
  [0]crclist       : 0xe714
  [0]crcmatrix     : 0x1fd7
  [0]crcstate      : 0x8e3a
  [0]crcfinal      : 0xbd59
  Correct operation validated. See README.md for run and reporting rules.
  ```
* The coremark score is `Iterations/Sec`
* copy-paste it into a log file, and save it in `logs` directory


### Coremark on P2

In order to run coremark on P2, you need a network connection between the host and the FPGA. We recommend a direct ethernet connection (no router etc.) and a static IP address.

For example, if your host network adapter is `eth`, do:
```bash
  ip addr add 10.88.88.1/24 broadcast 10.88.88.255 dev eth1
  ip link set eth1 up
```


First upload desired bitstream on the FPGA and start `openocd`, then:

* Build coremark for P2:
  ```bash
  cd coremark
  make PORT_DIR=linux64 clean
  make PORT_DIR=linux64 link
  cp coremark.elf ../../bootmem/.
  ```
* Build debian image
  ```
  cd bootmem
  make debian
  ```
* Load and run the image with `riscv64-unknown-elf-gdb`

* Start HTTP server in the directory where is `coremark.elf` located:
  ```
  python3 -m http.server 8000 --bind 10.88.88.1 -d .
  ```

* Once linux boots up, set up a network interface to communicate with teh host:
  ```
  ip addr add 10.88.88.2/24 broadcast 10.88.88.255 dev eth0
  ip link set eth0 up
  ```

* Download `coremark.elf` over the network:
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

After attempting to use Dhrystone ([sifive](https://github.com/sifive/benchmark-dhrystone), [original](https://github.com/Keith-S-Thompson/dhrystone/tree/master/v2.2)), we encountered several issues that make it not worth the trouble to use (especially with the [embench-iot](https://github.com/embench/embench-iot), a more pertinent tool). Here are the reasons:
* Dhrystone does not compile for HiFive1 RevB as the memory layout spec is not correct. [See this issue.](https://github.com/sifive/freedom-e-sdk/issues/396).
* Dhrystone does not account for any advantages of RISC (in case comparisons between RISC and non-RISC chips were to be attempted). [See this paper.](https://www.eembc.org/techlit/datasheets/ECLDhrystoneWhitePaper2.pdf)
* Porting Dhrystone for the P1 would be challenging as it relies on `malloc`, `memcpy`, `strcpy`, and `strcmp`, among others. The work involved in defining these is not worth it given the availability of embench.

## Embench-IOT

https://github.com/embench/embench-iot