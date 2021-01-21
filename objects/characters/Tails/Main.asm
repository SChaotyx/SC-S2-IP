; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------

	include "objects/characters/Tails/Animate.asm"
	include "objects/characters/Tails/LPLC.asm"
	include "objects/characters/Tails/Tails Fly.asm"

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
	move.b	#0,(Fly_flag).w
	move.w	#0,(Fly_timer).w
	cmpi.b	#AniIDTailsAni_Hang2,anim(a0)
	bne.s	return_1CBC4
	move.b	#AniIDTailsAni_Walk,anim(a0)

return_1CBC4:
	rts
; End of subroutine Tails_ResetOnFloor