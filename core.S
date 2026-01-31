	.set W_LASTWORD, 0
	.macro HDFW LABEL, NAME
		.section .highcode, "ax"
		.p2align 1, 0
	NAME_\LABEL:
		.ascii "\NAME"
		.set NLEN_\LABEL, . - NAME_\LABEL
		.p2align 1, 0
		.set SHI_BLEN_\LABEL, ((BLEN_\LABEL / 2) << 8)
		.2byte NLEN_\LABEL | SHI_BLEN_\LABEL
		.set PREV_\LABEL, W_LASTWORD
		.4byte PREV_\LABEL
	W_\LABEL:
		.set W_LASTWORD, W_\LABEL
	.endm

	.macro LDFW LABEL, NAME
		.section .text, "ax"
		.p2align 1, 0
	NAME_\LABEL:
		.ascii "\NAME"
		.set NLEN_\LABEL, . - NAME_\LABEL
		.p2align 1, 0
		.set SHI_BLEN_\LABEL, ((BLEN_\LABEL / 2) << 8)
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
                .section .text, "ax"
                .p2align 1, 0
        NAME_\LABEL:
                .ascii "\NAME"
                .set NLEN_\LABEL, . - NAME_\LABEL
                .p2align 1, 0
                .set SHI_BLEN_\LABEL, ((BLEN_\LABEL / 2) << 8)
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

	.macro NC sym
		jal ra, \sym
	.endm

	.macro NT sym
		jal x0, \sym
	.endm

	.section .bss
	.p2align 2, 0
FORTH_LATEST:
	.4BYTE 0x0

	HDFW FORTH, "FORTH"
	PPUSH a5
	la a5, FORTH_LATEST
	ret
	ENDW FORTH

	HDFW NOOP, "NOOP"
	ret
	ENDW NOOP

	HDFW TRUE, "TRUE"
	PPUSH a5
	li a5, FORTH_TRUE
	ret
	ENDW TRUE

	HDFW FALSE, "FALSE"
	PPUSH a5
	li a5, FORTH_FALSE
	ret
	ENDW FALSE

	HDFW 0BRANCH, "0BRANCH"
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

	HDFW SWLIT, "SWLIT"
	PPUSH a5
	lh a5, 0(ra)
	addi ra, ra, 2
	ret
	ENDW SWLIT

	HDFW UWLIT, "UWLIT"
	PPUSH a5
	lhu a5, 0(ra)
	addi ra, ra, 2
	ret
	ENDW UWLIT

	HDFW SLLIT, "SLLIT"
	PPUSH a5
	lhu a5, 0(ra)
	lhu a0, 2(ra)
	slli a0, a0, 16
	or a5, a5, a0
	addi ra, ra, 4
	ret
	ENDW SLLIT

	HDFW ULLIT, "ULLIT"
	j W_SLLIT
	ENDW ULLIT

	HDFW EXECUTE, "EXECUTE"
	mv a0, a5
	PPOP a5
	jr a0
	ENDW EXECUTE

	HDFW PERFORM, "PERFORM"
	lhu a0, 0(a5)
	lhu a1, 2(a5)
	slli a1, a1, 16
	or a0, a0, a1
	PPOP a5
	jr a0
	ENDW PERFORM

	HDFW DROP, "DROP"
	PPOP a5
	ret
	ENDW DROP

	HDFW DUP, "DUP"
	PPUSH a5
	ret
	ENDW DUP

	HDFW SWAP, "SWAP"
	lw a0, 0(s1)
	sw a5, 0(s1)
	mv a5, a0
	ret
	ENDW SWAP

	HDFW NIP, "NIP"
	addi s1, s1, 4
	ret
	ENDW NIP

	HDFW OVER, "OVER"
	addi s1, s1, -4
	sw a5, 0(s1)
	lw a5, 4(s1)
	ret
	ENDW OVER

	HDFW ROT, "ROT"
	lw a0, 0(s1)
	lw a1, 4(s1)
	sw a5, 0(s1)
	sw a0, 4(s1)
	mv a5, a1
	ret
	ENDW ROT

	HDFW NROT, "-ROT"
	lw a0, 0(s1)
	lw a1, 4(s1)
	sw a5, 4(s1)
	sw a1, 0(s1)
	mv a5, a0
	ret
	ENDW NROT
	
	HDFW TOR, ">R"
	RPUSH a5
	PPOP a5
	ret
	ENDW TOR

	HDFW FROMR, "R>"
	PPUSH a5
	RPOP a5
	ret
	ENDW FROMR

	HDFW PICK, "PICK"
	slli a5, a5, 2
	add a5, s1, a5
	lw a5, 0(a5)
	ret
	ENDW PICK

	HDFW DEPTH, "DEPTH"
	PPUSH a5
	lw a0, USER_PS0(tp)
	sub a5, a0, s1
	srli a5, a5, 2
	addi a5, a5, -1
	ret
	ENDW DEPTH

	HDFW 2DROP, "2DROP"
	lw a5, 4(s1)
	addi s1, s1, 8
	ret
	ENDW 2DROP

	HDFW 2DUP, "2DUP"
	lw a0, 0(s1)
	addi s1, s1, -8
	sw a0, 0(s1)
	sw a5, 4(s1)
	ret
	ENDW 2DUP

	HDFW 2SWAP, "2SWAP"
	lw a0, 0(s1)
	lw a1, 4(s1)
	lw a2, 8(s1)
	sw a2, 0(s1)
	sw a5, 4(s1)
	sw a0, 8(s1)
	mv a5, a1
	ret
	ENDW 2SWAP

	HDFW 2NIP, "2NIP"
	lw a0, 0(s1)
	addi s1, s1, 8
	sw a0, 0(s1)
	ret
	ENDW 2NIP

	HDFW 2OVER, "2OVER"
	lw a0, 4(s1)
	lw a1, 8(s1)
	addi s1, s1, -8
	sw a5, 4(s1)
	sw a1, 0(s1)
	mv a5, a0
	ret
	ENDW 2OVER

	HDFW 2ROT, "2ROT"
	RPUSH ra
	NC W_TOR; NC W_TOR;
	NC W_2SWAP;
	NC W_FROMR; NC W_FROMR;
	NC W_2SWAP;
	RPOP ra
	ret
	ENDW 2ROT

	HDFW 2NROT, "2-ROT"
	RPUSH ra
	NC W_2SWAP;
	NC W_TOR; NC W_TOR;
	NC W_2SWAP;
	NC W_FROMR; NC W_FROMR;
	RPOP ra
	ret
	ENDW 2NROT

	HDFW 3DROP, "3DROP"
	lw a5, 8(s1)
	addi s1, s1, 12
	ret
	ENDW 3DROP

	HDFW 3DUP, "3DUP"
	RPUSH ra
	NC W_DUP
	NC W_2OVER
	NC W_ROT
	RPOP ra
	ret
	ENDW 3DUP

	HDFW EQ, "="
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

	HDFW NE, "<>"
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

	HDFW LT, "<"
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

	HDFW GT, ">"
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

	HDFW ULT, "U<"
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

	HDFW UGT, "U>"
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

	HDFW EQZ, "0="
	mv a0, a5
	li a5, FORTH_FALSE
	beqz a0, 1f
	ret
1:
	li a5, FORTH_TRUE
	ret
	ENDW EQZ

	HDFW NEZ, "0<>"
	mv a0, a5
	li a5, FORTH_FALSE
	bnez a0, 1f
	ret
1:
	li a5, FORTH_TRUE
	ret
	ENDW NEZ

	HDFW LTZ, "0<"
	mv a0, a5
	li a5, FORTH_FALSE
	bltz a0, 1f
	ret
1:
	li a5, FORTH_TRUE
	ret
	ENDW LTZ

	HDFW GTZ, "0>"
	mv a0, a5
	li a5, FORTH_FALSE
	bgtz a0, 1f
	ret
1:
	li a5, FORTH_TRUE
	ret
	ENDW GTZ

	HDFW MIN, "MIN"
	lw a0, 0(s1)
	addi s1, s1, 4
	blt a0, a5, 1f
	ret
1:
	mv a5, a0
	ret
	ENDW MIN

	HDFW MAX, "MAX"
	lw a0, 0(s1)
	addi s1, s1, 4
	bgt a0, a5, 1f
	ret
1:
	mv a5, a0
	ret
	ENDW MAX

	HDFW UMIN, "UMIN"
	lw a0, 0(s1)
	addi s1, s1, 4
	bltu a0, a5, 1f
	ret
1:
	mv a5, a0
	ret
	ENDW UMIN

	HDFW UMAX, "UMAX"
	lw a0, 0(s1)
	addi s1, s1, 4
	bgtu a0, a5, 1f
	ret
1:
	mv a5, a0
	ret
	ENDW UMAX

	HDFW PLUS, "+"
	PPOP a0
	add a5, a0, a5
	ret
	ENDW PLUS

	HDFW MINUS, "-"
	PPOP a0
	sub a5, a0, a5
	ret
	ENDW MINUS

	HDFW MULTI, "*"
	PPOP a0
	mul a5, a0, a5
	ret
	ENDW MULTI

	HDFW DIVID, "/"
	PPOP a0
	div a5, a0, a5
	ret
	ENDW DIVID

	HDFW MOD, "MOD"
	PPOP a0
	rem a5, a0, a5
	ret
	ENDW MOD

	HDFW AND, "AND"
	PPOP a0
	and a5, a0, a5
	ret
	ENDW AND

	HDFW OR, "OR"
	PPOP a0
	or a5, a0, a5
	ret
	ENDW OR

	HDFW XOR, "XOR"
	PPOP a0
	xor a5, a0, a5
	ret
	ENDW XOR

	HDFW LSHIFT, "LSHIFT"
	PPOP a0
	sll a5, a0, a5
	ret
	ENDW LSHIFT

	HDFW RSHIFT, "RSHIFT"
	PPOP a0
	srl a5, a0, a5
	ret
	ENDW RSHIFT

	HDFW INVERT, "INVERT"
	xori a5, a5, -1
	ret
	ENDW INVERT

	HDFW NEGATE, "NEGATE"
	xori a5, a5, -1
	addi a5, a5, 1
	ret
	ENDW NEGATE

	HDFW 1PLUS, "1+"
	addi a5, a5, 1
	ret
	ENDW 1PLUS

	HDFW 2PLUS, "2+"
	addi a5, a5, 2
	ret
	ENDW 2PLUS

	HDFW 4PLUS, "4+"
	addi a5, a5, 4
	ret
	ENDW 4PLUS

	HDFW 1MINUS, "1-"
	addi a5, a5, -1
	ret
	ENDW 1MINUS

	HDFW 2MINUS, "2-"
	addi a5, a5, -2
	ret
	ENDW 2MINUS

	HDFW 4MINUS, "4-"
	addi a5, a5, -4
	ret
	ENDW 4MINUS

	HDFW 2MULTI, "2*"
	slli a5, a5, 1
	ret
	ENDW 2MULTI

	HDFW 4MULTI, "4*"
	slli a5, a5, 2
	ret
	ENDW 4MULTI

	HDFW 2DIVID, "2/"
	srli a5, a5, 1
	ret
	ENDW 2DIVID

	HDFW 4DIVID, "4/"
	srli a5, a5, 2
	ret
	ENDW 4DIVID

	HDFW ABS, "ABS"
	bltz a5, 1f
	ret
1:
	xori a5, a5, -1
	addi a5, a5, 1
	ret
	ENDW ABS

	HDFW CLOAD, "C@"
	lbu a5, 0(a5)
	ret
	ENDW CLOAD

	HDFW WLOAD, "W@"
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

	HDFW LLOAD, "L@"
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

	HDFW LOAD, "@"
	j W_LLOAD
	ENDW LOAD

	.section .data, "a"
	.p2align 2, 0
FORTH_DP:
	.4byte _bss_end
	.section .text, "ax"

	HDFW DP, "DP"
	PPUSH a5
	la a5, FORTH_DP
	ret
	ENDW DP

	HDFW HERE, "HERE"
	RPUSH ra
	NC W_DP; NC W_LOAD;
	RPOP ra
	ret
	ENDW HERE

	HDFW PAD, "PAD"
	RPUSH ra
	NC W_HERE; NC W_UWLIT; .2BYTE 256; NC W_PLUS;
	RPOP ra
	ret
	ENDW PAD

	HDFW CSTORE, "C!"
	lw a0, 0(s1)
	sb a0, 0(a5)
	lw a5, 4(s1)
	addi s1, s1, 8
	ret
	ENDW CSTORE

	HDFW WSTORE, "W!"
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

	HDFW LSTORE, "L!"
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

	HDFW STORE, "!"
	j W_LSTORE
	ENDW STORE

	HDFW WALIGNED, "WALIGNED"
	addi a5, a5, 1
	andi a5, a5, -2
	ret
	ENDW WALIGNED

	HDFW LALIGNED, "LALIGNED"
	addi a5, a5, 3
	andi a5, a5, -4
	ret
	ENDW LALIGNED

	HDFW CELL, "CELL"
	j W_0X4
	ENDW CELL

	HDFW CELLS, "CELLS"
	j W_4MULTI
	ENDW CELLS

	HDFW UPLOAD, "UP@"
	PPUSH a5
	mv a5, tp
	ret
	ENDW UPLOAD

	HDFW PAUSE, "PAUSE"
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

	HDFW ON, "ON"
	RPUSH ra
	NC W_TRUE; NC W_SWAP; NC W_STORE;
	RPOP ra
	ret
	ENDW ON

	HDFW OFF, "OFF"
	RPUSH ra
	NC W_FALSE; NC W_SWAP; NC W_STORE;
	RPOP ra
	ret
	ENDW OFF

	HDFW ALLOT, "ALLOT"
	RPUSH ra
	NC W_HERE; NC W_PLUS; NC W_DP; NC W_STORE;
	RPOP ra
	ret
	ENDW ALLOT

	HDFW CCOMMA, "C,"
	RPUSH ra
	NC W_HERE; NC W_CSTORE; NC W_0X1; NC W_ALLOT;
	RPOP ra
	ret
	ENDW CCOMMA

	HDFW WCOMMA, "W,"
	RPUSH ra
	NC W_HERE; NC W_WSTORE; NC W_0X2; NC W_ALLOT;
	RPOP ra
	ret
	ENDW WCOMMA

	HDFW LCOMMA, "L,"
	RPUSH ra
	NC W_HERE; NC W_LSTORE; NC W_0X4; NC W_ALLOT;
	RPOP ra
	ret
	ENDW LCOMMA

	HDFW COMMA, ","
	j W_LCOMMA
	ENDW COMMA

	HDFW WALIGN, "WALIGN"
	RPUSH ra
	NC W_HERE; NC W_WALIGNED; NC W_DP; NC W_STORE;
	RPOP ra
	ret
	ENDW WALIGN

	HDFW LALIGN, "LALIGN"
	RPUSH ra
	NC W_HERE; NC W_LALIGNED; NC W_DP; NC W_STORE;
	RPOP ra
	ret
	ENDW LALIGN
