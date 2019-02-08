vlib work
vlib riviera

vlib riviera/xil_defaultlib

vmap xil_defaultlib riviera/xil_defaultlib

vlog -work xil_defaultlib  -v2k5 \
"../../../../iobuf_0/iobuf.v" \
"../../../../iobuf_0/sim/iobuf_0.v" \


vlog -work xil_defaultlib \
"glbl.v"

