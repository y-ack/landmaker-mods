	CPU 68020
	PADDING OFF
	ORG $000000
	BINCLUDE "pbobble4j_program.bin"

ASSERTPC	MACRO addr
	IF *<>addr
		ERROR "!!shift introduced!!"
	ENDIF
	ENDM

ROM_FREE = $1B3D20
AVEC_5_PTR = $74
NEXTSCAN  = $3A34					; $4065CC
PREVFRAME = $3A32					; $4065CE
FRAME = -$1A2C					; $4065d4 ?
SCANLINE = -$1A2A				; $4065d6
PRINT_HEX = $8D4
SCR3_X = $660006
SCR3_Y = $66000E
VBLANK_RETURN = $15BC
	
	ORG AVEC_5_PTR
	dc.l timer_int

	ORG $434
	dc.w $2789

	;; replace vblank handler spin loop timer
	ORG $15b4
	jmp      (vblank_hook).l
	;; replace frame processing graphics ready trampoline
	ORG $15de
	jmp      (gfx_int_hook).l
	;; skip normal scr3 scroll per frame
	ORG $18D2
	nop
	nop
	nop
	ORG $18E4
	nop
	nop
	nop

	ORG ROM_FREE

frame_processing = $140e
gfx_int_hook:
	;; print scanline we hit graphics done, then jump as normal
	movem.l   A4/D7/D6/D5,-(SP)
	lea       ($61c42c).l,A4
	move.l    #$1047103A,(A4)+		; 'G:'
	move.w    SCANLINE(A5),D5
	moveq     #$3,D7
.gfx_next_nybble:
	rol.w     #$4,D5
	move.w    D5,D6
	andi.w    #$F,D6
	move.b    (HEXCHARS,PC,D6),D6
	ori.w     #$1000,D6
	move.w    D6,(A4)+
	dbf       D7, .gfx_next_nybble

	movem.l   (SP)+,A4/D7/D6/D5
	jmp       (frame_processing).l
 
	
;;; new frame counter update and timer interrupt
vblank_hook:
	movem.l   D0,-(SP)
	movem.l   A6/A4/D7/D6/D5,-(SP)
	;; print frame number to screen
	move.w    FRAME(A5),D5
    lea       ($61c40c).l,A4
	moveq     #$3,D7
.vblank_frame_nybble:
	rol.w     #$4,D5
	move.w    D5,D6
	andi.w    #$F,D6
	move.b    (HEXCHARS,PC,D6),D6
	ori.w     #$1000,D6
	move.w    D6,(A4)+
	dbf       D7, .vblank_frame_nybble

	;; print scanline at vblank hit
	lea       ($61c41c).l,A4
	move.l    #$1056103A,(A4)+		; 'G:'
	move.w    SCANLINE(A5),D5
	move.w    NEXTSCAN(A5),D6
	cmp.w     D5,D6
	bne       .noresetnextscan
	move.w    #0,NEXTSCAN(A5)
.noresetnextscan:
	moveq     #$3,D7
.vblank_scan_nybble:
	rol.w     #$4,D5
	move.w    D5,D6
	andi.w    #$F,D6
	move.b    (HEXCHARS,PC,D6),D6
	ori.w     #$1000,D6
	move.w    D6,(A4)+
	dbf       D7, .vblank_scan_nybble

	;; reset scanline counter
	move.w    #0,SCANLINE(A5)
	;; not restoring D0 for vblank
	movem.l   (SP)+,A6/A4/D7/D6/D5

	move.w    #$500,D0	
	jmp       (VBLANK_RETURN).l


;;; TIMER INTERRUPT (approximately HBLANK)
timer_int:
	;; ALLOWED: D0, D5, D6
	movem.l   D6/D5/D0,-(SP)
	;; are we on a new frame?
	move.w    FRAME(A5),D0
	move.w    PREVFRAME(A5),D5
	cmp.w     D0,D5
	beq       noupdate
	;; are we on the scanline to test?
	move.w    NEXTSCAN(A5),D6
	move.w    SCANLINE(A5),D5
	cmp.w     D5,D6
	bne       noupdate
	;; update waits
	move.w    D0,PREVFRAME(A5)	;PREVFRAME = FRAME
	addq.w    #1,NEXTSCAN(A5)
	move.w    D5,D0
print_scanline:
	;; ALLOWED: D0, D5, D6, D7, A4, A6
	movem.l   A6/A4/D7,-(SP)
	;; draw info to screen, update scroll regs
    lea       ($61c02c).l,A4
	moveq     #$3,D7
.timer_next_nybble:
	rol.w     #$4,D5
	move.w    D5,D6
	andi.w    #$F,D6
	move.b    (HEXCHARS,PC,D6),D6
	ori.w     #$1000,D6
	move.w    D6,(A4)+
	dbf       D7, .timer_next_nybble
	;; bottom of screen
	move.w    D0,D5				;copy stored scanline to print
    lea       ($61ce2c).l,A4
	moveq     #$3,D7
.timer_next_nybble2:
	rol.w     #$4,D5
	move.w    D5,D6
	andi.w    #$F,D6
	move.b    (HEXCHARS,PC,D6),D6
	ori.w     #$1000,D6
	move.w    D6,(A4)+
	dbf       D7, .timer_next_nybble2
;; update_regs:
;; 	andi.w    #$F,D0
;; 	neg.w     D0
;; 	asl.w     #8,D0
;; 	move.w    D0,(SCR3_X).l
;; 	asl.w     #$1,D0
;; 	move.w    D0,(SCR3_Y).l
SPRITE_TOP0 = $600040
SPRITE_BOT0 = $603610
SPRITE_TOP1 = $608040
SPRITE_BOT1 = $60B610
	andi.w    #$F,D0
	addi.w    #$20,D0
	lea       (SPRITE_TOP0).l, A4
	move.w    D0,(A4)+			; tile
	move.w    #0,(A4)+			; zoom
	move.l    #$c0640018,(A4)+ 	; X:Y
	move.l    #$00C10000,(A4)+	; color:don'tcare
	move.w    #$0000,(A4)+
	lea       (SPRITE_TOP1).l, A4
	move.w    D0,(A4)+			; tile
	move.w    #0,(A4)+			; zoom
	move.l    #$c0840018,(A4)+ 	; X:Y
	move.l    #$00C10000,(A4)+	; color:don'tcare
	move.w    #$0000,(A4)+

	lea       (SPRITE_BOT0).l, A4
	move.w    D0,(A4)+			; tile
	move.w    #0,(A4)+			; zoom
	move.l    #$c06400F0,(A4)+ 	; X:Y
	move.l    #$00C10000,(A4)+	; color:don'tcare
	move.w    #$0000,(A4)+
	lea       (SPRITE_BOT1).l, A4
	move.w    D0,(A4)+			; tile
	move.w    #0,(A4)+			; zoom
	move.l    #$c08400F0,(A4)+ 	; X:Y
	move.l    #$00C10000,(A4)+	; color:don'tcare
	move.w    #$0000,(A4)+

	
	movem.l   (SP)+,A6/A4/D7
	;; ALLOWED: D0, D5, D6
noupdate:
	;; update scanline
	addq.w    #$1,SCANLINE(A5)
	movem.l   (SP)+,D6/D5/D0
    rte

	jsr       ($f86).l
	rts

HEXCHARS:
	dc.b      "0123456789ABCDEF!"

	ORG $2a5a
	nop
	nop