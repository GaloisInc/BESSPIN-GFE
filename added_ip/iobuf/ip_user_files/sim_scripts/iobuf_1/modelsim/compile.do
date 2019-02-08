vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xil_defaultlib -64 -incr \
"../../../../iobuf_1/iobuf.v" \
"../../../../iobuf_1/sim/iobuf_1.v" \


vlog -work xil_defaultlib \
"glbl.v"

