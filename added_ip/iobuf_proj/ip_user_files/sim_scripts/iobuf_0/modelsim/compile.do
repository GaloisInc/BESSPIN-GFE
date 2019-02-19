vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xil_defaultlib -64 -incr \
"../../../../iobuf_0/iobuf.v" \
"../../../../iobuf_0/sim/iobuf_0.v" \


vlog -work xil_defaultlib \
"glbl.v"

