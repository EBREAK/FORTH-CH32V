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

	ADFW ASM_XORI, "XORI,"
	# ( IMM RS1 RD -- )
	RPUSH ra
	FC W_UWLIT; .2BYTE 0x4; FC W_SWAP; FC W_UWLIT; .2BYTE 0b0010011;
	FC W_I_TYPE; FC W_LCOMMA;
	RPOP ra
	ret
	ENDW ASM_XORI

	ADFW ASM_SRLI, "SRLI,"
	# ( IMM RS1 RD -- )
	RPUSH ra
	FC W_UWLIT; .2BYTE 0X5; FC W_SWAP; FC W_UWLIT; .2BYTE 0b0010011;
	FC W_I_TYPE; FC W_LCOMMA;
	RPOP ra
	ret
	ENDW ASM_SRLI

	ADFW ASM_SRAI, "SRAI,"
	# ( IMM RS1 RD -- )
	RPUSH ra
	FC W_ROT; FC W_UWLIT; .2BYTE (0x20 << 5); FC W_OR; FC W_NROT;
	FC W_UWLIT; .2BYTE 0X5; FC W_SWAP; FC W_UWLIT; .2BYTE 0b0010011;
	FC W_I_TYPE; FC W_LCOMMA;
	RPOP ra
	ret
	ENDW ASM_SRAI

	ADFW ASM_ORI, "ORI,"
	# ( IMM RS1 RD -- )
	RPUSH ra
	FC W_UWLIT; .2BYTE 0X6; FC W_SWAP; FC W_UWLIT; .2BYTE 0b0010011;
	FC W_I_TYPE; FC W_LCOMMA;
	RPOP ra
	ret
	ENDW ASM_ORI

	ADFW ASM_LB, "LB,"
	# ( IMM RS1 RD -- )
	RPUSH ra
	FC W_UWLIT; .2BYTE 0X0; FC W_SWAP; FC W_UWLIT; .2BYTE 0b000011;
	FC W_I_TYPE; FC W_LCOMMA;
	RPOP ra
	ret
	ENDW ASM_LB

	ADFW ASM_LH, "LH,"
	# ( IMM RS1 RD -- )
	RPUSH ra
	FC W_UWLIT; .2BYTE 0X1; FC W_SWAP; FC W_UWLIT; .2BYTE 0b000011;
	FC W_I_TYPE; FC W_LCOMMA;
	RPOP ra
	ret
	ENDW ASM_LH

	ADFW ASM_LW, "LW,"
	# ( IMM RS1 RD -- )
	RPUSH ra
	FC W_UWLIT; .2BYTE 0X2; FC W_SWAP; FC W_UWLIT; .2BYTE 0b000011;
	FC W_I_TYPE; FC W_LCOMMA;
	RPOP ra
	ret
	ENDW ASM_LW

	ADFW ASM_LBU, "LBU,"
	# ( IMM RS1 RD -- )
	RPUSH ra
	FC W_UWLIT; .2BYTE 0X4; FC W_SWAP; FC W_UWLIT; .2BYTE 0b000011;
	FC W_I_TYPE; FC W_LCOMMA;
	RPOP ra
	ret
	ENDW ASM_LBU

	ADFW ASM_LHU, "LHU,"
	# ( IMM RS1 RD -- )
	RPUSH ra
	FC W_UWLIT; .2BYTE 0X5; FC W_SWAP; FC W_UWLIT; .2BYTE 0b000011;
	FC W_I_TYPE; FC W_LCOMMA;
	RPOP ra
	ret
	ENDW ASM_LHU

	ADFW ASM_JALR, "JALR,"
	# ( IMM RS1 RD -- )
	RPUSH ra
	FC W_UWLIT; .2BYTE 0X0; FC W_SWAP; FC W_UWLIT; .2BYTE 0b1100111;
	FC W_I_TYPE; FC W_LCOMMA;
	RPOP ra
	ret
	ENDW ASM_JALR

	ADFW ASM_ECALL, "ECALL,"
	# ( -- )
	RPUSH ra
	FC W_0X0; FC W_0X0; FC W_0X0; FC W_0X0;
	FC W_UWLIT; .2BYTE 0b1110011;
	FC W_I_TYPE; FC W_LCOMMA;
	RPOP ra
	ret
	ENDW ASM_ECALL

	ADFW ASM_EBREAK, "EBREAK,"
	# ( -- )
	RPUSH ra
	FC W_0X1; FC W_0X0; FC W_0X0; FC W_0X0;
	FC W_UWLIT; .2BYTE 0b1110011;
	FC W_I_TYPE; FC W_LCOMMA;
	RPOP ra
	ret
	ENDW ASM_EBREAK

	ADFW S_TYPE, "S-TYPE"
	# ( IMM RS2 RS1 FUNCT3 OPCODE -- INST )
	lw a0, 0(s1)
	slli a0, a0, 12
	or a5, a5, a0
	lw a0, 4(s1)
	slli a0, a0, 15
	or a5, a5, a0
	lw a0, 8(s1)
	slli a0, a0, 20
	or a5, a5, a0
	lw a0, 12(s1)
	addi s1, s1, 16
	andi a1, a0, 0x1F
	slli a1, a1, 7
	or a5, a5, a1
	slli a0, a0, 20
	li a1, (0x7F << 25)
	and a0, a0, a1
	or a5, a5, a0
	ret
	ENDW S_TYPE

	ADFW DIS_S_TYPE, "DIS-S-TYPE"
	# ( INST -- IMM RS2 RS1 FUNCT3 OPCODE )
	addi s1, s1, -16
	srli a0, a5, 7
	andi a0, a0, 0b11111
	srli a1, a5, 20
	li a2, 0b111111100000
	and a1, a1, a2
	or a0, a0, a1
	li a1, (1 << 11)
	and a1, a0, a1
	beqz a1, 1f
	li a1, 0b11111111111111111111000000000000
	or a0, a0, a1
1:
	sw a0, 12(s1)
	srli a0, a5, 20
	andi a0, a0, 0b11111
	sw a0, 8(s1)
	srli a0, a5, 15
	andi a0, a0, 0b11111
	sw a0, 4(s1)
	srli a0, a5, 12
	andi a0, a0, 0b111
	sw a0, 0(s1)
	andi a5, a5, 0b1111111
	ret
	ENDW DIS_S_TYPE

	ADFW ASM_SB, "SB,"
	# ( IMM RS2 RS1 -- )
	RPUSH ra
	FC W_UWLIT; .2BYTE 0X0; FC W_UWLIT; .2BYTE 0b0100011;
	FC W_S_TYPE; FC W_LCOMMA;
	RPOP ra
	ret
	ENDW ASM_SB

	ADFW ASM_SH, "SH,"
	# ( IMM RS2 RS1 -- )
	RPUSH ra
	FC W_UWLIT; .2BYTE 0X1; FC W_UWLIT; .2BYTE 0b0100011;
	FC W_S_TYPE; FC W_LCOMMA;
	RPOP ra
	ret
	ENDW ASM_SH

	ADFW ASM_SW, "SW,"
	# ( IMM RS2 RS1 -- )
	RPUSH ra
	FC W_UWLIT; .2BYTE 0X2; FC W_UWLIT; .2BYTE 0b0100011;
	FC W_S_TYPE; FC W_LCOMMA;
	RPOP ra
	ret
	ENDW ASM_SW

	ADFW B_TYPE, "B-TYPE"
	# ( IMM RS2 RS1 FUNCT3 OPCODE -- INST )
	lw a0, 0(s1)
	slli a0, a0, 12
	or a5, a5, a0
	lw a0, 4(s1)
	slli a0, a0, 15
	or a5, a5, a0
	lw a0, 8(s1)
	slli a0, a0, 20
	or a5, a5, a0
	lw a0, 12(s1)
	addi s1, s1, 16
	srli a1, a0, 4
	andi a1, a1, (1 << 7)
	or a5, a5, a1
	slli a1, a0, 7
	li a2, (0b1111 << 8)
	and a1, a1, a2
	or a5, a5, a1
	slli a1, a0, 20
	li a2, (0b111111 << 25)
	and a1, a1, a2
	or a5, a5, a1
	slli a1, a0, 19
	li a2, (0x1 << 31)
	and a1, a1, a2
	or a5, a5, a1
	ret
	ENDW B_TYPE

	ADFW DIS_B_TYPE, "DIS-B-TYPE"
	# ( INST -- IMM RS2 RS1 FUNCT3 OPCODE )
	addi s1, s1, -16
	srli a0, a5, 7
	andi a0, a0, 0b11110
	slli a1, a5, 4
	li a2, (1 << 11)
	and a1, a1, a2
	or a0, a0, a1
	srli a1, a5, 20
	li a2, (0b111111 << 5)
	and a1, a1, a2
	or a0, a0, a1
	srli a1, a5, 19
	li a2, (1 << 12)
	and a1, a1, a2
	or a0, a0, a1
	beqz a1, 1f
	li a1, 0b11111111111111111111000000000000
	or a0, a0, a1
1:
	sw a0, 12(s1)
	srli a0, a5, 20
	andi a0, a0, 0x1F
	sw a0, 8(s1)
	srli a0, a5, 15
	andi a0, a0, 0x1F
	sw a0, 4(s1)
	srli a0, a5, 12
	andi a0, a0, 0x7
	sw a0, 0(s1)
	andi a5, a5, 0x7F
	ret
	ENDW DIS_B_TYPE

	ADFW ASM_BEQ, "BEQ,"
	# ( IMM RS2 RS1 -- )
	RPUSH ra
	FC W_UWLIT; .2BYTE 0X0; FC W_UWLIT; .2BYTE 0b1100011;
	FC W_B_TYPE; FC W_LCOMMA;
	RPOP ra
	ret
	ENDW ASM_BEQ

	ADFW ASM_BNE, "BNE,"
	# ( IMM RS2 RS1 -- )
	RPUSH ra
	FC W_UWLIT; .2BYTE 0X1; FC W_UWLIT; .2BYTE 0b1100011;
	FC W_B_TYPE; FC W_LCOMMA;
	RPOP ra
	ret
	ENDW ASM_BNE

	ADFW ASM_BLT, "BLT,"
	# ( IMM RS2 RS1 -- )
	RPUSH ra
	FC W_UWLIT; .2BYTE 0X4; FC W_UWLIT; .2BYTE 0b1100011;
	FC W_B_TYPE; FC W_LCOMMA;
	RPOP ra
	ret
	ENDW ASM_BLT

	ADFW ASM_BGE, "BGE,"
	# ( IMM RS2 RS1 -- )
	RPUSH ra
	FC W_UWLIT; .2BYTE 0X5; FC W_UWLIT; .2BYTE 0b1100011;
	FC W_B_TYPE; FC W_LCOMMA;
	RPOP ra
	ret
	ENDW ASM_BGE

	ADFW ASM_BLTU, "BLTU,"
	# ( IMM RS2 RS1 -- )
	RPUSH ra
	FC W_UWLIT; .2BYTE 0X6; FC W_UWLIT; .2BYTE 0b1100011;
	FC W_B_TYPE; FC W_LCOMMA;
	RPOP ra
	ret
	ENDW ASM_BLTU

	ADFW ASM_BGEU, "BGEU,"
	# ( IMM RS2 RS1 -- )
	RPUSH ra
	FC W_UWLIT; .2BYTE 0X7; FC W_UWLIT; .2BYTE 0b1100011;
	FC W_B_TYPE; FC W_LCOMMA;
	RPOP ra
	ret
	ENDW ASM_BGEU

	ADFW R_TYPE, "R-TYPE"
	# ( FUNCT7 RS2 RS1 FUNCT3 RD OPCODE -- INST )
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
	lw a0, 16(s1)
	slli a0, a0, 25
	or a5, a5, a0
	addi s1, s1, 20
	ret
	ENDW R_TYPE

	ADFW DIS_R_TYPE, "DIS-R-TYPE"
	# ( INST -- FUNCT7 RS2 RS1 FUNCT3 RD OPCODE )
	addi s1, s1, -20
	srli a0, a5, 7
	andi a0, a0, 0b11111
	sw a0, 0(s1)
	srli a0, a5, 12
	andi a0, a0, 0b111
	sw a0, 4(s1)
	srli a0, a5, 15
	andi a0, a0, 0b11111
	sw a0, 8(s1)
	srli a0, a5, 20
	andi a0, a0, 0b11111
	sw a0, 12(s1)
	srli a0, a5, 25
	andi a0, a0, 0b1111111
	sw a0, 16(s1)
	andi a5, a5, 0b1111111
	ret
	ENDW DIS_R_TYPE

	ADFW ASM_ADD, "ADD,"
	# ( RS2 RS1 RD -- )
	RPUSH ra
	FC W_TOR; FC W_TOR; FC W_TOR; FC W_UWLIT; .2BYTE 0b0;
	FC W_FROMR; FC W_FROMR; FC W_UWLIT; .2BYTE 0b0; FC W_FROMR;
	FC W_UWLIT; .2BYTE 0b0110011; FC W_R_TYPE; FC W_LCOMMA;
	RPOP ra
	ret
	ENDW ASM_ADD

	ADFW ASM_SUB, "SUB,"
	# ( RS2 RS1 RD -- )
	RPUSH ra
	FC W_TOR; FC W_TOR; FC W_TOR; FC W_UWLIT; .2BYTE 0b100000;
	FC W_FROMR; FC W_FROMR; FC W_UWLIT; .2BYTE 0b0; FC W_FROMR;
	FC W_UWLIT; .2BYTE 0b0110011; FC W_R_TYPE; FC W_LCOMMA;
	RPOP ra
	ret
	ENDW ASM_SUB

	ADFW ASM_SLL, "SLL,"
	# ( RS2 RS1 RD -- )
	RPUSH ra
	FC W_TOR; FC W_TOR; FC W_TOR; FC W_UWLIT; .2BYTE 0b0;
	FC W_FROMR; FC W_FROMR; FC W_UWLIT; .2BYTE 0x1; FC W_FROMR;
	FC W_UWLIT; .2BYTE 0b0110011; FC W_R_TYPE; FC W_LCOMMA;
	RPOP ra
	ret
	ENDW ASM_SLL

	ADFW ASM_SLT, "SLT,"
	# ( RS2 RS1 RD -- )
	RPUSH ra
	FC W_TOR; FC W_TOR; FC W_TOR; FC W_UWLIT; .2BYTE 0b0;
	FC W_FROMR; FC W_FROMR; FC W_UWLIT; .2BYTE 0x2; FC W_FROMR;
	FC W_UWLIT; .2BYTE 0b0110011; FC W_R_TYPE; FC W_LCOMMA;
	RPOP ra
	ret
	ENDW ASM_SLT

	ADFW ASM_SLTU, "SLTU,"
	# ( RS2 RS1 RD -- )
	RPUSH ra
	FC W_TOR; FC W_TOR; FC W_TOR; FC W_UWLIT; .2BYTE 0b0;
	FC W_FROMR; FC W_FROMR; FC W_UWLIT; .2BYTE 0x3; FC W_FROMR;
	FC W_UWLIT; .2BYTE 0b0110011; FC W_R_TYPE; FC W_LCOMMA;
	RPOP ra
	ret
	ENDW ASM_SLTU

	ADFW ASM_XOR, "XOR,"
	# ( RS2 RS1 RD -- )
	RPUSH ra
	FC W_TOR; FC W_TOR; FC W_TOR; FC W_UWLIT; .2BYTE 0b0;
	FC W_FROMR; FC W_FROMR; FC W_UWLIT; .2BYTE 0x4; FC W_FROMR;
	FC W_UWLIT; .2BYTE 0b0110011; FC W_R_TYPE; FC W_LCOMMA;
	RPOP ra
	ret
	ENDW ASM_XOR

	ADFW ASM_SRL, "SRL,"
	# ( RS2 RS1 RD -- )
	RPUSH ra
	FC W_TOR; FC W_TOR; FC W_TOR; FC W_UWLIT; .2BYTE 0b0;
	FC W_FROMR; FC W_FROMR; FC W_UWLIT; .2BYTE 0x5; FC W_FROMR;
	FC W_UWLIT; .2BYTE 0b0110011; FC W_R_TYPE; FC W_LCOMMA;
	RPOP ra
	ret
	ENDW ASM_SRL

	ADFW ASM_SRA, "SRA,"
	# ( RS2 RS1 RD -- )
	RPUSH ra
	FC W_TOR; FC W_TOR; FC W_TOR; FC W_UWLIT; .2BYTE 0b100000;
	FC W_FROMR; FC W_FROMR; FC W_UWLIT; .2BYTE 0x5; FC W_FROMR;
	FC W_UWLIT; .2BYTE 0b0110011; FC W_R_TYPE; FC W_LCOMMA;
	RPOP ra
	ret
	ENDW ASM_SRA

	ADFW ASM_OR, "OR,"
	# ( RS2 RS1 RD -- )
	RPUSH ra
	FC W_TOR; FC W_TOR; FC W_TOR; FC W_UWLIT; .2BYTE 0b0;
	FC W_FROMR; FC W_FROMR; FC W_UWLIT; .2BYTE 0x6; FC W_FROMR;
	FC W_UWLIT; .2BYTE 0b0110011; FC W_R_TYPE; FC W_LCOMMA;
	RPOP ra
	ret
	ENDW ASM_OR

	ADFW ASM_AND, "AND,"
	# ( RS2 RS1 RD -- )
	RPUSH ra
	FC W_TOR; FC W_TOR; FC W_TOR; FC W_UWLIT; .2BYTE 0b0;
	FC W_FROMR; FC W_FROMR; FC W_UWLIT; .2BYTE 0x7; FC W_FROMR;
	FC W_UWLIT; .2BYTE 0b0110011; FC W_R_TYPE; FC W_LCOMMA;
	RPOP ra
	ret
	ENDW ASM_AND

	ADFW ASM_FAR_CALL, "FAR-CALL,"
	# ( ADDR -- )
	RPUSH ra
	FC W_UWLIT; .2BYTE (1 << 11); FC W_OVER; FC W_AND; FC W_0BRANCH; .2BYTE 1f - .
	FC W_DUP; FC W_UWLIT; .2BYTE (1 << 12); FC W_PLUS; FC W_0X1; FC W_ASM_LUI;
	FC W_0X1; FC W_0X1; FC W_ASM_JALR;
	j 2f
1:
	FC W_DUP; FC W_0X1; FC W_ASM_LUI;
	FC W_0X1; FC W_0X1; FC W_ASM_JALR;
2:
	RPOP ra
	ret
	ENDW ASM_FAR_CALL

	ADFW ASM_RET, "RET,"
	RPUSH ra
	FC W_0X0; FC W_0X1; FC W_0X0; FC W_ASM_JALR;
	RPOP ra
	ret
	ENDW ASM_RET

	ADFW ASM_NEAR_CALL, "NEAR-CALL,"
	# ( ADDR -- )
	RPUSH ra
	FC W_HERE; FC W_MINUS; FC W_0X1; FC W_ASM_JAL;
	RPOP ra
	ret
	ENDW ASM_NEAR_CALL

	ADFW ASM_LIU32, "LIU32,"
	# ( VAL REG -- )
	RPUSH ra
	FC W_OVER; FC W_UWLIT; .2BYTE (1 << 11); FC W_AND; FC W_0BRANCH; .2BYTE 1f - .
	FC W_2DUP; FC W_SWAP; FC W_UWLIT; .2BYTE (1 << 12); FC W_PLUS;
	FC W_SWAP; FC W_ASM_LUI;
	FC W_DUP; FC W_ASM_ADDI;
	j 2f
1:
	FC W_2DUP; FC W_ASM_LUI;
	FC W_DUP; FC W_ASM_ADDI;
2:
	RPOP ra
	ret
	ENDW ASM_LIU32
