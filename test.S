	LDFW PZCHK, "PZCHK"
	li a0, TOS_INIT
	bne a0, a5, 1f
	lw a0, USER_PS0(tp)
	bne s1, a0, 1f
	ret
1:
	li a0, UART1_BASE
	li a1, '#'
	sw a1, R32_UART_DATAR(a0)
	j 1b
	ENDW PZCHK

	LDFW EQCHK, "EQCHK"
	mv a0, a5
	lw a1, 0(s1)
	lw a5, 4(s1)
	addi s1, s1, 8
	bne a0, a1, 1f
	ret
1:
	li a0, UART1_BASE
	li a1, '!'
	sw a1, R32_UART_DATAR(a0)
	j 1b
	ENDW EQCHK

	.section .text, "ax"
FORTH_SELFTEST:
	RPUSH ra

	.include "core_test.S"
	.include "string_test.S"
	.include "io_test.S"
	.include "assembler_test.S"
	.include "interpret_test.S"
	.include "fifo_test.S"

	RPOP ra
	ret
