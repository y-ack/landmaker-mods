	CPU 68000
	PADDING OFF
	ORG $000000
	IFDEF LANDMAKRJ
	BINCLUDE "landmakrj_program.bin"
	ELSE
	BINCLUDE "landmakr_program.bin"
	ENDIF
;; this include defines rom shifts (inserts) from 2.01J to 2.02O
;; to produce patches for both versions, add the closest previous shift
;; to ref'd 2.01 addresses (or subtract,  if based on 2.02 addresses)
;; shift points:
;; 1154C, 13954, 15BFC, 91470, A06C8, A06D4, A06F0, A07E2, A1114, A112C, A1416
;;
	INCLUDE "shifts.S"

;; end of defined rom data, beginning of void space
ROM_FREE = $11B364 + SHIFT_A1416

ending = $8E97C + SHIFT_15FBC
	ORG $08E20E + SHIFT_15BFC
	bsr.w	(ending)

;;; select ending b
	ORG $0FEC98 + SHIFT_A1416
	move.b	#2, (A4)

;;; set all clip layers enable for playfield 4
	ORG $0FEFE6 + SHIFT_A1416
	asl.w	#2, D6
	lea 	$62B600, A0
	move.l	#$3F0D3F0D, (A0,D6.w)

;; set clip windows
	lea 	$625000, A0
	move.l	#$90809080, (A0,D6.w) ;first visible column
	lea 	$625200,A0
	move.l	#$b0a0b0a0, (A0,D6.w)
	lea 	$625400,A0
	move.l	#$d0c0d0c0, (A0,D6.w)
	lea 	$625600,A0
	move.l	#$f0e0f0e0, (A0,D6.w) ;last visible column, aligned with "B"
	asr.w	#2, D6
	dbf 	D6, $fefe6
	jmp		$ff0fa