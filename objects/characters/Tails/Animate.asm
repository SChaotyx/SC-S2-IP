; ---------------------------------------------------------------------------
; Subroutine to animate Tails' sprites
; See also: AnimateSprite and Sonic_Animate
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1CDC4:
Tails_Animate:
	cmpi.b  #1,(Sec_player).w
    beq.w   Sonic_AnimatePart2
	cmpi.b  #3,(Sec_player).w
    beq.w   Knuckles_Animate
Tails_AnimatePart2:
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
	move.b	d0,d1
	lsr.b	#1,d1
	add.b	d1,d0
	add.b	d0,d0
	move.b	d0,d3

	cmpi.w	#$700,d2		; is Tails going really fast?
	blo.s	TAnim_SpeedSelected	; if not, branch
	lea	(TailsAni_HaulAss).l,a1

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
	addi.b	#$75,d0
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
	addi.b	#$75,d0
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

TailsAni_Walk:	dc.b $FF,$10,$11,$12,$13,$14,$15, $E, $F,$FF
	rev02even
TailsAni_Run:	dc.b $FF,$2E,$2F,$30,$31,$FF,$FF,$FF,$FF,$FF
	rev02even
TailsAni_Roll:	dc.b   1,$48,$47,$46,$FF
	rev02even
TailsAni_Roll2:	dc.b   1,$48,$47,$46,$FF
	rev02even
TailsAni_Push:	dc.b $FD,$63,$64,$65,$66,$FF,$FF,$FF,$FF,$FF
	rev02even
TailsAni_Wait:	dc.b   7,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  3,  2,  1,  1,  1
		dc.b   1,  1,  1,  1,  1,  3,  2,  1,  1,  1,  1,  1,  1,  1,  1,  1
		dc.b   5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5
		dc.b   6,  7,  8,  7,  8,  7,  8,  7,  8,  7,  8,  6,$FE,$1C
	rev02even
TailsAni_Balance:	dc.b   9,$69,$69,$6A,$6A,$69,$69,$6A,$6A,$69,$69,$6A,$6A,$69,$69,$6A
			dc.b $6A,$69,$69,$6A,$6A,$69,$6A,$FF
	rev02even
TailsAni_LookUp:	dc.b $3F,  4,$FF
	rev02even
TailsAni_Duck:		dc.b $3F,$5B,$FF
	rev02even
TailsAni_Spindash:	dc.b   0,$60,$61,$62,$FF
	rev02even
TailsAni_Dummy1:	dc.b $3F,$82,$FF
	rev02even
TailsAni_Dummy2:	dc.b   7,  8,  8,  9,$FD,  5
	rev02even
TailsAni_Dummy3:	dc.b   7,  9,$FD,  5
	rev02even
TailsAni_Stop:		dc.b   7,$67,$68,$67,$68,$FD,  0
	rev02even
TailsAni_Float:		dc.b   9,$6E,$73,$FF
	rev02even
TailsAni_Float2:	dc.b   9,$6E,$6F,$70,$71,$72,$FF
	rev02even
TailsAni_Spring:	dc.b   3,$59,$5A,$59,$5A,$59,$5A,$59,$5A,$59,$5A,$59,$5A,$FD,  0
	rev02even
TailsAni_Hang:		dc.b   5,$6C,$6D,$FF
	rev02even
TailsAni_Blink:		dc.b  $F,  1,  2,  3,$FE,  1
	rev02even
TailsAni_Blink2:	dc.b  $F,  1,  2,$FE,  1
	rev02even
TailsAni_Hang2:		dc.b $13,$85,$86,$FF
	rev02even
TailsAni_Bubble:	dc.b  $B,$74,$74,$12,$13,$FD,  0
	rev02even
TailsAni_DeathBW:	dc.b $20,$5D,$FF
	rev02even
TailsAni_Drown:		dc.b $2F,$5D,$FF
	rev02even
TailsAni_Death:		dc.b   3,$5D,$FF
	rev02even
TailsAni_Hurt:		dc.b   3,$5D,$FF
	rev02even
TailsAni_Hurt2:		dc.b   3,$5C,$FF
	rev02even
TailsAni_Slide:		dc.b   9,$6B,$5C,$FF
	rev02even
TailsAni_Blank:		dc.b $77,  0,$FD,  0
	rev02even
TailsAni_Dummy4:	dc.b   3,  1,  2,  3,  4,  5,  6,  7,  8,$FF
	rev02even
TailsAni_Dummy5:	dc.b   3,  1,  2,  3,  4,  5,  6,  7,  8,$FF
	rev02even
TailsAni_HaulAss:	dc.b $FF,$32,$33,$FF
			dc.b $FF,$FF,$FF,$FF,$FF,$FF
	rev02even
TailsAni_Fly:		dc.b   1,$5E,$5F,$FF
	even

; ===========================================================================