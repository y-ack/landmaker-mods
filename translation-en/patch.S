	CPU 68020
	PADDING OFF
	ORG $000000
	IFDEF LANDMAKRJ
	BINCLUDE "landmakrj_program.bin"
	ELSE
	BINCLUDE "landmakr_program.bin"
	ENDIF

	INCLUDE "shifts.S"

ROM_FREE = $11B364 + SHIFT_A1416	
REGION = $1ffffe

	ORG $64F10 + SHIFT_15FBC
	INCLUDE "tables-emes.s"
	
	ORG $84444 + SHIFT_15FBC
	INCLUDE "tables-wmes.s"

	ORG $91812 + SHIFT_91470
	beq.b		*+$1c
	ORG $918C0 + SHIFT_91470
	bne.b		*+$06
	ORG $919C0 + SHIFT_91470
	bne.b		*+$06
;;; this is the result screen text
;;; 	ORG $98EE2 + SHIFT_91470
;;; 	beq.b		*+$3C

	