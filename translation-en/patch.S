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
	
;;; _BL_TITLE02
	;; ORG $83F94 + SHIFT_15FBC
	;; dc.l    [20*1]$0C00035A
	;; dc.l	$C00035A, $C00035A, $C00035A, $C00035A, $C00035A, $C00035A
	;; dc.l	$C006485, $C006486, $C006487, $C006488, $C006489, $C00648A
	;; dc.l	$C00648B, $C00035A, $C00035A, $C00035A, $C00035A, $C00035A
	;; dc.l	$C00035A, $C00035A, $C00035A, $C00035A, $C00035A, $C00035A
	;; dc.l	$C00035A, $C00648C, $C00648D, $C00648E, $C00648F, $C006490
	;; dc.l	$C006491, $C006492, $C006493, $C006494, $C00035A, $C00035A
	;; dc.l	$C00035A, $C00035A, $C00035A, $C00035A, $C00035A, $C00035A
	;; dc.l	$C00035A, $C00035A, $C00035A, $C006495, $C006496, $C006497
	;; dc.l	$C006498, $C006499, $C00649A, $C00649B, $C00649C, $C00649D
	;; dc.l	$C00035A, $C00035A, $C00035A, $C00035A, $C00035A, $C00035A
	;; dc.l	$C00035A, $C00035A, $C00035A, $C00035A, $C00035A, $C00649E
	;; dc.l	$C00649F, $C0064A0, $C0064A1, $C0064A2, $C0064A3, $C0064A4
	;; dc.l	$C0064A5, $C0064A6, $C0064A7, $C00035A, $C00035A, $C00035A
	;; dc.l	$C00035A, $C00035A, $C00035A, $C00035A, $C00035A, $C00035A
	;; dc.l	$C00035A, $C0064A8, $C0064A9, $C0064AA, $C0064AB, $C0064AC
	;; dc.l	$C0064AD, $C0064AE, $C0064AF, $C0064B0, $C0064B1, $C0064B2
	;; dc.l	$C00035A, $C00035A, $C00035A, $C00035A, $C00035A, $C00035A
	;; dc.l	$C00035A, $C00035A, $C00035A, $C0064B3, $C0064B4, $C0064B5
	;; dc.l	$C0064B6, $C0064B7, $C0064B8, $C0064B9, $C0064BA, $C0064BB
	;; dc.l	$C0064BC, $C0064BD, $C00035A, $C00035A, $C00035A, $C00035A
	;; dc.l	$C00035A, $C00035A, $C00035A, $C00035A, $C0064BE, $C0064BF
	;; dc.l	$C0064C0, $C0064C1, $C0064C2, $C0064C3, $C0064C4, $C0064C5
	;; dc.l	$C0064C6, $C0064C7, $C0064C8, $C0064C9, $C00035A, $C00035A
	;; dc.l	$C00035A, $C00035A, $C00035A, $C00035A, $C00035A, $C00035A
	;; dc.l	$C0064CA, $C0064CB, $C0064CC, $C0064CD, $C0064CE, $C0064CF
	;; dc.l	$C0064D0, $C0064D1, $C0064D2, $C0064D3, $C0064D4, $C00035A
	;; dc.l	$C00035A, $C00035A, $C00035A, $C00035A
	;; dc.l	[20*5]$0C00035A
	;; dc.l	[20*1]$0C0064D5

;;; hook title cr text
	ORG $90C5E + SHIFT_15FBC
	jmp 		new_title_text

;;; skip wmes vram typo patches
	ORG $9176C + SHIFT_91470
	nop
	nop
	
	ORG $917FE + SHIFT_91470
	nop
	nop
;;; skip emes vram typo patches
	ORG $FEF0A + SHIFT_A1416
	nop
	nop
	
;;; invert win message checks
	ORG $91812 + SHIFT_91470
	beq.b		*+$1c
	ORG $918C0 + SHIFT_91470
	bne.b		*+$06
	ORG $919C0 + SHIFT_91470
	bne.b		*+$06

;;; invert ending message checks
	ORG $FE7D4 + SHIFT_A1416
	beq.b		*+$1c
;;; ending last win message palette
	ORG $FE9F4 + SHIFT_A1416
	beq.b		*+$1e
	ORG $FEBA8 + SHIFT_A1416
	beq.b		*+$1e
	ORG $FECA8 + SHIFT_A1416
	beq.b		*+$1e
	ORG $FED94 + SHIFT_A1416
	bne.b		*+$08
;;; "YOU ARE GREAT LAND MAKER!"
	ORG $FEDBC + SHIFT_A1416
	bne.b		*+$24
;;; ending message tilemap / CONGRATULATIONS
	ORG $FEFB6 + SHIFT_A1416
	beq.b		*+$16
;;; final message tilemap
	ORG $FF2D0 + SHIFT_A1416
	beq.b		*+$22

	
	ORG ROM_FREE
strmov_textram = $57A2
STR_CR = $90CB0 + SHIFT_15FBC
STR_RESERVED = $90D22 + SHIFT_15FBC
new_title_text:	
	;; this was a redundant region lookup originally.. hm...
	;; strmov_textram(STR_CR, 0x61cb80, 6)
	move.w		#$6, -(SP)
	pea			($61cb80).l
	pea			(STR_CR).l
	nop
	jsr			strmov_textram
	lea			($a,SP), SP
	;; strmov_textram("ALL RIGHTS RESERVED", 0x61cc80, 6)
	move.w		#$6, -(SP)
	pea			($61cc80).l
	pea			(STR_RESERVED).l
	nop
	jsr			strmov_textram
	lea			($a,SP), SP
	;; strmov_textram(tl_credit, 0x61cd80, 6)
	move.w		#$6, -(SP)
	pea			($61cd80).l
	pea			str_tl_credit
	nop
	jsr			strmov_textram
	lea			($a,SP), SP
	rts
	align		16,0
str_tl_credit:
	dc.b	"          TRANSLATION BY MA97        \0"

	align		16,0
	dc.b		"romhacking  ywy\0"
	dc.b		"qcs.shsbs.xyz/share/ywy/\0"
	align		16,0
	dc.b		"font dev.    12\0"
	dc.b		"   2023.06.04  \0"

	ORG $102A68 + SHIFT_A1416
	dc.w		2023, 06, 04, 04, 18
