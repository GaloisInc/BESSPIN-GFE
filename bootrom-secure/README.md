# How to Secure Boot an OS
1. Build a binary image of the OS you want to boot following whatever instructions you 
have for doing that. IMPORTANT: the file we want here is the raw bytes of the OS, _not_ 
an ELF; if you only have instructions for building an ELF, you can get the raw bytes 
with `riscv64-unknown-elf-objcopy -O binary whatever.elf whatever.bin`.

2. If you will be building a bitstream, continue with the "How to Build a Bitstream with 
the Boot ROM" instructions below. If you are only testing the boot ROM, without building 
a bitstream, skip to the "How to Test the Boot ROM (Without Building a Bitstream)" 
instructions.

# How to Build a Bitstream with the Boot ROM
1. Setup your machine to build the GFE, following the instructions in the GFE README. 
When invoking the `setup_soc_project.sh` script, pass the filename of the binary image 
you built above as an additional parameter (e.g., 
`setup_soc_project.sh chisel_p2 whatever.bin`). The boot ROM will be automatically
configured for that processor (32 vs. 64 bit) and binary image, and you can observe this
configuration in the console output.

2. Follow the normal GFE instructions for building the bitstream. The boot ROM will
automatically be built, with the correct bit width, and incorporated into the SoC.

3. Before programming the FPGA with the bitstream, flash the binary image to the
FPGA with the `tcl/program_flash` script (e.g., 
`tcl/program_flash datafile whatever.bin`).

4. Program the FPGA with the bitstream. If secure boot worked successfully, the OS should
boot. If it did not, you can connect to the processor using GDB and load the symbols from
the secure boot ROM, in `bootrom-configured/bootrom.elf`, at address `0x70000000`,
with `add-symbol-file bootrom.elf 0x70000000`. You should then see the system 
(eventually) stop at the symbol `sb_assert_fail` with parameters
`function="unsuccessful_secure_boot"` and `condition="unsuccessful secure boot"`.

# How to Test the Boot ROM (Without Building a Bitstream)
In order to test the boot ROM without building a bitstream, we will load
the boot ROM high in main memory and run it manually through `gdb`, simulating the 
operation of running it directly from a bitstream's ROM. This requires manual
configuration, as follows.

1. Get the SHA-256 hash of the binary image using `sha256sum whatever.bin`.

2. Get the length of the binary image from `ls -nl`.

3. Configure the boot ROM by running (in this directory) `./configure <hash> <length>`. 
Enter the hash _exactly as it appears in the `sha256sum` output_; in particular, do
not prefix it with `0x` to indicate that it is hexadecimal. Before doing this 
configuration, you might want to copy the entire `bootrom-secure` directory to another location (as would happen when building a bitstream) to avoid unintentionally 
overwriting part of the original boot ROM distribution.

4. To prevent the default boot ROM from immediately trying to boot into your OS without executing the secure boot checks first, prepend the provided padding to your binary
image. This padding is a small infinite loop that runs as soon as the processor starts up.
    * for a 32-bit processor, `cat padding-32.bin whatever.bin > whatever_padded.bin`
    * for a 64-bit processor, `cat padding-64.bin whatever.bin > whatever_padded.bin`

5. Open `secure-boot/peripherals/config.py` and locate the `Flash_OS` initialization. 
The arguments are as follows:
    * `flash_base`: The memory-mapped address in flash to start copying the OS from. 
    Because of the padding you added in step 4, change the default `0x44000000` to 
    `0x44000100`.
    * `ram_base`: The memory-mapped address in RAM to copy the OS to. It is important 
    that this matches the address the OS was linked to load at. The default value 
    that's already there should be fine in most cases. If you change `ram_base`, you
    should also change `BOOT_ADDRESS` to point to the same address.
    * `size`: The number of bytes to copy from flash to RAM; this should have been
    configured properly by step 3.
    * `sha256sum`: The SHA-256 hash of the bytes to be copied; this should have been
    configured properly by step 3.
    * `ram_device`: A description of the RAM in the system; no changes should be needed.

6. Build the boot ROM using `env XLEN=<bits> NO_PCI=<no_pci> CPU_SPEED=<speed> make`. These parameters control various aspects of the device tree for the resulting boot ROM, so it is important to get them right; in particular, if you build a boot rom for a Bluespec P2 that doesn't have PCIe, but you forget to specify `NO_PCI=1`, Linux will kernel panic at boot time.
    * `bits` is the bit width of your processor (32 or 64)
    * `no_pci` is 0 if your SoC supports PCIe, and 1 otherwise
    * `speed` is the CPU speed in mHz (that is, MHz times 100000 - e.g., 100000000 for a 100MHz P2)

7. Flash the binary image to the FPGA, with the `tcl/program_flash` script: `tcl/program_flash datafile whatever_padded.bin`

8. Flash your bitstream to the FPGA to clear all the processor state and boot with the
default boot ROM. At this point, the processor should infinitely loop (in the code
prepended to your binary image in step 4).

9. Connect to the processor using GDB, and run:
    1. `add-symbol-file bootrom.elf 0xF0400000`
    2. `restore bootrom.bin binary 0xF0400000`
    3. `set $pc = 0xF0400000`
    
    
10. The boot ROM is now set up, and should run when you `continue` within GDB. You
should then either see the OS boot, or (eventually) stop at the symbol
`sb_assert_fail` with parameters `function="unsuccessful_secure_boot"` and 
`condition="unsuccessful secure boot"`.

# How to Run the Assurance Checks
1. Install the [Nix package manager](https://nixos.org/nix/). Nix is available for both Linux and MacOS.

2. Run (from a configured secure boot ROM directory, either `bootrom-configured` or
one you have made yourself)
   
   - `nix-shell --pure --run 'make clean && env XLEN=64 make check'` to run the assurance 
   case for the 64-bit boot ROM, or
      
   - `nix-shell --pure --run 'make clean && env XLEN=32 make check'` to run the
   assurance case for the 32-bit boot ROM.
   
3. If the assurance checks are successful, you should see the message 
   "ALL CHECKS PASSED".
