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
	bclr	#4,status(a0)		; clear roll jump flag
    btst	#6,status(a0)
    bne.s   Tails_Swiming
    move.b	#AniIDTailsAni_Fly,anim(a0)
    cmpi.w  #-$120,y_vel(a0)
    bgt.s   +
    sub.w   #40,y_vel(a0)
    bra.s   ++
+
    sub.w   #45,y_vel(a0)
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
    ; upward limiter
    cmpi.w  #-$120,y_vel(a0)
    blt.s   +
    sub.w   #40,y_vel(a0)
+
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
    cmpi.w  #-$120,y_vel(a0)
    bgt.s   +
    sub.w   #40/4,y_vel(a0)
    bra.s   ++
+
    sub.w   #45/4,y_vel(a0)
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
    ; upward limiter
    cmpi.w  #-$120,y_vel(a0)
    blt.s   +
    sub.w   #35/2,y_vel(a0)
+
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
