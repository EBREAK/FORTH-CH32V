	.set W_LASTWORD, 0
	.macro DFW LABEL, NAME
		.section .highcode, "ax"
		.p2align 1, 0
	NAME_\LABEL:
		.ascii "\NAME"
		.set NLEN_\LABEL, . - NAME_\LABEL
		.p2align 1, 0
		.set SHI_BLEN_\LABEL, (BLEN_\LABEL << 8)
		.2byte NLEN_\LABEL | SHI_BLEN_\LABEL
		.set PREV_\LABEL, W_LASTWORD
		.4byte PREV_\LABEL
	W_\LABEL:
		.set W_LASTWORD, W_\LABEL
	.endm

	.macro ENDW LABEL
		.set BLEN_\LABEL, . - W_\LABEL
	.endm

        .macro IDFW LABEL, NAME
                .section .highcode, "ax"
                .p2align 1, 0
        NAME_\LABEL:
                .ascii "\NAME"
                .set NLEN_\LABEL, . - NAME_\LABEL
                .p2align 1, 0
                .set SHI_BLEN_\LABEL, (BLEN_\LABEL << 8)
                .2byte NLEN_\LABEL | SHI_BLEN_\LABEL
                .set PREV_\LABEL, W_LASTWORD
                .4byte PREV_\LABEL + 1 # bit0 is immediate flag
        W_\LABEL:
                .set W_LASTWORD, W_\LABEL
        .endm

        .macro IENDW LABEL
                .set BLEN_\LABEL, . - W_\LABEL
        .endm

	.macro PPUSH reg
		addi s1, s1, -4
		sw \reg, 0(s1)
	.endm

	.macro PPOP reg
		lw \reg, 0(s1)
		addi s1, s1, 4
	.endm

	.macro RPUSH reg
		addi s0, s0, -4
		sw \reg, 0(s0)
	.endm

	.macro RPOP reg
		lw \reg, 0(s0)
		addi s0, s0, 4
	.endm

	.macro FC sym
		call \sym
	.endm

	.macro FT sym
		tail \sym
	.endm

	.section .bss
	.p2align 2, 0
FORTH_LATEST:
	.4BYTE 0x0

	DFW FORTH, "FORTH"
	PPUSH a5
	la a5, FORTH_LATEST
	ret
	ENDW FORTH

	DFW TRUE, "TRUE"
	PPUSH a5
	li a5, FORTH_TRUE
	ret
	ENDW TRUE

	DFW FALSE, "FALSE"
	PPUSH a5
	li a5, FORTH_FALSE
	ret
	ENDW FALSE

	DFW 0BRANCH, "0BRANCH"
	mv a0, a5
	PPOP a5
	beqz a0, 1f
	addi ra, ra, 2
	ret
1:
	lh a0, 0(ra)
	add ra, ra, a0
	ret
	ENDW 0BRANCH

	DFW SWLIT, "SWLIT"
	PPUSH a5
	lh a5, 0(ra)
	addi ra, ra, 2
	ret
	ENDW SWLIT

	DFW UWLIT, "UWLIT"
	PPUSH a5
	lhu a5, 0(ra)
	addi ra, ra, 2
	ret
	ENDW UWLIT

	DFW SLLIT, "SLLIT"
	PPUSH a5
	lhu a5, 0(ra)
	lhu a0, 2(ra)
	slli a0, a0, 16
	or a5, a5, a0
	addi ra, ra, 4
	ret
	ENDW SLLIT

	DFW ULLIT, "ULLIT"
	j W_SLLIT
	ENDW ULLIT

	DFW EXECUTE, "EXECUTE"
	mv a0, a5
	PPOP a5
	jr a0
	ENDW EXECUTE

	DFW PERFORM, "PERFORM"
	lhu a0, 0(a5)
	lhu a1, 2(a5)
	slli a1, a1, 16
	or a0, a0, a1
	PPOP a5
	jr a0
	ENDW PERFORM

	DFW DROP, "DROP"
	PPOP a5
	ret
	ENDW DROP

	DFW DUP, "DUP"
	PPUSH a5
	ret
	ENDW DUP

	DFW SWAP, "SWAP"
	lw a0, 0(s1)
	sw a5, 0(s1)
	mv a5, a0
	ret
	ENDW SWAP

	DFW NIP, "NIP"
	addi s1, s1, 4
	ret
	ENDW NIP

	DFW OVER, "OVER"
	addi s1, s1, -4
	sw a5, 0(s1)
	lw a5, 4(s1)
	ret
	ENDW OVER

	DFW ROT, "ROT"
	lw a0, 0(s1)
	lw a1, 4(s1)
	sw a5, 0(s1)
	sw a0, 4(s1)
	mv a5, a1
	ret
	ENDW ROT

	DFW NROT, "-ROT"
	lw a0, 0(s1)
	lw a1, 4(s1)
	sw a5, 4(s1)
	sw a1, 0(s1)
	mv a5, a0
	ret
	ENDW NROT
	
	DFW TOR, ">R"
	RPUSH a5
	PPOP a5
	ret
	ENDW TOR

	DFW FROMR, "R>"
	PPUSH a5
	RPOP a5
	ret
	ENDW FROMR

	DFW PICK, "PICK"
	slli a5, a5, 2
	add a5, s1, a5
	lw a5, 0(a5)
	ret
	ENDW PICK

	DFW DEPTH, "DEPTH"
	PPUSH a5
	lw a0, USER_PS0(tp)
	sub a5, a0, s1
	srli a5, a5, 2
	addi a5, a5, -1
	ret
	ENDW DEPTH

	DFW 2DROP, "2DROP"
	lw a5, 4(s1)
	addi s1, s1, 8
	ret
	ENDW 2DROP

	DFW 2DUP, "2DUP"
	lw a0, 0(s1)
	addi s1, s1, -8
	sw a0, 0(s1)
	sw a5, 4(s1)
	ret
	ENDW 2DUP

	DFW 2SWAP, "2SWAP"
	lw a0, 0(s1)
	lw a1, 4(s1)
	lw a2, 8(s1)
	sw a2, 0(s1)
	sw a5, 4(s1)
	sw a0, 8(s1)
	mv a5, a1
	ret
	ENDW 2SWAP

	DFW 2NIP, "2NIP"
	lw a0, 0(s1)
	addi s1, s1, 8
	sw a0, 0(s1)
	ret
	ENDW 2NIP

	DFW 2OVER, "2OVER"
	lw a0, 4(s1)
	lw a1, 8(s1)
	addi s1, s1, -8
	sw a5, 4(s1)
	sw a1, 0(s1)
	mv a5, a0
	ret
	ENDW 2OVER

	DFW 2ROT, "2ROT"
	RPUSH ra
	FC W_TOR; FC W_TOR;
	FC W_2SWAP;
	FC W_FROMR; FC W_FROMR;
	FC W_2SWAP;
	RPOP ra
	ret
	ENDW 2ROT

	DFW 2NROT, "2-ROT"
	RPUSH ra
	FC W_2SWAP;
	FC W_TOR; FC W_TOR;
	FC W_2SWAP;
	FC W_FROMR; FC W_FROMR;
	RPOP ra
	ret
	ENDW 2NROT

	DFW 3DROP, "3DROP"
	lw a5, 8(s1)
	addi s1, s1, 12
	ret
	ENDW 3DROP

	DFW 3DUP, "3DUP"
	RPUSH ra
	FC W_DUP
	FC W_2OVER
	FC W_ROT
	RPOP ra
	ret
	ENDW 3DUP

	DFW EQ, "="
	lw a0, 0(s1)
	addi s1, s1, 4
	mv a1, a5
	li a5, FORTH_FALSE
	beq a0, a1, 1f
	ret
1:
	li a5, FORTH_TRUE
	ret
	ENDW EQ

	DFW NE, "<>"
	lw a0, 0(s1)
	addi s1, s1, 4
	mv a1, a5
	li a5, FORTH_FALSE
	bne a0, a1, 1f
	ret
1:
	li a5, FORTH_TRUE
	ret
	ENDW NE

	DFW LT, "<"
	lw a0, 0(s1)
	addi s1, s1, 4
	mv a1, a5
	li a5, FORTH_FALSE
	blt a0, a1, 1f
	ret
1:
	li a5, FORTH_TRUE
	ret
	ENDW LT

	DFW GT, ">"
	lw a0, 0(s1)
	addi s1, s1, 4
	mv a1, a5
	li a5, FORTH_FALSE
	bgt a0, a1, 1f
	ret
1:
	li a5, FORTH_TRUE
	ret
	ENDW GT

	DFW ULT, "U<"
	lw a0, 0(s1)
	addi s1, s1, 4
	mv a1, a5
	li a5, FORTH_FALSE
	bltu a0, a1, 1f
	ret
1:
	li a5, FORTH_TRUE
	ret
	ENDW ULT

	DFW UGT, "U>"
	lw a0, 0(s1)
	addi s1, s1, 4
	mv a1, a5
	li a5, FORTH_FALSE
	bgtu a0, a1, 1f
	ret
1:
	li a5, FORTH_TRUE
	ret
	ENDW UGT

	DFW EQZ, "0="
	mv a0, a5
	li a5, FORTH_FALSE
	beqz a0, 1f
	ret
1:
	li a5, FORTH_TRUE
	ret
	ENDW EQZ

	DFW NEZ, "0<>"
	mv a0, a5
	li a5, FORTH_FALSE
	bnez a0, 1f
	ret
1:
	li a5, FORTH_TRUE
	ret
	ENDW NEZ

	DFW LTZ, "0<"
	mv a0, a5
	li a5, FORTH_FALSE
	bltz a0, 1f
	ret
1:
	li a5, FORTH_TRUE
	ret
	ENDW LTZ

	DFW GTZ, "0>"
	mv a0, a5
	li a5, FORTH_FALSE
	bgtz a0, 1f
	ret
1:
	li a5, FORTH_TRUE
	ret
	ENDW GTZ

	DFW MIN, "MIN"
	lw a0, 0(s1)
	addi s1, s1, 4
	blt a0, a5, 1f
	ret
1:
	mv a5, a0
	ret
	ENDW MIN

	DFW MAX, "MAX"
	lw a0, 0(s1)
	addi s1, s1, 4
	bgt a0, a5, 1f
	ret
1:
	mv a5, a0
	ret
	ENDW MAX

	DFW UMIN, "UMIN"
	lw a0, 0(s1)
	addi s1, s1, 4
	bltu a0, a5, 1f
	ret
1:
	mv a5, a0
	ret
	ENDW UMIN

	DFW UMAX, "UMAX"
	lw a0, 0(s1)
	addi s1, s1, 4
	bgtu a0, a5, 1f
	ret
1:
	mv a5, a0
	ret
	ENDW UMAX

	DFW PLUS, "+"
	PPOP a0
	add a5, a0, a5
	ret
	ENDW PLUS

	DFW MINUS, "-"
	PPOP a0
	sub a5, a0, a5
	ret
	ENDW MINUS

	DFW MULTI, "*"
	PPOP a0
	mul a5, a0, a5
	ret
	ENDW MULTI

	DFW DIVID, "/"
	PPOP a0
	div a5, a0, a5
	ret
	ENDW DIVID

	DFW MOD, "MOD"
	PPOP a0
	rem a5, a0, a5
	ret
	ENDW MOD

	DFW AND, "AND"
	PPOP a0
	and a5, a0, a5
	ret
	ENDW AND

	DFW OR, "OR"
	PPOP a0
	or a5, a0, a5
	ret
	ENDW OR

	DFW XOR, "XOR"
	PPOP a0
	xor a5, a0, a5
	ret
	ENDW XOR

	DFW LSHIFT, "LSHIFT"
	PPOP a0
	sll a5, a0, a5
	ret
	ENDW LSHIFT

	DFW RSHIFT, "RSHIFT"
	PPOP a0
	srl a5, a0, a5
	ret
	ENDW RSHIFT

	DFW INVERT, "INVERT"
	xori a5, a5, -1
	ret
	ENDW INVERT

	DFW NEGATE, "NEGATE"
	xori a5, a5, -1
	addi a5, a5, 1
	ret
	ENDW NEGATE

	DFW 1PLUS, "1+"
	addi a5, a5, 1
	ret
	ENDW 1PLUS

	DFW 2PLUS, "2+"
	addi a5, a5, 2
	ret
	ENDW 2PLUS

	DFW 4PLUS, "4+"
	addi a5, a5, 4
	ret
	ENDW 4PLUS

	DFW 1MINUS, "1-"
	addi a5, a5, -1
	ret
	ENDW 1MINUS

	DFW 2MINUS, "2-"
	addi a5, a5, -2
	ret
	ENDW 2MINUS

	DFW 4MINUS, "4-"
	addi a5, a5, -4
	ret
	ENDW 4MINUS

	DFW 2MULTI, "2*"
	slli a5, a5, 1
	ret
	ENDW 2MULTI

	DFW 4MULTI, "4*"
	slli a5, a5, 2
	ret
	ENDW 4MULTI

	DFW 2DIVID, "2/"
	srli a5, a5, 1
	ret
	ENDW 2DIVID

	DFW 4DIVID, "4/"
	srli a5, a5, 2
	ret
	ENDW 4DIVID

	DFW ABS, "ABS"
	bltz a5, 1f
	ret
1:
	xori a5, a5, -1
	addi a5, a5, 1
	ret
	ENDW ABS

	DFW CLOAD, "C@"
	lbu a5, 0(a5)
	ret
	ENDW CLOAD

	DFW WLOAD, "W@"
	andi a0, a5, 0x1
	bnez a0, 1f
	lhu a5, 0(a5)
	ret
1:
	lbu a0, 0(a5)
	lbu a1, 1(a5)
	slli a1, a1, 8
	or a5, a0, a1
	ret
	ENDW WLOAD

	DFW LLOAD, "L@"
	andi a0, a5, 0x3
	bnez a0, 1f
	lw a5, 0(a5)
	ret
1:
	andi a0, a5, 0x1
	bnez a0, 2f
	lhu a0, 0(a5)
	lhu a1, 2(a5)
	slli a1, a1, 16
	or a5, a0, a1
	ret
2:
	lbu a0, 0(a5)
	lbu a1, 1(a5)
	slli a1, a1, 8
	or a0, a0, a1
	lbu a1, 2(a5)
	slli a1, a1, 16
	or a0, a0, a1
	lbu a1, 3(a5)
	slli a1, a1, 24
	or a5, a0, a1
	ret
	ENDW LLOAD

	DFW LOAD, "@"
	j W_LLOAD
	ENDW LOAD

	.section .data, "a"
	.p2align 2, 0
FORTH_DP:
	.4byte _bss_end
	.section .text, "ax"

	DFW DP, "DP"
	PPUSH a5
	la a5, FORTH_DP
	ret
	ENDW DP

	DFW HERE, "HERE"
	RPUSH ra
	FC W_DP; FC W_LOAD;
	RPOP ra
	ret
	ENDW HERE

	DFW PAD, "PAD"
	RPUSH ra
	FC W_HERE; FC W_UWLIT; .2BYTE 256; FC W_PLUS;
	RPOP ra
	ret
	ENDW PAD

	DFW CSTORE, "C!"
	lw a0, 0(s1)
	sb a0, 0(a5)
	lw a5, 4(s1)
	addi s1, s1, 8
	ret
	ENDW CSTORE

	DFW WSTORE, "W!"
	lw a0, 0(s1)
	mv a1, a5
	lw a5, 4(s1)
	addi s1, s1, 8
	andi a2, a1, 0x1
	bnez a2, 1f
	sh a0, 0(a1)
	ret
1:
	sb a0, 0(a1)
	srli a0, a0, 8
	sb a0, 1(a1)
	ret
	ENDW WSTORE

	DFW LSTORE, "L!"
	lw a0, 0(s1)
	mv a1, a5
	lw a5, 4(s1)
	addi s1, s1, 8
	andi a2, a1, 0x3
	bnez a2, 1f
	sw a0, 0(a1)
	ret
1:
	andi a2, a1, 0x1
	bnez a2, 2f
	sh a0, 0(a1)
	srli a0, a0, 16
	sh a0, 2(a1)
	ret
2:
	sb a0, 0(a1)
	srli a0, a0, 8
	sb a0, 1(a1)
	srli a0, a0, 8
	sb a0, 2(a1)
	srli a0, a0, 8
	sb a0, 3(a1)
	ret
	ENDW LSTORE

	DFW STORE, "!"
	j W_LSTORE
	ENDW STORE

	DFW WALIGNED, "WALIGNED"
	addi a5, a5, 1
	andi a5, a5, -2
	ret
	ENDW WALIGNED

	DFW LALIGNED, "LALIGNED"
	addi a5, a5, 3
	andi a5, a5, -4
	ret
	ENDW LALIGNED

	DFW CELL, "CELL"
	j W_0X4
	ENDW CELL

	DFW CELLS, "CELLS"
	j W_4MULTI
	ENDW CELLS

	DFW UPLOAD, "UP@"
	PPUSH a5
	mv a5, tp
	ret
	ENDW UPLOAD

	DFW PAUSE, "PAUSE"
	sw a5, USER_TOS(tp)
	sw ra, USER_RAP(tp)
	sw s1, USER_PSP(tp)
	sw s0, USER_RSP(tp)
	lw tp, USER_NXT(tp)
	lw a5, USER_TOS(tp)
	lw ra, USER_RAP(tp)
	lw s1, USER_PSP(tp)
	lw s0, USER_RSP(tp)
	ret
	ENDW PAUSE

	DFW USER_EMITAVA, "USER-EMIT?"
	PPUSH a5
	li a5, USER_EMITAVA
	ret
	ENDW USER_EMITAVA

	DFW USER_EMIT, "USER-EMIT"
	PPUSH a5
	li a5, USER_EMIT
	ret
	ENDW USER_EMIT

	DFW USER_KEYAVA, "USER-KEY?"
	PPUSH a5
	li a5, USER_KEYAVA
	ret
	ENDW USER_KEYAVA

	DFW USER_KEY, "USER-KEY"
	PPUSH a5
	li a5, USER_KEY
	ret
	ENDW USER_KEY

	DFW USER_DOT, "USER-."
	PPUSH a5
	li a5, USER_DOT
	ret
	ENDW USER_DOT

	DFW ON, "ON"
	RPUSH ra
	FC W_TRUE; FC W_SWAP; FC W_STORE;
	RPOP ra
	ret
	ENDW ON

	DFW OFF, "OFF"
	RPUSH ra
	FC W_FALSE; FC W_SWAP; FC W_STORE;
	RPOP ra
	ret
	ENDW OFF

	DFW ALLOT, "ALLOT"
	RPUSH ra
	FC W_HERE; FC W_PLUS; FC W_DP; FC W_STORE;
	RPOP ra
	ret
	ENDW ALLOT

	DFW CCOMMA, "C,"
	RPUSH ra
	FC W_HERE; FC W_CSTORE; FC W_0X1; FC W_ALLOT;
	RPOP ra
	ret
	ENDW CCOMMA

	DFW WCOMMA, "W,"
	RPUSH ra
	FC W_HERE; FC W_WSTORE; FC W_0X2; FC W_ALLOT;
	RPOP ra
	ret
	ENDW WCOMMA

	DFW LCOMMA, "L,"
	RPUSH ra
	FC W_HERE; FC W_LSTORE; FC W_0X4; FC W_ALLOT;
	RPOP ra
	ret
	ENDW LCOMMA

	DFW COMMA, ","
	j W_LCOMMA
	ENDW COMMA

	DFW WALIGN, "WALIGN"
	RPUSH ra
	FC W_HERE; FC W_WALIGNED; FC W_DP; FC W_STORE;
	RPOP ra
	ret
	ENDW WALIGN

	DFW LALIGN, "LALIGN"
	RPUSH ra
	FC W_HERE; FC W_LALIGNED; FC W_DP; FC W_STORE;
	RPOP ra
	ret
	ENDW LALIGN
