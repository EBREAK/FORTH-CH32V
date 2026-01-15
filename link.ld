ENTRY(_start)

MEMORY {
	/* min flash: ch32v203 32  KiB */
	/* max flash: ch32v307 480 KiB */
	FLASH (rx)  : ORIGIN = 0x00000000, LENGTH = 128K
	/* min sram: ch32v203 10  KiB */
	/* max sram: ch32v307 128 KiB */
	SRAM (rwx) : ORIGIN = 0x20000000, LENGTH = 20K
}

SECTIONS {
	.init :
	{
		. = ALIGN(4);
		KEEP(*(SORT_NONE(.init)))
		. = ALIGN(4);
	} >FLASH AT>FLASH

	.highcodelalign :  
	{
		. = ALIGN(4);
		PROVIDE(_highcode_lma = .); 
	} >FLASH AT>FLASH

	.highcode :
	{
		. = ALIGN(4);
		PROVIDE(_highcode_vma_start = .);
		*(.vector_table)
		*(.highcode);
		*(.highcode*);
		*(.data)
		*(.data*)
		. = ALIGN(4);
		PROVIDE(_highcode_vma_end = .);
	} >SRAM AT>FLASH

	.text :
	{
		. = ALIGN(4);
		*(.text)
		*(.text*)
		*(.rodata)
		*(.rodata*)
		. = ALIGN(4);
	} >FLASH AT>FLASH

	.bss :
	{
		. = ALIGN(4);
		PROVIDE(_bss_start = .);
		*(.sbss)
		*(.sbss*)
		*(.bss)
		*(.bss*)
		*(.COMMON)
		*(.COMMON*)
		. = ALIGN(4);
		PROVIDE(_bss_end = .);
	} >SRAM AT>FLASH

	PROVIDE(__global_pointer$ = ORIGIN(SRAM) + 0x7F8);
	PROVIDE(__stack_end = ORIGIN(SRAM) + LENGTH(SRAM));
}
