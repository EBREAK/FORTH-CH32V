        LDFW CH32_CHIPID, "CH32-CHIPID"
        PPUSH a5
	li a0, 0x1FFFF704
	lw a0, 0(a0)
	srli a5, a0, 20
	li a1, 0xFFF
	and a5, a5, a1
        ret
        ENDW CH32_CHIPID
	
