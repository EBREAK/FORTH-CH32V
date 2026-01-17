	.equ IRQ_NUM_MAX, 255

	.section .vector_table
	/* must align with 1KiB, so we put it on sram start */
vector_table:
	.fill IRQ_NUM_MAX, 4, 0
vector_table_end:

	.section .text, "ax"
isr_putchar:
	addi sp, sp, -8
	sw a1, 0(sp)
	sw a2, 4(sp)
	li a1, UART1_BASE
1:
	lw a2, R32_UART_STATR(a1)
	andi a2, a2, UART_TC
	beqz a2, 1b
	sw a0, R32_UART_DATAR(a1)
	lw a1, 0(sp)
	lw a2, 4(sp)
	addi sp, sp, 8
	ret

isr_puts:
	addi sp, sp, -8
	sw ra, 0(sp)
	sw a1, 4(sp)
	mv a1, a0
1:
	lbu a0, 0(a1)
	beqz a0, 2f
	call isr_putchar
	addi a1, a1, 1
	j 1b
2:
	lw ra, 0(sp)
	lw a1, 4(sp)
	addi sp, sp, 8
	ret

isr_puthex:
	addi sp, sp, -16
	sw ra, 0(sp)
	sw a1, 4(sp)
	sw a2, 8(sp)
	sw a3, 12(sp)

	mv a1, a0
	li a2, 28
	la a3, NUM2HEX_LUT
1:
	srl a0, a1, a2
	andi a0, a0, 0xF
	add a0, a0, a3
	lbu a0, 0(a0)
	call isr_putchar
	addi a2, a2, -4
	bgez a2, 1b

	lw ra, 0(sp)
	lw a1, 4(sp)
	lw a2, 8(sp)
	lw a3, 12(sp)
	addi sp, sp, 16
	ret

isr_dump_regs:
	addi sp, sp, -8
	sw ra, 0(sp)
	sw a0, 4(sp)

	la a0, MSG_MCAUSE_DUMP
	call isr_puts
	csrr a0, mcause
	call isr_puthex
	la a0, MSG_CR
	call isr_puts

	la a0, MSG_MEPC_DUMP
	call isr_puts
	csrr a0, mepc
	call isr_puthex
	la a0, MSG_CR
	call isr_puts

	la a0, MSG_MTVAL_DUMP
	call isr_puts
	csrr a0, mtval
	call isr_puthex
	la a0, MSG_CR
	call isr_puts

	lw ra, 0(sp)
	lw a0, 4(sp)
	addi sp, sp, -8
	ret

unhandled_irq_handler:
	la a0, MSG_IRQ_UNHANDLED
	call isr_puts
	call isr_dump_regs
1:	j 1b

	.section .rodata
MSG_IRQ_UNHANDLED:
	.asciz "\r\nUNHANDLED IRQ\r\n"
MSG_MCAUSE_DUMP:
	.asciz "MCAUSE: "
MSG_MEPC_DUMP:
	.asciz "MEPC: "
MSG_MTVAL_DUMP:
	.asciz "MTVAL: "
MSG_CR:
	.asciz "\r\n"

	.section .text
irq_init:
	/* disable all irq */
	la a0, PFIC_BASE
	li a1, 0xFFFFFFFF
	sw a1, R32_PFIC_IRER1(a0)
	sw a1, R32_PFIC_IRER2(a0)
	sw a1, R32_PFIC_IRER3(a0)
	sw a1, R32_PFIC_IRER4(a0)

	/* interrupt hardware stack */
	li a0, 0x1
	csrw 0x804, a0

	/* Enable global interrupt, configure privileged mode */
	li a0, (0 << 11) | (1 << 3) | (1 << 7)
	csrw mstatus, a0

	/* interrupt vector table address & mode */
	la a0, vector_table
	ori a0, a0, 0x3
	csrw mtvec, a0

	/* fill irq vector table */
	la a0, vector_table
	la a1, vector_table_end
	la a2, unhandled_irq_handler
	bgeu a0, a1, 2f
1:
	sw a2, 0(a0)
	addi a0, a0, 4
	bltu a0, a1, 1b
2:

systick_irq_init:
	la a0, vector_table
	la a1, systick_irq_handler
	sw a1, (IRQN_SYSTICK * 4)(a0)

	la a0, millis_ticks
	sw x0, 0(a0)

	la a0, PFIC_BASE
	li a1, (1 << IRQN_SYSTICK)
	sw a1, R32_PFIC_IENR1(a0)

	ret

	.section .bss
	.p2align 2, 0
millis_ticks:
	.4byte 0x0

	.section .text
systick_irq_handler:
	la a0, SYSTICK_BASE
	sw zero, R32_STK_SR(a0)
	la a0, millis_ticks
	li a1, 1
	amoadd.w a0, a1, 0(a0)
	# call isr_puthex
	mret
