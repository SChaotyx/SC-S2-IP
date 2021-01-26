
; ===========================================================================
; ----------------------------------------------------------------------------
; Object 01 - Main Character
; ----------------------------------------------------------------------------
; Sprite_19F50:
Obj01:
	; a0=character
	tst.w	(Debug_placement_mode).w	; is debug mode being used?
	beq.s	Obj01_Normal			; if not, branch
	jmp	(DebugMode).l
; ---------------------------------------------------------------------------
; loc_19F5C:
Obj01_Normal:
	moveq	#0,d0
	move.b	routine(a0),d0
	move.w	Obj01_Index(pc,d0.w),d1
	jmp	Obj01_Index(pc,d1.w)
; ===========================================================================
; off_19F6A: Obj01_States:
Obj01_Index:	offsetTable
		offsetTableEntry.w Obj01_Init		;  0
		offsetTableEntry.w Obj01_Control	;  2
		offsetTableEntry.w Obj01_Hurt		;  4
		offsetTableEntry.w Obj01_Dead		;  6
		offsetTableEntry.w Obj01_Gone		;  8
		offsetTableEntry.w Obj01_Respawning	; $A
		offsetTableEntry.w Obj01_Drowned	; $C
; ===========================================================================
; loc_19F76: Obj_01_Sub_0: Obj01_Main:
Obj01_Init:
	addq.b	#2,routine(a0)	; => Obj01_Control
	bsr.w	SetPlayer_Radius
    bsr.w   SetPlayer_Mappings
	move.b	#2,priority(a0)
	move.b	#$18,width_pixels(a0)
	move.b	#4,render_flags(a0)
	lea	(Sonic_top_speed).w,a2	; Load Sonic_top_speed into a2
	bsr.w	ApplySpeedSettings	; Fetch Speed settings
	;tst.b	(Last_star_pole_hit).w
	;bne.s	Obj01_Init_Continued
	; only happens when not starting at a checkpoint:
	bsr.w	SetPlayer_ArtTile
	bsr.w	Adjust2PArtPointer
	move.b	#$C,top_solid_bit(a0)
	move.b	#$D,lrb_solid_bit(a0)
	move.w	x_pos(a0),(Saved_x_pos).w
	move.w	y_pos(a0),(Saved_y_pos).w
	move.w	art_tile(a0),(Saved_art_tile).w
	move.w	top_solid_bit(a0),(Saved_Solid_bits).w

Obj01_Init_Continued:
	move.b	#0,flips_remaining(a0)
	move.b	#4,flip_speed(a0)
	move.b	#0,(Super_Sonic_flag).w
	move.b	#$1E,air_left(a0)
    cmpi.b  #2,(Main_player).w
    bne.s   +
    move.b	#ObjID_TailsTails,(Tails_Tails+id).w ; load Obj05 (Tails' Tails) at $FFFFD000
	move.w	a0,(Tails_Tails+parent).w ; set its parent object to this
+
	subi.w	#$20,x_pos(a0)
	addi_.w	#4,y_pos(a0)
	move.w	#0,(Sonic_Pos_Record_Index).w

	move.w	#$3F,d2
-	bsr.w	Sonic_RecordPos
	subq.w	#4,a1
	move.l	#0,(a1)
	dbf	d2,-

	addi.w	#$20,x_pos(a0)
	subi_.w	#4,y_pos(a0)

; ---------------------------------------------------------------------------
; Normal state for Sonic
; ---------------------------------------------------------------------------
; loc_1A030: Obj_01_Sub_2:
Obj01_Control:
	tst.w	(Debug_mode_flag).w	; is debug cheat enabled?
	beq.s	+			; if not, branch
	btst	#button_B,(Ctrl_1_Press).w	; is button B pressed?
	beq.s	+			; if not, branch
	move.w	#1,(Debug_placement_mode).w	; change Sonic into a ring/item
	clr.b	(Control_Locked).w		; unlock control
	rts
; -----------------------------------------------------------------------
+	tst.b	(Control_Locked).w	; are controls locked?
	bne.s	+			; if yes, branch
	move.w	(Ctrl_1).w,(Ctrl_1_Logical).w	; copy new held buttons, to enable joypad control
+
	btst	#0,obj_control(a0)	; is Sonic interacting with another object that holds him in place or controls his movement somehow?
	bne.s	+			; if yes, branch to skip Sonic's control
	moveq	#0,d0
	move.b	status(a0),d0
	andi.w	#6,d0	; %0000 %0110
	move.w	Obj01_Modes(pc,d0.w),d1
	jsr	Obj01_Modes(pc,d1.w)	; run Sonic's movement control code
+
	cmpi.w	#-$100,(Camera_Min_Y_pos).w	; is vertical wrapping enabled?
	bne.s	+				; if not, branch
	andi.w	#$7FF,y_pos(a0) 		; perform wrapping of Sonic's y position
+
	bsr.s	Sonic_Display
	bsr.w	Sonic_Super
	bsr.w	Sonic_RecordPos
	bsr.w	Sonic_Water
	move.b	(Primary_Angle).w,next_tilt(a0)
	move.b	(Secondary_Angle).w,tilt(a0)
	tst.b	(WindTunnel_flag).w
	beq.s	+
	tst.b	anim(a0)
	bne.s	+
	move.b	next_anim(a0),anim(a0)
+
	bsr.w	SetPlayer_Animate
	tst.b	obj_control(a0)
	bmi.s	+
	jsr	(TouchResponse).l
+
	bra.w	LoadPlayerDynPLC

; ===========================================================================
; secondary states under state Obj01_Control
; off_1A0BE:
Obj01_Modes:	offsetTable
		offsetTableEntry.w Obj01_MdNormal	; 0 - not airborne or rolling
		offsetTableEntry.w Obj01_MdAir			; 2 - airborne
		offsetTableEntry.w Obj01_MdRoll			; 4 - rolling
		offsetTableEntry.w Obj01_MdJump			; 6 - jumping
; ===========================================================================

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1A0C6:
Sonic_Display:
	move.w	invulnerable_time(a0),d0
	beq.s	Obj01_Display
	subq.w	#1,invulnerable_time(a0)
	lsr.w	#3,d0
	bcc.s	Obj01_ChkInvin
; loc_1A0D4:
Obj01_Display:
	jsr	(DisplaySprite).l
; loc_1A0DA:
Obj01_ChkInvin:		; Checks if invincibility has expired and disables it if it has.
	btst	#status_sec_isInvincible,status_secondary(a0)
	beq.s	Obj01_ChkShoes
	tst.w	invincibility_time(a0)
	beq.s	Obj01_ChkShoes	; If there wasn't any time left, that means we're in Super Sonic mode.
	subq.w	#1,invincibility_time(a0)
	bne.s	Obj01_ChkShoes
	tst.b	(Current_Boss_ID).w	; Don't change music if in a boss fight
	bne.s	Obj01_RmvInvin
	cmpi.b	#$C,air_left(a0)	; Don't change music if drowning
	blo.s	Obj01_RmvInvin
	move.w	(Level_Music).w,d0
	jsr	(PlayMusic).l
;loc_1A106:
Obj01_RmvInvin:
	bclr	#status_sec_isInvincible,status_secondary(a0)
; loc_1A10C:
Obj01_ChkShoes:		; Checks if Speed Shoes have expired and disables them if they have.
	btst	#status_sec_hasSpeedShoes,status_secondary(a0)
	beq.s	Obj01_ExitChk
	tst.w	speedshoes_time(a0)
	beq.s	Obj01_ExitChk
	subq.w	#1,speedshoes_time(a0)
	bne.s	Obj01_ExitChk
	lea	(Sonic_top_speed).w,a2	; Load Sonic_top_speed into a2
	bsr.w	ApplySpeedSettings	; Fetch Speed settings
; loc_1A14A:
Obj01_RmvSpeed:
	bclr	#status_sec_hasSpeedShoes,status_secondary(a0)
	move.w	#MusID_SlowDown,d0	; Slow down tempo
	jmp	(PlayMusic).l
; ---------------------------------------------------------------------------
; return_1A15A:
Obj01_ExitChk:
	rts
; End of subroutine Sonic_Display

; ---------------------------------------------------------------------------
; Subroutine to record Sonic's previous positions for invincibility stars
; and input/status flags for Tails' AI to follow
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1A15C:
Sonic_RecordPos:
	move.w	(Sonic_Pos_Record_Index).w,d0
	lea	(Sonic_Pos_Record_Buf).w,a1
	lea	(a1,d0.w),a1
	move.w	x_pos(a0),(a1)+
	move.w	y_pos(a0),(a1)+
	addq.b	#4,(Sonic_Pos_Record_Index+1).w

	lea	(Sonic_Stat_Record_Buf).w,a1
	lea	(a1,d0.w),a1
	move.w	(Ctrl_1_Logical).w,(a1)+
	move.w	status(a0),(a1)+

	rts
; End of subroutine Sonic_RecordPos

; ---------------------------------------------------------------------------
; Subroutine for Sonic when he's underwater
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1A186:
Sonic_Water:
	tst.b	(Water_flag).w	; does level have water?
	bne.s	Obj01_InWater	; if yes, branch

return_1A18C:
	rts
; ---------------------------------------------------------------------------
; loc_1A18E:
Obj01_InWater:
	move.w	(Water_Level_1).w,d0
	cmp.w	y_pos(a0),d0	; is Sonic above the water?
	bge.s	Obj01_OutWater	; if yes, branch

	tst.w	y_vel(a0)	; check if player is moving upward (i.e. from jumping)
	bmi.s	return_1A18C	; if yes, skip routine

	bset	#6,status(a0)	; set underwater flag
	bne.s	return_1A18C	; if already underwater, branch

	movea.l	a0,a1
	bsr.w	ResumeMusic
	move.b	#ObjID_SmallBubbles,(Sonic_BreathingBubbles+id).w ; load Obj0A (sonic's breathing bubbles) at $FFFFD080
	move.b	#$81,(Sonic_BreathingBubbles+subtype).w
	move.l	a0,(Sonic_BreathingBubbles+objoff_3C).w
	lea	(Sonic_top_speed).w,a2	; Load Sonic_top_speed into a2
	bsr.w	ApplySpeedSettings	; Fetch Speed settings
	asr.w	x_vel(a0)
	asr.w	y_vel(a0)	; memory operands can only be shifted one bit at a time
	asr.w	y_vel(a0)
	beq.s	return_1A18C
	move.w	#$100,(Sonic_Dust+anim).w	; splash animation
	move.w	#SndID_Splash,d0	; splash sound
	jmp	(PlaySound).l
; ---------------------------------------------------------------------------
; loc_1A1FE:
Obj01_OutWater:
	bclr	#6,status(a0) ; unset underwater flag
	beq.s	return_1A18C ; if already above water, branch

	movea.l	a0,a1
	bsr.w	ResumeMusic
	lea	(Sonic_top_speed).w,a2	; Load Sonic_top_speed into a2
	bsr.w	ApplySpeedSettings	; Fetch Speed settings
	cmpi.b	#4,routine(a0)	; is Sonic falling back from getting hurt?
	beq.s	+		; if yes, branch
	asl	y_vel(a0)
+
	tst.w	y_vel(a0)
	beq.w	return_1A18C
	move.w	#$100,(Sonic_Dust+anim).w	; splash animation
	movea.l	a0,a1
	bsr.w	ResumeMusic
	cmpi.w	#-$1000,y_vel(a0)
	bgt.s	+
	move.w	#-$1000,y_vel(a0)	; limit upward y velocity exiting the water
+
	move.w	#SndID_Splash,d0	; splash sound
	jmp	(PlaySound).l
; End of subroutine Sonic_Water

; ===========================================================================
; loc_1A2B8:
Obj01_MdNormal:
	bsr.w	SetPlayer_Move
	bsr.w	Sonic_CheckSpindash
	bsr.w	Sonic_Jump
	bsr.w	Sonic_SlopeResist
	bsr.w	Sonic_Move
	bsr.w	Sonic_Roll
	bsr.w	Sonic_LevelBound
	jsr	(ObjectMove).l
	bsr.w	AnglePos
	bsr.w	Sonic_SlopeRepel

return_1A2DE:
	rts
; End of subroutine Obj01_MdNormal

; ===========================================================================
; Start of subroutine Obj01_MdAir
; Called if Sonic is airborne, but not in a ball (thus, probably not jumping)
; loc_1A2E0: Obj01_MdJump
Obj01_MdAir:
	tst.b	double_jump_flag(a0)
	bne.w	DoubleJump_Check
	bsr.w	Sonic_JumpHeight
	bsr.w	Sonic_ChgJumpDir
	bsr.w	Sonic_LevelBound
	jsr	(ObjectMoveAndFall).l
	btst	#6,status(a0)	; is Sonic underwater?
	beq.s	+		; if not, branch
	subi.w	#$28,y_vel(a0)	; reduce gravity by $28 ($38-$28=$10)
+
	bsr.w	Sonic_JumpAngle
	bsr.w	Sonic_DoLevelCollision
	rts
; End of subroutine Obj01_MdAir
; ===========================================================================
; Start of subroutine Obj01_MdRoll
; Called if Sonic is in a ball, but not airborne (thus, probably rolling)
; loc_1A30A:
Obj01_MdRoll:
	tst.b	pinball_mode(a0)
	bne.s	+
	bsr.w	Sonic_Jump
+
	bsr.w	Sonic_RollRepel
	bsr.w	Sonic_RollSpeed
	bsr.w	Sonic_LevelBound
	jsr	(ObjectMove).l
	bsr.w	AnglePos
	bsr.w	Sonic_SlopeRepel
	rts
; End of subroutine Obj01_MdRoll
; ===========================================================================
; Start of subroutine Obj01_MdJump
; Called if Sonic is in a ball and airborne (he could be jumping but not necessarily)
; Notes: This is identical to Obj01_MdAir, at least at this outer level.
;        Why they gave it a separate copy of the code, I don't know.
; loc_1A330: Obj01_MdJump2:
Obj01_MdJump:
	bsr.w	Sonic_JumpHeight
	bsr.w	Sonic_ChgJumpDir
	bsr.w	Sonic_LevelBound
	jsr	(ObjectMoveAndFall).l
	btst	#6,status(a0)	; is Sonic underwater?
	beq.s	+		; if not, branch
	subi.w	#$28,y_vel(a0)	; reduce gravity by $28 ($38-$28=$10)
+
	bsr.w	Sonic_JumpAngle
	bsr.w	Sonic_DoLevelCollision
	rts
; End of subroutine Obj01_MdJump

; ---------------------------------------------------------------------------
; Subroutine to make Sonic walk/run
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1A35A:
Sonic_Move:
	move.w	(Sonic_top_speed).w,d6
	move.w	(Sonic_acceleration).w,d5
	move.w	(Sonic_deceleration).w,d4
    if status_sec_isSliding = 7
	tst.b	status_secondary(a0)
	bmi.w	Obj01_Traction
    else
	btst	#status_sec_isSliding,status_secondary(a0)
	bne.w	Obj01_Traction
    endif
	tst.w	move_lock(a0)
	bne.w	Obj01_ResetScr
	btst	#button_left,(Ctrl_1_Held_Logical).w	; is left being pressed?
	beq.s	Obj01_NotLeft			; if not, branch
	bsr.w	Sonic_MoveLeft
; loc_1A382:
Obj01_NotLeft:
	btst	#button_right,(Ctrl_1_Held_Logical).w	; is right being pressed?
	beq.s	Obj01_NotRight			; if not, branch
	bsr.w	Sonic_MoveRight
; loc_1A38E:
Obj01_NotRight:
	move.b	angle(a0),d0
	addi.b	#$20,d0
	andi.b	#$C0,d0		; is Sonic on a slope?
	bne.w	Obj01_ResetScr	; if yes, branch
	tst.w	inertia(a0)	; is Sonic moving?
	bne.w	Obj01_ResetScr	; if yes, branch
	bclr	#5,status(a0)
	move.b	#AniIDSonAni_Wait,anim(a0)	; use "standing" animation
	btst	#3,status(a0)
	beq.w	MainPlayer_Balance
	moveq	#0,d0
	move.b	interact(a0),d0
    if object_size=$40
	lsl.w	#6,d0
    else
	mulu.w	#object_size,d0
    endif
	lea	(Object_RAM).w,a1 ; a1=character
	lea	(a1,d0.w),a1 ; a1=object
	tst.b	status(a1)
	bmi.w	MainPlayer_Lookup
	moveq	#0,d1
	move.b	width_pixels(a1),d1
	move.w	d1,d2
	add.w	d2,d2
	subq.w	#2,d2
	add.w	x_pos(a0),d1
	sub.w	x_pos(a1),d1
	;tst.b	(Super_Sonic_flag).w
	;bne.w	SuperSonic_Balance
	cmpi.w	#2,d1
	blt.w	MainPlayer_BalanceOnObjLeft
	cmp.w	d2,d1
	bge.w	MainPlayer_BalanceOnObjRight
	bra.w	MainPlayer_Lookup
; ---------------------------------------------------------------------------

MainPlayer_Balance:
	jsr	(ChkFloorEdge).l
	cmpi.w	#$C,d1
	blt.w	MainPlayer_Lookup
	cmpi.b	#3,next_tilt(a0)
	bne.s	MainPlayer_BalanceLeft
	bclr	#0,status(a0)
	bra.s	MainPlayer_BalanceDone

MainPlayer_BalanceOnObjRight:
	bclr	#0,status(a0)
	bra.s	MainPlayer_BalanceonObjDone
; ---------------------------------------------------------------------------

MainPlayer_BalanceLeft:
	cmpi.b	#3,tilt(a0)
	bne.w	MainPlayer_Lookup
	bset	#0,status(a0)
	bra.s	MainPlayer_BalanceDone

MainPlayer_BalanceOnObjLeft:
	bset	#0,status(a0)
	bra.s	MainPlayer_BalanceonObjDone
; ---------------------------------------------------------------------------

MainPlayer_BalanceDone:
	move.b	#AniIDSonAni_Balance,anim(a0)
	cmpi.b	#1,(Main_player).w
	bne.w	Obj01_ResetScr
	move.w	x_pos(a0),d3
	btst	#0,status(a0)
	bne.s	+
	subq.w	#6,d3
	bra.s	++
+
	addq.w	#6,d3
+
	jsr	(ChkFloorEdge_Part2).l
	cmpi.w	#$C,d1
	blt.w	Obj01_ResetScr
	move.b	#AniIDSonAni_Balance2,anim(a0)
	btst	#0,status(a0)
	bne.w	Obj01_ResetScr
	bclr	#0,status(a0)
	bra.w	Obj01_ResetScr
; ---------------------------------------------------------------------------

MainPlayer_BalanceonObjDone:
	move.b	#AniIDSonAni_Balance,anim(a0)
	cmpi.b	#1,(Main_player).w
	bne.w	Obj01_ResetScr
	btst	#0,status(a0)
	bne.s	+
	addq.w	#6,d2
	cmp.w	d2,d1
	blt.w	Obj01_ResetScr
	bra.s	++
+
	cmpi.w	#-4,d1
	bge.w	Obj01_ResetScr
+
	move.b	#AniIDSonAni_Balance2,anim(a0)
	btst	#0,status(a0)
	bne.w	Obj01_ResetScr
	bclr	#0,status(a0)
	bra.w	Obj01_ResetScr


; ---------------------------------------------------------------------------
; loc_1A584:
MainPlayer_Lookup:
	btst	#button_up,(Ctrl_1_Held_Logical).w	; is up being pressed?
	beq.s	Sonic_Duck			; if not, branch
	move.b	#AniIDSonAni_LookUp,anim(a0)			; use "looking up" animation
	addq.w	#1,(Sonic_Look_delay_counter).w
	cmpi.w	#$78,(Sonic_Look_delay_counter).w
	blo.s	Obj01_ResetScr_Part2
	move.w	#$78,(Sonic_Look_delay_counter).w
	cmpi.w	#$C8,(Camera_Y_pos_bias).w
	beq.s	Obj01_UpdateSpeedOnGround
	addq.w	#2,(Camera_Y_pos_bias).w
	bra.s	Obj01_UpdateSpeedOnGround
; ---------------------------------------------------------------------------
; loc_1A5B2:
Sonic_Duck:
	btst	#button_down,(Ctrl_1_Held_Logical).w	; is down being pressed?
	beq.s	Obj01_ResetScr			; if not, branch
	move.b	#AniIDSonAni_Duck,anim(a0)			; use "ducking" animation
	addq.w	#1,(Sonic_Look_delay_counter).w
	cmpi.w	#$78,(Sonic_Look_delay_counter).w
	blo.s	Obj01_ResetScr_Part2
	move.w	#$78,(Sonic_Look_delay_counter).w
	cmpi.w	#8,(Camera_Y_pos_bias).w
	beq.s	Obj01_UpdateSpeedOnGround
	subq.w	#2,(Camera_Y_pos_bias).w
	bra.s	Obj01_UpdateSpeedOnGround

; ===========================================================================
; moves the screen back to its normal position after looking up or down
; loc_1A5E0:
Obj01_ResetScr:
	move.w	#0,(Sonic_Look_delay_counter).w
; loc_1A5E6:
Obj01_ResetScr_Part2:
	cmpi.w	#(224/2)-16,(Camera_Y_pos_bias).w	; is screen in its default position?
	beq.s	Obj01_UpdateSpeedOnGround	; if yes, branch.
	bhs.s	+				; depending on the sign of the difference,
	addq.w	#4,(Camera_Y_pos_bias).w	; either add 2
+	subq.w	#2,(Camera_Y_pos_bias).w	; or subtract 2

; ---------------------------------------------------------------------------
; updates Sonic's speed on the ground
; ---------------------------------------------------------------------------
; sub_1A5F8:
Obj01_UpdateSpeedOnGround:
	tst.b	(Super_Sonic_flag).w
	beq.w	+
	move.w	#$C,d5
+
	move.b	(Ctrl_1_Held_Logical).w,d0
	andi.b	#button_left_mask|button_right_mask,d0 ; is left/right pressed?
	bne.s	Obj01_Traction	; if yes, branch
	move.w	inertia(a0),d0
	beq.s	Obj01_Traction
	bmi.s	Obj01_SettleLeft

; slow down when facing right and not pressing a direction
; Obj01_SettleRight:
	sub.w	d5,d0
	bcc.s	+
	move.w	#0,d0
+
	move.w	d0,inertia(a0)
	bra.s	Obj01_Traction
; ---------------------------------------------------------------------------
; slow down when facing left and not pressing a direction
; loc_1A624:
Obj01_SettleLeft:
	add.w	d5,d0
	bcc.s	+
	move.w	#0,d0
+
	move.w	d0,inertia(a0)

; increase or decrease speed on the ground
; loc_1A630:
Obj01_Traction:
	move.b	angle(a0),d0
	jsr	(CalcSine).l
	muls.w	inertia(a0),d1
	asr.l	#8,d1
	move.w	d1,x_vel(a0)
	muls.w	inertia(a0),d0
	asr.l	#8,d0
	move.w	d0,y_vel(a0)

; stops Sonic from running through walls that meet the ground
; loc_1A64E:
Obj01_CheckWallsOnGround:
	move.b	angle(a0),d0
	addi.b	#$40,d0
	bmi.s	return_1A6BE
	move.b	#$40,d1			; Rotate 90 degrees clockwise
	tst.w	inertia(a0)		; Check inertia
	beq.s	return_1A6BE	; If not moving, don't do anything
	bmi.s	+				; If negative, branch
	neg.w	d1				; Otherwise, we want to rotate counterclockwise
+
	move.b	angle(a0),d0
	add.b	d1,d0
	move.w	d0,-(sp)
	bsr.w	CalcRoomInFront
	move.w	(sp)+,d0
	tst.w	d1
	bpl.s	return_1A6BE
	asl.w	#8,d1
	addi.b	#$20,d0
	andi.b	#$C0,d0
	beq.s	loc_1A6BA
	cmpi.b	#$40,d0
	beq.s	loc_1A6A8
	cmpi.b	#$80,d0
	beq.s	loc_1A6A2
	add.w	d1,x_vel(a0)
	bset	#5,status(a0)
	move.w	#0,inertia(a0)
	rts
; ---------------------------------------------------------------------------
loc_1A6A2:
	sub.w	d1,y_vel(a0)
	rts
; ---------------------------------------------------------------------------
loc_1A6A8:
	sub.w	d1,x_vel(a0)
	bset	#5,status(a0)
	move.w	#0,inertia(a0)
	rts
; ---------------------------------------------------------------------------
loc_1A6BA:
	add.w	d1,y_vel(a0)

return_1A6BE:
	rts
; End of subroutine Sonic_Move


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1A6C0:
Sonic_MoveLeft:
	move.w	inertia(a0),d0
	beq.s	+
	bpl.s	Sonic_TurnLeft ; if Sonic is already moving to the right, branch
+
	bset	#0,status(a0)
	bne.s	+
	bclr	#5,status(a0)
	move.b	#AniIDSonAni_Run,next_anim(a0)
+
	sub.w	d5,d0	; add acceleration to the left
	move.w	d6,d1
	neg.w	d1
	cmp.w	d1,d0	; compare new speed with top speed
	bgt.s	+	; if new speed is less than the maximum, branch
	add.w	d5,d0	; remove this frame's acceleration change
	cmp.w	d1,d0	; compare speed with top speed
	ble.s	+	; if speed was already greater than the maximum, branch
	move.w	d1,d0	; limit speed on ground going left
+
	move.w	d0,inertia(a0)
	move.b	#AniIDSonAni_Walk,anim(a0)	; use walking animation
	rts
; ---------------------------------------------------------------------------
; loc_1A6FA:
Sonic_TurnLeft:
	sub.w	d4,d0
	bcc.s	+
	move.w	#-$80,d0
+
	move.w	d0,inertia(a0)
	move.b	angle(a0),d0
	addi.b	#$20,d0
	andi.b	#$C0,d0
	bne.s	return_1A744
	cmpi.w	#$400,d0
	blt.s	return_1A744
	move.b	#AniIDSonAni_Stop,anim(a0)	; use "stopping" animation
	bclr	#0,status(a0)
	move.w	#SndID_Skidding,d0
	jsr	(PlaySound).l
	cmpi.b	#$C,air_left(a0)
	blo.s	return_1A744	; if he's drowning, branch to not make dust
	move.b	#6,(Sonic_Dust+routine).w
	move.b	#$15,(Sonic_Dust+mapping_frame).w

return_1A744:
	rts
; End of subroutine Sonic_MoveLeft


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1A746:
Sonic_MoveRight:
	move.w	inertia(a0),d0
	bmi.s	Sonic_TurnRight	; if Sonic is already moving to the left, branch
	bclr	#0,status(a0)
	beq.s	+
	bclr	#5,status(a0)
	move.b	#AniIDSonAni_Run,next_anim(a0)
+
	add.w	d5,d0	; add acceleration to the right
	cmp.w	d6,d0	; compare new speed with top speed
	blt.s	+	; if new speed is less than the maximum, branch
	sub.w	d5,d0	; remove this frame's acceleration change
	cmp.w	d6,d0	; compare speed with top speed
	bge.s	+	; if speed was already greater than the maximum, branch
	move.w	d6,d0	; limit speed on ground going right
+
	move.w	d0,inertia(a0)
	move.b	#AniIDSonAni_Walk,anim(a0)	; use walking animation
	rts
; ---------------------------------------------------------------------------
; loc_1A77A:
Sonic_TurnRight:
	add.w	d4,d0
	bcc.s	+
	move.w	#$80,d0
+
	move.w	d0,inertia(a0)
	move.b	angle(a0),d0
	addi.b	#$20,d0
	andi.b	#$C0,d0
	bne.s	return_1A7C4
	cmpi.w	#-$400,d0
	bgt.s	return_1A7C4
	move.b	#AniIDSonAni_Stop,anim(a0)	; use "stopping" animation
	bset	#0,status(a0)
	move.w	#SndID_Skidding,d0	; use "stopping" sound
	jsr	(PlaySound).l
	cmpi.b	#$C,air_left(a0)
	blo.s	return_1A7C4	; if he's drowning, branch to not make dust
	move.b	#6,(Sonic_Dust+routine).w
	move.b	#$15,(Sonic_Dust+mapping_frame).w

return_1A7C4:
	rts
; End of subroutine Sonic_MoveRight

; ---------------------------------------------------------------------------
; Subroutine to change Sonic's speed as he rolls
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1A7C6:
Sonic_RollSpeed:
	move.w	(Sonic_top_speed).w,d6
	asl.w	#1,d6
	moveq	#6,d5	; natural roll deceleration = 1/2 normal acceleration
	move.w	#$20,d4	; controlled roll deceleration... interestingly,
			; this should be Sonic_deceleration/4 according to Tails_RollSpeed,
			; which means Sonic is much better than Tails at slowing down his rolling when he's underwater
    if status_sec_isSliding = 7
	tst.b	status_secondary(a0)
	bmi.w	Obj01_Roll_ResetScr
    else
	btst	#status_sec_isSliding,status_secondary(a0)
	bne.w	Obj01_Roll_ResetScr
    endif
	tst.w	move_lock(a0)
	bne.s	Sonic_ApplyRollSpeed
	btst	#button_left,(Ctrl_1_Held_Logical).w	; is left being pressed?
	beq.s	+				; if not, branch
	bsr.w	Sonic_RollLeft
+
	btst	#button_right,(Ctrl_1_Held_Logical).w	; is right being pressed?
	beq.s	Sonic_ApplyRollSpeed		; if not, branch
	bsr.w	Sonic_RollRight

; loc_1A7FC:
Sonic_ApplyRollSpeed:
	move.w	inertia(a0),d0
	beq.s	Sonic_CheckRollStop
	bmi.s	Sonic_ApplyRollSpeedLeft

; Sonic_ApplyRollSpeedRight:
	sub.w	d5,d0
	bcc.s	+
	move.w	#0,d0
+
	move.w	d0,inertia(a0)
	bra.s	Sonic_CheckRollStop
; ---------------------------------------------------------------------------
; loc_1A812:
Sonic_ApplyRollSpeedLeft:
	add.w	d5,d0
	bcc.s	+
	move.w	#0,d0
+
	move.w	d0,inertia(a0)

; loc_1A81E:
Sonic_CheckRollStop:
	tst.w	inertia(a0)
	bne.s	Obj01_Roll_ResetScr
	tst.b	pinball_mode(a0) ; note: the spindash flag has a different meaning when Sonic's already rolling -- it's used to mean he's not allowed to stop rolling
	bne.s	Sonic_KeepRolling
	bclr	#2,status(a0)
	move.b	#$13,y_radius(a0)
	cmpi.b	#2,(Main_player).w
	bne.s	+
	move.b	#$F,y_radius(a0)
+
	move.b	#9,x_radius(a0)
	move.b	#AniIDSonAni_Wait,anim(a0)
	subq.w	#5,y_pos(a0)
	bra.s	Obj01_Roll_ResetScr

; ---------------------------------------------------------------------------
; magically gives Sonic an extra push if he's going to stop rolling where it's not allowed
; (such as in an S-curve in HTZ or a stopper chamber in CNZ)
; loc_1A848:
Sonic_KeepRolling:
	move.w	#$400,inertia(a0)
	btst	#0,status(a0)
	beq.s	Obj01_Roll_ResetScr
	neg.w	inertia(a0)

; resets the screen to normal while rolling, like Obj01_ResetScr
; loc_1A85A:
Obj01_Roll_ResetScr:
	cmpi.w	#(224/2)-16,(Camera_Y_pos_bias).w	; is screen in its default position?
	beq.s	Sonic_SetRollSpeeds		; if yes, branch
	bhs.s	+				; depending on the sign of the difference,
	addq.w	#4,(Camera_Y_pos_bias).w	; either add 2
+	subq.w	#2,(Camera_Y_pos_bias).w	; or subtract 2

; loc_1A86C:
Sonic_SetRollSpeeds:
	move.b	angle(a0),d0
	jsr	(CalcSine).l
	muls.w	inertia(a0),d0
	asr.l	#8,d0
	move.w	d0,y_vel(a0)	; set y velocity based on $14 and angle
	muls.w	inertia(a0),d1
	asr.l	#8,d1
	cmpi.w	#$1000,d1
	ble.s	+
	move.w	#$1000,d1	; limit Sonic's speed rolling right
+
	cmpi.w	#-$1000,d1
	bge.s	+
	move.w	#-$1000,d1	; limit Sonic's speed rolling left
+
	move.w	d1,x_vel(a0)	; set x velocity based on $14 and angle
	bra.w	Obj01_CheckWallsOnGround
; End of function Sonic_RollSpeed


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


; loc_1A8A2:
Sonic_RollLeft:
	move.w	inertia(a0),d0
	beq.s	+
	bpl.s	Sonic_BrakeRollingRight
+
	bset	#0,status(a0)
	move.b	#AniIDSonAni_Roll,anim(a0)	; use "rolling" animation
	rts
; ---------------------------------------------------------------------------
; loc_1A8B8:
Sonic_BrakeRollingRight:
	sub.w	d4,d0	; reduce rightward rolling speed
	bcc.s	+
	move.w	#-$80,d0
+
	move.w	d0,inertia(a0)
	rts
; End of function Sonic_RollLeft


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


; loc_1A8C6:
Sonic_RollRight:
	move.w	inertia(a0),d0
	bmi.s	Sonic_BrakeRollingLeft
	bclr	#0,status(a0)
	move.b	#AniIDSonAni_Roll,anim(a0)	; use "rolling" animation
	rts
; ---------------------------------------------------------------------------
; loc_1A8DA:
Sonic_BrakeRollingLeft:
	add.w	d4,d0	; reduce leftward rolling speed
	bcc.s	+
	move.w	#$80,d0
+
	move.w	d0,inertia(a0)
	rts
; End of subroutine Sonic_RollRight


; ---------------------------------------------------------------------------
; Subroutine for moving Sonic left or right when he's in the air
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1A8E8:
Sonic_ChgJumpDir:
	move.w	(Sonic_top_speed).w,d6
	move.w	(Sonic_acceleration).w,d5
	asl.w	#1,d5
	btst	#4,status(a0)		; did Sonic jump from rolling?
	bne.s	Obj01_Jump_ResetScr	; if yes, branch to skip midair control
	move.w	x_vel(a0),d0
	btst	#button_left,(Ctrl_1_Held_Logical).w
	beq.s	+	; if not holding left, branch

	bset	#0,status(a0)
	sub.w	d5,d0	; add acceleration to the left
	move.w	d6,d1
	neg.w	d1
	cmp.w	d1,d0	; compare new speed with top speed
	bgt.s	+	; if new speed is less than the maximum, branch
	add.w	d5,d0	; +++ remove this frame's acceleration change
	cmp.w	d1,d0	; +++ compare speed with top speed
	ble.s	+	; +++ if speed was already greater than the maximum, branch
	move.w	d1,d0	; limit speed in air going left, even if Sonic was already going faster (speed limit/cap)
+
	btst	#button_right,(Ctrl_1_Held_Logical).w
	beq.s	+	; if not holding right, branch

	bclr	#0,status(a0)
	add.w	d5,d0	; accelerate right in the air
	cmp.w	d6,d0	; compare new speed with top speed
	blt.s	+	; if new speed is less than the maximum, branch
	sub.w	d5,d0	; +++ remove this frame's acceleration change
	cmp.w	d6,d0	; +++ compare speed with top speed
	bge.s	+	; +++ if speed was already greater than the maximum, branch
	move.w	d6,d0	; limit speed in air going right, even if Sonic was already going faster (speed limit/cap)
; Obj01_JumpMove:
+	move.w	d0,x_vel(a0)

; loc_1A932: Obj01_ResetScr2:
Obj01_Jump_ResetScr:
	cmpi.w	#(224/2)-16,(Camera_Y_pos_bias).w	; is screen in its default position?
	beq.s	Sonic_JumpPeakDecelerate	; if yes, branch
	bhs.s	+				; depending on the sign of the difference,
	addq.w	#4,(Camera_Y_pos_bias).w	; either add 2
+	subq.w	#2,(Camera_Y_pos_bias).w	; or subtract 2

; loc_1A944:
Sonic_JumpPeakDecelerate:
	cmpi.w	#-$400,y_vel(a0)	; is Sonic moving faster than -$400 upwards?
	blo.s	return_1A972		; if yes, return
	move.w	x_vel(a0),d0
	move.w	d0,d1
	asr.w	#5,d1		; d1 = x_velocity / 32
	beq.s	return_1A972	; return if d1 is 0
	bmi.s	Sonic_JumpPeakDecelerateLeft	; branch if moving left

; Sonic_JumpPeakDecelerateRight:
	sub.w	d1,d0	; reduce x velocity by d1
	bcc.s	+
	move.w	#0,d0
+
	move.w	d0,x_vel(a0)
	rts
;-------------------------------------------------------------
; loc_1A966:
Sonic_JumpPeakDecelerateLeft:
	sub.w	d1,d0	; reduce x velocity by d1
	bcs.s	+
	move.w	#0,d0
+
	move.w	d0,x_vel(a0)

return_1A972:
	rts
; End of subroutine Sonic_ChgJumpDir
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to prevent Sonic from leaving the boundaries of a level
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1A974:
Sonic_LevelBound:
	move.l	x_pos(a0),d1
	move.w	x_vel(a0),d0
	ext.l	d0
	asl.l	#8,d0
	add.l	d0,d1
	swap	d1
	move.w	(Camera_Min_X_pos).w,d0
	addi.w	#$10,d0
	cmp.w	d1,d0			; has Sonic touched the left boundary?
	bhi.s	Sonic_Boundary_Sides	; if yes, branch
	move.w	(Camera_Max_X_pos).w,d0
	addi.w	#320-24,d0		; screen width - Sonic's width_pixels
	tst.b	(Current_Boss_ID).w
	bne.s	+
	addi.w	#$40,d0
+
	cmp.w	d1,d0			; has Sonic touched the right boundary?
	bls.s	Sonic_Boundary_Sides	; if yes, branch

; loc_1A9A6:
Sonic_Boundary_CheckBottom:
	move.w	(Camera_Max_Y_pos_now).w,d0
	addi.w	#$E0,d0
	cmp.w	y_pos(a0),d0		; has Sonic touched the bottom boundary?
	blt.s	Sonic_Boundary_Bottom	; if yes, branch
	rts
; ---------------------------------------------------------------------------
Sonic_Boundary_Bottom: ;;
	jmpto	(KillCharacter).l, JmpTo_KillCharacter
; ===========================================================================

; loc_1A9BA:
Sonic_Boundary_Sides:
	move.w	d0,x_pos(a0)
	move.w	#0,2+x_pos(a0) ; subpixel x
	move.w	#0,x_vel(a0)
	move.w	#0,inertia(a0)
	bra.s	Sonic_Boundary_CheckBottom
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to start rolling when he's moving
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1A9D2:
Sonic_Roll:
    if status_sec_isSliding = 7
	tst.b	status_secondary(a0)
	bmi.s	Obj01_NoRoll
    else
	btst	#status_sec_isSliding,status_secondary(a0)
	bne.s	Obj01_NoRoll
    endif
	mvabs.w	inertia(a0),d0
	cmpi.w	#$80,d0		; is Sonic moving at $80 speed or faster?
	blo.s	Obj01_NoRoll	; if not, branch
	move.b	(Ctrl_1_Held_Logical).w,d0
	andi.b	#button_left_mask|button_right_mask,d0 ; is left/right being pressed?
	bne.s	Obj01_NoRoll	; if yes, branch
	btst	#button_down,(Ctrl_1_Held_Logical).w ; is down being pressed?
	bne.s	Obj01_ChkRoll			; if yes, branch
; return_1A9F8:
Obj01_NoRoll:
	rts

; ---------------------------------------------------------------------------
; loc_1A9FA:
Obj01_ChkRoll:
	btst	#2,status(a0)	; is Sonic already rolling?
	beq.s	Obj01_DoRoll	; if not, branch
	rts

; ---------------------------------------------------------------------------
; loc_1AA04:
Obj01_DoRoll:
	bset	#2,status(a0)
	move.b	#$E,y_radius(a0)
	move.b	#7,x_radius(a0)
	move.b	#AniIDSonAni_Roll,anim(a0)	; use "rolling" animation
	addq.w	#5,y_pos(a0)
	move.w	#SndID_Roll,d0
	jsr	(PlaySound).l	; play rolling sound
	tst.w	inertia(a0)
	bne.s	return_1AA36
	move.w	#$200,inertia(a0)

return_1AA36:
	rts
; End of function Sonic_Roll


; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to jump
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1AA38:
Sonic_Jump:
	move.b	(Ctrl_1_Press_Logical).w,d0
	andi.b	#button_B_mask|button_C_mask|button_A_mask,d0 ; is A, B or C pressed?
	beq.w	return_1AAE6	; if not, return
	moveq	#0,d0
	move.b	angle(a0),d0
	addi.b	#$80,d0
	bsr.w	CalcRoomOverHead
	cmpi.w	#6,d1			; does Sonic have enough room to jump?
	blt.w	return_1AAE6		; if not, branch
	move.w	#$680,d2
	tst.b	(Super_Sonic_flag).w
	beq.s	+
	move.w	#$800,d2	; set higher jump speed if super
+
	btst	#6,status(a0)	; Test if underwater
	beq.s	+
	move.w	#$380,d2	; set lower jump speed if under
+
	cmpi.b	#3,(Main_player).w
	bne.s	+
	subi.w	#$80,d2
+
	moveq	#0,d0
	move.b	angle(a0),d0
	subi.b	#$40,d0
	jsr	(CalcSine).l
	muls.w	d2,d1
	asr.l	#8,d1
	add.w	d1,x_vel(a0)	; make Sonic jump (in X... this adds nothing on level ground)
	muls.w	d2,d0
	asr.l	#8,d0
	add.w	d0,y_vel(a0)	; make Sonic jump (in Y)
	bset	#1,status(a0)
	bclr	#5,status(a0)
	addq.l	#4,sp
	move.b	#1,jumping(a0)
	clr.b	stick_to_convex(a0)
	move.w	#SndID_Jump,d0
	jsr	(PlaySound).l	; play jumping sound
	;move.b	#$13,y_radius(a0)
	;move.b	#9,x_radius(a0)
	btst	#2,status(a0)
	bne.s	Sonic_RollJump
	move.b	#$E,y_radius(a0)
	move.b	#7,x_radius(a0)
	move.b	#AniIDSonAni_Roll,anim(a0)	; use "jumping" animation
	bset	#2,status(a0)
	addq.w	#5,y_pos(a0)

return_1AAE6:
	rts
; ---------------------------------------------------------------------------
; loc_1AAE8:
Sonic_RollJump:
	bset	#4,status(a0)	; set the rolling+jumping flag
	rts
; End of function Sonic_Jump


; ---------------------------------------------------------------------------
; Subroutine letting Sonic control the height of the jump
; when the jump button is released
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; ===========================================================================
; loc_1AAF0:
Sonic_JumpHeight:
	tst.b	jumping(a0)	; is Sonic jumping?
	beq.s	Sonic_UpVelCap	; if not, branch

	move.w	#-$400,d1
	btst	#6,status(a0)	; is Sonic underwater?
	beq.s	+		; if not, branch
	move.w	#-$200,d1
+
	bsr.w	SetPlayer_AirMove
	cmp.w	y_vel(a0),d1	; is Sonic going up faster than d1?
	ble.s	+		; if not, branch
	move.b	(Ctrl_1_Held_Logical).w,d0
	andi.b	#button_B_mask|button_C_mask|button_A_mask,d0 ; is a jump button pressed?
	bne.s	+		; if yes, branch
	move.w	d1,y_vel(a0)	; immediately reduce Sonic's upward speed to d1
+
	cmpi.b	#1,(Main_player).w
	bne.s	+
	tst.b	y_vel(a0)		; is Sonic exactly at the height of his jump?
	beq.s	Sonic_CheckGoSuper	; if yes, test for turning into Super Sonic
+
	rts
; ---------------------------------------------------------------------------
; loc_1AB22:
Sonic_UpVelCap:
	tst.b	pinball_mode(a0)	; is Sonic charging a spindash or in a rolling-only area?
	bne.s	return_1AB36		; if yes, return
	cmpi.w	#-$FC0,y_vel(a0)	; is Sonic moving up really fast?
	bge.s	return_1AB36		; if not, return
	move.w	#-$FC0,y_vel(a0)	; cap upward speed

return_1AB36:
	rts
; End of subroutine Sonic_JumpHeight

; ---------------------------------------------------------------------------
; Subroutine called at the peak of a jump that transforms Sonic into Super Sonic
; if he has enough rings and emeralds
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1AB38: test_set_SS:
Sonic_CheckGoSuper:
	tst.b	(Super_Sonic_flag).w	; is Sonic already Super?
	bne.w	return_1ABA4		; if yes, branch
	cmpi.b	#7,(Emerald_count).w	; does Sonic have exactly 7 emeralds?
	bne.w	return_1ABA4		; if not, branch
	cmpi.w	#50,(Ring_count).w	; does Sonic have at least 50 rings?
	blo.s	return_1ABA4		; if not, branch
	; fixes a bug where the player can get stuck if transforming at the end of a level
	tst.b	(Update_HUD_timer).w	; has Sonic reached the end of the act?
	beq.s	return_1ABA4		; if yes, branch

	move.b	#1,(Super_Sonic_palette).w
	move.b	#$F,(Palette_timer).w
	move.b	#1,(Super_Sonic_flag).w
	cmpi.b  #1,(Main_player).w
    bne.s   +
	move.l	#Mapunc_SuperSonic,mappings(a0)
+
	move.b	#$81,obj_control(a0)
	move.b	#AniIDSupSonAni_Transform,anim(a0)			; use transformation animation
	move.b	#ObjID_SuperSonicStars,(SuperSonicStars+id).w ; load Obj7E (super sonic stars object) at $FFFFD040
	lea	(Sonic_top_speed).w,a2	; Load Sonic_top_speed into a2
	bsr.w	ApplySpeedSettings	; Fetch Speed settings
	move.w	#0,invincibility_time(a0)
	bset	#status_sec_isInvincible,status_secondary(a0)	; make Sonic invincible
	move.w	#SndID_SuperTransform,d0
	jsr	(PlaySound).l	; Play transformation sound effect.
	move.w	#MusID_SuperSonic,d0
	jmp	(PlayMusic).l	; load the Super Sonic song and return

; ---------------------------------------------------------------------------
return_1ABA4:
	rts
; End of subroutine Sonic_CheckGoSuper


; ---------------------------------------------------------------------------
; Subroutine doing the extra logic for Super Sonic
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1ABA6:
Sonic_Super:
	tst.b	(Super_Sonic_flag).w	; Ignore all this code if not Super Sonic
	beq.w	return_1AC3C
	cmpi.b	#1,(Super_Sonic_palette).w	; is Super Sonic's transformation sequence finished?
	beq.s	return_1ABA4			; if not, branch
	tst.b	(Update_HUD_timer).w
	beq.s	Sonic_RevertToNormal ; ?
	subq.w	#1,(Super_Sonic_frame_count).w
	bhi.w	return_1AC3C
	move.w	#60,(Super_Sonic_frame_count).w	; Reset frame counter to 60
	tst.w	(Ring_count).w
	beq.s	Sonic_RevertToNormal
	ori.b	#1,(Update_HUD_rings).w
	cmpi.w	#1,(Ring_count).w
	beq.s	+
	cmpi.w	#10,(Ring_count).w
	beq.s	+
	cmpi.w	#100,(Ring_count).w
	bne.s	++
+
	ori.b	#$80,(Update_HUD_rings).w
+
	subq.w	#1,(Ring_count).w
	bne.s	return_1AC3C
; loc_1ABF2:
Sonic_RevertToNormal:
	move.b	#2,(Super_Sonic_palette).w	; Remove rotating palette
	move.w	#$28,(Palette_frame).w
	move.b	#0,(Super_Sonic_flag).w
	move.b	#1,next_anim(a0)	; Change animation back to normal ?
	move.w	#1,invincibility_time(a0)	; Remove invincibility
	lea	(Sonic_top_speed).w,a2	; Load Sonic_top_speed into a2
	bsr.w	ApplySpeedSettings	; Fetch Speed settings
	cmpi.b  #1,(Main_player).w
    bne.s   +
	move.l	#Mapunc_Sonic,mappings(a0)
+

return_1AC3C:
	rts
; End of subroutine Sonic_Super

; ---------------------------------------------------------------------------
; Subroutine to check for starting to charge a spindash
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1AC3E:
Sonic_CheckSpindash:
	tst.b	spindash_flag(a0)
	bne.s	Sonic_UpdateSpindash
	cmpi.b	#AniIDSonAni_Duck,anim(a0)
	bne.s	return_1AC8C
	move.b	(Ctrl_1_Press_Logical).w,d0
	andi.b	#button_B_mask|button_C_mask|button_A_mask,d0
	beq.w	return_1AC8C
	move.b	#AniIDSonAni_Spindash,anim(a0)
	move.w	#SndID_SpindashRev,d0
	jsr	(PlaySound).l
	addq.l	#4,sp
	move.b	#1,spindash_flag(a0)
	move.w	#0,spindash_counter(a0)
	cmpi.b	#$C,air_left(a0)	; if he's drowning, branch to not make dust
	blo.s	+
	move.b	#2,(Sonic_Dust+anim).w
+
	bsr.w	Sonic_LevelBound
	bsr.w	AnglePos

return_1AC8C:
	rts
; End of subroutine Sonic_CheckSpindash


; ---------------------------------------------------------------------------
; Subrouting to update an already-charging spindash
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1AC8E:
Sonic_UpdateSpindash:
	move.b	(Ctrl_1_Held_Logical).w,d0
	btst	#button_down,d0
	bne.w	Sonic_ChargingSpindash

	; unleash the charged spindash and start rolling quickly:
	move.b	#$E,y_radius(a0)
	move.b	#7,x_radius(a0)
	move.b	#AniIDSonAni_Roll,anim(a0)
	addq.w	#5,y_pos(a0)	; add the difference between Sonic's rolling and standing heights
	move.b	#0,spindash_flag(a0)
	moveq	#0,d0
	move.b	spindash_counter(a0),d0
	add.w	d0,d0
	move.w	SpindashSpeeds(pc,d0.w),inertia(a0)
	tst.b	(Super_Sonic_flag).w
	beq.s	+
	move.w	SpindashSpeedsSuper(pc,d0.w),inertia(a0)
+
	move.w	inertia(a0),d0
	subi.w	#$800,d0
	add.w	d0,d0
	andi.w	#$1F00,d0
	neg.w	d0
	addi.w	#$2000,d0
	move.w	d0,(Horiz_scroll_delay_val).w
	btst	#0,status(a0)
	beq.s	+
	neg.w	inertia(a0)
+
	bset	#2,status(a0)
	move.b	#0,(Sonic_Dust+anim).w
	move.w	#SndID_SpindashRelease,d0	; spindash zoom sound
	jsr	(PlaySound).l

	move.b	angle(a0),d0
	jsr	(CalcSine).l
	muls.w	inertia(a0),d1
	asr.l	#8,d1
	move.w	d1,x_vel(a0)
	muls.w	inertia(a0),d0
	asr.l	#8,d0
	move.w	d0,y_vel(a0)

	bra.s	Obj01_Spindash_ResetScr
; ===========================================================================
; word_1AD0C:
SpindashSpeeds:
	dc.w  $800	; 0
	dc.w  $880	; 1
	dc.w  $900	; 2
	dc.w  $980	; 3
	dc.w  $A00	; 4
	dc.w  $A80	; 5
	dc.w  $B00	; 6
	dc.w  $B80	; 7
	dc.w  $C00	; 8
; word_1AD1E:
SpindashSpeedsSuper:
	dc.w  $B00	; 0
	dc.w  $B80	; 1
	dc.w  $C00	; 2
	dc.w  $C80	; 3
	dc.w  $D00	; 4
	dc.w  $D80	; 5
	dc.w  $E00	; 6
	dc.w  $E80	; 7
	dc.w  $F00	; 8
; ===========================================================================
; loc_1AD30:
Sonic_ChargingSpindash:			; If still charging the dash...
	tst.w	spindash_counter(a0)
	beq.s	+
	move.w	spindash_counter(a0),d0
	lsr.w	#5,d0
	sub.w	d0,spindash_counter(a0)
	bcc.s	+
	move.w	#0,spindash_counter(a0)
+
	move.b	(Ctrl_1_Press_Logical).w,d0
	andi.b	#button_B_mask|button_C_mask|button_A_mask,d0
	beq.w	Obj01_Spindash_ResetScr
	move.w	#(AniIDSonAni_Spindash<<8),anim(a0)
	move.w	#SndID_SpindashRev,d0
	jsr	(PlaySound).l
	addi.w	#$200,spindash_counter(a0)
	cmpi.w	#$800,spindash_counter(a0)
	blo.s	Obj01_Spindash_ResetScr
	move.w	#$800,spindash_counter(a0)

; loc_1AD78:
Obj01_Spindash_ResetScr:
	addq.l	#4,sp
	cmpi.w	#(224/2)-16,(Camera_Y_pos_bias).w
	beq.s	loc_1AD8C
	bhs.s	+
	addq.w	#4,(Camera_Y_pos_bias).w
+	subq.w	#2,(Camera_Y_pos_bias).w

loc_1AD8C:
	bsr.w	Sonic_LevelBound
	bsr.w	AnglePos
	rts
; End of subroutine Sonic_UpdateSpindash


; ---------------------------------------------------------------------------
; Subroutine to slow Sonic walking up a slope
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1AD96:
Sonic_SlopeResist:
	move.b	angle(a0),d0
	addi.b	#$60,d0
	cmpi.b	#$C0,d0
	bhs.s	return_1ADCA
	move.b	angle(a0),d0
	jsr	(CalcSine).l
	muls.w	#$20,d0
	asr.l	#8,d0
	tst.w	inertia(a0)
	beq.s	return_1ADCA
	bmi.s	loc_1ADC6
	tst.w	d0
	beq.s	+
	add.w	d0,inertia(a0)	; change Sonic's $14
+
	rts
; ---------------------------------------------------------------------------

loc_1ADC6:
	add.w	d0,inertia(a0)

return_1ADCA:
	rts
; End of subroutine Sonic_SlopeResist

; ---------------------------------------------------------------------------
; Subroutine to push Sonic down a slope while he's rolling
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1ADCC:
Sonic_RollRepel:
	move.b	angle(a0),d0
	addi.b	#$60,d0
	cmpi.b	#$C0,d0
	bhs.s	return_1AE06
	move.b	angle(a0),d0
	jsr	(CalcSine).l
	muls.w	#$50,d0
	asr.l	#8,d0
	tst.w	inertia(a0)
	bmi.s	loc_1ADFC
	tst.w	d0
	bpl.s	loc_1ADF6
	asr.l	#2,d0

loc_1ADF6:
	add.w	d0,inertia(a0)
	rts
; ===========================================================================

loc_1ADFC:
	tst.w	d0
	bmi.s	loc_1AE02
	asr.l	#2,d0

loc_1AE02:
	add.w	d0,inertia(a0)

return_1AE06:
	rts
; End of function Sonic_RollRepel

; ---------------------------------------------------------------------------
; Subroutine to push Sonic down a slope
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1AE08:
Sonic_SlopeRepel:
	nop
	tst.b	stick_to_convex(a0)
	bne.s	return_1AE42
	tst.w	move_lock(a0)
	bne.s	loc_1AE44
	move.b	angle(a0),d0
	addi.b	#$20,d0
	andi.b	#$C0,d0
	beq.s	return_1AE42
	mvabs.w	inertia(a0),d0
	cmpi.w	#$280,d0
	bhs.s	return_1AE42
	clr.w	inertia(a0)
	bset	#1,status(a0)
	move.w	#$1E,move_lock(a0)

return_1AE42:
	rts
; ===========================================================================

loc_1AE44:
	subq.w	#1,move_lock(a0)
	rts
; End of function Sonic_SlopeRepel

; ---------------------------------------------------------------------------
; Subroutine to return Sonic's angle to 0 as he jumps
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1AE4A:
Sonic_JumpAngle:
	move.b	angle(a0),d0	; get Sonic's angle
	beq.s	Sonic_JumpFlip	; if already 0, branch
	bpl.s	loc_1AE5A	; if higher than 0, branch

	addq.b	#2,d0		; increase angle
	bcc.s	BranchTo_Sonic_JumpAngleSet
	moveq	#0,d0

BranchTo_Sonic_JumpAngleSet
	bra.s	Sonic_JumpAngleSet
; ===========================================================================

loc_1AE5A:
	subq.b	#2,d0		; decrease angle
	bcc.s	Sonic_JumpAngleSet
	moveq	#0,d0

; loc_1AE60:
Sonic_JumpAngleSet:
	move.b	d0,angle(a0)
; End of function Sonic_JumpAngle
	; continue straight to Sonic_JumpFlip

; ---------------------------------------------------------------------------
; Updates Sonic's secondary angle if he's tumbling
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1AE64:
Sonic_JumpFlip:
	move.b	flip_angle(a0),d0
	beq.s	return_1AEA8
	tst.w	inertia(a0)
	bmi.s	Sonic_JumpLeftFlip
; loc_1AE70:
Sonic_JumpRightFlip:
	move.b	flip_speed(a0),d1
	add.b	d1,d0
	bcc.s	BranchTo_Sonic_JumpFlipSet
	subq.b	#1,flips_remaining(a0)
	bcc.s	BranchTo_Sonic_JumpFlipSet
	move.b	#0,flips_remaining(a0)
	moveq	#0,d0

BranchTo_Sonic_JumpFlipSet
	bra.s	Sonic_JumpFlipSet
; ===========================================================================
; loc_1AE88:
Sonic_JumpLeftFlip:
	tst.b	flip_turned(a0)
	bne.s	Sonic_JumpRightFlip
	move.b	flip_speed(a0),d1
	sub.b	d1,d0
	bcc.s	Sonic_JumpFlipSet
	subq.b	#1,flips_remaining(a0)
	bcc.s	Sonic_JumpFlipSet
	move.b	#0,flips_remaining(a0)
	moveq	#0,d0
; loc_1AEA4:
Sonic_JumpFlipSet:
	move.b	d0,flip_angle(a0)

return_1AEA8:
	rts
; End of function Sonic_JumpFlip

; ---------------------------------------------------------------------------
; Subroutine for Sonic to interact with the floor and walls when he's in the air
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1AEAA: Sonic_Floor:
Sonic_DoLevelCollision:
	move.l	#Primary_Collision,(Collision_addr).w
	cmpi.b	#$C,top_solid_bit(a0)
	beq.s	+
	move.l	#Secondary_Collision,(Collision_addr).w
+
	move.b	lrb_solid_bit(a0),d5
	move.w	x_vel(a0),d1
	move.w	y_vel(a0),d2
	jsr	(CalcAngle).l
	subi.b	#$20,d0
	andi.b	#$C0,d0
	cmpi.b	#$40,d0
	beq.w	Sonic_HitLeftWall
	cmpi.b	#$80,d0
	beq.w	Sonic_HitCeilingAndWalls
	cmpi.b	#$C0,d0
	beq.w	Sonic_HitRightWall
	bsr.w	CheckLeftWallDist
	tst.w	d1
	bpl.s	+
	sub.w	d1,x_pos(a0)
	move.w	#0,x_vel(a0) ; stop Sonic since he hit a wall
+
	bsr.w	CheckRightWallDist
	tst.w	d1
	bpl.s	+
	add.w	d1,x_pos(a0)
	move.w	#0,x_vel(a0) ; stop Sonic since he hit a wall
+
	bsr.w	Sonic_CheckFloor
	tst.w	d1
	bpl.s	return_1AF8A
	move.b	y_vel(a0),d2
	addq.b	#8,d2
	neg.b	d2
	cmp.b	d2,d1
	bge.s	+
	cmp.b	d2,d0
	blt.s	return_1AF8A
+
	add.w	d1,y_pos(a0)
	move.b	d3,angle(a0)
	bsr.w	Player_ResetOnFloor
	move.b	d3,d0
	addi.b	#$20,d0
	andi.b	#$40,d0
	bne.s	loc_1AF68
	move.b	d3,d0
	addi.b	#$10,d0
	andi.b	#$20,d0
	beq.s	loc_1AF5A
	asr	y_vel(a0)
	bra.s	loc_1AF7C
; ===========================================================================

loc_1AF5A:
	move.w	#0,y_vel(a0)
	move.w	x_vel(a0),inertia(a0)
	rts
; ===========================================================================

loc_1AF68:
	move.w	#0,x_vel(a0) ; stop Sonic since he hit a wall
	cmpi.w	#$FC0,y_vel(a0)
	ble.s	loc_1AF7C
	move.w	#$FC0,y_vel(a0)

loc_1AF7C:
	move.w	y_vel(a0),inertia(a0)
	tst.b	d3
	bpl.s	return_1AF8A
	neg.w	inertia(a0)

return_1AF8A:
	rts
; ===========================================================================
; loc_1AF8C:
Sonic_HitLeftWall:
	bsr.w	CheckLeftWallDist
	tst.w	d1
	bpl.s	Sonic_HitCeiling ; branch if distance is positive (not inside wall)
	sub.w	d1,x_pos(a0)
	move.w	#0,x_vel(a0) ; stop Sonic since he hit a wall
	move.w	y_vel(a0),inertia(a0)
	rts
; ===========================================================================
; loc_1AFA6:
Sonic_HitCeiling:
	bsr.w	Sonic_CheckCeiling
	tst.w	d1
	bpl.s	Sonic_HitFloor ; branch if distance is positive (not inside ceiling)
	sub.w	d1,y_pos(a0)
	tst.w	y_vel(a0)
	bpl.s	return_1AFBE
	move.w	#0,y_vel(a0) ; stop Sonic in y since he hit a ceiling

return_1AFBE:
	rts
; ===========================================================================
; loc_1AFC0:
Sonic_HitFloor:
	tst.w	y_vel(a0)
	bmi.s	return_1AFE6
	bsr.w	Sonic_CheckFloor
	tst.w	d1
	bpl.s	return_1AFE6
	add.w	d1,y_pos(a0)
	move.b	d3,angle(a0)
	bsr.w	Player_ResetOnFloor
	move.w	#0,y_vel(a0)
	move.w	x_vel(a0),inertia(a0)

return_1AFE6:
	rts
; ===========================================================================
; loc_1AFE8:
Sonic_HitCeilingAndWalls:
	bsr.w	CheckLeftWallDist
	tst.w	d1
	bpl.s	+
	sub.w	d1,x_pos(a0)
	move.w	#0,x_vel(a0)	; stop Sonic since he hit a wall
+
	bsr.w	CheckRightWallDist
	tst.w	d1
	bpl.s	+
	add.w	d1,x_pos(a0)
	move.w	#0,x_vel(a0)	; stop Sonic since he hit a wall
+
	bsr.w	Sonic_CheckCeiling
	tst.w	d1
	bpl.s	return_1B042
	sub.w	d1,y_pos(a0)
	move.b	d3,d0
	addi.b	#$20,d0
	andi.b	#$40,d0
	bne.s	loc_1B02C
	move.w	#0,y_vel(a0) ; stop Sonic in y since he hit a ceiling
	rts
; ===========================================================================

loc_1B02C:
	move.b	d3,angle(a0)
	bsr.w	Player_ResetOnFloor
	move.w	y_vel(a0),inertia(a0)
	tst.b	d3
	bpl.s	return_1B042
	neg.w	inertia(a0)

return_1B042:
	rts
; ===========================================================================
; loc_1B044:
Sonic_HitRightWall:
	bsr.w	CheckRightWallDist
	tst.w	d1
	bpl.s	Sonic_HitCeiling2
	add.w	d1,x_pos(a0)
	move.w	#0,x_vel(a0) ; stop Sonic since he hit a wall
	move.w	y_vel(a0),inertia(a0)
	rts
; ===========================================================================
; identical to Sonic_HitCeiling...
; loc_1B05E:
Sonic_HitCeiling2:
	bsr.w	Sonic_CheckCeiling
	tst.w	d1
	bpl.s	Sonic_HitFloor2
	sub.w	d1,y_pos(a0)
	tst.w	y_vel(a0)
	bpl.s	return_1B076
	move.w	#0,y_vel(a0) ; stop Sonic in y since he hit a ceiling

return_1B076:
	rts
; ===========================================================================
; identical to Sonic_HitFloor...
; loc_1B078:
Sonic_HitFloor2:
	tst.w	y_vel(a0)
	bmi.s	return_1B09E
	bsr.w	Sonic_CheckFloor
	tst.w	d1
	bpl.s	return_1B09E
	add.w	d1,y_pos(a0)
	move.b	d3,angle(a0)
	bsr.w	Player_ResetOnFloor
	move.w	#0,y_vel(a0)
	move.w	x_vel(a0),inertia(a0)

return_1B09E:
	rts
; End of function Sonic_DoLevelCollision


; ---------------------------------------------------------------------------
; Subroutine to reset Player mode when he lands on the floor
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

Player_ResetOnFloor:
	cmpi.b	#1,(Main_player).w
	beq.w	Sonic_ResetOnFloor
	cmpi.b	#2,(Main_player).w
	beq.w	Tails_ResetOnFloor
	cmpi.b	#3,(Main_player).w
	beq.w	Knuckles_ResetOnFloor
Player_ResetOnFloor_Part2:
	cmpi.b	#1,(Main_player).w
	beq.w	Sonic_ResetOnFloor_Part2
	cmpi.b	#2,(Main_player).w
	beq.w	Tails_ResetOnFloor_Part2
	cmpi.b	#3,(Main_player).w
	beq.w	Knuckles_ResetOnFloor_Part2
	rts
; End of subroutine Player_ResetOnFloor


; ===========================================================================
; ---------------------------------------------------------------------------
; Sonic when he gets hurt
; ---------------------------------------------------------------------------
; loc_1B120: Obj_01_Sub_4:
Obj01_Hurt:
	tst.w	(Debug_mode_flag).w
	beq.s	Obj01_Hurt_Normal
	btst	#button_B,(Ctrl_1_Press).w
	beq.s	Obj01_Hurt_Normal
	move.w	#1,(Debug_placement_mode).w
	clr.b	(Control_Locked).w
	rts
; ---------------------------------------------------------------------------
; loc_1B13A:
Obj01_Hurt_Normal:
	tst.b	routine_secondary(a0)
	bmi.w	Sonic_HurtInstantRecover
	jsr	(ObjectMove).l
	addi.w	#$30,y_vel(a0)
	btst	#6,status(a0)
	beq.s	+
	subi.w	#$20,y_vel(a0)
+
	cmpi.w	#-$100,(Camera_Min_Y_pos).w
	bne.s	+
	andi.w	#$7FF,y_pos(a0)
+
	bsr.w	Sonic_HurtStop
	bsr.w	Sonic_LevelBound
	bsr.w	Sonic_RecordPos
	bsr.w	SetPlayer_Animate
	bsr.w	LoadPlayerDynPLC
	jmp	(DisplaySprite).l
; ===========================================================================
; loc_1B184:
Sonic_HurtStop:
	move.w	(Camera_Max_Y_pos_now).w,d0
	addi.w	#$E0,d0
	cmp.w	y_pos(a0),d0
	blt.w	JmpTo_KillCharacter
	bsr.w	Sonic_DoLevelCollision
	btst	#1,status(a0)
	bne.s	return_1B1C8
	moveq	#0,d0
	move.w	d0,y_vel(a0)
	move.w	d0,x_vel(a0)
	move.w	d0,inertia(a0)
	move.b	d0,obj_control(a0)
	move.b	#AniIDSonAni_Walk,anim(a0)
	subq.b	#2,routine(a0)	; => Obj01_Control
	move.w	#$78,invulnerable_time(a0)
	move.b	#0,spindash_flag(a0)

return_1B1C8:
	rts
; ===========================================================================
; makes Sonic recover control after being hurt before landing
; seems to be unused
; loc_1B1CA:
Sonic_HurtInstantRecover:
	subq.b	#2,routine(a0)	; => Obj01_Control
	move.b	#0,routine_secondary(a0)
	bsr.w	Sonic_RecordPos
	bsr.w	SetPlayer_Animate
	bsr.w	LoadPlayerDynPLC
	jmp	(DisplaySprite).l
; ===========================================================================

; ---------------------------------------------------------------------------
; Sonic when he dies
; ...poor Sonic
; ---------------------------------------------------------------------------

; loc_1B1E6: Obj_01_Sub_6:
Obj01_Dead:
	tst.w	(Debug_mode_flag).w
	beq.s	+
	btst	#button_B,(Ctrl_1_Press).w
	beq.s	+
	move.w	#1,(Debug_placement_mode).w
	clr.b	(Control_Locked).w
	rts
+
	bsr.w	CheckGameOver
	jsr	(ObjectMoveAndFall).l
	bsr.w	Sonic_RecordPos
	bsr.w	SetPlayer_Animate
	bsr.w	LoadPlayerDynPLC
	jmp	(DisplaySprite).l

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1B21C:
CheckGameOver:
	move.b	#1,(Scroll_lock).w
	move.b	#0,spindash_flag(a0)
	move.w	(Camera_Max_Y_pos_now).w,d0
	addi.w	#$100,d0
	cmp.w	y_pos(a0),d0
	bge.w	return_1B31A
	move.b	#8,routine(a0)	; => Obj01_Gone
	move.w	#60,restart_countdown(a0)
	addq.b	#1,(Update_HUD_lives).w	; update lives counter
	subq.b	#1,(Life_count).w	; subtract 1 from number of lives
	bne.s	Obj01_ResetLevel	; if it's not a game over, branch
	move.w	#0,restart_countdown(a0)
	move.b	#ObjID_GameOver,(GameOver_GameText+id).w ; load Obj39 (game over text)
	move.b	#ObjID_GameOver,(GameOver_OverText+id).w ; load Obj39 (game over text)
	move.b	#1,(GameOver_OverText+mapping_frame).w
	move.w	a0,(GameOver_GameText+parent).w
	clr.b	(Time_Over_flag).w
; loc_1B26E:
Obj01_Finished:
	clr.b	(Update_HUD_timer).w
	clr.b	(Update_HUD_timer_2P).w
	move.b	#8,routine(a0)	; => Obj01_Gone
	move.w	#MusID_GameOver,d0
	jsr	(PlayMusic).l
	moveq	#PLCID_GameOver,d0
	jmp	(LoadPLC).l
; End of function CheckGameOver

; ===========================================================================
; ---------------------------------------------------------------------------
; Sonic when the level is restarted
; ---------------------------------------------------------------------------
; loc_1B28E:
Obj01_ResetLevel:
	tst.b	(Time_Over_flag).w
	beq.s	Obj01_ResetLevel_Part2
	move.w	#0,restart_countdown(a0)
	move.b	#ObjID_TimeOver,(TimeOver_TimeText+id).w ; load Obj39
	move.b	#ObjID_TimeOver,(TimeOver_OverText+id).w ; load Obj39
	move.b	#2,(TimeOver_TimeText+mapping_frame).w
	move.b	#3,(TimeOver_OverText+mapping_frame).w
	move.w	a0,(TimeOver_TimeText+parent).w
	bra.s	Obj01_Finished
; ---------------------------------------------------------------------------
Obj01_ResetLevel_Part2:
	tst.w	(Two_player_mode).w
	beq.s	return_1B31A
	move.b	#0,(Scroll_lock).w
	move.b	#$A,routine(a0)	; => Obj01_Respawning
	move.w	(Saved_x_pos).w,x_pos(a0)
	move.w	(Saved_y_pos).w,y_pos(a0)
	move.w	(Saved_art_tile).w,art_tile(a0)
	move.w	(Saved_Solid_bits).w,top_solid_bit(a0)
	clr.w	(Ring_count).w
	clr.b	(Extra_life_flags).w
	move.b	#0,obj_control(a0)
	move.b	#5,anim(a0)
	move.w	#0,x_vel(a0)
	move.w	#0,y_vel(a0)
	move.w	#0,inertia(a0)
	move.b	#2,status(a0)
	move.w	#0,move_lock(a0)
	move.w	#0,restart_countdown(a0)

return_1B31A:
	rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Sonic when he's offscreen and waiting for the level to restart
; ---------------------------------------------------------------------------
; loc_1B31C: Obj_01_Sub_8:
Obj01_Gone:
	tst.w	restart_countdown(a0)
	beq.s	+
	subq.w	#1,restart_countdown(a0)
	bne.s	+
	move.w	#1,(Level_Inactive_flag).w
+
	rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Sonic when he's waiting for the camera to scroll back to where he respawned
; ---------------------------------------------------------------------------
; loc_1B330: Obj_01_Sub_A:
Obj01_Respawning:
	tst.w	(Camera_X_pos_diff).w
	bne.s	+
	tst.w	(Camera_Y_pos_diff).w
	bne.s	+
	move.b	#2,routine(a0)	; => Obj01_Control
+
	bsr.w	SetPlayer_Animate
	bsr.w	LoadPlayerDynPLC
	jmp	(DisplaySprite).l
; ===========================================================================

; ---------------------------------------------------------------------------
; Sonic when he's drowning
; ---------------------------------------------------------------------------
Obj01_Drowned:
	bsr.w	ObjectMove	; Make Sonic able to move
	addi.w	#$10,y_vel(a0)	; Apply gravity
	bsr.w	Sonic_RecordPos	; Record position
	bsr.w	SetPlayer_Animate	; Animate Sonic
	bsr.w	LoadPlayerDynPLC	; Load Sonic's DPLCs
	bra.w	DisplaySprite	; And finally, display Sonic








JmpTo_KillCharacter
	jmp	(KillCharacter).l

    if ~~removeJmpTos
	align 4
    endif
