	CPU 68000
	PADDING OFF
	ORG $000000
	IFDEF landmakrj
	BINCLUDE "landmakrj_program.bin"
	ELSE
	BINCLUDE "landmakr_program.bin"
	ENDIF

	INCLUDE "../shifts.S"

ROM_FREE = $11B364 + SHIFT_A1416


;;
	ORG $098CD6 + SHIFT_91470
;; round setup after stage select, get a random layout
	jsr			$1468.l		;; p_rand.l
	asr.w		#$4,D0		;; vanilla
;; vanilla does practice + attract demo check here to force layout 1
