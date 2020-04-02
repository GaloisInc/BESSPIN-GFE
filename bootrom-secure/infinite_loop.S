// the source file for the binary padding; it was compiled into "padding-32.bin"
// and "padding-64.bin" using these commands:
//
// 
// riscv64-unknown-elf-gcc -O0 -g3 -march=rv64imac -mabi=lp64 -o infinite_loop.o infinite_loop.S
// riscv64-unknown-elf-objcopy -O binary infinite_loop.o infinite_loop_64.bin
// riscv64-unknown-elf-gcc -O0 -g3 -march=rv32im -mabi=ilp32 -c -o infinite_loop.o infinite_loop.S
// riscv64-unknown-elf-objcopy -O binary infinite_loop.o infinite_loop_32.bin
//
// and then each of the "*.bin" files was padded to 128 bytes by adding null bytes
// to the end

        lui a3, 0
loop:
        auipc a4, 0
        addi a3, a3, 1
        jalr a5, a4, 0
