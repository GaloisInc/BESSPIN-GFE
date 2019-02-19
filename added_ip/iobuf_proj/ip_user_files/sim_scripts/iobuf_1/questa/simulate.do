onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib iobuf_1_opt

do {wave.do}

view wave
view structure
view signals

do {iobuf_1.udo}

run -all

quit -force
