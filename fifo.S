	.set FIFO8_BUFF, 0
	.set FIFO8_SIZE, 4
	.set FIFO8_HEAD, 8
	.set FIFO8_NUM, 12

	LDFW FIFO8_BUFF, "FIFO8-BUFF"
	PPUSH a5
	li a5, FIFO8_BUFF
	ret
	ENDW FIFO8_BUFF

	LDFW FIFO8_SIZE, "FIFO8-SIZE"
	PPUSH a5
	li a5, FIFO8_SIZE
	ret
	ENDW FIFO8_SIZE

	LDFW FIFO8_HEAD, "FIFO8-HEAD"
	PPUSH a5
	li a5, FIFO8_HEAD
	ret
	ENDW FIFO8_HEAD

	LDFW FIFO8_NUM, "FIFO8-NUM"
	PPUSH a5
	li a5, FIFO8_NUM
	ret
	ENDW FIFO8_NUM

	LDFW FIFO8_RESET, "FIFO8-RESET"
	# ( FIFO8-CTX -- )
	sw zero, FIFO8_HEAD(a5)
	sw zero, FIFO8_NUM(a5)
	PPOP a5
	ret
	ENDW FIFO8_RESET

	LDFW FIFO8_NUM_USED, "FIFO8-NUM-USED"
	# ( FIFO8-CTX -- COUNT )
	lw a5, FIFO8_NUM(a5)
	ret
	ENDW FIFO8_NUM_USED

	LDFW FIFO8_NUM_FREE, "FIFO8-NUM-FREE"
	# ( FIFO8-CTX -- COUNT )
	lw a0, FIFO8_SIZE(a5)
	lw a1, FIFO8_NUM(a5)
	sub a5, a0, a1
	ret
	ENDW FIFO8_NUM_FREE

	LDFW FIFO8_PUSH, "FIFO8-PUSH"
	# ( C FIFO8-CTX -- )
	lw a0, FIFO8_HEAD(a5)
	lw a1, FIFO8_NUM(a5)
	add a0, a1, a0
	lw a1, FIFO8_SIZE(a5)
	rem a0, a0, a1
	lw a1, FIFO8_BUFF(a5)
	add a0, a0, a1
	lbu a1, 0(s1)
	sb a1, 0(a0)
	add a5, a5, FIFO8_NUM
	li a0, 1
	amoadd.w a0, a0, (a5)
	lw a5, 4(s1)
	addi s1, s1, 8
	ret
	ENDW FIFO8_PUSH

	LDFW FIFO8_POP, "FIFO8-POP"
	# ( FIFO8-CTX -- C )
	mv a4, a5
	lw a0, FIFO8_HEAD(a4)
	lw a2, FIFO8_SIZE(a4)
	rem a0, a0, a2
	lw a1, FIFO8_BUFF(a4)
	add a0, a0, a1
	lbu a5, 0(a0)
	lw a0, FIFO8_HEAD(a4)
	add a0, a0, 1
	rem a0, a0, a2
	sw a0, FIFO8_HEAD(a4)
	add a0, a4, FIFO8_NUM
	li a1, -1
	amoadd.w a1, a1, (a0)
	ret
	ENDW FIFO8_POP

	LDFW FIFO8_IS_FULL, "FIFO8-FULL?"
	# ( FIFO8-CTX -- FLAG )
	lw a0, FIFO8_NUM(a5)
	lw a1, FIFO8_SIZE(a5)
	li a5, FORTH_TRUE
	bge a0, a1, 1f
	li a5, FORTH_FALSE
1:
	ret
	ENDW FIFO8_IS_FULL

	LDFW FIFO8_IS_EMPTY, "FIFO8-EMPTY?"
	# ( FIFO8-CTX -- FLAG )
	lw a0, FIFO8_NUM(a5)
	li a5, FORTH_TRUE
	beqz a0, 1f
	li a5, FORTH_FALSE
1:
	ret
	ENDW FIFO8_IS_EMPTY
