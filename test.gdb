# -*- gdb-script -*-

set remotetimeout 5000
set remotelogfile gdb-remote.log
set logging overwrite
set logging file gdb-client.log
set logging on
set pagination off

define broken_reset
  set *((int *) 0x6FFF0000) = 1
end

target remote | openocd --debug --log_output openocd.log --command "gdb_port pipe"  --command "gdb_report_data_abort enable" --file testing/targets/ssith_gfe.cfg
#target remote | openocd --log_output openocd.log --command "gdb_port pipe" --command "gdb_report_data_abort enable" --file testing/targets/ssith_gfe.cfg

#broken_reset
#monitor reset halt

set $a0=0
set $a1=0x70000020

#restore bootrom/bootrom.img binary 0xc01000000
#set $a1=0xc0100020

#file riscv-tests/isa/rv64ui-p-simple

file bootmem/build-bbl/bbl

# todo: fix load addresses
#add-symbol-file bootmem/build-bbl/bbl
add-symbol-file bootmem/build-linux/vmlinux
#add-symbol-file bootmem/build-busybox/busybox_unstripped

#load
#continue

#break write_tohost

# info registers
