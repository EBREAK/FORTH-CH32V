	LDFW MILLIS, "MILLIS"
	PPUSH a5
	la a0, millis_ticks
	lw a5, 0(a0)
	ret
	ENDW MILLIS
