# How to configure the BootROM for a new OS
1. Build a binary dump of the OS you want to boot following whatever instructions you have for doing that. N.B. the file we want here is the raw bytes of the OS, not an ELF; if you only have instructions for build an ELF, you can get the raw bytes with `riscv32-unknown-elf-objcopy -O binary whatever.elf whatever.bin`.
2. If you will be building a bitstream, skip to step 4.
3. To avoid the default BootROM from immediately trying to boot into your OS without executing the secure boot checks first, prepend some invalid instructions to the binary.

        cat $(dd if=/dev/zero count=1 bs=256) whatever.bin >whatever_with_zeros.bin

4. Open `secure-boot/peripherals/config.py` and locate the `Flash_OS` initialization. The arguments have these meanings:

    * `flash_base`: The memory-mapped address in flash to start copying the OS from. If you are building a bitstream, you want `0x44000000`; otherwise you want `0x44000100` to skip the zeros we inserted in step 3.
    * `ram_base`: The memory-mapped address in RAM to copy the OS to. It is important that this matches the address the OS was linked to load at. The default value that's already there should be fine in most cases.
    * `size`: The number of bytes to copy from flash to RAM; so the size in bytes of `whatever.bin` (not `whatever_with_zeros.bin`).
    * `sha256sum`: The SHA256 hash of the bytes to be copied; so the output of `sha256sum whatever.bin`.
    * `ram_device`: No change should be needed here.

    You should also change `BOOT_ADDRESS` to point to the same place as the `ram_base` argument to the `Flash_OS` initialization stanza.
5. Put the binary into flash memory; the gfe repo has a script in `tcl/program_flash` that will do this for you:

        tcl/program_flash datafile whatever_with_zeros.bin

    (Use `whatever.bin` instead if you are building a bitstream.)

# How to Build a Bitstream with the BootROM
1. Setup your machine to build the GFE, following the instructions in the GFE README.
2. Replace the `bootrom` subdirectory of the GFE with the directory containing this README.
3. Build the bootrom using `env XLEN=64 make` for 64-bit targets and `env XLEN=32 make` for 32-bit targets.
4. Follow the normal GFE instructions for building a bitstream.
5. To test that the secure boot worked successfully, connect to the processor using GDB. After secure boot has finished, the current symbol should be `successful_secure_boot`.

# How to Test the BootROM (without first building a bitstream)
1. Setup your machine to build the GFE, following the instructions in the GFE README.
2. Program an FPGA with a bitstream. The bootrom on it doesn't matter.
4. Build the bootrom using `nix-shell --pure --run make`, setting the `CROSS_COMPILE` environment variable appropriately.
5. Connect to the processor using gdb.
6. Run in GDB:
    1. `add-symbol-file bootrom.elf 0xF0400000`
    2. `restore bootrom.bin binary 0xF0400000`
    3. `set $pc = 0xF0400000`
7. The bootrom is setup, and the processor will resume execution if you run the `continue` command

# How to Run the Assurance Checks
1. Install the [Nix package manager](https://nixos.org/nix/). Nix is available for both Linux and MacOS.
2. Run (from the bootrom directory)
   
   `nix-shell --pure --run 'make clean && env CROSS_COMPILE=riscv64-unknown-elf- make check'` to run the assurance case for the 64-bit bootrom,
   
   or `nix-shell --pure --run 'make clean && env CROSS_COMPILE=riscv32-unknown-elf- make check'` to check the 32-bit assurance case.
3. If it was successful, you should see the message "ALL CHECKS PASSED" appear.
