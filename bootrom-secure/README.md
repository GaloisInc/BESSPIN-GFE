# How to Build a Bitstream with the BootROM
1. Setup your machine to build the GFE, following the instructions in the GFE README.
2. Replace the `bootrom` subdirectory of the GFE with the directory containing this README.
3. Build the bootrom using `env CROSS_COMPILE=riscv64-unknown-elf- make` for 64-bit targets and `env CROSS_COMPILE=riscv32-unknown-elf- make` for 32-bit targets.
4. Follow the normal GFE instructions for building a bitstream.
5. To test that the secure boot worked successfully, connect to the processor using GDB. After secure boot has finished, the current symbol should be `successful_secure_boot`.

# How to Test the BootROM (without first building a bitstream)
1. Setup your machine to build the GFE, following the instructions in the GFE README.
2. Program an FPGA with a bitstream. The bootrom on it doesn't matter.
3. Modify the `linker.ld` file. Comment out the "FOR PRODUCTION" line and uncomment the "TESTING" line.
4. Build the bootrom using `make`, setting the `CROSS_COMPILE` environment variable appropriately.
5. Connect to the processor using gdb.
6. Run in GDB:
    1. `add-symbol-file bootrom.elf 0x80400000`
    2. `restore bootrom.bin binary 0x80400000`
    3. `set $pc = 0x80400000`
7. The bootrom is setup, and the processor will resume execution if you run the `continue` command

# How to Run the Assurance Checks
1. Install the [Nix package manager](https://nixos.org/nix/). Nix is available for both Linux and MacOS.
2. Run (from the bootrom directory)
   
   `nix-shell --pure --run 'make clean && env CROSS_COMPILE=riscv64-unknown-elf- make check'` to run the assurance case for the 64-bit bootrom,
   
   or `nix-shell --pure --run 'make clean && env CROSS_COMPILE=riscv32-unknown-elf- make check'` to check the 32-bit assurance case.
3. If it was successful, you should see the message "ALL CHECKS PASSED" appear.
