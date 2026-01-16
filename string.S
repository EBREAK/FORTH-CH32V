	LDFW FILL, "FILL"
	lw a0, 4(s1)
	lw a1, 0(s1)
	mv a2, a5
	lw a5, 8(s1)
	addi s1, s1, 12
	beqz a1, 2f
1:
	sb a2, 0(a0)
	addi a0, a0, 1
	addi a1, a1, -1
	bnez a1, 1b
2:
	ret
	ENDW FILL

	LDFW CMOVE, "CMOVE"
	lw a0, 4(s1)
	lw a1, 0(s1)
	mv a2, a5
	lw a5, 8(s1)
	addi s1, s1, 12
	beqz a2, 2f
1:
	lbu a3, 0(a0)
	sb a3, 0(a1)
	addi a0, a0, 1
	addi a1, a1, 1
	addi a2, a2, -1
	bnez a2, 1b
2:
	ret
	ENDW CMOVE

	LDFW COMPARE, "COMPARE"
	lw a0, 8(s1)
	lw a1, 4(s1)
	lw a2, 0(s1)
	mv a3, a5
	addi s1, s1, 12

	/*
	bne a0, a2, 1f
	bne a1, a3, 1f
	li a5, 0
	ret
	*/
1:
	bne a1, a3, 2f
	bnez a1, 2f
	li a5, 0
	ret
2:
	beq a1, a3, 4f
	li a5, -1
	blt a1, a3, 3f
	li a5, 1
3:
	ret
4:
	lbu a3, 0(a0)
	lbu a4, 0(a2)
	beq a3, a4, 6f
	li a5, 1
	bgt a3, a4, 5f
	li a5, -1
5:
	ret
6:
	addi a0, a0, 1
	addi a1, a1, -1
	addi a2, a2, 1
	bnez a1, 4b
	li a5, 0
	ret
	ENDW COMPARE

NUM2HEX_LUT:
	.ascii "0123456789ABCDEF"
	LDFW NUM2HEX, "NUM>HEX"
	andi a5, a5, 0xf
	la a0, NUM2HEX_LUT
	add a5, a0, a5
	lbu a5, 0(a5)
	ret
	ENDW NUM2HEX

	LDFW HEX2NUM, "HEX>NUM"
	li a0, '9'
	ble a5, a0, 1f
	addi a5, a5, -7
1:
	addi a5, a5, -48
	ret
	ENDW HEX2NUM
