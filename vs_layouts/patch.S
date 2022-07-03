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

;; game control loop:
;; 2p vs stage selection
	ORG $8E470 + SHIFT_15FBC 
	jmp     (vs_stage).l        ; set random 0-10
end_mode_check = $8E4D2 + SHIFT_15FBC
	; returns to end_mode_check
;	ASSERTPC $8E488 + SHIFT_15FBC

;; game control loop:
;; patch over win screen/music check
	ORG $8E562 + SHIFT_15FBC
	jmp     (win_screen_ok).l
	; returns to appropriate branch
;	ASSERTPC $8E56A + SHIFT_15FBC

;; game control loop: 
;; patch over bonus/practice screen check
	ORG $8E616 + SHIFT_15FBC
	jmp     (bonus_check).l
	; returns to appropriate branch
;	ASSERTPC $8E62C + SHIFT_15FBC


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
	asr.w   #4,D0
	tst.l   GAME_STATE(A5)      ; is attract mode?
	bne.b   .got_layout
; attract demo: force layout 1
	moveq   #1,D0
.got_layout:
	andi.w  #3,D0
	move.w  D0,LAYOUT(A5)
	
	ASSERTPC $98CFC + SHIFT_91470


	ORG ROM_FREE
;; new 2p vs stage selection
;; every round, random 0-10
;; (hiryu-bonus)
vs_stage:
	jsr    (p_rand).l

; 0.03125 bias against bonus stage
; 48 cycles
	andi.w  #%11111,D0               ; 0-31
	move.w  .b5div3(PC,D0*2),D0 ; pseudo-div 3 
	nop
	move.w  D0,STAGE(A5)
	jmp     end_mode_check
.b5div3:
	dc.w 0,0,0,1,1,1 ; 6
	dc.w 2,2,2,3,3,3 ; 12
	dc.w 4,4,4,5,5,5 ; 18
	dc.w 6,6,6,7,7,7 ; 24
	dc.w 8,8,8,9,9,9 ; 30
	dc.w 10,10       ; 32

;; slower method (avg case 106 worst 418+ c)
;; 0.00009 bias hiryu on
;; 8 discards
.loop_discard:
	move.b  D0,D1
	andi.b  #3,D1
	cmpi.b  #11,D0
	blt.b   (.valid_stage)
	lsr     #4,D0
	bra     (.loop_discard)
.valid_stage:
; can discard repeats at this point
	move.w  D0,STAGE(A5)
	jmp     end_mode_check


lab_win_fall_through = $8E56A + SHIFT_15FBC
lab_win_screen_skip = $8E588 + SHIFT_15BFC
win_screen_ok:
	tst.w   IS_2P_VS(A5)
	bne     lab_win_fall_through
; 1p mode: skip win screen on boss stages
	cmpi.w  #$8,STAGE(A5)
	bge     lab_win_screen_skip
	jmp     lab_win_fall_through

lab_bonus_screen = $8E62E + SHIFT_15FBC
lab_no_bonus = $8E636 + SHIFT_15FBC
bonus_check:
; normal practice check
	tst.w   IS_PRACTICE(A5)
	bne.b   .practice
; must skip if 2p vs context
  tst.w   IS_2P_VS(A5)
  bne.b   .no_bonus
; back to normal check
  cmpi.w  #$a,STAGE(A5)
  blt.b   .no_bonus
	jmp     lab_bonus_screen
.practice:
	cmpi.w  #3,STAGE(A5)
	blt.b   .no_bonus
	jmp     lab_bonus_screen
.no_bonus:
	jmp     lab_no_bonus
