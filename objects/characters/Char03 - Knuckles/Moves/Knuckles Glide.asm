
Knuckles_CheckGlide:				  ; ...
		tst.w	($FFFFFFD0).w		  ; Don't glide on demos
		bne.w	return_3165D2
		tst.b	(CutSceneFlag).w
		bne.w	return_3165D2
		tst.b	double_jump_flag(a0)
		bne.w	return_3165D2
		bsr.w	DetectPlayerCtrl
		move.b	(Ctrl_Press_Logical).w,d0
		and.b	#$70,d0
		beq.w	return_3165D2
		;tst.b	($FFFFFE19).w
		;bne.s	Knuckles_BeginGlide
		;cmp.b	#7,($FFFFFFB1).w
		;bcs.s	Knuckles_BeginGlide
		;cmp.w	#50,($FFFFFE20).w
		;bcs.w	Knuckles_BeginGlide
		;tst.b	($FFFFFE1E).w
		;bne.s	Knuckles_TurnSuper
		

Knuckles_BeginGlide:				  ; ...
		bclr	#2,status(a0)
		move.b	#$A,y_radius(a0)
		move.b	#$A,x_radius(a0)
		bclr	#4,status(a0)
		move.b	#1,double_jump_flag(a0)
		add.w	#$200,y_vel(a0)
		bpl.s	loc_31659E
		move.w	#0,y_vel(a0)

loc_31659E:					  ; ...
		moveq	#0,d1
		move.w	#$400,d0
		move.w	d0,inertia(a0)
		btst	#0,status(a0)
		beq.s	loc_3165B4
		neg.w	d0
		moveq	#-$80,d1

loc_3165B4:					  ; ...
		move.w	d0,x_vel(a0)
		move.b	d1,double_jump_properly(a0)
		move.w	#0,angle(a0)
		move.b	#0,($FFFFF7AC).w
		bset	#1,($FFFFF7AC).w
		bsr.w	sub_315C7C

return_3165D2:					  ; ...
		rts
; ---------------------------------------------------------------------------

Obj01_MdAir_Gliding:
		bsr.w	DetectPlayerCtrl				  ; ...
		bsr.w	Knuckles_GlideSpeedControl
		bsr.w	Sonic_LevelBound
		jsr	ObjectMove		  ; AKA	SpeedToPos in Sonic 1
		bsr.w	Knuckles_GlideControl

return_3156B8:					  ; ...
		rts
; End of function Obj01_MdAir


; =============== S U B	R O U T	I N E =======================================


Knuckles_GlideControl:				  ; ...

; FUNCTION CHUNK AT 00315C40 SIZE 0000003C BYTES

		move.b	double_jump_flag(a0),d0
		beq.s	return_3156B8
		cmp.b	#2,d0
		beq.w	Knuckles_FallingFromGlide
		cmp.b	#3,d0
		beq.w	Knuckles_Sliding
		cmp.b	#4,d0
		beq.w	Knuckles_Climbing_Wall
		cmp.b	#5,d0
		beq.w	Knuckles_Climbing_Up

Knuckles_NormalGlide:
		move.b	#$A,y_radius(a0)
		move.b	#$A,x_radius(a0)
		bsr.w	Knuckles_DoLevelCollision2
		btst	#5,($FFFFF7AC).w
		bne.w	Knuckles_BeginClimb
		move.b	#$13,y_radius(a0)
		move.b	#9,x_radius(a0)
		btst	#1,($FFFFF7AC).w
		beq.s	Knuckles_BeginSlide
		move.b	(Ctrl_Held_Logical).w,d0
		and.b	#$70,d0
		bne.s	loc_31574C
		move.b	#2,double_jump_flag(a0)
		move.b	#$21,anim(a0)
		bclr	#0,status(a0)
		tst.w	x_vel(a0)
		bpl.s	loc_315736
		bset	#0,status(a0)

loc_315736:					  ; ...
		asr	x_vel(a0)
		asr	x_vel(a0)
		move.b	#$13,y_radius(a0)
		move.b	#9,x_radius(a0)
		rts
; ---------------------------------------------------------------------------

loc_31574C:					  ; ...
		bra.w	sub_315C7C
; ---------------------------------------------------------------------------

Knuckles_BeginSlide:				  ; ...
		bclr	#0,status(a0)
		tst.w	x_vel(a0)
		bpl.s	loc_315762
		bset	#0,status(a0)

loc_315762:					  ; ...
		move.b	angle(a0),d0
		add.b	#$20,d0
		and.b	#$C0,d0
		beq.s	loc_315780
		move.w	inertia(a0),x_vel(a0)
		move.w	#0,y_vel(a0)
		bra.w	Knuckles_ResetOnFloor_Part2
; ---------------------------------------------------------------------------

loc_315780:					  ; ...
		move.b	#3,double_jump_flag(a0)
		move.b	#$CC,mapping_frame(a0)
		move.b	#$7F,anim_frame_duration(a0)
		move.b	#0,anim_frame(a0)
		cmp.b	#$C,air_left(a0)
		bcs.s	return_3157AC
		move.b	#6,($FFFFD124).w
		move.b	#$15,($FFFFD11A).w

return_3157AC:					  ; ...
		rts
; ---------------------------------------------------------------------------

Knuckles_BeginClimb:				  ; ...
		tst.b	($FFFFF7AD).w
		bmi.w	loc_31587A
		move.b	lrb_solid_bit(a0),d5
		move.b	double_jump_properly(a0),d0
		add.b	#$40,d0
		bpl.s	loc_3157D8
		bset	#0,status(a0)
		bsr.w	CheckLeftCeilingDist
		or.w	d0,d1
		bne.s	Knuckles_FallFromGlide
		addq.w	#1,x_pos(a0)
		bra.s	loc_3157E8
; ---------------------------------------------------------------------------

loc_3157D8:					  ; ...
		bclr	#0,status(a0)
		bsr.w	CheckRightCeilingDist
		or.w	d0,d1
		bne.w	loc_31586A

loc_3157E8:					  ; ...
		move.b	#$13,y_radius(a0)
		move.b	#9,x_radius(a0)
		tst.b	($FFFFFE19).w
		beq.s	loc_315804
		cmp.w	#$480,inertia(a0)
		bcs.s	loc_315804
		nop

loc_315804:					  ; ...
		move.w	#0,inertia(a0)
		move.w	#0,x_vel(a0)
		move.w	#0,y_vel(a0)
		move.b	#4,double_jump_flag(a0)
		move.b	#$B7,mapping_frame(a0)
		move.b	#$7F,anim_frame_duration(a0)
		move.b	#0,anim_frame(a0)
		move.b	#3,double_jump_properly(a0)
		move.w	x_pos(a0),x_sub(a0)
		rts
; ---------------------------------------------------------------------------

Knuckles_FallFromGlide:				  ; ...
		move.w	x_pos(a0),d3
		move.b	y_radius(a0),d0
		ext.w	d0
		sub.w	d0,d3
		subq.w	#1,d3

loc_31584A:					  ; ...
		move.w	y_pos(a0),d2
		sub.w	#$B,d2
		jsr	ChkFloorEdge_Part2
		tst.w	d1
		bmi.s	loc_31587A
		cmp.w	#$C,d1
		bcc.s	loc_31587A
		add.w	d1,y_pos(a0)
		bra.w	loc_3157E8
; ---------------------------------------------------------------------------

loc_31586A:					  ; ...
		move.w	x_pos(a0),d3
		move.b	y_radius(a0),d0
		ext.w	d0
		add.w	d0,d3
		addq.w	#1,d3
		bra.s	loc_31584A
; ---------------------------------------------------------------------------

loc_31587A:					  ; ...
		move.b	#2,double_jump_flag(a0)
		move.b	#$21,anim(a0)
		move.b	#$13,y_radius(a0)
		move.b	#9,x_radius(a0)
		bset	#1,($FFFFF7AC).w
		rts
; ---------------------------------------------------------------------------

Knuckles_FallingFromGlide:			  ; ...
		bsr.w	Sonic_ChgJumpDir
		add.w	#$38,y_vel(a0)
		btst	#6,status(a0)
		beq.s	loc_3158B2
		sub.w	#$28,y_vel(a0)

loc_3158B2:					  ; ...
		bsr.w	Knuckles_DoLevelCollision2
		btst	#1,($FFFFF7AC).w
		bne.s	return_315900
		move.w	#0,inertia(a0)
		move.w	#0,x_vel(a0)
		move.w	#0,y_vel(a0)
		move.b	y_radius(a0),d0
		sub.b	#$13,d0
		ext.w	d0
		add.w	d0,y_pos(a0)
		move.b	angle(a0),d0
		add.b	#$20,d0
		and.b	#$C0,d0
		beq.s	loc_3158F0
		bra.w	Knuckles_ResetOnFloor_Part2
; ---------------------------------------------------------------------------

loc_3158F0:					  ; ...
		bsr.w	Knuckles_ResetOnFloor_Part2
		move.w	#$F,move_lock(a0)
		move.b	#$23,anim(a0)

return_315900:					  ; ...
		rts
; ---------------------------------------------------------------------------

Knuckles_Sliding:				  ; ...
		move.b	(Ctrl_Held_Logical).w,d0
		and.b	#$70,d0
		beq.s	loc_315926
		tst.w	x_vel(a0)
		bpl.s	loc_31591E
		add.w	#$20,x_vel(a0)
		bmi.s	loc_31591C
		bra.s	loc_315926
; ---------------------------------------------------------------------------

loc_31591C:					  ; ...
		bra.s	loc_315958
; ---------------------------------------------------------------------------

loc_31591E:					  ; ...
		sub.w	#$20,x_vel(a0)
		bpl.s	loc_315958

loc_315926:					  ; ...
		move.w	#0,inertia(a0)
		move.w	#0,x_vel(a0)
		move.w	#0,y_vel(a0)
		move.b	y_radius(a0),d0
		sub.b	#$13,d0
		ext.w	d0
		add.w	d0,y_pos(a0)
		bsr.w	Knuckles_ResetOnFloor_Part2
		move.w	#$F,move_lock(a0)
		move.b	#$22,anim(a0)
		rts
; ---------------------------------------------------------------------------

loc_315958:					  ; ...
		move.b	#$A,y_radius(a0)
		move.b	#$A,x_radius(a0)
		bsr.w	Knuckles_DoLevelCollision2
		bsr.w	Sonic_CheckFloor
		cmp.w	#$E,d1
		bge.s	loc_315988
		add.w	d1,y_pos(a0)
		move.b	d3,angle(a0)
		move.b	#$13,y_radius(a0)
		move.b	#9,x_radius(a0)
		rts
; ---------------------------------------------------------------------------

loc_315988:					  ; ...
		move.b	#2,double_jump_flag(a0)
		move.b	#$21,anim(a0)
		move.b	#$13,y_radius(a0)
		move.b	#9,x_radius(a0)
		bset	#1,($FFFFF7AC).w
		rts
; ---------------------------------------------------------------------------

Knuckles_Climbing_Wall:				  ; ...
		tst.b	($FFFFF7AD).w
		bmi.w	loc_315BAE
		move.w	x_pos(a0),d0
		cmp.w	x_sub(a0),d0
		bne.w	loc_315BAE
		btst	#3,status(a0)
		bne.w	loc_315BAE
		move.w	#0,inertia(a0)
		move.w	#0,x_vel(a0)
		move.w	#0,y_vel(a0)
		move.l	#$FFFFD600,($FFFFF796).w
		cmp.b	#$D,lrb_solid_bit(a0)
		beq.s	loc_3159F0
		move.l	#$FFFFD900,($FFFFF796).w

loc_3159F0:					  ; ...
		move.b	lrb_solid_bit(a0),d5
		move.b	#$A,y_radius(a0)
		move.b	#$A,x_radius(a0)
		moveq	#0,d1
		btst	#0,(Ctrl_Held_Logical).w
		beq.w	loc_315A76
		move.w	y_pos(a0),d2
		sub.w	#$B,d2
		bsr.w	sub_315C22
		cmp.w	#4,d1
		bge.w	Knuckles_ClimbUp	  ; Climb onto the floor above you
		tst.w	d1
		bne.w	loc_315B30
		move.b	lrb_solid_bit(a0),d5
		move.w	y_pos(a0),d2
		subq.w	#8,d2
		move.w	x_pos(a0),d3
		bsr.w	sub_3192E6		  ; Doesn't exist in S2
		tst.w	d1
		bpl.s	loc_315A46
		sub.w	d1,y_pos(a0)
		moveq	#1,d1
		bra.w	loc_315B04
; ---------------------------------------------------------------------------

loc_315A46:					  ; ...
		subq.w	#1,y_pos(a0)
		tst.b	($FFFFFE19).w
		beq.s	loc_315A54
		subq.w	#1,y_pos(a0)

loc_315A54:					  ; ...
		moveq	#1,d1
		move.w	($FFFFEECC).w,d0
		cmp.w	#-$100,d0
		beq.w	loc_315B04
		add.w	#$10,d0
		cmp.w	y_pos(a0),d0
		ble.w	loc_315B04
		move.w	d0,y_pos(a0)
		bra.w	loc_315B04
; ---------------------------------------------------------------------------

loc_315A76:					  ; ...
		btst	#1,(Ctrl_Held_Logical).w
		beq.w	loc_315B04
		cmp.b	#$BD,mapping_frame(a0)
		bne.s	loc_315AA2
		move.b	#$B7,mapping_frame(a0)
		addq.w	#3,y_pos(a0)
		subq.w	#3,x_pos(a0)
		btst	#0,status(a0)
		beq.s	loc_315AA2
		addq.w	#6,x_pos(a0)

loc_315AA2:					  ; ...
		move.w	y_pos(a0),d2
		add.w	#$B,d2
		bsr.w	sub_315C22
		tst.w	d1
		bne.w	loc_315BAE
		move.b	top_solid_bit(a0),d5
		move.w	y_pos(a0),d2
		add.w	#9,d2
		move.w	x_pos(a0),d3
		bsr.w	sub_318FF6
		tst.w	d1
		bpl.s	loc_315AF4
		add.w	d1,y_pos(a0)
		move.b	($FFFFF768).w,angle(a0)
		move.w	#0,inertia(a0)
		move.w	#0,x_vel(a0)
		move.w	#0,y_vel(a0)
		bsr.w	Knuckles_ResetOnFloor_Part2
		move.b	#5,anim(a0)
		rts
; ---------------------------------------------------------------------------

loc_315AF4:					  ; ...
		addq.w	#1,y_pos(a0)
		tst.b	($FFFFFE19).w
		beq.s	loc_315B02
		addq.w	#1,y_pos(a0)

loc_315B02:					  ; ...
		moveq	#-1,d1

loc_315B04:					  ; ...
		tst.w	d1
		beq.s	loc_315B30
		subq.b	#1,double_jump_properly(a0)
		bpl.s	loc_315B30
		move.b	#3,double_jump_properly(a0)
		add.b	mapping_frame(a0),d1
		cmp.b	#$B7,d1
		bcc.s	loc_315B22
		move.b	#$BC,d1

loc_315B22:					  ; ...
		cmp.b	#$BC,d1
		bls.s	loc_315B2C
		move.b	#$B7,d1

loc_315B2C:					  ; ...
		move.b	d1,mapping_frame(a0)

loc_315B30:					  ; ...
		move.b	#$20,anim_frame_duration(a0)
		move.b	#0,anim_frame(a0)
		move.b	#$13,y_radius(a0)
		move.b	#9,x_radius(a0)
		move.w	(Ctrl_Held_Logical).w,d0
		and.w	#$70,d0
		beq.s	return_315B94
		move.w	#$FC80,y_vel(a0)
		move.w	#$400,x_vel(a0)
		bchg	#0,status(a0)
		bne.s	loc_315B6A
		neg.w	x_vel(a0)

loc_315B6A:					  ; ...
		bset	#1,status(a0)
		move.b	#1,jumping(a0)
		move.b	#$E,y_radius(a0)
		move.b	#7,x_radius(a0)
		move.b	#2,anim(a0)
		bset	#2,status(a0)
		move.b	#0,double_jump_flag(a0)

return_315B94:					  ; ...
		rts
; ---------------------------------------------------------------------------

Knuckles_ClimbUp:				  ; ...
		move.b	#5,double_jump_flag(a0)		  ; Climb up to	the floor above	you
		move.b	#9,x_radius(a0)
		move.b	#$13,y_radius(a0)
		cmp.b	#$BD,mapping_frame(a0)
		beq.s	return_315BAC
		move.b	#0,double_jump_properly(a0)
		bsr.s	sub_315BDA

return_315BAC:					  ; ...
		rts
; ---------------------------------------------------------------------------

loc_315BAE:					  ; ...
		move.b	#2,double_jump_flag(a0)
		move.w	#$2121,anim(a0)
		move.b	#$CB,mapping_frame(a0)
		move.b	#7,anim_frame_duration(a0)
		move.b	#1,anim_frame(a0)
		move.b	#$13,y_radius(a0)
		move.b	#9,x_radius(a0)
		rts
; End of function Knuckles_GlideControl


; =============== S U B	R O U T	I N E =======================================


sub_315BDA:					  ; ...
		moveq	#0,d0
		move.b	double_jump_properly(a0),d0
		lea	word_315C12(pc,d0.w),a1
		move.b	(a1)+,mapping_frame(a0)
		move.b	(a1)+,d0
		ext.w	d0
		btst	#0,status(a0)
		beq.s	loc_315BF6
		neg.w	d0

loc_315BF6:					  ; ...
		add.w	d0,x_pos(a0)
		move.b	(a1)+,d1
		ext.w	d1
		add.w	d1,y_pos(a0)
		move.b	(a1)+,anim_frame_duration(a0)
		addq.b	#4,double_jump_properly(a0)
		move.b	#0,anim_frame(a0)
		rts
; End of function sub_315BDA

; ---------------------------------------------------------------------------
word_315C12:	dc.w $BD03,$FD06,$BE08,$F606,$BFF8,$F406,$D208,$FB06; 0	; ...

; =============== S U B	R O U T	I N E =======================================


sub_315C22:					  ; ...

; FUNCTION CHUNK AT 00319208 SIZE 00000020 BYTES
; FUNCTION CHUNK AT 003193D2 SIZE 00000024 BYTES

		move.b	lrb_solid_bit(a0),d5
		btst	#0,status(a0)
		bne.s	loc_315C36
		move.w	x_pos(a0),d3
		bra.w	loc_319208
; ---------------------------------------------------------------------------

loc_315C36:					  ; ...
		move.w	x_pos(a0),d3
		subq.w	#1,d3
		bra.w	loc_3193D2
; End of function sub_315C22

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR Knuckles_GlideControl

Knuckles_Climbing_Up:				  ; ...
		tst.b	anim_frame_duration(a0)
		bne.s	return_315C7A
		bsr.w	sub_315BDA
		cmp.b	#$10,double_jump_properly(a0)
		bne.s	return_315C7A
		move.w	#0,inertia(a0)
		move.w	#0,x_vel(a0)
		move.w	#0,y_vel(a0)
		btst	#0,status(a0)
		beq.s	loc_315C70
		subq.w	#1,x_pos(a0)

loc_315C70:					  ; ...
		bsr.w	Knuckles_ResetOnFloor_Part2
		move.b	#5,anim(a0)

return_315C7A:					  ; ...
		rts
; END OF FUNCTION CHUNK	FOR Knuckles_GlideControl

; =============== S U B	R O U T	I N E =======================================


sub_315C7C:					  ; ...
		move.b	#$20,anim_frame_duration(a0)
		move.b	#0,anim_frame(a0)
		move.w	#$2020,anim(a0)
		bclr	#5,status(a0)
		bclr	#0,status(a0)
		moveq	#0,d0
		move.b	double_jump_properly(a0),d0
		add.b	#$10,d0
		lsr.w	#5,d0
		move.b	byte_315CC2(pc,d0.w),d1
		move.b	d1,mapping_frame(a0)
		cmp.b	#$C4,d1
		bne.s	return_315CC0
		bset	#0,status(a0)
		move.b	#$C0,mapping_frame(a0)

return_315CC0:					  ; ...
		rts
; End of function sub_315C7C

; ---------------------------------------------------------------------------
byte_315CC2:	dc.b $C0,$C1,$C2,$C3,$C4,$C3,$C2,$C1; 0	; ...

; =============== S U B	R O U T	I N E =======================================


Knuckles_GlideSpeedControl:			  ; ...
		cmp.b	#1,double_jump_flag(a0)
		bne.w	loc_315D88
		move.w	inertia(a0),d0
		cmp.w	#$400,d0
		bcc.s	loc_315CE2
		addq.w	#8,d0
		bra.s	loc_315CFC
; ---------------------------------------------------------------------------

loc_315CE2:					  ; ...
		cmp.w	#$1800,d0
		bcc.s	loc_315CFC
		move.b	double_jump_properly(a0),d1
		and.b	#$7F,d1
		bne.s	loc_315CFC
		addq.w	#4,d0
		tst.b	($FFFFFE19).w
		beq.s	loc_315CFC
		addq.w	#8,d0

loc_315CFC:					  ; ...
		move.w	d0,inertia(a0)
		move.b	double_jump_properly(a0),d0
		btst	#2,(Ctrl_Held_Logical).w
		beq.s	loc_315D1C
		cmp.b	#$80,d0
		beq.s	loc_315D1C
		tst.b	d0
		bpl.s	loc_315D18
		neg.b	d0

loc_315D18:					  ; ...
		addq.b	#2,d0
		bra.s	loc_315D3A
; ---------------------------------------------------------------------------

loc_315D1C:					  ; ...
		btst	#3,(Ctrl_Held_Logical).w
		beq.s	loc_315D30
		tst.b	d0
		beq.s	loc_315D30
		bmi.s	loc_315D2C
		neg.b	d0

loc_315D2C:					  ; ...
		addq.b	#2,d0
		bra.s	loc_315D3A
; ---------------------------------------------------------------------------

loc_315D30:					  ; ...
		move.b	d0,d1
		and.b	#$7F,d1
		beq.s	loc_315D3A
		addq.b	#2,d0

loc_315D3A:					  ; ...
		move.b	d0,double_jump_properly(a0)
		move.b	double_jump_properly(a0),d0
		jsr	CalcSine
		muls.w	inertia(a0),d1
		asr.l	#8,d1
		move.w	d1,x_vel(a0)
		cmp.w	#$80,y_vel(a0)
		blt.s	loc_315D62
		sub.w	#$20,y_vel(a0)
		bra.s	loc_315D68
; ---------------------------------------------------------------------------

loc_315D62:					  ; ...
		add.w	#$20,y_vel(a0)

loc_315D68:					  ; ...
		move.w	($FFFFEECC).w,d0
		cmp.w	#$FF00,d0
		beq.w	loc_315D88
		add.w	#$10,d0
		cmp.w	y_pos(a0),d0
		ble.w	loc_315D88
		asr	x_vel(a0)
		asr	inertia(a0)

loc_315D88:					  ; ...
		cmp.w	#$60,($FFFFEED8).w
		beq.s	return_315D9A
		bcc.s	loc_315D96
		addq.w	#4,($FFFFEED8).w

loc_315D96:					  ; ...
		subq.w	#2,($FFFFEED8).w

return_315D9A:					  ; ...
		rts
; End of function Knuckles_GlideSpeedControl

; =============== S U B	R O U T	I N E =======================================

; Doesn't exist in S2

sub_3192E6:					  ; ...
		move.b	x_radius(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eor.w	#$F,d2
		lea	($FFFFF768).w,a4
		move.w	#-$10,a3
		move.w	#$800,d6
		bsr.w	FindFloor
		move.b	#$80,d2

loc_319306:
		bra.w	loc_318FE8
; End of function sub_3192E6

; =============== S U B	R O U T	I N E =======================================


sub_318FF6:					  ; ...
		move.b	x_radius(a0),d0
		ext.w	d0
		add.w	d0,d2
		lea	($FFFFF768).w,a4
		move.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindFloor
		move.b	#0,d2
		bra.s	loc_318FE8
; End of function sub_318FF6
; ---------------------------------------------------------------------------
; This doesn't exist in S2...
; START	OF FUNCTION CHUNK FOR sub_315C22

loc_319208:					  ; ...
		move.b	x_radius(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	($FFFFF768).w,a4
		move.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindWall
		move.b	#$C0,d2
		bra.w	loc_318FE8
; END OF FUNCTION CHUNK	FOR sub_315C22
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_315C22

loc_3193D2:					  ; ...
		move.b	x_radius(a0),d0
		ext.w	d0
		sub.w	d0,d3
		eor.w	#$F,d3
		lea	($FFFFF768).w,a4
		move.w	#$FFF0,a3
		move.w	#$400,d6
		bsr.w	FindWall
		move.b	#$40,d2
		bra.w	loc_318FE8
; END OF FUNCTION CHUNK	FOR sub_315C22
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR CheckRightWallDist

loc_318FE8:					  ; ...
		move.b	($FFFFF768).w,d3
		btst	#0,d3
		beq.s	return_318FF4
		move.b	d2,d3

return_318FF4:					  ; ...
		rts
; END OF FUNCTION CHUNK	FOR CheckRightWallDist



; =============== S U B	R O U T	I N E =======================================


Knuckles_DoLevelCollision2:			  ; ...
		move.l	#$FFFFD600,($FFFFF796).w
		cmp.b	#$C,top_solid_bit(a0)
		beq.s	loc_31694E
		move.l	#$FFFFD900,($FFFFF796).w

loc_31694E:					  ; ...
		move.b	lrb_solid_bit(a0),d5
		move.w	x_vel(a0),d1
		move.w	y_vel(a0),d2
		jsr	CalcAngle
		sub.b	#$20,d0
		and.b	#$C0,d0
		cmp.b	#$40,d0
		beq.w	Knuckles_HitLeftWall2
		cmp.b	#$80,d0
		beq.w	Knuckles_HitCeilingAndWalls2
		cmp.b	#$C0,d0
		beq.w	Knuckles_HitRightWall2
		bsr.w	CheckLeftWallDist
		tst.w	d1
		bpl.s	loc_316998
		sub.w	d1,x_pos(a0)
		move.w	#0,x_vel(a0)
		bset	#5,($FFFFF7AC).w

loc_316998:					  ; ...
		bsr.w	CheckRightWallDist
		tst.w	d1
		bpl.s	loc_3169B0
		add.w	d1,x_pos(a0)
		move.w	#0,x_vel(a0)
		bset	#5,($FFFFF7AC).w

loc_3169B0:					  ; ...
		bsr.w	Sonic_CheckFloor
		tst.w	d1
		bpl.s	return_3169CC
		add.w	d1,y_pos(a0)
		move.b	d3,angle(a0)
		move.w	#0,y_vel(a0)
		bclr	#1,($FFFFF7AC).w

return_3169CC:					  ; ...
		rts
; ---------------------------------------------------------------------------

Knuckles_HitLeftWall2:				  ; ...
		bsr.w	CheckLeftWallDist
		tst.w	d1
		bpl.s	Knuckles_HitCeilingAlt
		sub.w	d1,x_pos(a0)
		move.w	#0,x_vel(a0)
		bset	#5,($FFFFF7AC).w

Knuckles_HitCeilingAlt:				  ; ...
		bsr.w	CheckCeilingDist
		tst.w	d1
		bpl.s	Knuckles_HitFloor
		neg.w	d1
		cmp.w	#$14,d1
		bcc.s	loc_316A08
		add.w	d1,y_pos(a0)
		tst.w	y_vel(a0)
		bpl.s	return_316A06
		move.w	#0,y_vel(a0)

return_316A06:					  ; ...
		rts
; ---------------------------------------------------------------------------

loc_316A08:					  ; ...
		bsr.w	CheckRightWallDist
		tst.w	d1
		bpl.s	return_316A20
		add.w	d1,x_pos(a0)
		move.w	#0,x_vel(a0)
		bset	#5,($FFFFF7AC).w

return_316A20:					  ; ...
		rts
; ---------------------------------------------------------------------------

Knuckles_HitFloor:				  ; ...
		tst.w	y_vel(a0)
		bmi.s	return_316A44
		bsr.w	Sonic_CheckFloor
		tst.w	d1
		bpl.s	return_316A44
		add.w	d1,y_pos(a0)
		move.b	d3,angle(a0)
		move.w	#0,y_vel(a0)
		bclr	#1,($FFFFF7AC).w

return_316A44:					  ; ...
		rts
; ---------------------------------------------------------------------------

Knuckles_HitCeilingAndWalls2:			  ; ...
		bsr.w	CheckLeftWallDist
		tst.w	d1
		bpl.s	loc_316A5E
		sub.w	d1,x_pos(a0)
		move.w	#0,x_vel(a0)
		bset	#5,($FFFFF7AC).w

loc_316A5E:					  ; ...
		bsr.w	CheckRightWallDist
		tst.w	d1
		bpl.s	loc_316A76
		add.w	d1,x_pos(a0)
		move.w	#0,x_vel(a0)
		bset	#5,($FFFFF7AC).w

loc_316A76:					  ; ...
		bsr.w	CheckCeilingDist
		tst.w	d1
		bpl.s	return_316A88
		sub.w	d1,y_pos(a0)
		move.w	#0,y_vel(a0)

return_316A88:					  ; ...
		rts
; ---------------------------------------------------------------------------

Knuckles_HitRightWall2:				  ; ...
		bsr.w	CheckRightWallDist
		tst.w	d1
		bpl.s	loc_316AA2
		add.w	d1,x_pos(a0)
		move.w	#0,x_vel(a0)
		bset	#5,($FFFFF7AC).w

loc_316AA2:					  ; ...
		bsr.w	CheckCeilingDist
		tst.w	d1
		bpl.s	loc_316ABC
		sub.w	d1,y_pos(a0)
		tst.w	y_vel(a0)
		bpl.s	return_316ABA
		move.w	#0,y_vel(a0)

return_316ABA:					  ; ...
		rts
; ---------------------------------------------------------------------------

loc_316ABC:					  ; ...
		tst.w	y_vel(a0)
		bmi.s	return_316ADE
		bsr.w	Sonic_CheckFloor
		tst.w	d1
		bpl.s	return_316ADE
		add.w	d1,y_pos(a0)
		move.b	d3,angle(a0)
		move.w	#0,y_vel(a0)
		bclr	#1,($FFFFF7AC).w

return_316ADE:					  ; ...
		rts
; End of function Knuckles_DoLevelCollision2

; =============== S U B	R O U T	I N E =======================================


CheckCeilingDist:				  ; ...
		move.w	y_pos(a0),d2
		move.w	x_pos(a0),d3
		moveq	#0,d0
		move.b	y_radius(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eor.w	#$F,d2
		move.b	x_radius(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	($FFFFF768).w,a4
		move.w	#$FFF0,a3
		move.w	#$800,d6
		bsr.w	FindFloor
		move.w	d1,-(sp)
		move.w	y_pos(a0),d2
		move.w	x_pos(a0),d3
		moveq	#0,d0
		move.b	y_radius(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eor.w	#$F,d2
		move.b	x_radius(a0),d0
		ext.w	d0
		sub.w	d0,d3
		lea	($FFFFF76A).w,a4
		move.w	#$FFF0,a3
		move.w	#$800,d6
		bsr.w	FindFloor
		move.w	(sp)+,d0
		move.b	#$80,d2
		bra.w	loc_1ECC6
; End of function CheckCeilingDist

