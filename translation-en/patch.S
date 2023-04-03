	CPU 68020
	PADDING OFF
	ORG $000000
	IFDEF LANDMAKRJ
	BINCLUDE "landmakrj_program.bin"
	ELSE
	BINCLUDE "landmakr_program.bin"
	ENDIF

	INCLUDE "shifts.S"

ASSERTPC	MACRO addr
	IF *<>addr
		ERROR "!!shift introduced!!"
	ENDIF
	ENDM

ROM_FREE = $11B364 + SHIFT_A1416	
