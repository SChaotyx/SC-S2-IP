; ---------------------------------------------------------------------------
; Knuckles pattern loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1B848:
LoadKnucklesDynPLC:
	moveq	#0,d0
	move.b	mapping_frame(a0),d0	; load frame number
; loc_1B84E:
LoadKnucklesDynPLC_Part2:
	cmpi.b	#1,(Main_player).w
	beq.s	+
	cmpi.b	#1,(Sec_player).w
	beq.s	+

	cmp.b	(Sonic_LastLoadedDPLC).w,d0
	beq.s	return_LKDPLC
	move.b	d0,(Sonic_LastLoadedDPLC).w
	bra.s	LoadKnucklesDynPLC_Continue
+
	cmp.b	(Tails_LastLoadedDPLC).w,d0
	beq.s	return_LKDPLC
	move.b	d0,(Tails_LastLoadedDPLC).w

LoadKnucklesDynPLC_Continue:
	lea	(MapRUnc_Knuckles).l,a2
	add.w	d0,d0
	adda.w	(a2,d0.w),a2
	move.w	(a2)+,d5
	subq.w	#1,d5
	bmi.s	return_LKDPLC
	cmpi.b	#1,(Main_player).w
	beq.s	+
	cmpi.b	#1,(Sec_player).w
	beq.s	+

	move.w	#tiles_to_bytes(ArtTile_ArtUnc_Sonic),d4
	bra.s	KPLC_ReadEntry
+
	move.w	#tiles_to_bytes(ArtTile_ArtUnc_Tails),d4

KPLC_ReadEntry:
	moveq	#0,d1
	move.w	(a2)+,d1
	move.w	d1,d3
	lsr.w	#8,d3
	andi.w	#$F0,d3
	addi.w	#$10,d3
	andi.w	#$FFF,d1
	lsl.l	#5,d1
	addi.l	#ArtUnc_Knuckles,d1
	move.w	d4,d2
	add.w	d3,d4
	add.w	d3,d4
	jsr	(QueueDMATransfer).l
	dbf	d5,KPLC_ReadEntry	; repeat for number of entries

return_LKDPLC:
	rts
