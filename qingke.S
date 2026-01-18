	LDFW IRQ_ALL_OFF, "IRQ-ALL-OFF"
	li a0, 0x88
	csrc 0x800, a0
	fence.i
	ret
	ENDW IRQ_ALL_OFF

	LDFW IRQ_ALL_ON, "IRQ-ALL-ON"
	li a0, 0x88
	csrs 0x800, a0
	ret
	ENDW IRQ_ALL_ON
