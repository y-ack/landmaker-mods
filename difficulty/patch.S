	CPU 68000
	PADDING OFF
	ORG $000000
	IFDEF landmakrj
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
	INCLUDE "../shifts.S"

;; end of defined rom data, beginning of void space
ROM_FREE = $11B364 + SHIFT_A1416

;; per-stage cpu difficulty level
;; easiest is 0, maximum is 6
	ORG $0A04A4 + SHIFT_91470
	dc.w	6		; hiryu (0)
	dc.w	6		; aifa (3)
	dc.w	6		; soumei (4)
	dc.w	6		; renki (4)
	dc.w	6		; youen (2)
	dc.w	6		; kouko (4)
	dc.w	6		; rinrei (4)
	dc.w	6		; roushinshi (6)
	dc.w	6		; ranju (6)
	dc.w	6		; gaira (6)
	dc.w	6		; bonus stage (6)

;; per-stage cpu "decision time" delay table
;; values originally ranged from 0 (gaira, bonus) to 180 (hiryu)
	ORG $0A04BA + SHIFT_91470
	dc.w	0		; hiryu
	dc.w	0		; aifa
	dc.w	0		; soumei
	dc.w	0		; renki
	dc.w	0		; youen
	dc.w	0		; kouko
	dc.w	0		; rinrei
	dc.w	0		; roushinshi
	dc.w	0		; ranju
	dc.w	0		; gaira
	dc.w	0		; bonus stage

