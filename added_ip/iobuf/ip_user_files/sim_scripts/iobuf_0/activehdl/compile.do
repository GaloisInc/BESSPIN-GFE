vlib work
vlib activehdl

vlib activehdl/xil_defaultlib

vmap xil_defaultlib activehdl/xil_defaultlib

vlog -work xil_defaultlib  -v2k5 \
"../../../../iobuf_0/iobuf.v" \
"../../../../iobuf_0/sim/iobuf_0.v" \


vlog -work xil_defaultlib \
"glbl.v"

