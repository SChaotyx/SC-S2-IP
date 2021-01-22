; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to make Tails fly
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

Tails_CheckFly:
    move.b	(Ctrl_1_Press_Logical).w,d0
    _cmpi.b	#ObjID_Sonic,id(a0)	; is this object ID Sonic (obj01)?
	beq.s	+
    move.b	(Ctrl_2_Press_Logical).w,d0
+
    tst.b   (Fly_flag).w
    bne.s   Tails_Flying
	andi.b	#button_B_mask|button_C_mask|button_A_mask,d0
    beq.w   Tails_FlyReturn
    move.b  #1,(Fly_flag).w
    rts
; ---------------------------------------------------------------------------

Tails_Flying:
    btst	#6,status(a0)
    bne.s   Tails_Swiming
    move.b	#AniIDTailsAni_Fly,anim(a0)
    sub.w   #45,y_vel(a0)
    ; upward limiter
    cmpi.w  #-$120,y_vel(a0)
    bge.s   +
    add.w  #45,y_vel(a0)
+
    cmpi.w  #$1E0,(Fly_timer).w
    bge.s   Tails_FlyTired
    add.w   #1,(Fly_timer).w
    cmpi.b  #2,(Fly_flag).w
    bge.s   Tails_FlyUpward
    andi.b	#button_B_mask|button_C_mask|button_A_mask,d0
    beq.w   Tails_FlyReturn
    move.b  #2,(Fly_flag).w
    rts
; ---------------------------------------------------------------------------

Tails_FlyUpward:
    add.b   #1,(Fly_flag).w
    sub.w   #35,y_vel(a0)
    cmpi.b  #22,(Fly_flag).w
    blt.s   +
    move.b  #1,(Fly_flag).w
+
    rts
; ---------------------------------------------------------------------------

Tails_FlyTired:
	move.b	#AniIDTailsAni_Tired,anim(a0)
    rts
; ===========================================================================


Tails_Swiming:
    move.b	#AniIDTailsAni_Swim,anim(a0)
    sub.w   #45/4,y_vel(a0)
    ; upward limiter
    cmpi.w  #-$100,y_vel(a0)
    bge.s   +
    add.w  #45,y_vel(a0)
+
    cmpi.w  #$1E0,(Fly_timer).w
    bge.s   Tails_SwimTired
    add.w   #1,(Fly_timer).w
    cmpi.b  #2,(Fly_flag).w
    bge.s   Tails_SwimUpward
    andi.b	#button_B_mask|button_C_mask|button_A_mask,d0
    beq.w   Tails_FlyReturn
    move.b  #2,(Fly_flag).w
    rts
; ---------------------------------------------------------------------------

Tails_SwimUpward:
    add.b   #1,(Fly_flag).w
    sub.w   #35/2,y_vel(a0)
    cmpi.b  #32,(Fly_flag).w
    blt.s   +
    move.b  #1,(Fly_flag).w
+
    rts
; ---------------------------------------------------------------------------

Tails_SwimTired:
	move.b	#AniIDTailsAni_SwimTired,anim(a0)
    rts
; ===========================================================================

Tails_FlyReturn:
    rts
