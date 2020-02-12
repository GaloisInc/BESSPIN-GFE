# Benchmarks
A list of available benchmarks. For results, see `RESULTS.md` and `./logs` folder

## Coremark
We have a [Galois fork of coremark](https://gitlab-ext.galois.com/ssith/coremark) which supports both P1 and P2 CPUs.

To compile coremark executable, you need to install [GFE dependencies](https://gitlab-ext.galois.com/ssith/gfe#update-dependencies).

### Coremark on P1
* Build coremark for P1:
  ```bash
  cd benchmarks/coremark
  make PORT_DIR=riscv-bare-metal GFE_TARGET=P1 ITERATIONS=2000 clean
  make PORT_DIR=riscv-bare-metal GFE_TARGET=P1 ITERATIONS=2000 link
  ```
* Run the coremark binary from `gfe` root directory and set `$cpu` to your processor:
  ```
  ./pytest_processor.py $cpu --elf benchmarks/coremark/coremark.bin --timeout 60 --expected "Correct operation validated" --absent "Errors detected"
  ```
* You should see something like this:
  ```
  2K performance run parameters for coremark.
  CoreMark Size    : 666
  Total ticks      : 711159355
  Total time (secs): 14.223187
  Iterations/Sec   : 140.615460
  Iterations       : 2000
  Compiler version : GCC9.2.0
  Compiler flags   : -march=rv32imac -mabi=ilp32 -DCLOCKS_PER_SEC=50000000 -DUART_BAUD_RATE=115200 -O2 -mcmodel=medany -static -std=gnu99 -ffast-math -fno-common -fno-builtin-printf -I./riscv-common   -static -nostdlib -nostartfiles -lm -lgcc -T ./riscv-common/test.ld
  Memory location  : STACK
  seedcrc          : 0xe9f5
  [0]crclist       : 0xe714
  [0]crcmatrix     : 0x1fd7
  [0]crcstate      : 0x8e3a
  [0]crcfinal      : 0x4983
  Correct operation validated. See README.md for run and reporting rules.
  ```
* The coremark score is `Iterations/Sec`
* The coremark score/MHz is `Iterations/Sec/MHz`

### Coremark on P2
* Build coremark for P2 (make sure to set `ITERATIONS=3000`):
  ```bash
  cd benchmarks/coremark
  make PORT_DIR=riscv-bare-metal GFE_TARGET=P2 ITERATIONS=3000 clean
  make PORT_DIR=riscv-bare-metal GFE_TARGET=P2 ITERATIONS=3000 link
  ```
* Run the coremark binary from `gfe` root directory and set `$cpu` to your processor:
  ```
  ./pytest_processor.py $cpu --elf benchmarks/coremark/coremark.bin --timeout 60 --expected "Correct operation validated" --absent "Errors detected"
  ```
* You should see something like this:
  ```
  2K performance run parameters for coremark.
  CoreMark Size    : 666
  Total ticks      : 1102777510
  Total time (secs): 11.027775
  Iterations/Sec   : 272.040368
  Iterations       : 3000
  Compiler version : GCC9.2.0
  Compiler flags   : -march=rv64imafdc -mabi=lp64d -DCLOCKS_PER_SEC=100000000 -DUART_BAUD_RATE=115200 -O2 -mcmodel=medany -static -std=gnu99 -ffast-math -fno-common -fno-builtin-printf -I./riscv-common   -static -nostdlib -nostartfiles -lm -lgcc -T ./riscv-common/test.ld
  Memory location  : STACK
  seedcrc          : 0xe9f5
  [0]crclist       : 0xe714
  [0]crcmatrix     : 0x1fd7
  [0]crcstate      : 0x8e3a
  [0]crcfinal      : 0xcc42
  Correct operation validated. See README.md for run and reporting rules.
  CoreMark 1.0 : 272.040368 / GCC9.2.0 -march=rv64imafdc -mabi=lp
  ```
* The coremark score is `Iterations/Sec`
* The coremark score/MHz is `Iterations/Sec/MHz`