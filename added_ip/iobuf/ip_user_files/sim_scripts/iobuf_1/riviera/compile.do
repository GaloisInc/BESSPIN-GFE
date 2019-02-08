vlib work
vlib riviera

vlib riviera/xil_defaultlib

vmap xil_defaultlib riviera/xil_defaultlib

vlog -work xil_defaultlib  -v2k5 \
"../../../../iobuf_1/iobuf.v" \
"../../../../iobuf_1/sim/iobuf_1.v" \


vlog -work xil_defaultlib \
"glbl.v"

