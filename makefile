# SWITCH TO LLVM, BUT LLVM HAVEN'T RELAX SUPPORT. CAUSE HUGE BINARY SIZE

elf: clean
	#clang --target=riscv32-unknown-elf -static forth.S
	llvm-mc -triple=riscv32 -filetype=obj forth.S -o forth.o
	ld.lld --relax --relax-gp -T link.ld forth.o -o forth.elf
	riscv32-linux-gnu-objdump -a -D -s forth.elf > forth.dis

ocd:
	openocd-wch -f wch-riscv.cfg

db: elf
	gdb

flash: swd-flash

swd-flash:
	wlink flash forth.elf

usb-flash:
	wchisp flash forth.elf

clean:
	rm -vf *.elf *.bin *.out *.dis *.map *.hex
