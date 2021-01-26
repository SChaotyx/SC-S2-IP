; ---------------------------------------------------------------------------
; Multi Character pattern loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


LoadCharDynPLC:
	moveq	#0,d0
	move.b	mapping_frame(a0),d0	; load frame number

LoadCharDynPLC_Part2:
    _cmpi.b	#ObjID_MainPlayer,id(a0)
	beq.s	+
    cmp.b	(Tails_LastLoadedDPLC).w,d0
	beq.s	Creturn_1B89A
	move.b	d0,(Tails_LastLoadedDPLC).w
    bra.s   ++
+
	cmp.b	(Sonic_LastLoadedDPLC).w,d0
	beq.s	Creturn_1B89A
	move.b	d0,(Sonic_LastLoadedDPLC).w
+
	jsr   SetPlayerDPLC
	add.w	d0,d0
	adda.w	(a2,d0.w),a2
	move.w	(a2)+,d5
	subq.w	#1,d5
	bmi.s	Creturn_1B89A
    _cmpi.b	#ObjID_MainPlayer,id(a0)
	beq.s	+
	move.w	#tiles_to_bytes(ArtTile_ArtUnc_Tails),d4
    bra.s   CPLC_ReadEntry
+
	move.w	#tiles_to_bytes(ArtTile_ArtUnc_Sonic),d4
; loc_1B86E:
CPLC_ReadEntry:
	moveq	#0,d1
	move.w	(a2)+,d1
	move.w	d1,d3
	lsr.w	#8,d3
	andi.w	#$F0,d3
	addi.w	#$10,d3
	andi.w	#$FFF,d1
	lsl.l	#5,d1
	bsr.w   SetPlayerArt
	move.w	d4,d2
	add.w	d3,d4
	add.w	d3,d4
	jsr	(QueueDMATransfer).l
	dbf	d5,CPLC_ReadEntry	; repeat for number of entries

Creturn_1B89A:
	rts
; ===========================================================================