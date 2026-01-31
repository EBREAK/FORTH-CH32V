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

        .macro LEQU2WORD LABEL, VALUE
                .EQU \LABEL, \VALUE
                LDFW \LABEL, "\LABEL"
                        PPUSH a5
                        li a5, \LABEL
                        ret
                ENDW \LABEL
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

        .set W_ALASTWORD, 0
        .macro ADFW LABEL, NAME
                .section .text, "ax"
                .p2align 1, 0
        NAME_\LABEL:
                .ascii "\NAME"
                .set NLEN_\LABEL, . - NAME_\LABEL
                .p2align 1, 0
                .set SHI_BLEN_\LABEL, ((BLEN_\LABEL / 2) << 8)
                .2byte NLEN_\LABEL | SHI_BLEN_\LABEL
                .set PREV_\LABEL, W_ALASTWORD
                .4byte PREV_\LABEL
        W_\LABEL:
                .set W_ALASTWORD, W_\LABEL
        .endm
