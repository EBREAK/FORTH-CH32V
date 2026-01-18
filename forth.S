	.option arch,rv32imac_zicsr

	.include "ch32v.S"
	.include "defs.S"
	.include "init.S"
	.include "irq.S"	
	.include "early.S"
	.include "core.S"
	.include "nums.S"
	.include "string.S"
	.include "io.S"
	.include "assembler.S"
	.include "interpret.S"
	.include "timer.S"
	.include "fifo.S"

	.include "qingke.S"
	.include "ch32info.S"

	.include "test.S"

/*
RAP	ra
TOS	a5
RSP	s0
PSP	s1
UP	tp
*/

	.section .text, "ax"
machine_main:
	FC irq_init
	FC early_init

	la a0, user_main
	csrw mepc, a0
	mret

user_main:
	la a0, RUNTIME_LATEST
	sw x0, 0(a0)

	la a0, FORTH_LATEST
	la a1, W_LASTWORD
	sw a1, 0(a0)

	la a0, ASSEMBLER_LATEST
	la a1, W_ALASTWORD
	sw a1, 0(a0)

	la a0, FORTH_CONTEXT

	la a1, RUNTIME_LATEST
	sw a1, (0 * 4)(a0)

	la a1, FORTH_LATEST
	sw a1, (1 * 4)(a0)

	la a1, ASSEMBLER_LATEST
	sw a1, (2 * 4)(a0)

	.section .bss
	.p2align 2, 0
PSTK_ROOT:
	.fill STK_DEPTH, 4, 0
PSTK_ROOT_TOP:
RSTK_ROOT:
	.fill STK_DEPTH, 4, 0
RSTK_ROOT_TOP:
WIB_ROOT:
	.fill WORD_NLEN_MAX + 1, 1, 0

	.section .data, "a"
	.ascii "USER ROOT"
	.p2align 2, 0
USER_ROOT:
	# 0
	.4byte 0
	# 1
	.4byte USER_ROOT
	# 2
	.4byte TOS_INIT
	# 3
	.4byte CODE_ROOT
	# 4
	.4byte PSTK_ROOT_TOP
	# 5 
	.4byte PSTK_ROOT_TOP
	# 6
	.4byte RSTK_ROOT_TOP
	# 7
	.4byte RSTK_ROOT_TOP
	# 8
	.4byte W_EARLY_EMITAVA
	# 9
	.4byte W_EARLY_EMIT
	# 10
	.4byte W_EARLY_KEYAVA
	# 11
	.4byte W_EARLY_KEY
	# 12
	.4byte W_HEXDOT
	# 13
	.4byte WIB_ROOT
	# 14
	.4byte 0 # WIN
	# 15
	.4byte 0 # INTERPRET STATE
	# 16
	.4byte 0 # RESV
	# 17
	.4byte 0 # RESV
	# 18
	.4byte 0 # RESV
	# 19
	.4byte 0 # RESV
	# 20
	.4byte 0 # RESV
	# 21
	.4byte 0 # RESV
	# 22
	.4byte 0 # RESV
	# 23
	.4byte 0 # RESV
	.ascii "USER ROOT END"

	.section .text, "ax"
	la tp, USER_ROOT
	lw a5, USER_TOS(tp)
	lw s0, USER_RSP(tp)
	lw s1, USER_PSP(tp)
	lw ra, USER_RAP(tp)

	jalr zero, ra, 0

CODE_ROOT:
	FC FORTH_SELFTEST

	.section .rodata
MSG_WELCOME:
	.ascii "FORTH ON CH32V"
	.set LEN_MSG_WELCOME, . - MSG_WELCOME
	.section .text, "ax"

	FC W_ULLIT; .4BYTE MSG_WELCOME; FC W_UWLIT; .2BYTE LEN_MSG_WELCOME;
	FC W_TYPE; FC W_CH32_CHIPID; FC W_0X3; FC W_NHEXDOT; FC W_CR;

	la ra, W_INTERPRET_LOOP
	jr ra
