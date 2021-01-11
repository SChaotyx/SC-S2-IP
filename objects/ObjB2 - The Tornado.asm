
; ----------------------------------------------------------------------------
; Object B2 - The Tornado (Tails' plane)
; ----------------------------------------------------------------------------
; Sprite_3A790:
ObjB2:
	moveq	#0,d0
	move.b	routine(a0),d0
	move.w	ObjB2_Index(pc,d0.w),d1
	jmp	ObjB2_Index(pc,d1.w)
; ===========================================================================
; off_3A79E:
ObjB2_Index:	offsetTable
		offsetTableEntry.w ObjB2_Init	;  0
		offsetTableEntry.w ObjB2_Main_SCZ	;  2
		offsetTableEntry.w ObjB2_Main_WFZ_Start	;  4
		offsetTableEntry.w ObjB2_Main_WFZ_End	;  6
		offsetTableEntry.w ObjB2_Invisible_grabber	;  8
		offsetTableEntry.w loc_3AD0C	; $A
		offsetTableEntry.w loc_3AD2A	; $C
		offsetTableEntry.w loc_3AD42	; $E
; ===========================================================================
; loc_3A7AE:
ObjB2_Init:
	bsr.w	LoadSubObject
	moveq	#0,d0
	move.b	subtype(a0),d0
	subi.b	#$4E,d0
	move.b	d0,routine(a0)

	;WHAAAAAAAAAAAAATTTTT ---> AH YA ENTENDÍ XD 
	cmpi.b	#2,(Sec_player).w
	beq.s	++
	cmpi.b	#8,d0
	bhs.s	++
	cmpi.b	#3,(Sec_player).w
	bne.s	+
	cmpi.b	#1,(Main_player).w
	move.b	#4,mapping_frame(a0)
	move.b	#2,anim(a0)
	bra.s	++
+
	move.b	#4,mapping_frame(a0)
	move.b	#1,anim(a0)

+ ; BranchTo5_JmpTo45_DisplaySprite
	jmp	DisplaySprite
; ===========================================================================
; loc_3A7DE:
ObjB2_Main_SCZ:
	bsr.w	ObjB2_Animate_Pilot
	tst.w	(Debug_placement_mode).w
	bne.w	ObjB2_animate
	lea	(MainCharacter).w,a1 ; a1=character
	move.w	art_tile(a1),d0
	andi.w	#high_priority,d0
	move.w	art_tile(a0),d1
	andi.w	#drawing_mask,d1
	or.w	d0,d1
	move.w	d1,art_tile(a0)
	move.w	x_pos(a0),-(sp)
	bsr.w	ObjB2_Move_with_player
	move.b	status(a0),objoff_2E(a0)
	move.w	#$1B,d1
	move.w	#8,d2
	move.w	#9,d3
	move.w	(sp)+,d4
	jsr	SolidObject
	bsr.w	ObjB2_Move_obbey_player
	move.b	objoff_2E(a0),d0
	move.b	status(a0),d1
	andi.b	#p1_standing,d0	; 'on object' bit
	andi.b	#p1_standing,d1	; 'on object' bit
	eor.b	d0,d1
	move.b	d1,objoff_2E(a0)
	lea	(MainCharacter).w,a1 ; a1=character
	move.w	x_pos(a1),d1
	move.w	(Camera_X_pos).w,d0
	move.w	d0,(Camera_Min_X_pos).w
	move.w	d0,d2
	addi.w	#$11,d2
	cmp.w	d2,d1
	bhi.s	+
	addq.w	#1,d1
	move.w	d1,x_pos(a1)
+ ; loc_3A85E:
	cmpi.w	#$1400,d0
	blo.s	loc_3A878
	cmpi.w	#$1568,d1
	bhs.s	ObjB2_SCZ_Finished
	st	(Control_Locked).w
	move.w	#(button_right_mask<<8)|button_right_mask,(Ctrl_1_Logical).w
	bra.w	loc_3A87C
; ===========================================================================

loc_3A878:
	subi.w	#$40,d0

loc_3A87C:
	move.w	d0,(Camera_Max_X_pos).w
; loc_3A880:
ObjB2_animate:
	lea	(Ani_objB2_a).l,a1
	jsr	AnimateSprite
	jmp	DisplaySprite
; ===========================================================================
; loc_3A88E:
ObjB2_SCZ_Finished:
	bsr.w	ObjB2_Deactivate_level
	move.w	#wing_fortress_zone_act_1,(Current_ZoneAndAct).w
	bra.s	ObjB2_animate
; ===========================================================================
; loc_3A89A:
ObjB2_Main_WFZ_Start:
	bsr.w	ObjB2_Animate_Pilot
	moveq	#0,d0
	move.b	routine_secondary(a0),d0
	move.w	off_3A8BA(pc,d0.w),d1
	jsr	off_3A8BA(pc,d1.w)
	lea	(Ani_objB2_a).l,a1
	jsr	AnimateSprite
	jmp	DisplaySprite
; ===========================================================================
off_3A8BA:	offsetTable
		offsetTableEntry.w ObjB2_Main_WFZ_Start_init	; 0
		offsetTableEntry.w ObjB2_Main_WFZ_Start_main	; 2
		offsetTableEntry.w ObjB2_Main_WFZ_Start_shot_down	; 4
		offsetTableEntry.w ObjB2_Main_WFZ_Start_fall_down	; 6
; ===========================================================================
; loc_3A8C2:
ObjB2_Main_WFZ_Start_init:
	addq.b	#2,routine_secondary(a0)
	move.w	#$C0,objoff_32(a0)
	move.w	#$100,x_vel(a0)
	rts
; ===========================================================================
; loc_3A8D4:
ObjB2_Main_WFZ_Start_main:
	subq.w	#1,objoff_32(a0)
	bmi.s	+
	move.w	x_pos(a0),-(sp)
	jsr ObjectMove
	bsr.w	loc_36776
	move.w	#$1B,d1
	move.w	#8,d2
	move.w	#9,d3
	move.w	(sp)+,d4
	jsr SolidObject
	bra.w	ObjB2_Horizontal_limit
; ===========================================================================
+ ; loc_3A8FC:
	addq.b	#2,routine_secondary(a0)
	move.w	#$60,objoff_2A(a0)
	move.w	#1,objoff_32(a0)
	move.w	#$100,x_vel(a0)
	move.w	#$100,y_vel(a0)
	rts
; ===========================================================================
; loc_3A91A:
ObjB2_Main_WFZ_Start_shot_down:
	move.b	(Vint_runcount+3).w,d0
	andi.b	#$1F,d0
	bne.s	+
	moveq	#SndID_Scatter,d0
	jsr PlaySound
+ ; loc_3A92A:
	subq.w	#1,objoff_2A(a0)
	bmi.s	+
- ; loc_3A930:
	bsr.w	ObjB2_Align_plane
	subq.w	#1,objoff_32(a0)
	bne.w	return_37A48
	move.w	#$E,objoff_32(a0)
	bra.w	ObjB2_Main_WFZ_Start_load_smoke
; ===========================================================================
+ ; loc_3A946:
	addq.b	#2,routine_secondary(a0)
	jmp	loc_3B7BC
; ===========================================================================
; loc_3A94E:
ObjB2_Main_WFZ_Start_fall_down:
	jsr ObjectMove
	bra.s	-
; ===========================================================================
; loc_3A954:
ObjB2_Main_WFZ_End:
	bsr.w	ObjB2_Animate_Pilot
	moveq	#0,d0
	move.b	routine_secondary(a0),d0
	move.w	ObjB2_Main_WFZ_states(pc,d0.w),d1
	jsr	ObjB2_Main_WFZ_states(pc,d1.w)
	lea	(Ani_objB2_a).l,a1
	jmp AnimateSprite
; ===========================================================================
; off_3A970:
ObjB2_Main_WFZ_states:	offsetTable
		offsetTableEntry.w ObjB2_Wait_Leader_position	;   0
		offsetTableEntry.w ObjB2_Move_Leader_edge	;   2
		offsetTableEntry.w ObjB2_Wait_for_plane	;   4
		offsetTableEntry.w ObjB2_Prepare_to_jump	;   6
		offsetTableEntry.w ObjB2_Jump_to_plane	;   8
		offsetTableEntry.w ObjB2_Landed_on_plane	;  $A
		offsetTableEntry.w ObjB2_Approaching_ship	;  $C
		offsetTableEntry.w ObjB2_Jump_to_ship	;  $E
		offsetTableEntry.w ObjB2_Dock_on_DEZ	; $10
; ===========================================================================
; loc_3A982:
ObjB2_Wait_Leader_position:
	lea	(MainCharacter).w,a1 ; a1=character
	cmpi.w	#$5EC,y_pos(a1)
	blo.s	+	; rts
	clr.w	(Ctrl_1_Logical).w
	addq.w	#1,objoff_2E(a0)
	cmpi.w	#$40,objoff_2E(a0)
	bhs.s	++
+ ; return_3A99E:
	rts
; ===========================================================================
+ ; loc_3A9A0:
	addq.b	#2,routine_secondary(a0)
	move.w	#$2E58,x_pos(a0)
	move.w	#$66C,y_pos(a0)
	lea	(MainCharacter).w,a1 ; a1=character
	bsr.w	ObjB2_Waiting_animation
	lea	(word_3AFBC).l,a2
	bsr.w	LoadChildObject
	move.w	#$3118,x_pos(a1)
	move.w	#$3F0,y_pos(a1)
	lea	(word_3AFB8).l,a2
	bsr.w	LoadChildObject
	move.w	#$3070,x_pos(a1)
	move.w	#$3B0,y_pos(a1)
	lea	(word_3AFB8).l,a2
	bsr.w	LoadChildObject
	move.w	#$3070,x_pos(a1)
	move.w	#$430,y_pos(a1)
	lea	(word_3AFC0).l,a2
	bsr.w	LoadChildObject
	clr.w	x_pos(a1)
	clr.w	y_pos(a1)
	rts
; ===========================================================================
; loc_3AA0E: ObjB2_Move_Leader_egde:
ObjB2_Move_Leader_edge:
	lea	(MainCharacter).w,a1 ; a1=character
	cmpi.w	#$2E30,x_pos(a1)
	bhs.s	+
	move.w	#(button_right_mask<<8)|button_right_mask,(Ctrl_1_Logical).w
	rts
; ===========================================================================
+ ; loc_3AA22:
	addq.b	#2,routine_secondary(a0)
	clr.w	(Ctrl_1_Logical).w
	clr.w	x_vel(a1)
	clr.w	y_vel(a1)
	clr.w	inertia(a1)
	; no cambies esto!!!!!!!!!!!!!!
	;------------------------------
	move.w	#$600,(Sonic_top_speed).w
	move.w	#$C,(Sonic_acceleration).w
	move.w	#$80,(Sonic_deceleration).w
	;------------------------------
	bra.w	ObjB2_Waiting_animation
; ===========================================================================
; loc_3AA4C:
ObjB2_Wait_for_plane:
	cmpi.w	#$380,(Camera_BG_X_offset).w
	bhs.s	+
	clr.w	(Ctrl_1_Logical).w
	bra.w	ObjB2_Waiting_animation
; ===========================================================================
+ ; loc_3AA5C:
	addq.b	#2,routine_secondary(a0)
	move.w	#$100,x_vel(a0)
	move.w	#-$100,y_vel(a0)
	clr.w	objoff_2A(a0)
	bra.w	ObjB2_Waiting_animation
; ===========================================================================
; loc_3AA74:
ObjB2_Prepare_to_jump:
	bsr.w	ObjB2_Waiting_animation
	addq.w	#1,objoff_2A(a0)
	cmpi.w	#$30,objoff_2A(a0)
	bne.s	+
	addq.b	#2,routine_secondary(a0)
	move.w	#(button_A_mask<<8)|button_A_mask,(Ctrl_1_Logical).w
	move.w	#$38,objoff_2E(a0)
	tst.b	(Super_Sonic_flag).w
	beq.s	+
	move.w	#$28,objoff_2E(a0)
+ ; loc_3AAA0:
	bsr.w	ObjB2_Align_plane
	jmp DisplaySprite
; ===========================================================================
; loc_3AAA8:
ObjB2_Jump_to_plane:
	clr.w	(Ctrl_1_Logical).w
	addq.w	#1,objoff_2A(a0)
	subq.w	#1,objoff_2E(a0)
	bmi.s	+
	move.w	#((button_right_mask|button_A_mask)<<8)|button_right_mask|button_A_mask,(Ctrl_1_Logical).w
+ ; loc_3AABC:
	bsr.w	ObjB2_Align_plane
	btst	#p1_standing_bit,status(a0)
	beq.s	+
	addq.b	#2,routine_secondary(a0)
	move.w	#$20,objoff_2E(a0)
	lea	(Level_Layout+$0D2).w,a1
	move.l	#$501F0025,(a1)+
	lea	(Level_Layout+$1D2).w,a1
	move.l	#$25001F50,(a1)+
	lea	(Level_Layout+$BD6).w,a1
	move.l	#$501F0025,(a1)+
	lea	(Level_Layout+$CD6).w,a1
	move.l	#$25001F50,(a1)+
+ ; BranchTo6_JmpTo45_DisplaySprite:
	jmp DisplaySprite
; ===========================================================================
; loc_3AAFE:
ObjB2_Landed_on_plane:
	addq.w	#1,objoff_2A(a0)
	cmpi.w	#$100,objoff_2A(a0)
	blo.s	loc_3AB18
	addq.b	#2,routine_secondary(a0)
	movea.w	objoff_3A(a0),a1 ; a1=object ??
	move.b	#2,routine_secondary(a1)

loc_3AB18:
	clr.w	(Ctrl_1_Logical).w
	lea	(MainCharacter).w,a1 ; a1=character
	move.w	x_pos(a0),x_pos(a1)
	clr.w	x_vel(a1)
	clr.w	y_vel(a1)
	clr.w	inertia(a1)
	bclr	#1,status(a1)
	bclr	#2,status(a1)
	move.l	#(1<<24)|(0<<16)|(AniIDSonAni_Wait<<8)|AniIDSonAni_Wait,mapping_frame(a1)
	move.w	#$100,anim_frame_duration(a1)
	move.b	#$13,y_radius(a1)
	cmpi.b	#2,(Main_player).w
	bne.s	+
	move.b	#$F,y_radius(a1)
+ ; loc_3AB60:
	bsr.w	ObjB2_Align_plane
	jmp DisplaySprite
; ===========================================================================
; loc_3AB68:
ObjB2_Approaching_ship:
	clr.w	(Ctrl_1_Logical).w
	bsr.w	ObjB2_Waiting_animation
	cmpi.w	#$437,objoff_2A(a0)
	blo.s	loc_3AB8A
	addq.b	#2,routine_secondary(a0)
; loc_3AB7C:
ObjB2_Jump_to_ship:
	cmpi.w	#$447,objoff_2A(a0)
	bhs.s	loc_3AB8A
	move.w	#(button_A_mask<<8)|button_A_mask,(Ctrl_1_Logical).w

loc_3AB8A:
	cmpi.w	#$460,objoff_2A(a0)
	blo.s	ObjB2_Dock_on_DEZ
	move.b	#6,(Dynamic_Resize_Routine).w ; => LevEvents_WFZ_Routine4
	addq.b	#2,routine_secondary(a0)
	lea	(word_3AFB8).l,a2
	bsr.w	LoadChildObject
	move.w	#$3090,x_pos(a1)
	move.w	#$3D0,y_pos(a1)
	lea	(word_3AFB8).l,a2
	bsr.w	LoadChildObject
	move.w	#$30C0,x_pos(a1)
	move.w	#$3F0,y_pos(a1)
	lea	(word_3AFB8).l,a2
	bsr.w	LoadChildObject
	move.w	#$3090,x_pos(a1)
	move.w	#$410,y_pos(a1)
; loc_3ABDE:
ObjB2_Dock_on_DEZ:
	cmpi.w	#$9C0,objoff_2A(a0)
	bhs.s	ObjB2_Start_DEZ
	move.w	objoff_2A(a0),d0
	addq.w	#1,d0
	move.w	d0,objoff_2A(a0)
	move.w	objoff_34(a0),d1
	move.w	word_3AC16(pc,d1.w),d2
	cmp.w	d2,d0
	blo.s	loc_3AC0E
	addq.w	#2,d1
	move.w	d1,objoff_34(a0)
	lea	byte_3AC2A(pc,d1.w),a1
	move.b	(a1)+,x_vel(a0)
	move.b	(a1)+,y_vel(a0)

loc_3AC0E:
	bsr.w	ObjB2_Align_plane
	jmp DisplaySprite
; ===========================================================================
word_3AC16:
	dc.w  $1E0
	dc.w  $260	; 1
	dc.w  $2A0	; 2
	dc.w  $2C0	; 3
	dc.w  $300	; 4
	dc.w  $3A0	; 5
	dc.w  $3F0	; 6
	dc.w  $460	; 7
	dc.w  $4A0	; 8
	dc.w  $580	; 9
byte_3AC2A:
	dc.b $FF
	dc.b $FF	; 1
	dc.b   1	; 2
	dc.b   0	; 3
	dc.b   0	; 4
	dc.b   1	; 5
	dc.b   1	; 6
	dc.b $FF	; 7
	dc.b   1	; 8
	dc.b   1	; 9
	dc.b   1	; 10
	dc.b $FF	; 11
	dc.b $FF	; 12
	dc.b   1	; 13
	dc.b $FF	; 14
	dc.b $FF	; 15
	dc.b $FF	; 16
	dc.b   1	; 17
	dc.b $FE	; 18
	dc.b   0	; 19
	dc.b   0	; 20
	dc.b   0	; 21
; ===========================================================================
; loc_3AC40:
ObjB2_Start_DEZ:
	move.w	#death_egg_zone_act_1,(Current_ZoneAndAct).w
; loc_3AC46:
ObjB2_Deactivate_level:
	move.w	#1,(Level_Inactive_flag).w
	clr.b	(Last_star_pole_hit).w
	clr.b	(Last_star_pole_hit_2P).w
	rts
; ===========================================================================
; loc_3AC56:
ObjB2_Waiting_animation:
	lea	(MainCharacter).w,a1 ; a1=character
	move.l	#(1<<24)|(0<<16)|(AniIDSonAni_Wait<<8)|AniIDSonAni_Wait,mapping_frame(a1)
	move.w	#$100,anim_frame_duration(a1)
	rts
; ===========================================================================
; loc_3AC6A:
ObjB2_Invisible_grabber:
	moveq	#0,d0
	move.b	routine_secondary(a0),d0
	move.w	off_3AC78(pc,d0.w),d1
	jmp	off_3AC78(pc,d1.w)
; ===========================================================================
off_3AC78:	offsetTable
		offsetTableEntry.w loc_3AC7E	; 0
		offsetTableEntry.w loc_3AC84	; 2
		offsetTableEntry.w loc_3ACF2	; 4
; ===========================================================================

loc_3AC7E:
	move.b	#$C7,collision_flags(a0)

loc_3AC84:
	tst.b	collision_property(a0)
	beq.s	return_3ACF0
	addq.b	#2,routine_secondary(a0)
	clr.b	collision_flags(a0)
	move.w	#(224/2)+8,(Camera_Y_pos_bias).w
	movea.w	objoff_2C(a0),a1 ; a1=object
	bset	#6,status(a1)
	lea	(MainCharacter).w,a1 ; a1=character
	clr.w	x_vel(a1)
	clr.w	y_vel(a1)
	move.w	x_pos(a0),d0
	subi.w	#$10,d0
	move.w	d0,x_pos(a1)
	cmpi.b	#2,(Main_player).w
	bne.s	loc_3ACC8
	subi.w	#$10,y_pos(a1)

loc_3ACC8:
	bset	#0,status(a1)
	bclr	#1,status(a1)
	bclr	#2,status(a1)
	move.b	#AniIDSonAni_Hang,anim(a1)
	move.b	#1,(MainCharacter+obj_control).w
	move.b	#1,(WindTunnel_holding_flag).w
	clr.w	(Ctrl_1_Logical).w

return_3ACF0:
	rts
; ===========================================================================

loc_3ACF2:
	lea	(MainCharacter).w,a1 ; a1=character
	clr.w	x_vel(a1)
	clr.w	y_vel(a1)
	move.w	x_pos(a0),d0
	subi.w	#$10,d0
	move.w	d0,x_pos(a1)
	rts
; ===========================================================================

loc_3AD0C:
	moveq	#0,d0
	move.b	routine_secondary(a0),d0
	move.w	off_3AD1A(pc,d0.w),d1
	jmp	off_3AD1A(pc,d1.w)
; ===========================================================================
off_3AD1A:	offsetTable
		offsetTableEntry.w +	; 0
; ===========================================================================
+ ; loc_3AD1C:
	bchg	#2,status(a0)
	bne.w	return_37A48
	jmp DisplaySprite
; ===========================================================================

loc_3AD2A:
	moveq	#0,d0
	move.b	routine_secondary(a0),d0
	move.w	off_3AD38(pc,d0.w),d1
	jmp	off_3AD38(pc,d1.w)
; ===========================================================================
off_3AD38:	offsetTable
		offsetTableEntry.w +	; 0
; ===========================================================================
+ ; loc_3AD3A:
	jsr ObjectMove
	jmp MarkObjGone
; ===========================================================================

loc_3AD42:
	moveq	#0,d0
	move.b	routine_secondary(a0),d0
	move.w	off_3AD50(pc,d0.w),d1
	jmp	off_3AD50(pc,d1.w)
; ===========================================================================
off_3AD50:	offsetTable
		offsetTableEntry.w loc_3AD54	; 0
		offsetTableEntry.w loc_3AD5C	; 2
; ===========================================================================

loc_3AD54:
	bsr.w	loc_3AD6E
	jmp DisplaySprite
; ===========================================================================

loc_3AD5C:
	bsr.w	loc_3AD6E
	lea	(Ani_objB2_b).l,a1
	jsr AnimateSprite
	jmp DisplaySprite
; ===========================================================================

loc_3AD6E:
	movea.w	objoff_2C(a0),a1 ; a1=object
	move.w	x_pos(a1),d0
	subi.w	#$C,d0
	move.w	d0,x_pos(a0)
	move.w	y_pos(a1),d0
	addi.w	#$28,d0
	move.w	d0,y_pos(a0)
	rts
; ===========================================================================
; loc_3AD8C:
ObjB2_Align_plane:
	move.w	x_pos(a0),-(sp)
	jsr ObjectMove
	bsr.w	loc_36776
	move.w	#$1B,d1
	move.w	#8,d2
	move.w	#9,d3
	move.w	(sp)+,d4
	jmp	SolidObject
; ===========================================================================
; loc_3ADAA:
ObjB2_Move_with_player:
	lea	(MainCharacter).w,a1 ; a1=character
	btst	#3,status(a1)
	beq.s	ObjB2_Move_below_player
	bsr.w	ObjB2_Move_vert
	bsr.w	ObjB2_Vertical_limit
	jsr ObjectMove
	bra.w	loc_36776
; ===========================================================================
; loc_3ADC6:
ObjB2_Move_below_player:
	tst.b	objoff_2E(a0)
	beq.s	loc_3ADD4
	bsr.w	Obj_GetOrientationToPlayer
	move.w	d2,objoff_38(a0)

loc_3ADD4:
	move.w	#1,d0
	move.w	objoff_38(a0),d3
	beq.s	loc_3ADE8
	bmi.s	loc_3ADE2
	neg.w	d0

loc_3ADE2:
	add.w	d0,d3
	move.w	d3,objoff_38(a0)

loc_3ADE8:
	move.w	x_pos(a1),d1
	add.w	d3,d1
	move.w	d1,x_pos(a0)
	bra.w	loc_36776
; ===========================================================================
; loc_3ADF6:
ObjB2_Move_vert:
	tst.b	objoff_2F(a0)
	bne.s	loc_3AE16
	tst.b	objoff_2E(a0)
	beq.s	return_3AE38
	st	objoff_2F(a0)
	clr.b	objoff_30(a0)
	move.w	#$200,y_vel(a0)
	move.b	#$14,objoff_31(a0)

loc_3AE16:
	subq.b	#1,objoff_31(a0)
	bpl.s	loc_3AE26
	clr.b	objoff_2F(a0)
	clr.w	y_vel(a0)
	rts
; ===========================================================================

loc_3AE26:
	move.w	y_vel(a0),d0
	cmpi.w	#-$100,d0
	ble.s	loc_3AE34
	addi.w	#-$20,d0

loc_3AE34:
	move.w	d0,y_vel(a0)

return_3AE38:
	rts
; ===========================================================================
; loc_3AE3A:
ObjB2_Move_obbey_player:
	lea	(MainCharacter).w,a1 ; a1=character
	btst	#3,status(a1)
	beq.s	ObjB2_Move_vert2
	tst.b	objoff_2F(a0)
	bne.s	loc_3AE72
	clr.w	y_vel(a0)
	move.w	(Ctrl_1).w,d2
	move.w	#$80,d3
	andi.w	#(button_up_mask|button_down_mask)<<8,d2
	beq.s	loc_3AE72
	andi.w	#button_down_mask<<8,d2
	bne.s	loc_3AE66
	neg.w	d3

loc_3AE66:
	move.w	d3,y_vel(a0)
	bsr.w	ObjB2_Vertical_limit
	jsr ObjectMove

loc_3AE72:
	bsr.w	Obj_GetOrientationToPlayer
	moveq	#$10,d3
	add.w	d3,d2
	cmpi.w	#$20,d2
	blo.s	return_3AE9E
	mvabs.w	inertia(a1),d2
	cmpi.w	#$900,d2
	bhs.s	return_3AE9E
	tst.w	d0
	beq.s	loc_3AE94
	neg.w	d3

loc_3AE94:
	move.w	x_pos(a1),d1
	add.w	d3,d1
	move.w	d1,x_pos(a0)

return_3AE9E:
	rts
; ===========================================================================
; loc_3AEA0:
ObjB2_Move_vert2:
	tst.b	objoff_30(a0)
	bne.s	loc_3AEC0
	tst.b	objoff_2E(a0)
	beq.s	return_3AE9E
	st	objoff_30(a0)
	clr.b	objoff_2F(a0)
	move.w	#$200,y_vel(a0)
	move.b	#$2B,objoff_31(a0)

loc_3AEC0:
	subq.b	#1,objoff_31(a0)
	bpl.s	loc_3AED0
	clr.b	objoff_30(a0)
	clr.w	y_vel(a0)
	rts
; ===========================================================================

loc_3AED0:
	move.w	y_vel(a0),d0
	cmpi.w	#-$100,d0
	ble.s	loc_3AEDE
	addi.w	#-$20,d0

loc_3AEDE:
	move.w	d0,y_vel(a0)
	bsr.w	ObjB2_Vertical_limit
	jsr ObjectMove
	rts
; ===========================================================================
; loc_3AEEC:
ObjB2_Horizontal_limit:
	bsr.w	Obj_GetOrientationToPlayer
	moveq	#$10,d3
	add.w	d3,d2
	cmpi.w	#$20,d2
	blo.s	return_3AF0A
	tst.w	d0
	beq.s	loc_3AF00
	neg.w	d3

loc_3AF00:
	move.w	x_pos(a0),d1
	sub.w	d3,d1
	move.w	d1,x_pos(a1)

return_3AF0A:
	rts
; ===========================================================================
; loc_3AF0C:
ObjB2_Vertical_limit:
	move.w	(Camera_Y_pos).w,d0
	move.w	y_pos(a0),d1
	move.w	y_vel(a0),d2
	beq.s	return_3AF32
	bpl.s	loc_3AF26
	addi.w	#$34,d0
	cmp.w	d0,d1
	blo.s	loc_3AF2E
	rts
; ===========================================================================

loc_3AF26:
	addi.w	#$A8,d0
	cmp.w	d0,d1
	blo.s	return_3AF32

loc_3AF2E:
	clr.w	y_vel(a0)

return_3AF32:
	rts
; ===========================================================================
; loc_3AF34:
ObjB2_Main_WFZ_Start_load_smoke:
	jsr SingleObjLoad2
	bne.s	+
	_move.b	#ObjID_TornadoSmoke2,id(a1) ; load objC3
	move.b	#$90,subtype(a1) ; <== ObjC3_SubObjData
	move.w	a0,objoff_2C(a1)
	move.w	x_pos(a0),x_pos(a1)
	move.w	y_pos(a0),y_pos(a1)
+ ; return_3AF56:
	rts
; ===========================================================================
; loc_3AF58:
ObjB2_Animate_Pilot:
	subq.b	#1,objoff_37(a0)
	bmi.s	+
	rts
; ===========================================================================
+ ; loc_3AF60:
	move.b	#8,objoff_37(a0)
	moveq	#0,d0
	move.b	objoff_36(a0),d0
	cmpi.b	#1,(Sec_player).w
	bne.s	+
	moveq	#Sonic_pilot_frames_end-Sonic_pilot_frames,d1
+
	cmpi.b	#2,(Sec_player).w
	bne.s	+
	moveq	#Tails_pilot_frames_end-Tails_pilot_frames,d1
+
	cmpi.b	#3,(Sec_player).w
	bne.s	+
	moveq	#Knuckles_pilot_frames_end-Knuckles_pilot_frames,d1
+

  ; loc_3AF78:
	addq.b	#1,d0
	cmp.w	d1,d0
	blo.s	+
	moveq	#0,d0
+ ; loc_3AF80:
	move.b	d0,objoff_36(a0)
	cmpi.b	#1,(Sec_player).w
	bne.s	+
	move.b	Sonic_pilot_frames(pc,d0.w),d0
	jmp LoadSonicDynPLC_Part2
+
	cmpi.b	#2,(Sec_player).w
	bne.s	+
	move.b	Tails_pilot_frames(pc,d0.w),d0
	jmp LoadTailsDynPLC_Part2
+
	cmpi.b	#3,(Sec_player).w
	bne.s	+
	move.b	Knuckles_pilot_frames(pc,d0.w),d0
	jmp LoadKnucklesDynPLC_Part2
+
;	include "objects/ObjB2 - Animate Pilot.asm"
; ===========================================================================
  ; loc_3AF94:
; ===========================================================================
; byte_3AF9C:
Sonic_pilot_frames:
	dc.b $21
	dc.b $24	; 1
Sonic_pilot_frames_end:

; byte_3AFA0:
Tails_pilot_frames:
	dc.b $FB
	dc.b $FB	; 1
	dc.b $FB	; 2
	dc.b $FB	; 3
	dc.b   $FC	; 4
	dc.b   $FD	; 5
	dc.b   $FE	; 6
	dc.b   $FD	; 7
	dc.b   $FC	; 8
	dc.b   $FC	; 9
	dc.b $FB	; 10
	dc.b $FB	; 11
	dc.b $FB	; 12
	dc.b $FB	; 13
	dc.b   $FC	; 14
	dc.b   $FD	; 15
	dc.b   $FE	; 16
	dc.b   $FD	; 17
	dc.b   $FC	; 18
	dc.b   $FC	; 19
	dc.b   $FF	; 20
	dc.b   $FF	; 21
	dc.b   $FC	; 22
	dc.b   $FC	; 23
Tails_pilot_frames_end:

Knuckles_pilot_frames:
	dc.b $21
	dc.b $22
	dc.b $23
	dc.b $24
Knuckles_pilot_frames_end:

word_3AFB8:
	dc.w objoff_3E
	dc.b ObjID_Tornado
	dc.b $58
word_3AFBC:
	dc.w objoff_3C
	dc.b ObjID_Tornado
	dc.b $56
word_3AFC0:
	dc.w objoff_3A
	dc.b ObjID_Tornado
	dc.b $5C
; seems unused
	dc.w objoff_3E
	dc.b ObjID_Tornado
	dc.b $5A
; off_3AFC8:
ObjB2_SubObjData:
	subObjData ObjB2_MapUnc_3AFF2,make_art_tile(ArtTile_ArtNem_Tornado,0,1),4,4,$60,0
; off_3AFD2:
ObjB2_SubObjData2:
	subObjData ObjB2_MapUnc_3B292,make_art_tile(ArtTile_ArtNem_TornadoThruster,0,0),4,3,$40,0
; animation script
; off_3AFDC:
Ani_objB2_a:	offsetTable
		offsetTableEntry.w byte_3AFE0	; 0
		offsetTableEntry.w byte_3AFE6	; 1
		offsetTableEntry.w byte_3AFE6K	; 1
byte_3AFE0:	dc.b   0,  0,  1,  2,  3,$FF
byte_3AFE6:	dc.b   0,  4,  5,  6,  7,$FF
byte_3AFE6K:	dc.b   0,  8,  9,  $A,  $B,$FF
		even
; animation script
; off_3AFEC:
Ani_objB2_b:	offsetTable
		offsetTableEntry.w +	; 0
; byte_3AFEE:
+		dc.b   0,  1,  2,$FF
		even
; -----------------------------------------------------------------------------
; sprite mappings
; -----------------------------------------------------------------------------
ObjB2_MapUnc_3AFF2:	BINCLUDE "mappings/sprite/objB2_a.bin"
; -----------------------------------------------------------------------------
; sprite mappings
; -----------------------------------------------------------------------------
ObjB2_MapUnc_3B292:	BINCLUDE "mappings/sprite/objB2_b.bin"

