define cpu_reset
	print "Reseting the CPU"
	set *(0x6fff0000)=1
end

target remote localhost:3333
cpu_reset
disconnect

target remote localhost:3333
print "Setting a0/a1"
set $a0=0
set $a1 = 0x70000020
print "Loading binary"
load

