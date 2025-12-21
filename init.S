	.section .init
_start:
	.global _start
	.option norvc
	j reset
	.option rvc
1:

	.section .text
reset:
	nop

	.option push 
	.option norelax 
	la gp, __global_pointer$
	.option pop 

	la x16, __mgp_base + 0x7F8
	li a0, (2 * 0x7F8)
	add x17, x16, a0
	add x18, x17, a0
	add x19, x18, a0
	add x20, x19, a0
	add x21, x20, a0
	add x22, x21, a0
	add x23, x22, a0
	add x24, x23, a0
	add x25, x24, a0
	add x26, x25, a0
	add x27, x26, a0
	add x28, x27, a0
	add x29, x28, a0
	add x30, x29, a0
	add x31, x30, a0

	la sp, __stack_end

	la a0, _highcode_lma
	la a1, _highcode_vma_start
	la a2, _highcode_vma_end
	bgeu a1, a2, 2f
1:
	lw a3, 0(a0)
	sw a3, 0(a1)
	addi a0, a0, 4
	addi a1, a1, 4
	bltu a1, a2, 1b
2:


	j machine_main
