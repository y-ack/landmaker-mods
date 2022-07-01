	CPU 68000
	PADDING OFF
	ORG $000000
	IFDEF LANDMAKRJ
	BINCLUDE "landmakrj_program.bin"
	ELSE
	BINCLUDE "landmakr_program.bin"
	ENDIF

	INCLUDE "shifts.S"

ROM_FREE = $11B364 + SHIFT_A1416	
p_rand = $001468
IS_2P_VS = $401F6E
STAGE = -$60AC
LAYOUT = -$E90
IS_PRACTICE = -$609E
GAME_STATE = -$60C0


;; game control loop: 2p vs stage selection
;; original code as reference
	ORG $8E470 + SHIFT_15FBC 
	jsr     (p_rand).l          ; get a random number 0-3
	andi.w  #$3,D0
	addq.w  #1,D0               ; + 1
	add.w   STAGE(A5),D0        ; + stage_num
	andi.w  #$7,D0              ; % ranju stage
	move.w  D0,STAGE(A5)        ; =>stage_num
	bra.b   .end_mode_check     ; (end of conditional branch)
	ORG $8E4A6 + SHIFT_15FBC
.end_mode_check:

;; round setup after stage selection + $10
;; layout selection
	ORG $98CD6 + SHIFT_91470
	jsr     (p_rand).l
	asr.w   #4,D0
	tst.w   IS_PRACTICE(A5)
	bne.b   .practice_mode
; not practice mode:
	andi.w  #$3,D0
	tst.l   GAME_STATE(A5)      ; is this attract mode?
	bne.b   .got_layout
; attract demo: force layout 1
	move.w  #1,D0
	bra.b   .got_layout
.practice_mode:
  andi.w  #3,D0
.got_layout:
	move.w  D0,LAYOUT(A5)
	
	ORG $98CFC + SHIFT_91470
