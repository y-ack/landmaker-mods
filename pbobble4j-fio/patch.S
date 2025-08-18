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
SCANLINE = -$1A2A				; $4065d6
PRINT_HEX = $8D4
VBLANK_RETURN = $15BC
	
	;; replace vblank handler spin loop timer
	ORG $15b4
	jmp      (vblank_hook).l


	ORG ROM_FREE

frame_processing = $140e
;;; new frame counter update and timer interrupt
vblank_hook:
	movem.l   D0,-(SP)
	movem.l   A6/A4/D7/D6/D5,-(SP)
	;; screen destination
	lea       ($61c00c).l,A4
	;; FIO byte
	lea       ($4a0000).l,A6
	;; dwords to print
	moveq     #32,D0 ;; 64 / 4 
.next_fio:
	move.w    (A6)+,D5
	moveq     #$3,D7
.print_nybble:
	rol.w     #$4,D5
	move.w    D5,D6
	andi.w    #$F,D6
	move.b    (HEXCHARS,PC,D6),D6
	ori.w     #$1000,D6
	move.w    D6,(A4)+
	dbf       D7,.print_nybble

	;; skip screen addr for space
;	addq.w    #2,A4
	add.w     #$078,A4
.nonewline:
	dbf       D0,.next_fio

	;; not restoring D0 for vblank
	movem.l   (SP)+,A6/A4/D7/D6/D5

	move.w    #$500,D0	
	jmp       (VBLANK_RETURN).l


HEXCHARS:
	dc.b      "0123456789ABCDEF!"
