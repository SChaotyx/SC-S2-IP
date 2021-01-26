; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------

	include "objects/characters/Char02 - Tails/Moves/Tails Fly.asm"

; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------


; ---------------------------------------------------------------------------
; Subroutine to reset Tails' mode when he lands on the floor
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1CB50:
Tails_ResetOnFloor:
	tst.b	pinball_mode(a0)
	bne.s	Tails_ResetOnFloor_Part3
	move.b	#AniIDTailsAni_Walk,anim(a0)
; loc_1CB5C:
Tails_ResetOnFloor_Part2:
	btst	#2,status(a0)
	beq.s	Tails_ResetOnFloor_Part3
	bclr	#2,status(a0)
	move.b	#$F,y_radius(a0) ; this slightly increases Tails' collision height to standing
	move.b	#9,x_radius(a0)
	move.b	#AniIDTailsAni_Walk,anim(a0)	; use running/walking/standing animation
	subq.w	#1,y_pos(a0)	; move Tails up 1 pixel so the increased height doesn't push him slightly into the ground
; loc_1CB80:
Tails_ResetOnFloor_Part3:
	bclr	#1,status(a0)
	bclr	#5,status(a0)
	bclr	#4,status(a0)
	move.b	#0,jumping(a0)
	move.w	#0,(Chain_Bonus_counter).w
	move.b	#0,flip_angle(a0)
	move.b	#0,flip_turned(a0)
	move.b	#0,flips_remaining(a0)
	move.w	#0,(Tails_Look_delay_counter).w
	move.b	#0,double_jump_flag(a0)
	move.b	#0,double_jump_properly(a0)
	cmpi.b	#AniIDTailsAni_Hang2,anim(a0)
	bne.s	return_1CBC4
	move.b	#AniIDTailsAni_Walk,anim(a0)

return_1CBC4:
	rts
; End of subroutine Tails_ResetOnFloor



; ---------------------------------------------------------------------------
; Subroutine to animate Tails' sprites
; See also: AnimateSprite and Sonic_Animate
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1CDC4:
Tails_Animate:
	lea	(TailsAniData).l,a1
; loc_1CDCA:
Tails_Animate_Part2:
	moveq	#0,d0
	move.b	anim(a0),d0
	cmp.b	next_anim(a0),d0	; has animation changed?
	beq.s	TAnim_Do		; if not, branch
	move.b	d0,next_anim(a0)	; set to next animation
	move.b	#0,anim_frame(a0)	; reset animation frame
	move.b	#0,anim_frame_duration(a0)	; reset frame duration
	bclr	#5,status(a0)
; loc_1CDEC:
TAnim_Do:
	add.w	d0,d0
	adda.w	(a1,d0.w),a1	; calculate address of appropriate animation script
	move.b	(a1),d0
	bmi.s	TAnim_WalkRunZoom	; if animation is walk/run/roll/jump, branch
	move.b	status(a0),d1
	andi.b	#1,d1
	andi.b	#$FC,render_flags(a0)
	or.b	d1,render_flags(a0)
	subq.b	#1,anim_frame_duration(a0)	; subtract 1 from frame duration
	bpl.s	TAnim_Delay			; if time remains, branch
	move.b	d0,anim_frame_duration(a0)	; load frame duration
; loc_1CE12:
TAnim_Do2:
	moveq	#0,d1
	move.b	anim_frame(a0),d1	; load current frame number
	move.b	1(a1,d1.w),d0		; read sprite number from script
	cmpi.b	#$F0,d0
	bhs.s	TAnim_End_FF		; if animation is complete, branch
; loc_1CE22:
TAnim_Next:
	move.b	d0,mapping_frame(a0)	; load sprite number
	addq.b	#1,anim_frame(a0)	; go to next frame
; return_1CE2A:
TAnim_Delay:
	rts
; ===========================================================================
; loc_1CE2C:
TAnim_End_FF:
	addq.b	#1,d0		; is the end flag = $FF ?
	bne.s	TAnim_End_FE	; if not, branch
	move.b	#0,anim_frame(a0)	; restart the animation
	move.b	1(a1),d0	; read sprite number
	bra.s	TAnim_Next
; ===========================================================================
; loc_1CE3C:
TAnim_End_FE:
	addq.b	#1,d0		; is the end flag = $FE ?
	bne.s	TAnim_End_FD	; if not, branch
	move.b	2(a1,d1.w),d0	; read the next byte in the script
	sub.b	d0,anim_frame(a0)	; jump back d0 bytes in the script
	sub.b	d0,d1
	move.b	1(a1,d1.w),d0	; read sprite number
	bra.s	TAnim_Next
; ===========================================================================
; loc_1CE50:
TAnim_End_FD:
	addq.b	#1,d0			; is the end flag = $FD ?
	bne.s	TAnim_End		; if not, branch
	move.b	2(a1,d1.w),anim(a0)	; read next byte, run that animation
; return_1CE5A:
TAnim_End:
	rts
; ===========================================================================
; loc_1CE5C:
TAnim_WalkRunZoom: ; a0=character
	; note: for some reason SAnim_WalkRun doesn't need to do this here...
	subq.b	#1,anim_frame_duration(a0)	; subtract 1 from Tails' frame duration
	bpl.s	TAnim_Delay			; if time remains, branch

	addq.b	#1,d0		; is the end flag = $FF ?
	bne.w	TAnim_Roll	; if not, branch
	moveq	#0,d0		; is animation walking/running?
	move.b	flip_angle(a0),d0	; if not, branch
	bne.w	TAnim_Tumble
	moveq	#0,d1
	move.b	angle(a0),d0	; get Tails' angle
	bmi.s	+
	beq.s	+
	subq.b	#1,d0
+
	move.b	status(a0),d2
	andi.b	#1,d2		; is Tails mirrored horizontally?
	bne.s	+		; if yes, branch
	not.b	d0		; reverse angle
+
	addi.b	#$10,d0		; add $10 to angle
	bpl.s	+		; if angle is $0-$7F, branch
	moveq	#3,d1
+
	andi.b	#$FC,render_flags(a0)
	eor.b	d1,d2
	or.b	d2,render_flags(a0)
	btst	#5,status(a0)
	bne.w	TAnim_Push
	lsr.b	#4,d0		; divide angle by 16
	andi.b	#6,d0		; angle must be 0, 2, 4 or 6
	mvabs.w	inertia(a0),d2	; get Tails' "speed" for animation purposes
    if status_sec_isSliding = 7
	tst.b	status_secondary(a0)
	bpl.w	+
    else
	btst	#status_sec_isSliding,status_secondary(a0)
	beq.w	+
    endif
	add.w	d2,d2
+
	move.b	d0,d3
	add.b	d3,d3
	add.b	d3,d3
	lea	(TailsAni_Walk).l,a1

	cmpi.w	#$600,d2		; is Tails going pretty fast?
	blo.s	TAnim_SpeedSelected	; if not, branch
	lea	(TailsAni_Run).l,a1
	move.b	d0,d3
	add.b	d3,d3
	cmpi.w	#$700,d2		; is Tails going really fast?
	blo.s	TAnim_SpeedSelected	; if not, branch
	lea	(TailsAni_HaulAss).l,a1
	move.b	d0,d3
; loc_1CEEE:
TAnim_SpeedSelected:
	neg.w	d2
	addi.w	#$800,d2
	bpl.s	+
	moveq	#0,d2
+
	lsr.w	#8,d2
	move.b	d2,anim_frame_duration(a0)	; modify frame duration
	bsr.w	TAnim_Do2
	add.b	d3,mapping_frame(a0)
	rts
; ===========================================================================
; loc_1CF08
TAnim_Tumble:
	move.b	flip_angle(a0),d0
	moveq	#0,d1
	move.b	status(a0),d2
	andi.b	#1,d2
	bne.s	TAnim_Tumble_Left
	andi.b	#$FC,render_flags(a0)
	addi.b	#$B,d0
	divu.w	#$16,d0
	addi.b	#$31,d0
	move.b	d0,mapping_frame(a0)
	move.b	#0,anim_frame_duration(a0)
	rts
; ===========================================================================
; loc_1CF36
TAnim_Tumble_Left:
	andi.b	#$FC,render_flags(a0)
	tst.b	flip_turned(a0)
	beq.s	+
	ori.b	#1,render_flags(a0)
	addi.b	#$B,d0
	bra.s	++
; ===========================================================================
+
	ori.b	#3,render_flags(a0)
	neg.b	d0
	addi.b	#$8F,d0
+
	divu.w	#$16,d0
	addi.b	#$31,d0
	move.b	d0,mapping_frame(a0)
	move.b	#0,anim_frame_duration(a0)
	rts

; ===========================================================================
; loc_1CF6E:
TAnim_Roll:
	addq.b	#1,d0		; is the end flag = $FE ?
	bne.s	TAnim_GetTailFrame	; if not, branch
	mvabs.w	inertia(a0),d2
	lea	(TailsAni_Roll2).l,a1
	cmpi.w	#$600,d2
	bhs.s	+
	lea	(TailsAni_Roll).l,a1
+
	neg.w	d2
	addi.w	#$400,d2
	bpl.s	+
	moveq	#0,d2
+
	lsr.w	#8,d2
	move.b	d2,anim_frame_duration(a0)
	move.b	status(a0),d1
	andi.b	#1,d1
	andi.b	#$FC,render_flags(a0)
	or.b	d1,render_flags(a0)
	bra.w	TAnim_Do2
; ===========================================================================
; loc_1CFB2
TAnim_Push:
	move.w	inertia(a0),d2
	bmi.s	+
	neg.w	d2
+
	addi.w	#$800,d2
	bpl.s	+
	moveq	#0,d2
+
	lsr.w	#6,d2
	move.b	d2,anim_frame_duration(a0)
	lea	(TailsAni_Push).l,a1
	move.b	status(a0),d1
	andi.b	#1,d1
	andi.b	#$FC,render_flags(a0)
	or.b	d1,render_flags(a0)
	bra.w	TAnim_Do2

; ===========================================================================
; loc_1CFE4:
TAnim_GetTailFrame:
	move.w	x_vel(a2),d1
	move.w	y_vel(a2),d2
	jsr	(CalcAngle).l
	moveq	#0,d1
	move.b	status(a0),d2
	andi.b	#1,d2
	bne.s	loc_1D002
	not.b	d0
	bra.s	loc_1D006
; ===========================================================================

loc_1D002:
	addi.b	#$80,d0

loc_1D006:
	addi.b	#$10,d0
	bpl.s	+
	moveq	#3,d1
+
	andi.b	#$FC,render_flags(a0)
	eor.b	d1,d2
	or.b	d2,render_flags(a0)
	lsr.b	#3,d0
	andi.b	#$C,d0
	move.b	d0,d3
	lea	(Obj05Ani_Directional).l,a1
	move.b	#3,anim_frame_duration(a0)
	bsr.w	TAnim_Do2
	add.b	d3,mapping_frame(a0)
	rts
; ===========================================================================

; ---------------------------------------------------------------------------
; Animation script - Tails
; ---------------------------------------------------------------------------
; off_1D038:
TailsAniData:		offsetTable
TailsAni_Walk_ptr:	offsetTableEntry.w TailsAni_Walk	;  0 ;   0
TailsAni_Run_ptr:	offsetTableEntry.w TailsAni_Run		;  1 ;   1
TailsAni_Roll_ptr:	offsetTableEntry.w TailsAni_Roll	;  2 ;   2
TailsAni_Roll2_ptr:	offsetTableEntry.w TailsAni_Roll2	;  3 ;   3
TailsAni_Push_ptr:	offsetTableEntry.w TailsAni_Push	;  4 ;   4
TailsAni_Wait_ptr:	offsetTableEntry.w TailsAni_Wait	;  5 ;   5
TailsAni_Balance_ptr:	offsetTableEntry.w TailsAni_Balance	;  6 ;   6
TailsAni_LookUp_ptr:	offsetTableEntry.w TailsAni_LookUp	;  7 ;   7
TailsAni_Duck_ptr:	offsetTableEntry.w TailsAni_Duck	;  8 ;   8
TailsAni_Spindash_ptr:	offsetTableEntry.w TailsAni_Spindash	;  9 ;   9
TailsAni_Dummy1_ptr:	offsetTableEntry.w TailsAni_Dummy1	; 10 ;  $A
TailsAni_Dummy2_ptr:	offsetTableEntry.w TailsAni_Dummy2	; 11 ;  $B
TailsAni_Dummy3_ptr:	offsetTableEntry.w TailsAni_Dummy3	; 12 ;  $C
TailsAni_Stop_ptr:	offsetTableEntry.w TailsAni_Stop	; 13 ;  $D
TailsAni_Float_ptr:	offsetTableEntry.w TailsAni_Float	; 14 ;  $E
TailsAni_Float2_ptr:	offsetTableEntry.w TailsAni_Float2	; 15 ;  $F
TailsAni_Spring_ptr:	offsetTableEntry.w TailsAni_Spring	; 16 ; $10
TailsAni_Hang_ptr:	offsetTableEntry.w TailsAni_Hang	; 17 ; $11
TailsAni_Blink_ptr:	offsetTableEntry.w TailsAni_Blink	; 18 ; $12
TailsAni_Blink2_ptr:	offsetTableEntry.w TailsAni_Blink2	; 19 ; $13
TailsAni_Hang2_ptr:	offsetTableEntry.w TailsAni_Hang2	; 20 ; $14
TailsAni_Bubble_ptr:	offsetTableEntry.w TailsAni_Bubble	; 21 ; $15
TailsAni_DeathBW_ptr:	offsetTableEntry.w TailsAni_DeathBW	; 22 ; $16
TailsAni_Drown_ptr:	offsetTableEntry.w TailsAni_Drown	; 23 ; $17
TailsAni_Death_ptr:	offsetTableEntry.w TailsAni_Death	; 24 ; $18
TailsAni_Hurt_ptr:	offsetTableEntry.w TailsAni_Hurt	; 25 ; $19
TailsAni_Hurt2_ptr:	offsetTableEntry.w TailsAni_Hurt2	; 26 ; $1A
TailsAni_Slide_ptr:	offsetTableEntry.w TailsAni_Slide	; 27 ; $1B
TailsAni_Blank_ptr:	offsetTableEntry.w TailsAni_Blank	; 28 ; $1C
TailsAni_Dummy4_ptr:	offsetTableEntry.w TailsAni_Dummy4	; 29 ; $1D
TailsAni_Dummy5_ptr:	offsetTableEntry.w TailsAni_Dummy5	; 30 ; $1E
TailsAni_HaulAss_ptr:	offsetTableEntry.w TailsAni_HaulAss	; 31 ; $1F
TailsAni_Fly_ptr:	offsetTableEntry.w TailsAni_Fly		; 32 ; $20
TailsAni_Tired_ptr:	offsetTableEntry.w TailsAni_Tired		; 33 ; $21
TailsAni_Swim_ptr:	offsetTableEntry.w TailsAni_Swim		; 34 ; $22
TailsAni_SwimTired_ptr:	offsetTableEntry.w TailsAni_SwimTired		; 35 ; $34

TailsAni_Walk:	dc.b  $FF,   7,   8,   1,   2,   3,   4,   5,   6, $FF
	rev02even
TailsAni_Run:	dc.b  $FF, $21, $22, $23, $24, $FF, $FF, $FF, $FF, $FF
	rev02even
TailsAni_Roll:	dc.b    1, $96, $97, $98, $FF
	rev02even
TailsAni_Roll2:	dc.b    0, $96, $97, $98, $FF
	rev02even
TailsAni_Push:	dc.b  $FD, $A9, $AA, $AB, $AC, $FF, $FF, $FF, $FF, $FF
	rev02even
TailsAni_Wait:	dc.b    7, $AD, $AD, $AD, $AD, $AD, $AD, $AD, $AD, $AD, $AD, $AF, $AE, $AD, $AD, $AD
				dc.b  $AD, $AD, $AD, $AD, $AD, $AF, $AE, $AD, $AD, $AD, $AD, $AD, $AD, $AD, $AD, $AD
				dc.b  $B1, $B1, $B1, $B1, $B1, $B1, $B1, $B1, $B1, $B1, $B1, $B1, $B1, $B1, $B1, $B1
				dc.b  $B2, $B3, $B4, $B3, $B4, $B3, $B4, $B3, $B4, $B3, $B4, $B2, $FE, $1C
	rev02even
TailsAni_Balance:	dc.b    9, $9A, $9A, $9B, $9B, $9A, $9A, $9B, $9B, $9A, $9A, $9B, $9B, $9A, $9A, $9B
					dc.b  $9B, $9A, $9A, $9B, $9B, $9A, $9B, $FF
	rev02even
TailsAni_LookUp:	dc.b  $3F, $B0, $FF
	rev02even
TailsAni_Duck:		dc.b  $3F, $99, $FF
	rev02even
TailsAni_Spindash:	dc.b    0, $86, $87, $88, $FF
	rev02even
TailsAni_Dummy1:	dc.b $3F,$82,$FF
	rev02even
TailsAni_Dummy2:	dc.b   7,  8,  8,  9,$FD,  5
	rev02even
TailsAni_Dummy3:	dc.b   7,  9,$FD,  5
	rev02even
TailsAni_Stop:		dc.b    3, $8E, $8F, $8E, $8F, $FD,   0
	rev02even
TailsAni_Float:		dc.b    9, $B5, $FF
	rev02even
TailsAni_Float2:	dc.b    9, $B5, $B6, $B7, $B8, $B9, $BA, $BB, $BC, $FF
	rev02even
TailsAni_Spring:	dc.b    3, $8B, $8C, $8B, $8C, $8B, $8C, $8B, $8C, $8B, $8C, $8B, $8C, $FD,   0
	rev02even
TailsAni_Hang:		dc.b    1, $9D, $9E, $FF
	rev02even
TailsAni_Blink:		dc.b   $F,   1,   2,   3, $FE,   1
	rev02even
TailsAni_Blink2:	dc.b   $F, $A5, $A6, $FE,   1
	rev02even
TailsAni_Hang2:		dc.b  $13, $91, $FF
	rev02even
TailsAni_Bubble:	dc.b   $B, $9F, $9F,   3,   4, $FD,   0
	rev02even
TailsAni_DeathBW:	dc.b  $20, $9C, $FF
	rev02even
TailsAni_Drown:		dc.b  $2F, $9C, $FF
	rev02even
TailsAni_Death:		dc.b    3, $9C, $FF
	rev02even
TailsAni_Hurt:		dc.b  $40, $8A, $FF
	rev02even
TailsAni_Hurt2:		dc.b    9, $89, $8A, $FF
	rev02even
TailsAni_Slide:		dc.b    9, $CB, $CC, $FF
	rev02even
TailsAni_Blank:		dc.b $77,  0,$FD,  0
	rev02even
TailsAni_Dummy4:	dc.b   3,  1,  2,  3,  4,  5,  6,  7,  8,$FF
	rev02even
TailsAni_Dummy5:	dc.b   3,  1,  2,  3,  4,  5,  6,  7,  8,$FF
	rev02even
TailsAni_HaulAss:	dc.b  $FF, $C3, $C4, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	rev02even
TailsAni_Fly:		dc.b  $1F, $A0, $FF
	rev02even
TailsAni_Tired:		dc.b   $B, $A3, $A4, $FF
	rev02even
TailsAni_Swim:		dc.b    7, $BD, $BE, $BF, $C0, $C1, $FF
	rev02even
TailsAni_SwimTired: dc.b	$B, $C2, $CD, $CE, $FF
	even

; ===========================================================================



; ---------------------------------------------------------------------------
; Tails pattern loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1D1AC:
LoadTailsDynPLC:
	moveq	#0,d0
	move.b	mapping_frame(a0),d0	; load frame number
; loc_1D1B2:
LoadTailsDynPLC_Part2:
	cmp.b	(Tails_LastLoadedDPLC).w,d0
	beq.s	return_1D1FE
	move.b	d0,(Tails_LastLoadedDPLC).w
	lea	(MapRUnc_Tails).l,a2
	add.w	d0,d0
	adda.w	(a2,d0.w),a2
	move.w	(a2)+,d5
	subq.w	#1,d5
	bmi.s	return_1D1FE
	move.w	#tiles_to_bytes(ArtTile_ArtUnc_Tails),d4
; loc_1D1D2:
TPLC_ReadEntry:
	moveq	#0,d1
	move.w	(a2)+,d1
	move.w	d1,d3
	lsr.w	#8,d3
	andi.w	#$F0,d3
	addi.w	#$10,d3
	andi.w	#$FFF,d1
	lsl.l	#5,d1
	addi.l	#ArtUnc_Tails,d1
	move.w	d4,d2
	add.w	d3,d4
	add.w	d3,d4
	jsr	(QueueDMATransfer).l
	dbf	d5,TPLC_ReadEntry	; repeat for number of entries

return_1D1FE:
	rts


; ---------------------------------------------------------------------------
; Tails' Tails pattern loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1D184:
LoadTailsTailsDynPLC:
	moveq	#0,d0
	move.b	mapping_frame(a0),d0
	cmp.b	(TailsTails_LastLoadedDPLC).w,d0
	beq.w	return_1D1FE2
	move.b	d0,(TailsTails_LastLoadedDPLC).w
	lea	(MapRUnc_TailsTails).l,a2
	add.w	d0,d0
	adda.w	(a2,d0.w),a2
	move.w	(a2)+,d5
	subq.w	#1,d5
	bmi.w	return_1D1FE2
	move.w	#tiles_to_bytes(ArtTile_ArtUnc_Tails_Tails),d4
	bra.w	TTPLC_ReadEntry

TTPLC_ReadEntry:
	moveq	#0,d1
	move.w	(a2)+,d1
	move.w	d1,d3
	lsr.w	#8,d3
	andi.w	#$F0,d3
	addi.w	#$10,d3
	andi.w	#$FFF,d1
	lsl.l	#5,d1
	addi.l	#ArtUnc_TailsTails,d1
	move.w	d4,d2
	add.w	d3,d4
	add.w	d3,d4
	jsr	(QueueDMATransfer).l
	dbf	d5,TTPLC_ReadEntry	; repeat for number of entries

return_1D1FE2:
	rts
