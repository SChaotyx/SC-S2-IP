; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------

	include "objects/characters/Knuckles/Animate.asm"
	include "objects/characters/Knuckles/LPLC.asm"
	include "objects/characters/Knuckles/Knuckles Glide.asm"

; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
; Subroutine to reset Knuckles mode when he lands on the floor
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

Knuckles_ResetOnFloor:
	tst.b	pinball_mode(a0)
	bne.s	Knuckles_ResetOnFloor_Part3
	move.b	#AniIDSonAni_Walk,anim(a0)
; loc_1B0AC:
Knuckles_ResetOnFloor_Part2:
	btst	#2,status(a0)
	beq.s	Knuckles_ResetOnFloor_Part3
	bclr	#2,status(a0)
	move.b	#$13,y_radius(a0) ; this increases Sonic's collision height to standing
	move.b	#9,x_radius(a0)
	move.b	#AniIDSonAni_Walk,anim(a0)	; use running/walking/standing animation
	subq.w	#5,y_pos(a0)	; move Sonic up 5 pixels so the increased height doesn't push him into the ground
; loc_1B0DA:
Knuckles_ResetOnFloor_Part3:
	bclr	#1,status(a0)
	bclr	#5,status(a0)
	bclr	#4,status(a0)
	move.b	#0,jumping(a0)
	move.w	#0,(Chain_Bonus_counter).w
	move.b	#0,flip_angle(a0)
	move.b	#0,flip_turned(a0)
	move.b	#0,flips_remaining(a0)
	move.w	#0,(Sonic_Look_delay_counter).w
	move.b	#0,$21(a0) ; clear glide flag
	cmpi.b	#AniIDSonAni_Hang2,anim(a0)
	bne.s	return_1B11EK
	move.b	#AniIDSonAni_Walk,anim(a0)

return_1B11EK:
	rts
; End of subroutine Knuckles_ResetOnFloor