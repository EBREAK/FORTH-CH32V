CROSS_COMPILE ?= riscv-wch-elf-
CC = $(CROSS_COMPILE)gcc
OD = $(CROSS_COMPILE)objdump
OC = $(CROSS_COMPILE)objcopy
SZ = $(CROSS_COMPILE)size
DB = $(CROSS_COMPILE)gdb

CFLAGS += \
	-Os \
	-march=rv32imac_zicsr \
	-mabi=ilp32 \
	-ggdb \
	-nostdlib \
	-T link.ld \
	-static \

elf: clean
	$(CC) $(CFLAGS) forth.S -o forth.elf
	$(OD) -d -s forth.elf > forth.dis
	$(OC) -O binary forth.elf forth.bin
	$(OC) -O ihex forth.elf forth.hex
	$(SZ) forth.elf

ocd:
	openocd-wch -f wch-riscv.cfg

db: elf
	$(DB)

flash:
	wlink flash forth.elf

clean:
	rm -vf *.elf *.bin *.out *.dis *.map *.hex
