	HDFW 0X0, "$0"
	PPUSH a5
	li a5, 0x0
	ret
	ENDW 0X0

	HDFW 0X1, "$1"
	PPUSH a5
	li a5, 0x1
	ret
	ENDW 0X1

	HDFW 0X2, "$2"
	PPUSH a5
	li a5, 0x2
	ret
	ENDW 0X2

	HDFW 0X3, "$3"
	PPUSH a5
	li a5, 0x3
	ret
	ENDW 0X3

	HDFW 0X4, "$4"
	PPUSH a5
	li a5, 0x4
	ret
	ENDW 0X4

	HDFW 0X5, "$5"
	PPUSH a5
	li a5, 0x5
	ret
	ENDW 0X5

	HDFW 0X6, "$6"
	PPUSH a5
	li a5, 0x6
	ret
	ENDW 0X6

	HDFW 0X7, "$7"
	PPUSH a5
	li a5, 0x7
	ret
	ENDW 0X7

	HDFW 0X8, "$8"
	PPUSH a5
	li a5, 0x8
	ret
	ENDW 0X8


	HDFW 0X9, "$9"
	PPUSH a5
	li a5, 0x9
	ret
	ENDW 0X9

	HDFW 0XA, "$A"
	PPUSH a5
	li a5, 0xA
	ret
	ENDW 0XA

	HDFW 0XB, "$B"
	PPUSH a5
	li a5, 0xB
	ret
	ENDW 0XB

	HDFW 0XC, "$C"
	PPUSH a5
	li a5, 0xC
	ret
	ENDW 0XC

	HDFW 0XD, "$D"
	PPUSH a5
	li a5, 0xD
	ret
	ENDW 0XD

	HDFW 0XE, "$E"
	PPUSH a5
	li a5, 0xE
	ret
	ENDW 0XE

	HDFW 0XF, "$F"
	PPUSH a5
	li a5, 0xF
	ret
	ENDW 0XF

	HDFW 0X10, "$10"
	PPUSH a5
	li a5, 0x10
	ret
	ENDW 0X10

	HDFW 0X11, "$11"
	PPUSH a5
	li a5, 0x11
	ret
	ENDW 0X11

	HDFW 0X12, "$12"
	PPUSH a5
	li a5, 0x12
	ret
	ENDW 0X12

	HDFW 0X13, "$13"
	PPUSH a5
	li a5, 0x13
	ret
	ENDW 0X13

	HDFW 0X14, "$14"
	PPUSH a5
	li a5, 0x14
	ret
	ENDW 0X14

	HDFW 0X15, "$15"
	PPUSH a5
	li a5, 0x15
	ret
	ENDW 0X15

	HDFW 0X16, "$16"
	PPUSH a5
	li a5, 0x16
	ret
	ENDW 0X16

	HDFW 0X17, "$17"
	PPUSH a5
	li a5, 0x17
	ret
	ENDW 0X17

	HDFW 0X18, "$18"
	PPUSH a5
	li a5, 0x18
	ret
	ENDW 0X18

	HDFW 0X19, "$19"
	PPUSH a5
	li a5, 0x19
	ret
	ENDW 0X19

	HDFW 0X1A, "$1A"
	PPUSH a5
	li a5, 0x1A
	ret
	ENDW 0X1A

	HDFW 0X1B, "$1B"
	PPUSH a5
	li a5, 0x1B
	ret
	ENDW 0X1B

	HDFW 0X1C, "$1C"
	PPUSH a5
	li a5, 0x1C
	ret
	ENDW 0X1C

	HDFW 0X1D, "$1D"
	PPUSH a5
	li a5, 0x1D
	ret
	ENDW 0X1D

	HDFW 0X1E, "$1E"
	PPUSH a5
	li a5, 0x1E
	ret
	ENDW 0X1E

	HDFW 0X1F, "$1F"
	PPUSH a5
	li a5, 0x1F
	ret
	ENDW 0X1F

	HDFW 0X20, "$20"
	PPUSH a5
	li a5, 0x20
	ret
	ENDW 0X20

	LDFW 0X33, "$33"
	PPUSH a5
	li a5, 0x33
	ret
	ENDW 0X33

	LDFW 0X55, "$55"
	PPUSH a5
	li a5, 0x55
	ret
	ENDW 0X55

	LDFW 0X77, "$77"
	PPUSH a5
	li a5, 0x77
	ret
	ENDW 0X77

	LDFW 0XAA, "$AA"
	PPUSH a5
	li a5, 0xAA
	ret
	ENDW 0XAA

	LDFW 0XFF, "$FF"
	PPUSH a5
	li a5, 0xFF
	ret
	ENDW 0XFF

	LDFW 0XFFF, "$FFF"
	PPUSH a5
	li a5, 0xFFF
	ret
	ENDW 0XFFF

	LDFW 0X7FFF, "$7FFF"
	PPUSH a5
	li a5, 0x7FFF
	ret
	ENDW 0X7FFF

	LDFW 0XFFFF, "$FFFF"
	PPUSH a5
	li a5, 0xFFFF
	ret
	ENDW 0XFFFF

	LDFW 0XFFFFFFFF, "$FFFFFFFF"
	PPUSH a5
	li a5, 0xFFFFFFFF
	ret
	ENDW 0XFFFFFFFF

	LDFW 0X01234567, "$01234567"
	PPUSH a5
	li a5, 0x01234567
	ret
	ENDW 0X01234567

	LDFW 0X89ABCDEF, "$89ABCDEF"
	PPUSH a5
	li a5, 0x89ABCDEF
	ret
	ENDW 0X89ABCDEF

	LDFW STACK_SIZE, "STACK-SIZE"
	PPUSH a5
	li a5, STK_DEPTH * 4
	ret
	ENDW STACK_SIZE
