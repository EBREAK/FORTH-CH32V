CROSS_COMPILE ?= riscv-wch-elf-
CC = $(CROSS_COMPILE)gcc
OD = $(CROSS_COMPILE)objdump
OC = $(CROSS_COMPILE)objcopy
SZ = $(CROSS_COMPILE)size
DB = gdb

CFLAGS += \
	-Os \
	-march=rv32imac_zicsr \
	-mabi=ilp32 \
	-ggdb \
	-nostdlib \
	-T link.ld \
	-static \
	-mno-relax \

# relax is buggy when I move dict to highcode, why? I dont known, so disable it.

elf: clean
	$(CC) $(CFLAGS) forth.S -o forth.elf
	$(OD) -D -s forth.elf > forth.dis
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
