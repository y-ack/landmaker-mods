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
ANOTHERWORLDHACK = $7FF8

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
lab_win_fall_through = $8E56A + SHIFT_15FBC
lab_win_screen_skip = $8E588 + SHIFT_15BFC
	; returns to appropriate branch
;	ASSERTPC $8E56A + SHIFT_15FBC

;; game control loop: 
;; patch over bonus/practice screen check
	ORG $8E616 + SHIFT_15FBC
	jmp     (bonus_check).l
lab_bonus_screen = $8E62E + SHIFT_15FBC
lab_no_bonus = $8E636 + SHIFT_15FBC
	; returns to appropriate branch
;	ASSERTPC $8E62C + SHIFT_15FBC


;; round setup after stage sel:
;; p1/p2 board layout loads
	ORG $98D0E + SHIFT_91470
	jmp     (load_boards).l
	nop
load_boards_return = $98D16 + SHIFT_91470
	ASSERTPC load_boards_return

; replace layout load checks with
; one that takes into account vs hack
	ORG $98574 + SHIFT_91470 ; 1p opener
	tst.w   ANOTHERWORLDHACK(A5)
	ORG $9862A + SHIFT_91470 ; 1p continuation
	tst.w   ANOTHERWORLDHACK(A5)
	ORG $9867E + SHIFT_91470 ; 2p opener
	tst.w   ANOTHERWORLDHACK(A5)
	ORG $98730 + SHIFT_91470 ; 2p continuation
	tst.w   ANOTHERWORLDHACK(A5)



;; nerf plat stall
;; per-frame push/back type handling
	ORG $97C34 + SHIFT_91470
	jmp     (p1_flare_dec_pusher).l
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
p1_flare_push_return = $97C4A + SHIFT_91470
	ASSERTPC p1_flare_push_return

	ORG $97D36 + SHIFT_91470
	jmp     (p2_flare_dec_pusher).l
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
p2_flare_push_return = $97D4C + SHIFT_91470
	ASSERTPC p2_flare_push_return


;; flare activation also clears incoming push
	ORG $A9862 + SHIFT_A1416
	jmp     (flare_item_set_push).l
	nop
flare_set_push_return = $A986A + SHIFT_A1416
	ASSERTPC flare_set_push_return


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


win_screen_ok:
	tst.w   IS_2P_VS(A5)
	bne     lab_win_fall_through
; 1p mode: skip win screen on boss stages
	cmpi.w  #$8,STAGE(A5)
	bge     lab_win_screen_skip
	jmp     lab_win_fall_through

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


p1_load_stage_board = $98548 + SHIFT_91470
p2_load_stage_board = $98648 + SHIFT_91470
load_boards:
	move.w  ANOTHERWORLD(A5),ANOTHERWORLDHACK(A5)
; if 2p vs, random aw for 2x pool
	tst.w   IS_2P_VS(A5)
	beq.b   .skip_extra_layouts
	jsr     (p_rand).l
	andi.w  #1,D0
	move.w  D0,ANOTHERWORLDHACK(A5)
.skip_extra_layouts:
; normal calls
	jsr     (p1_load_stage_board).l
	jsr     (p2_load_stage_board).l
  jmp     (load_boards_return).l


P1_INCOMING_PUSH = -$5FDE
P1_PUSHER_OFFSET = -$EB4
p1_flare_dec_pusher:
; $40714C = p1_pusher_board_offset
	move.w  P1_PUSHER_OFFSET(A5),D0
	move.w  D0,-$EB8(A5)
; incoming push = max(0, incoming push - 6)
; 6 = flare push damage at < 60
	asr.w   #4,D0 ; convert board ofs to line
	move.w  P1_INCOMING_PUSH(A5),D1
	add.w   D0,D1
	subi.w  #6,D1
	bpl.b   .nozero
	clr.w   D1
.nozero:
	move.w  D1,P1_INCOMING_PUSH(A5)
	jmp     (p1_flare_push_return).l

P2_INCOMING_PUSH = -$5F36
P2_PUSHER_OFFSET = -$EB2
p2_flare_dec_pusher:
; $40714E = p2_pusher_board_offset
	move.w  P2_PUSHER_OFFSET(A5),D0
	move.w  D0,-$EB6(A5)
	asr.w   #4,D0 ; convert board ofs to line
	move.w  P2_INCOMING_PUSH(A5),D1
	add.w   D0,D1
	subi.w  #6,D1
	bpl.b   .nozero
	clr.w   D1
.nozero:
	move.w  D1,P2_INCOMING_PUSH(A5)
	jmp     (p2_flare_push_return).l



flare_item_set_push:
pushback_type	REG A0
player_state	REG A1
	move.w  #3,(pushback_type)
	
;	subi.w  #6,P2_INCOMING_PUSH(A5)
;	bmi.b   .nozero
;	clr.w   P2_INCOMING_PUSH(A5)
.nozero:
	jmp     (flare_set_push_return).l
