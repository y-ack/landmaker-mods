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
	
	;; ORG AVEC_5_PTR
	;; dc.l timer_int
	;; ORG $434
	;; dc.w $2789

	;; replace vblank handler spin loop timer
	ORG $15b4
	jmp      (vblank_hook).l
	;; replace frame processing graphics ready trampoline
	ORG $15de
	jmp      (gfx_int_hook).l


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
	movem.l   A6/A4/A2/A1/A0/D7/D6/D5/D2/D1,-(SP)
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

;;; draw sprites
SPRITE_0 = $6030C0
    move.l #SPRITE_0,D2			;spriteram ptr
    sub.l  A1,A1				;y
    move.w #780,A2				;sprite id
.L2:
    move.l D2,A0
    move.l A2,D1
    clr.w  D0
.L3:
    move.w D1,(A0)				;tile id
    clr.b  2(A0)				;y zoom
    clr.b  3(A0)				;x zoom
	;; move.w D0,D5				;
	;; or.w   #$C000,D5
    move.w D0,4(A0)				;x_pos
    move.w A1,6(A0)				;y_pos
    move.b #$C1,9(A0)			;palette
    addq.l #1,D1
    addq.w #8,D0				;inc x
    addq.w #8,D0
    addq.w #8,A0  				;inc sprite
    addq.w #8,A0
    cmp.w  #336,D0				; wrap to next line?
    bne    .L3					; no, next x sprite
    lea    (21,A2),A2			;inc sprite (2)
    addq.w #8,A1				;next y
    addq.w #8,A1				;
    add.l  #336,D2
    cmp.w  #1095,A2
    bne    .L2
    clr.w  D0
	
	;; reset scanline counter
	move.w    #0,SCANLINE(A5)
	;; not restoring D0 for vblank
	movem.l   (SP)+,A6/A4/A2/A1/A0/D7/D6/D5/D2/D1

	move.w    #$500,D0	
	jmp       (VBLANK_RETURN).l


HEXCHARS:
	dc.b      "0123456789ABCDEF!"

	ORG $2a5a
	nop
	nop