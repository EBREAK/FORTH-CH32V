# SWITCH TO LLVM, BUT LLVM HAVEN'T RELAX SUPPORT. CAUSE HUGE BINARY SIZE

elf: elf-llvm
	riscv-none-elf-objdump -a -D -s forth.elf > forth.dis

elf-llvm: clean
	llvm-mc -triple=riscv32 -filetype=obj forth.S -o forth.o
	ld.lld -T link.ld forth.o -o forth.elf

elf-gas: clean
	riscv-none-elf-gcc -T link.ld -static -march=rv32imac_zicsr -mabi=ilp32 -nostdlib -nostartfiles -ggdb -mno-relax forth.S -o forth.elf

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
	rm -vf *.elf *.bin *.out *.dis *.map *.hex *.o

linux-sender:
	cc -Wall -Wextra -O2 sender.c -o sender
