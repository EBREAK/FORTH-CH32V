	.set W_ALASTWORD, 0
        .macro ADFW LABEL, NAME
                .section .text
                .p2align 1, 0
        NAME_\LABEL:
                .ascii "\NAME"
                .set NLEN_\LABEL, . - NAME_\LABEL
                .p2align 1, 0
                .set SHI_BLEN_\LABEL, (BLEN_\LABEL << 7)
                .2byte NLEN_\LABEL | SHI_BLEN_\LABEL
                .set PREV_\LABEL, W_ALASTWORD
                .4byte PREV_\LABEL
        W_\LABEL:
                .set W_ALASTWORD, W_\LABEL
        .endm

	.section .bss
	.p2align 2, 0
ASSEMBLER_LATEST:
	.4BYTE 0x0

	ADFW ASSEMBLER, "ASSEMBLER"
	PPUSH a5
	la a5, ASSEMBLER_LATEST
	ENDW ASSEMBLER

	ADFW U_TYPE, "U-TYPE"
	# ( IMM RD OPCODE -- INST )
	lw a0, 4(s1)
	lw a1, 0(s1)
	addi s1, s1, 8
	li a2, 0xFFFFF000
	and a0, a0, a2
	slli a1, a1, 7
	or a5, a5, a1
	or a5, a5, a0
	ret
	ENDW U_TYPE

	ADFW DIS_U_TYPE, "DIS-U-TYPE"
	# ( INST -- IMM RD OPCODE )
	addi s1, s1, -8
	li a2, 0xFFFFF000
	and a0, a5, a2
	sw a0, 4(s1)
	srli a1, a5, 7
	andi a1, a1, 0b11111
	sw a1, 0(s1)
	andi a5, a5, 0b1111111
	ret
	ENDW DIS_U_TYPE

	ADFW ASM_LUI, "LUI,"
	# ( IMM RD -- )
	RPUSH ra
	FC W_UWLIT; .2BYTE 0b0110111; FC W_U_TYPE; FC W_LCOMMA;
	RPOP ra
	ret
	ENDW ASM_LUI

	ADFW ASM_AUIPC, "AUIPC,"
	# ( IMM RD -- )
	RPUSH ra
	FC W_UWLIT; .2BYTE 0b0010111; FC W_U_TYPE; FC W_LCOMMA;
	RPOP ra
	ret
	ENDW ASM_AUIPC

	ADFW J_TYPE, "J-TYPE"
	# ( IMM RD OPCODE -- INST )
	lw a0, 4(s1)
	lw a1, 0(s1)
	addi s1, s1, 8
	slli a1, a1, 7
	or a5, a5, a1
	li a2, 0b11111111000000000000 # 19:12 -> 19 -> 12
	and a1, a0, a2
	or a5, a5, a1
	li a2, (1 << 11) # 11 -> 20
	and a1, a0, a2
	slli a1, a1, 9
	or a5, a5, a1
	li a2, 0b11111111110 # 10:1 -> 30:21
	and a1, a0, a2
	slli a1, a1, 20
	or a5, a5, a1
	li a2, (1 << 20) # 20 -> 31
	and a1, a0, a2
	slli a1, a1, 11
	or a5, a5, a1
	ret
	ENDW J_TYPE

	ADFW DIS_J_TYPE, "DIS-J-TYPE"
	# ( INST -- IMM RD OPCODE )
	addi s1, s1, -8
	srli a2, a5, 20
	li a3, 0b11111111110
	and a0, a2, a3
	li a3, 0b11111111000000000000
	and a2, a5, a3
	or a0, a0, a2
	srli a2, a5, 9
	li a3, (1 << 11)
	and a2, a2, a3
	or a0, a0, a2
	srli a2, a5, 11
	li a3, (1 << 20)
	and a2, a2, a3
	or a0, a0, a2
	srli a1, a5, 7
	andi a1, a1, 0b11111
	sw a1, 0(s1)
	li a1, (1 << 20)
	and a1, a0, a1
	beqz a1, 1f
	li a1, 0b11111111111000000000000000000000
	or a0, a0, a1
1:
	sw a0, 4(s1)
	andi a5, a5, 0b1111111
	ret
	ENDW DIS_J_TYPE

	ADFW ASM_JAL, "JAL,"
	# ( IMM RD -- )
	RPUSH ra
	FC W_UWLIT; .2BYTE 0b1101111; FC W_J_TYPE; FC W_LCOMMA;
	RPOP ra
	ret
	ENDW ASM_JAL

	ADFW I_TYPE, "I-TYPE"
	# ( IMM RS1 FUNCT3 RD OPCODE -- INST )
	lw a0, 0(s1)
	slli a0, a0, 7
	or a5, a5, a0
	lw a0, 4(s1)
	slli a0, a0, 12
	or a5, a5, a0
	lw a0, 8(s1)
	slli a0, a0, 15
	or a5, a5, a0
	lw a0, 12(s1)
	slli a0, a0, 20
	or a5, a5, a0
	addi s1, s1, 16
	ret
	ENDW I_TYPE

	ADFW DIS_I_TYPE, "DIS-I-TYPE"
	# ( INST -- IMM RS1 FUNCT3 RD OPCODE )
	addi s1, s1, -16
	srli a0, a5, 20
	li a1, 0b111111111111
	and a0, a0, a1
	li a2, (1 << 11)
	and a1, a0, a2
	beqz a1, 1f
	li a2, 0b11111111111111111111000000000000
	or a0, a0, a2
1:
	sw a0, 12(s1)
	srli a0, a5, 15
	andi a0, a0, 0b11111
	sw a0, 8(s1)
	srli a0, a5, 12
	andi a0, a0, 0b111
	sw a0, 4(s1)
	srli a0, a5, 7
	andi a0, a0, 0b11111
	sw a0, 0(s1)
	andi a5, a5, 0b1111111
	ret
	ENDW DIS_I_TYPE

	ADFW ASM_ADDI, "ADDI,"
	# ( IMM RS1 RD -- )
	RPUSH ra
	FC W_UWLIT; .2BYTE 0x0; FC W_SWAP; FC W_UWLIT; .2BYTE 0b0010011;
	FC W_I_TYPE; FC W_LCOMMA;
	RPOP ra
	ret
	ENDW ASM_ADDI

	ADFW ASM_SLLI, "SLLI,"
	# ( IMM RS1 RD -- )
	RPUSH ra
	FC W_ROT; FC W_0X1F; FC W_AND; FC W_NROT;
	FC W_UWLIT; .2BYTE 0x1; FC W_SWAP; FC W_UWLIT; .2BYTE 0b0010011;
	FC W_I_TYPE; FC W_LCOMMA;
	RPOP ra
	ret
	ENDW ASM_SLLI

	ADFW ASM_SLTI, "SLTI,"
	# ( IMM RS1 RD -- )
	RPUSH ra
	FC W_UWLIT; .2BYTE 0x2; FC W_SWAP; FC W_UWLIT; .2BYTE 0b0010011;
	FC W_I_TYPE; FC W_LCOMMA;
	RPOP ra
	ret
	ENDW ASM_SLTI

	ADFW ASM_SLTIU, "SLTIU,"
	# ( IMM RS1 RD -- )
	RPUSH ra
	FC W_UWLIT; .2BYTE 0x3; FC W_SWAP; FC W_UWLIT; .2BYTE 0b0010011;
	FC W_I_TYPE; FC W_LCOMMA;
	RPOP ra
	ret
	ENDW ASM_SLTIU
