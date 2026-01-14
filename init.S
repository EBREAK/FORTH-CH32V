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
