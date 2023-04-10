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
REGION = $1ffffe
load_bl_tilemaps = $55c2
	
;;; patch win message pointer obtainment
	ORG $9175c + SHIFT_91470
	jmp acquire_wmes
	
	ORG ROM_FREE
replacement_alpha_blend_write:
	lea		($626360).l, A0 	; alpha blend ptr
	lea		($627560).l, A1		; sprite clip ptr
	move.w	#75, D0				; line count
	move.w	#$BCBA, D1
	move.w	#$0380, D2
.alpha_blend_write_loop:
	move.w	D1, (A0)
	move.w	D2, (A1)
	dbf		D0, .alpha_blend_write_loop
ALPHA_BLEND_WRITE_RETURN = $915e6 + SHIFT_91470
	jmp ALPHA_BLEND_WRITE_RETURN
	
	;; this is a region check and then load, alternatively 9182e
GET_WMES_RETURN = $9180a + SHIFT_91470
acquire_wmes:
	jmp GET_WMES_RETURN
	;; what do we need to do again...



_BL_SCR_KARIWAKU:
	dc.W	#3, #$14
	dc.L	$0c007fc4, $0c007fd8, $0c007fec
	dc.L	$0c007fc5, $0c007fd9, $0c007fed
	dc.L	$0c007fc6, $0c007fda, $0c007fee
	dc.L	$0c007fc7, $0c007fdb, $0c007fef
	dc.L	$0c007fc8, $0c007fdc, $0c007ff0
	dc.L	$0c007fc9, $0c007fdd, $0c007ff1
	dc.L	$0c007fca, $0c007fde, $0c007ff2
	dc.L	$0c007fcb, $0c007fdf, $0c007ff3
	dc.L	$0c007fcc, $0c007fe0, $0c007ff4
	dc.L	$0c007fcd, $0c007fe1, $0c007ff5
	dc.L	$0c007fce, $0c007fe2, $0c007ff6
	dc.L	$0c007fcf, $0c007fe3, $0c007ff7
	dc.L	$0c007fd0, $0c007fe4, $0c007ff8
	dc.L	$0c007fd1, $0c007fe5, $0c007ff9
	dc.L	$0c007fd2, $0c007fe6, $0c007ffa
	dc.L	$0c007fd3, $0c007fe7, $0c007ffb
	dc.L	$0c007fd4, $0c007fe8, $0c007ffc
	dc.L	$0c007fd5, $0c007fe9, $0c007ffd
	dc.L	$0c007fd6, $0c007fea, $0c007ffe
	dc.L	$0c007fd7, $0c007feb, $0c007fff