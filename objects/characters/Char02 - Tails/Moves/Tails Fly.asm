; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to check Tails fly
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

Tails_CheckFly:
	bsr.w	DetectPlayerCtrl
    tst.b	double_jump_flag(a0)    ; is Tails already flying?
	bne.w	Tails_CheckFly_Return   ; if yes, branch
    move.b	(Ctrl_Press_Logical).w,d0 ; read controller
	andi.b	#button_A_mask|button_B_mask|button_C_mask,d0   ; was button A, B or C pressed?
    beq.w	Tails_CheckFly_Return   ; if not, branch
    btst	#2,status(a0) ; if Tails spining?
	beq.s	Tails_CheckFly_Start   ; if not, branch
	bclr	#2,status(a0)   ; clear spining flag
	move.b	y_radius(a0),d1
	move.b	#$F,y_radius(a0) 
	move.b	#9,x_radius(a0)
	sub.b	#$F,d1
	ext.w	d1
	add.w	d1,y_pos(a0)

Tails_CheckFly_Start:
	bclr	#4,status(a0)   ; clear roll jump flag
	move.b	#1,double_jump_flag(a0) ; set fly flag
    move.b	#-$10,double_jump_properly(a0) ; set fly timer
    bsr.w	Tails_Set_Flying_Animation  ; start fly animation

Tails_CheckFly_Return:
    rts
; ===========================================================================


; ---------------------------------------------------------------------------
; Subroutine to make Tails fly/Swim
; ---------------------------------------------------------------------------
; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

Tails_Flying:
	bsr.w	DetectPlayerCtrl
    bsr.w	Tails_Fly_Move
	_cmpi.b	#ObjID_Sonic,id(a0)	; is this object ID Main_Player (obj01)?
	bne.s	+   ; if not, branch to sidekick version
	bsr.w	Sonic_ChgJumpDir
	bsr.w	Sonic_LevelBound
	jsr	(ObjectMove).l
	bsr.w	Sonic_JumpAngle
	movem.l	a4-a6,-(sp)
	bsr.w	Sonic_DoLevelCollision
	movem.l	(sp)+,a4-a6
    rts
+
	bsr.w	Tails_ChgJumpDir
	bsr.w	Tails_LevelBound
	jsr	(ObjectMove).l
	bsr.w	Tails_JumpAngle
	movem.l	a4-a6,-(sp)
	bsr.w	Tails_DoLevelCollision
	movem.l	(sp)+,a4-a6
    rts
; ---------------------------------------------------------------------------

Tails_Fly_Move:
    move.b	(Timer_frames+1).w,d0
	andi.b	#1,d0
	beq.s	+
    tst.b	double_jump_properly(a0)
	beq.s	+
	subq.b	#1,double_jump_properly(a0)
+
    cmpi.b	#1,double_jump_flag(a0)
	beq.s	Tails_FlyUpward
    cmpi.w	#-$100,y_vel(a0)
	blt.s	+
    subi.w	#$20,y_vel(a0)
	addq.b	#1,double_jump_flag(a0)
	cmpi.b	#$20,double_jump_flag(a0)
	bne.s	++
+
	move.b	#1,double_jump_flag(a0)
+
	bra.s	Tails_FlyLimit
; ---------------------------------------------------------------------------

Tails_FlyUpward:
    move.b	(Ctrl_Press_Logical).w,d0
	andi.b	#button_B_mask|button_C_mask|button_A_mask,d0
	beq.s	++
    cmpi.w	#-$100,y_vel(a0)
	blt.s	++
	tst.b	double_jump_properly(a0)
	beq.s	++
	;btst	#6,status(a0)
	;beq.s	+
+
	move.b	#2,double_jump_flag(a0)
+
	addi.w	#8,y_vel(a0)

Tails_FlyLimit:
	move.w	(Camera_Min_Y_pos).w,d0
	addi.w	#$10,d0
	cmp.w	y_pos(a0),d0
	blt.s	Tails_Set_Flying_Animation
	tst.w	y_vel(a0)
	bpl.s	Tails_Set_Flying_Animation
	move.w	#0,y_vel(a0)

; ---------------------------------------------------------------------------
; Subroutine to set Fly/Swim animation
; ---------------------------------------------------------------------------
; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

Tails_Set_Flying_Animation:
    btst	#6,status(a0)
	bne.s	Tails_FlyAnim_Underwater
	tst.b	double_jump_properly(a0)
	bne.s	+
	move.b	#AniIDTailsAni_Tired,anim(a0)
    rts
+
	move.b	#AniIDTailsAni_Fly,anim(a0)
    rts

Tails_FlyAnim_Underwater:
    tst.b	double_jump_properly(a0)
	bne.s	+
    move.b	#AniIDTailsAni_SwimTired,anim(a0)
    rts
+
    move.b	#AniIDTailsAni_Swim,anim(a0)
	tst.w	y_vel(a0)
	bpl.s	+
	cmpi.b	#2,anim_frame_duration(a0)
	beq.s	+
    subi.b	#1,anim_frame_duration(a0)	; modify frame duration
+
    rts
; ===========================================================================