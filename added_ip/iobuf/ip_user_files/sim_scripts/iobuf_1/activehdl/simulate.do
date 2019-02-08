onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+iobuf_1 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.iobuf_1 xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {iobuf_1.udo}

run -all

endsim

quit -force
