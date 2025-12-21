	.equ IRQ_NUM_MAX, 255

	.section .vector_table
	/* must align with 1KiB, so we put it on sram start */
vector_table:
	.fill IRQ_NUM_MAX, 4, 0
vector_table_end:

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
	li a0, 0x88           
	csrw mstatus, 0

	/* interrupt vector table address & mode */
	la a0, vector_table
	ori a0, a0, 0x3
	csrw mtvec, a0


	ret
