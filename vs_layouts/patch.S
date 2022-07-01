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
p_rand = $001468
IS_2P_VS = -$6092
STAGE = -$60AC
LAYOUT = -$E90
IS_PRACTICE = -$609E
GAME_STATE = -$60C0
ANOTHERWORLD = -$608E

;; game control loop: 2p vs stage selection
;; original code as reference
	ORG $8E470 + SHIFT_15FBC 
	jsr     (p_rand).l          ; get a random 0-3
	andi.w  #$3,D0
	addq.w  #1,D0               ; + 1
	add.w   STAGE(A5),D0        ; + stage_num
	andi.w  #$7,D0              ; % ranju stage
	move.w  D0,STAGE(A5)        ; =>stage_num
.end_mode_check = $8E4A6 + SHIFT_15FBC
	bra.b   .end_mode_check     ; (end of cond. branch)
; end offset to match:
	ASSERTPC $8E48A + SHIFT_15FBC


;; round setup after stage selection + $10
;; layout selection
	ORG $98CD6 + SHIFT_91470
	jsr     (p_rand).w
; is this a vs match?
	tst.w   IS_2P_VS(A5)
	beq.b   .not_vs
; yes: another world low bit of rnd
; todo: is global rng state low nibble ok?
	move.b	D0,D1
	andi.w	#1,D1
	move.w  D1,ANOTHERWORLD(A5)
.not_vs:
; this shift is vanilla... why?
	asr.w   #4,D0
	tst.l   GAME_STATE(A5)      ; is attract mode?
	bne.b   .got_layout
; attract demo: force layout 1
	moveq   #1,D0
.got_layout:
	andi.w  #3,D0
	move.w  D0,LAYOUT(A5)
	
	ASSERTPC $98CFC + SHIFT_91470
