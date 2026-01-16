	.section .text, "ax"
early_init:
	la a0, RCC_BASE

disable_all_rcc_irq:
	sw zero, R32_RCC_INTR(a0)

hsi_on:
	lw a1, R32_RCC_CTLR(a0)
	ori a1, a1, RCC_HSION
	sw a1, R32_RCC_CTLR(a0)

wait_hsi_rdy:
	lw a1, R32_RCC_CTLR(a0)
	andi a1, a1, RCC_HSIRDY
	beqz a1, wait_hsi_rdy

sysclk_switch_to_hsi:
	lw a1, R32_RCC_CFGR0(a0)
	andi a1, a1, ~(RCC_SW_MASK)
	ori a1, a1, RCC_SW_HSI
	sw a1, R32_RCC_CFGR0(a0)

wait_sysclk_switch_to_hsi:
	lw a1, R32_RCC_CFGR0(a0)
	andi a1, a1, RCC_SWS_MASK
	li a2, RCC_SWS_HSI
	bne a1, a2, wait_sysclk_switch_to_hsi

	/* SYSCLK: HSI RC 8Mhz */

set_hpre:
	lw a1, R32_RCC_CFGR0(a0)
	andi a1, a1, ~(RCC_HPRE_MASK)
	ori a1, a1, RCC_HPRE_DIV1
	sw a1, R32_RCC_CFGR0(a0)

	/* HCLK: SYSCLK / 1 = 8Mhz */

set_ppre1:
	lw a1, R32_RCC_CFGR0(a0)
	andi a1, a1, ~(RCC_PPRE1_MASK)
	ori a1, a1, RCC_PPRE1_DIV1
	sw a1, R32_RCC_CFGR0(a0)

	/* PB1CLK: HCLK / 1 = 8Mhz */

set_ppre2:
	lw a1, R32_RCC_CFGR0(a0)
	li a2, ~(RCC_PPRE2_MASK)
	and a1, a1, a2
	li a2, RCC_PPRE2_DIV1
	or a1, a1, a2
	sw a1, R32_RCC_CFGR0(a0)

	/* PB2CLK: HCLK / 1 = 8Mhz */

pb1_rst_deassert:
	


pb2_rst_deassert:
	lw a1, R32_RCC_APB2PRSTR(a0)
	li a2, ~(RCC_IOPA | RCC_USART1)
	and a1, a1, a2
	sw a1, R32_RCC_APB2PRSTR(a0)

pb1_clk_enable:

pb2_clk_enable:
	lw a1, R32_RCC_APB2PCENR(a0)
	li a2, RCC_IOPA | RCC_USART1
	or a1, a1, a2
	sw a1, R32_RCC_APB2PCENR(a0)

gpioa_init:
	li a0, GPIOA_BASE
	
usart1_gpio_init:
	lw a1, R32_GPIO_CFGHR(a0)
	li a2, ~((GPIO_MODE_MASK << 4) | (GPIO_MODE_MASK << 8) | (GPIO_MODE_MASK << 16))
	and a1, a1, a2
	li a2, ((GPIO_MODE_MUPPOUT_50M << 4) | (GPIO_MODE_FLOATIN << 8) | (GPIO_MODE_MUPPOUT_50M << 16))
	or a1, a1, a2
	sw a1, R32_GPIO_CFGHR(a0)

	/* PA9  USART1 TX  */
	/* PA10 USART1 RX  */
	/* PA12 USART1 RTS */

usart1_init:
	li a0, UART1_BASE

usart1_reset:
	sw zero, R32_UART_CTLR1(a0)
	sw zero, R32_UART_CTLR2(a0)
	sw zero, R32_UART_CTLR3(a0)
	sw zero, R32_UART_BRR(a0)

usart1_enable:
	li a1, UART_UE
	sw a1, R32_UART_CTLR1(a0)

	lw a1, R32_UART_CTLR1(a0)
	ori a1, a1, UART_TE | UART_RE
	sw a1, R32_UART_CTLR1(a0)

	lw a1, R32_UART_CTLR3(a0)
	ori a1, a1, UART_RTSE
	sw a1, R32_UART_CTLR3(a0)

usart1_set_baud:
	/* UART1 CLK SRC: PB2 */
	.equ UART_BAUD_9600, ((52 << 4) | (1 << 0))
	.equ UART_BAUD_115200, ((4 << 4) | (5 << 0))
	li a1, UART_BAUD_115200
	sw a1, R32_UART_BRR(a0)

chip_id:
	li a0, 0x1FFFF704
	lw a1, 0(a0)
	srli a1, a1, 20
	li a2, 0xFFF
	and a1, a1, a2

chip_is_ch32v307:
	li a2, 0x307
	bne a1, a2, chip_is_ch32v305
	# CH32V307:
	# SRAM MIN SIZE: 32KiB
	# SRAM MAX SIZE; 128KiB
	li sp, (0x20000000 | ((32 * 1024) - 4))
ch32v307_detect_sram_size:
	li a0, 0x4002201C
	lw a0, 0(a0)
	srli a0, a0, 7
	andi a1, a0, 0b110
	bnez a1, 1f
	# SRAM 128KiB
	li sp, (0x20000000 | ((128 * 1024) - 4))
	j chip_id_exit
1:
	li a2, 0b010
	bne a1, a2, 1f
	# SRAM 96KiB
	li sp, (0x20000000 | ((96 * 1024) - 4))
	j chip_id_exit
1:
	li a2, 0b100
	bne a1, a2, 1f
	# SRAM 64KiB
	li sp, (0x20000000 | ((64 * 1024) - 4))
	j chip_id_exit
1:
	andi a1, a0, 0b111
	li a2, 0b110
	bne a1, a2, 1f
	# SRAM 192KiB
	li sp, (0x20000000 | ((192 * 1024) - 4))
	j chip_id_exit
1:
	li a2, 0b111
	bne a1, a2, 1f
	# SRAM 32KiB
	li sp, (0x20000000 | ((32 * 1024) - 4))
	j chip_id_exit
1:


	j chip_id_exit
chip_is_ch32v305:

chip_is_unknown:


chip_id_exit:
	ret
