; ---------------------------------------------------------------------------
; Subroutine to animate Sonic's sprites
; See also: AnimateSprite
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1B350:
Sonic_Animate:
    cmpi.b  #2,(Main_player).w
    beq.w   Tails_AnimatePart2
	cmpi.b  #3,(Main_player).w
    beq.w   Knuckles_Animate
Sonic_AnimatePart2:
	lea	(SonicAniData).l,a1
	tst.b	(Super_Sonic_flag).w
	beq.s	+
	lea	(SuperSonicAniData).l,a1
+
	moveq	#0,d0
	move.b	anim(a0),d0
	cmp.b	next_anim(a0),d0	; has animation changed?
	beq.s	SAnim_Do		; if not, branch
	move.b	d0,next_anim(a0)	; set to next animation
	move.b	#0,anim_frame(a0)	; reset animation frame
	move.b	#0,anim_frame_duration(a0)	; reset frame duration
	bclr	#5,status(a0)
; loc_1B384:
SAnim_Do:
	add.w	d0,d0
	adda.w	(a1,d0.w),a1	; calculate address of appropriate animation script
	move.b	(a1),d0
	bmi.s	SAnim_WalkRun	; if animation is walk/run/roll/jump, branch
	move.b	status(a0),d1
	andi.b	#1,d1
	andi.b	#$FC,render_flags(a0)
	or.b	d1,render_flags(a0)
	subq.b	#1,anim_frame_duration(a0)	; subtract 1 from frame duration
	bpl.s	SAnim_Delay			; if time remains, branch
	move.b	d0,anim_frame_duration(a0)	; load frame duration
; loc_1B3AA:
SAnim_Do2:
	moveq	#0,d1
	move.b	anim_frame(a0),d1	; load current frame number
	move.b	1(a1,d1.w),d0		; read sprite number from script
	cmpi.b	#$F0,d0
	bhs.s	SAnim_End_FF		; if animation is complete, branch
; loc_1B3BA:
SAnim_Next:
	move.b	d0,mapping_frame(a0)	; load sprite number
	addq.b	#1,anim_frame(a0)	; go to next frame
; return_1B3C2:
SAnim_Delay:
	rts
; ===========================================================================
; loc_1B3C4:
SAnim_End_FF:
	addq.b	#1,d0		; is the end flag = $FF ?
	bne.s	SAnim_End_FE	; if not, branch
	move.b	#0,anim_frame(a0)	; restart the animation
	move.b	1(a1),d0	; read sprite number
	bra.s	SAnim_Next
; ===========================================================================
; loc_1B3D4:
SAnim_End_FE:
	addq.b	#1,d0		; is the end flag = $FE ?
	bne.s	SAnim_End_FD	; if not, branch
	move.b	2(a1,d1.w),d0	; read the next byte in the script
	sub.b	d0,anim_frame(a0)	; jump back d0 bytes in the script
	sub.b	d0,d1
	move.b	1(a1,d1.w),d0	; read sprite number
	bra.s	SAnim_Next
; ===========================================================================
; loc_1B3E8:
SAnim_End_FD:
	addq.b	#1,d0			; is the end flag = $FD ?
	bne.s	SAnim_End		; if not, branch
	move.b	2(a1,d1.w),anim(a0)	; read next byte, run that animation
; return_1B3F2:
SAnim_End:
	rts
; ===========================================================================
; loc_1B3F4:
SAnim_WalkRun:
	addq.b	#1,d0		; is the start flag = $FF ?
	bne.w	SAnim_Roll	; if not, branch
	moveq	#0,d0		; is animation walking/running?
	move.b	flip_angle(a0),d0	; if not, branch
	bne.w	SAnim_Tumble
	moveq	#0,d1
	move.b	angle(a0),d0	; get Sonic's angle
	bmi.s	+
	beq.s	+
	subq.b	#1,d0
+
	move.b	status(a0),d2
	andi.b	#1,d2		; is Sonic mirrored horizontally?
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
	bne.w	SAnim_Push
	lsr.b	#4,d0		; divide angle by 16
	andi.b	#6,d0		; angle must be 0, 2, 4 or 6
	mvabs.w	inertia(a0),d2	; get Sonic's "speed" for animation purposes
    if status_sec_isSliding = 7
	tst.b	status_secondary(a0)
	bpl.w	+
    else
	btst	#status_sec_isSliding,status_secondary(a0)
	beq.w	+
    endif
	add.w	d2,d2
+
	tst.b	(Super_Sonic_flag).w
	bne.s	SAnim_Super
	lea	(SonAni_Run).l,a1	; use running animation
	cmpi.w	#$600,d2		; is Sonic at running speed?
	bhs.s	+			; use running animation
	lea	(SonAni_Walk).l,a1	; if yes, branch
	add.b	d0,d0
+
	add.b	d0,d0
	move.b	d0,d3
	moveq	#0,d1
	move.b	anim_frame(a0),d1
	move.b	1(a1,d1.w),d0
	cmpi.b	#-1,d0
	bne.s	+
	move.b	#0,anim_frame(a0)
	move.b	1(a1),d0
+
	move.b	d0,mapping_frame(a0)
	add.b	d3,mapping_frame(a0)
	subq.b	#1,anim_frame_duration(a0)
	bpl.s	return_1B4AC
	neg.w	d2
	addi.w	#$800,d2
	bpl.s	+
	moveq	#0,d2
+
	lsr.w	#8,d2
	move.b	d2,anim_frame_duration(a0)	; modify frame duration
	addq.b	#1,anim_frame(a0)		; modify frame number

return_1B4AC:
	rts
; ===========================================================================
; loc_1B4AE:
SAnim_Super:
	lea	(SupSonAni_Run).l,a1	; use fast animation
	cmpi.w	#$800,d2		; is Sonic moving fast?
	bhs.s	SAnim_SuperRun		; if yes, branch
	lea	(SupSonAni_Walk).l,a1	; use slower animation
	add.b	d0,d0
	add.b	d0,d0
	bra.s	SAnim_SuperWalk
; ---------------------------------------------------------------------------
; loc_1B4C6:
SAnim_SuperRun:
	lsr.b	#1,d0
; loc_1B4C8:
SAnim_SuperWalk:
	move.b	d0,d3
	moveq	#0,d1
	move.b	anim_frame(a0),d1
	move.b	1(a1,d1.w),d0
	cmpi.b	#-1,d0
	bne.s	+
	move.b	#0,anim_frame(a0)
	move.b	1(a1),d0
+
	move.b	d0,mapping_frame(a0)
	add.b	d3,mapping_frame(a0)
	move.b	(Timer_frames+1).w,d1
	andi.b	#3,d1
	bne.s	+
	cmpi.b	#$B5,mapping_frame(a0)
	bhs.s	+
	addi.b	#$20,mapping_frame(a0)
+
	subq.b	#1,anim_frame_duration(a0)
	bpl.s	return_1B51E
	neg.w	d2
	addi.w	#$800,d2
	bpl.s	+
	moveq	#0,d2
+
	lsr.w	#8,d2
	move.b	d2,anim_frame_duration(a0)
	addq.b	#1,anim_frame(a0)

return_1B51E:
	rts
; ===========================================================================
; loc_1B520:
SAnim_Tumble:
	move.b	flip_angle(a0),d0
	moveq	#0,d1
	move.b	status(a0),d2
	andi.b	#1,d2
	bne.s	SAnim_Tumble_Left

	andi.b	#$FC,render_flags(a0)
	addi.b	#$B,d0
	divu.w	#$16,d0
	addi.b	#$5F,d0
	move.b	d0,mapping_frame(a0)
	move.b	#0,anim_frame_duration(a0)
	rts
; ===========================================================================
; loc_1B54E:
SAnim_Tumble_Left:
	andi.b	#$FC,render_flags(a0)
	tst.b	flip_turned(a0)
	beq.s	loc_1B566
	ori.b	#1,render_flags(a0)
	addi.b	#$B,d0
	bra.s	loc_1B572
; ===========================================================================

loc_1B566:
	ori.b	#3,render_flags(a0)
	neg.b	d0
	addi.b	#$8F,d0

loc_1B572:
	divu.w	#$16,d0
	addi.b	#$5F,d0
	move.b	d0,mapping_frame(a0)
	move.b	#0,anim_frame_duration(a0)
	rts
; ===========================================================================
; loc_1B586:
SAnim_Roll:
	subq.b	#1,anim_frame_duration(a0)	; subtract 1 from frame duration
	bpl.w	SAnim_Delay			; if time remains, branch
	addq.b	#1,d0		; is the start flag = $FE ?
	bne.s	SAnim_Push	; if not, branch
	mvabs.w	inertia(a0),d2
	lea	(SonAni_Roll2).l,a1
	cmpi.w	#$600,d2
	bhs.s	+
	lea	(SonAni_Roll).l,a1
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
	bra.w	SAnim_Do2
; ===========================================================================

SAnim_Push:
	subq.b	#1,anim_frame_duration(a0)	; subtract 1 from frame duration
	bpl.w	SAnim_Delay			; if time remains, branch
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
	lea	(SonAni_Push).l,a1
	tst.b	(Super_Sonic_flag).w
	beq.s	+
	lea	(SupSonAni_Push).l,a1
+
	move.b	status(a0),d1
	andi.b	#1,d1
	andi.b	#$FC,render_flags(a0)
	or.b	d1,render_flags(a0)
	bra.w	SAnim_Do2
; ===========================================================================

; ---------------------------------------------------------------------------
; Animation script - Sonic
; ---------------------------------------------------------------------------
; off_1B618:
SonicAniData:			offsetTable
SonAni_Walk_ptr:		offsetTableEntry.w SonAni_Walk		;  0 ;   0
SonAni_Run_ptr:			offsetTableEntry.w SonAni_Run		;  1 ;   1
SonAni_Roll_ptr:		offsetTableEntry.w SonAni_Roll		;  2 ;   2
SonAni_Roll2_ptr:		offsetTableEntry.w SonAni_Roll2		;  3 ;   3
SonAni_Push_ptr:		offsetTableEntry.w SonAni_Push		;  4 ;   4
SonAni_Wait_ptr:		offsetTableEntry.w SonAni_Wait		;  5 ;   5
SonAni_Balance_ptr:		offsetTableEntry.w SonAni_Balance	;  6 ;   6
SonAni_LookUp_ptr:		offsetTableEntry.w SonAni_LookUp	;  7 ;   7
SonAni_Duck_ptr:		offsetTableEntry.w SonAni_Duck		;  8 ;   8
SonAni_Spindash_ptr:		offsetTableEntry.w SonAni_Spindash	;  9 ;   9
SonAni_Blink_ptr:		offsetTableEntry.w SonAni_Blink		; 10 ;  $A
SonAni_GetUp_ptr:		offsetTableEntry.w SonAni_GetUp		; 11 ;  $B
SonAni_Balance2_ptr:		offsetTableEntry.w SonAni_Balance2	; 12 ;  $C
SonAni_Stop_ptr:		offsetTableEntry.w SonAni_Stop		; 13 ;  $D
SonAni_Float_ptr:		offsetTableEntry.w SonAni_Float		; 14 ;  $E
SonAni_Float2_ptr:		offsetTableEntry.w SonAni_Float2	; 15 ;  $F
SonAni_Spring_ptr:		offsetTableEntry.w SonAni_Spring	; 16 ; $10
SonAni_Hang_ptr:		offsetTableEntry.w SonAni_Hang		; 17 ; $11
SonAni_Dash2_ptr:		offsetTableEntry.w SonAni_Dash2		; 18 ; $12
SonAni_Dash3_ptr:		offsetTableEntry.w SonAni_Dash3		; 19 ; $13
SonAni_Hang2_ptr:		offsetTableEntry.w SonAni_Hang2		; 20 ; $14
SonAni_Bubble_ptr:		offsetTableEntry.w SonAni_Bubble	; 21 ; $15
SonAni_DeathBW_ptr:		offsetTableEntry.w SonAni_DeathBW	; 22 ; $16
SonAni_Drown_ptr:		offsetTableEntry.w SonAni_Drown		; 23 ; $17
SonAni_Death_ptr:		offsetTableEntry.w SonAni_Death		; 24 ; $18
SonAni_Hurt_ptr:		offsetTableEntry.w SonAni_Hurt		; 25 ; $19
SonAni_Hurt2_ptr:		offsetTableEntry.w SonAni_Hurt		; 26 ; $1A
SonAni_Slide_ptr:		offsetTableEntry.w SonAni_Slide		; 27 ; $1B
SonAni_Blank_ptr:		offsetTableEntry.w SonAni_Blank		; 28 ; $1C
SonAni_Balance3_ptr:		offsetTableEntry.w SonAni_Balance3	; 29 ; $1D
SonAni_Balance4_ptr:		offsetTableEntry.w SonAni_Balance4	; 30 ; $1E
SupSonAni_Transform_ptr:	offsetTableEntry.w SupSonAni_Transform	; 31 ; $1F
SonAni_Lying_ptr:		offsetTableEntry.w SonAni_Lying		; 32 ; $20
SonAni_LieDown_ptr:		offsetTableEntry.w SonAni_LieDown	; 33 ; $21

SonAni_Walk:	dc.b $FF, $F,$10,$11,$12,$13,$14, $D, $E,$FF
	rev02even
SonAni_Run:	dc.b $FF,$2D,$2E,$2F,$30,$FF,$FF,$FF,$FF,$FF
	rev02even
SonAni_Roll:	dc.b $FE,$3D,$41,$3E,$41,$3F,$41,$40,$41,$FF
	rev02even
SonAni_Roll2:	dc.b $FE,$3D,$41,$3E,$41,$3F,$41,$40,$41,$FF
	rev02even
SonAni_Push:	dc.b $FD,$48,$49,$4A,$4B,$FF,$FF,$FF,$FF,$FF
	rev02even
SonAni_Wait:
	dc.b   5,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1
	dc.b   1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  2
	dc.b   3,  3,  3,  3,  3,  4,  4,  4,  5,  5,  5,  4,  4,  4,  5,  5
	dc.b   5,  4,  4,  4,  5,  5,  5,  4,  4,  4,  5,  5,  5,  6,  6,  6
	dc.b   6,  6,  6,  6,  6,  6,  6,  4,  4,  4,  5,  5,  5,  4,  4,  4
	dc.b   5,  5,  5,  4,  4,  4,  5,  5,  5,  4,  4,  4,  5,  5,  5,  6
	dc.b   6,  6,  6,  6,  6,  6,  6,  6,  6,  4,  4,  4,  5,  5,  5,  4
	dc.b   4,  4,  5,  5,  5,  4,  4,  4,  5,  5,  5,  4,  4,  4,  5,  5
	dc.b   5,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  4,  4,  4,  5,  5
	dc.b   5,  4,  4,  4,  5,  5,  5,  4,  4,  4,  5,  5,  5,  4,  4,  4
	dc.b   5,  5,  5,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  7,  8,  8
	dc.b   8,  9,  9,  9,$FE,  6
	rev02even
SonAni_Balance:	dc.b   9,$CC,$CD,$CE,$CD,$FF
	rev02even
SonAni_LookUp:	dc.b   5, $B, $C,$FE,  1
	rev02even
SonAni_Duck:	dc.b   5,$4C,$4D,$FE,  1
	rev02even
SonAni_Spindash:dc.b   0,$42,$43,$42,$44,$42,$45,$42,$46,$42,$47,$FF
	rev02even
SonAni_Blink:	dc.b   1,  2,$FD,  0
	rev02even
SonAni_GetUp:	dc.b   3, $A,$FD,  0
	rev02even
SonAni_Balance2:dc.b   3,$C8,$C9,$CA,$CB,$FF
	rev02even
SonAni_Stop:	dc.b   5,$D2,$D3,$D4,$D5,$FD,  0 ; halt/skidding animation
	rev02even
SonAni_Float:	dc.b   7,$54,$59,$FF
	rev02even
SonAni_Float2:	dc.b   7,$54,$55,$56,$57,$58,$FF
	rev02even
SonAni_Spring:	dc.b $2F,$5B,$FD,  0
	rev02even
SonAni_Hang:	dc.b   1,$50,$51,$FF
	rev02even
SonAni_Dash2:	dc.b  $F,$43,$43,$43,$FE,  1
	rev02even
SonAni_Dash3:	dc.b  $F,$43,$44,$FE,  1
	rev02even
SonAni_Hang2:	dc.b $13,$6B,$6C,$FF
	rev02even
SonAni_Bubble:	dc.b  $B,$5A,$5A,$11,$12,$FD,  0 ; breathe
	rev02even
SonAni_DeathBW:	dc.b $20,$5E,$FF
	rev02even
SonAni_Drown:	dc.b $20,$5D,$FF
	rev02even
SonAni_Death:	dc.b $20,$5C,$FF
	rev02even
SonAni_Hurt:	dc.b $40,$4E,$FF
	rev02even
SonAni_Slide:	dc.b   9,$4E,$4F,$FF
	rev02even
SonAni_Blank:	dc.b $77,  0,$FD,  0
	rev02even
SonAni_Balance3:dc.b $13,$D0,$D1,$FF
	rev02even
SonAni_Balance4:dc.b   3,$CF,$C8,$C9,$CA,$CB,$FE,  4
	rev02even
SonAni_Lying:	dc.b   9,  8,  9,$FF
	rev02even
SonAni_LieDown:	dc.b   3,  7,$FD,  0
	even

; ---------------------------------------------------------------------------
; Animation script - Super Sonic
; (many of these point to the data above this)
; ---------------------------------------------------------------------------
SuperSonicAniData: offsetTable
	offsetTableEntry.w SupSonAni_Walk	;  0 ;   0
	offsetTableEntry.w SupSonAni_Run	;  1 ;   1
	offsetTableEntry.w SonAni_Roll		;  2 ;   2
	offsetTableEntry.w SonAni_Roll2		;  3 ;   3
	offsetTableEntry.w SupSonAni_Push	;  4 ;   4
	offsetTableEntry.w SupSonAni_Stand	;  5 ;   5
	offsetTableEntry.w SupSonAni_Balance	;  6 ;   6
	offsetTableEntry.w SonAni_LookUp	;  7 ;   7
	offsetTableEntry.w SupSonAni_Duck	;  8 ;   8
	offsetTableEntry.w SonAni_Spindash	;  9 ;   9
	offsetTableEntry.w SonAni_Blink		; 10 ;  $A
	offsetTableEntry.w SonAni_GetUp		; 11 ;  $B
	offsetTableEntry.w SonAni_Balance2	; 12 ;  $C
	offsetTableEntry.w SonAni_Stop		; 13 ;  $D
	offsetTableEntry.w SonAni_Float		; 14 ;  $E
	offsetTableEntry.w SonAni_Float2	; 15 ;  $F
	offsetTableEntry.w SonAni_Spring	; 16 ; $10
	offsetTableEntry.w SonAni_Hang		; 17 ; $11
	offsetTableEntry.w SonAni_Dash2		; 18 ; $12
	offsetTableEntry.w SonAni_Dash3		; 19 ; $13
	offsetTableEntry.w SonAni_Hang2		; 20 ; $14
	offsetTableEntry.w SonAni_Bubble	; 21 ; $15
	offsetTableEntry.w SonAni_DeathBW	; 22 ; $16
	offsetTableEntry.w SonAni_Drown		; 23 ; $17
	offsetTableEntry.w SonAni_Death		; 24 ; $18
	offsetTableEntry.w SonAni_Hurt		; 25 ; $19
	offsetTableEntry.w SonAni_Hurt		; 26 ; $1A
	offsetTableEntry.w SonAni_Slide		; 27 ; $1B
	offsetTableEntry.w SonAni_Blank		; 28 ; $1C
	offsetTableEntry.w SonAni_Balance3	; 29 ; $1D
	offsetTableEntry.w SonAni_Balance4	; 30 ; $1E
	offsetTableEntry.w SupSonAni_Transform	; 31 ; $1F

SupSonAni_Walk:		dc.b $FF,$77,$78,$79,$7A,$7B,$7C,$75,$76,$FF
	rev02even
SupSonAni_Run:		dc.b $FF,$B5,$B9,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	rev02even
SupSonAni_Push:		dc.b $FD,$BD,$BE,$BF,$C0,$FF,$FF,$FF,$FF,$FF
	rev02even
SupSonAni_Stand:	dc.b   7,$72,$73,$74,$73,$FF
	rev02even
SupSonAni_Balance:	dc.b   9,$C2,$C3,$C4,$C3,$C5,$C6,$C7,$C6,$FF
	rev02even
SupSonAni_Duck:		dc.b   5,$C1,$FF
	rev02even
SupSonAni_Transform:	dc.b   2,$6D,$6D,$6E,$6E,$6F,$70,$71,$70,$71,$70,$71,$70,$71,$FD,  0
	even