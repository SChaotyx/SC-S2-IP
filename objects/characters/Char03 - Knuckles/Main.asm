; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------

	include "objects/characters/Char03 - Knuckles/Moves/Knuckles Glide.asm"

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
	move.b	#0,double_jump_flag(a0)
	move.b	#0,double_jump_properly(a0)
	cmpi.b	#AniIDSonAni_Hang2,anim(a0)
	bne.s	return_1B11EK
	move.b	#AniIDSonAni_Walk,anim(a0)

return_1B11EK:
	rts
; End of subroutine Knuckles_ResetOnFloor



; ---------------------------------------------------------------------------
; Subroutine to animate Knuckles' sprites
; See also: AnimateSprite
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Knuckles_Animate:				  ; ...
		lea	(KnucklesAniData).l,a1
		moveq	#0,d0
		move.b	$1C(a0),d0
		cmp.b	$1D(a0),d0
		beq.s	KAnim_Do
		move.b	d0,$1D(a0)
		move.b	#0,$1B(a0)
		move.b	#0,$1E(a0)
		bclr	#5,$22(a0)

KAnim_Do:					  ; ...
		add.w	d0,d0
		add.w	(a1,d0.w),a1
		move.b	(a1),d0
		bmi.s	KAnim_WalkRun
		move.b	$22(a0),d1
		and.b	#1,d1
		and.b	#$FC,1(a0)
		or.b	d1,1(a0)
		subq.b	#1,$1E(a0)
		bpl.s	KAnim_Delay
		move.b	d0,$1E(a0)

KAnim_Do2:					  ; ...
		moveq	#0,d1
		move.b	$1B(a0),d1
		move.b	1(a1,d1.w),d0
		cmp.b	#$FC,d0
		bcc.s	KAnim_End_FF

KAnim_Next:					  ; ...
		move.b	d0,$1A(a0)
		addq.b	#1,$1B(a0)

KAnim_Delay:					  ; ...
		rts
; ---------------------------------------------------------------------------

KAnim_End_FF:					  ; ...
		addq.b	#1,d0
		bne.s	KAnim_End_FE
		move.b	#0,$1B(a0)
		move.b	1(a1),d0
		bra.s	KAnim_Next
; ---------------------------------------------------------------------------

KAnim_End_FE:					  ; ...
		addq.b	#1,d0
		bne.s	KAnim_End_FD
		move.b	2(a1,d1.w),d0
		sub.b	d0,$1B(a0)
		sub.b	d0,d1
		move.b	1(a1,d1.w),d0
		bra.s	KAnim_Next
; ---------------------------------------------------------------------------

KAnim_End_FD:					  ; ...
		addq.b	#1,d0
		bne.s	KAnim_End
		move.b	2(a1,d1.w),$1C(a0)

KAnim_End:					  ; ...
		rts
; ---------------------------------------------------------------------------

KAnim_WalkRun:					  ; ...
		addq.b	#1,d0
		bne.w	KAnim_Roll
		moveq	#0,d0
		move.b	$27(a0),d0
		bne.w	KAnim_Tumble
		moveq	#0,d1
		move.b	$26(a0),d0
		bmi.s	loc_31704E
		beq.s	loc_31704E
		subq.b	#1,d0

loc_31704E:					  ; ...
		move.b	$22(a0),d2
		and.b	#1,d2
		bne.s	loc_31705A
		not.b	d0

loc_31705A:					  ; ...
		add.b	#$10,d0
		bpl.s	loc_317062
		moveq	#3,d1

loc_317062:					  ; ...
		and.b	#$FC,1(a0)
		eor.b	d1,d2
		or.b	d2,1(a0)
		btst	#5,$22(a0)
		bne.w	KAnim_Push
		lsr.b	#4,d0
		and.b	#6,d0
		move.w	$14(a0),d2
		bpl.s	loc_317086
		neg.w	d2

loc_317086:					  ; ...
		tst.b	$2B(a0)
		bpl.w	loc_317090
		add.w	d2,d2

loc_317090:					  ; ...
		lea	(KnucklesAni_Run).l,a1
		cmp.w	#$600,d2
		bcc.s	loc_3170A4
		lea	(KnucklesAni_Walk).l,a1
		add.b	d0,d0

loc_3170A4:					  ; ...
		add.b	d0,d0
		move.b	d0,d3
		moveq	#0,d1
		move.b	$1B(a0),d1
		move.b	1(a1,d1.w),d0
		cmp.b	#$FF,d0
		bne.s	loc_3170C2
		move.b	#0,$1B(a0)
		move.b	1(a1),d0

loc_3170C2:					  ; ...
		move.b	d0,$1A(a0)
		add.b	d3,$1A(a0)
		subq.b	#1,$1E(a0)
		bpl.s	return_3170E4
		neg.w	d2
		add.w	#$800,d2
		bpl.s	loc_3170DA
		moveq	#0,d2

loc_3170DA:					  ; ...
		lsr.w	#8,d2
		move.b	d2,$1E(a0)
		addq.b	#1,$1B(a0)

return_3170E4:					  ; ...
		rts
; ---------------------------------------------------------------------------

KAnim_Tumble:					  ; ...
		move.b	$27(a0),d0
		moveq	#0,d1
		move.b	$22(a0),d2
		and.b	#1,d2
		bne.s	KAnim_Tumble_Left
		and.b	#$FC,1(a0)
		add.b	#$B,d0
		divu.w	#$16,d0
		add.b	#$31,d0
		move.b	d0,$1A(a0)
		move.b	#0,$1E(a0)
		rts
; ---------------------------------------------------------------------------

KAnim_Tumble_Left:				  ; ...
		and.b	#$FC,1(a0)
		tst.b	$29(a0)
		beq.s	loc_31712C
		or.b	#1,1(a0)
		add.b	#$B,d0
		bra.s	loc_317138
; ---------------------------------------------------------------------------

loc_31712C:					  ; ...
		or.b	#3,1(a0)
		neg.b	d0
		add.b	#-$71,d0

loc_317138:					  ; ...
		divu.w	#$16,d0
		add.b	#$31,d0
		move.b	d0,$1A(a0)
		move.b	#0,$1E(a0)
		rts
; ---------------------------------------------------------------------------

KAnim_Roll:					  ; ...
		subq.b	#1,$1E(a0)
		bpl.w	KAnim_Delay
		addq.b	#1,d0
		bne.s	KAnim_Push
		move.w	$14(a0),d2
		bpl.s	loc_317160
		neg.w	d2

loc_317160:					  ; ...
		lea	(KnucklesAni_Roll2).l,a1
		cmp.w	#$600,d2
		bcc.s	loc_317172
		lea	(KnucklesAni_Roll).l,a1

loc_317172:					  ; ...
		neg.w	d2
		add.w	#$400,d2
		bpl.s	loc_31717C
		moveq	#0,d2

loc_31717C:					  ; ...
		lsr.w	#8,d2
		move.b	d2,$1E(a0)
		move.b	$22(a0),d1
		and.b	#1,d1
		and.b	#$FC,1(a0)
		or.b	d1,1(a0)
		bra.w	KAnim_Do2
; ---------------------------------------------------------------------------

KAnim_Push:					  ; ...
		subq.b	#1,$1E(a0)
		bpl.w	KAnim_Delay
		move.w	$14(a0),d2
		bmi.s	loc_3171A8
		neg.w	d2

loc_3171A8:					  ; ...
		add.w	#$800,d2
		bpl.s	loc_3171B0
		moveq	#0,d2

loc_3171B0:					  ; ...
		lsr.w	#8,d2
		move.b	d2,$1E(a0)
		lea	(KnucklesAni_Push).l,a1
		move.b	$22(a0),d1
		and.b	#1,d1
		and.b	#$FC,1(a0)
		or.b	d1,1(a0)
		bra.w	KAnim_Do2
; End of function Knuckles_Animate

; ---------------------------------------------------------------------------
KnucklesAniData:dc.w KnucklesAni_Walk-KnucklesAniData; 0 ; ...
		dc.w KnucklesAni_Run-KnucklesAniData; 1
		dc.w KnucklesAni_Roll-KnucklesAniData; 2
		dc.w KnucklesAni_Roll2-KnucklesAniData;	3
		dc.w KnucklesAni_Push-KnucklesAniData; 4
		dc.w KnucklesAni_Wait-KnucklesAniData; 5
		dc.w KnucklesAni_Balance-KnucklesAniData; 6
		dc.w KnucklesAni_LookUp-KnucklesAniData; 7
		dc.w KnucklesAni_Duck-KnucklesAniData; 8
		dc.w KnucklesAni_Spindash-KnucklesAniData; 9
		dc.w KnucklesAni_Unused-KnucklesAniData; 10
		dc.w KnucklesAni_Pull-KnucklesAniData; 11
		dc.w KnucklesAni_Balance2-KnucklesAniData; 12
		dc.w KnucklesAni_Stop-KnucklesAniData; 13
		dc.w KnucklesAni_Float-KnucklesAniData;	14
		dc.w KnucklesAni_Float2-KnucklesAniData; 15
		dc.w KnucklesAni_Spring-KnucklesAniData; 16
		dc.w KnucklesAni_Hang-KnucklesAniData; 17
		dc.w KnucklesAni_Unused_0-KnucklesAniData; 18
		dc.w KnucklesAni_S3EndingPose-KnucklesAniData; 19
		dc.w KnucklesAni_WFZHang-KnucklesAniData; 20
		dc.w KnucklesAni_Bubble-KnucklesAniData; 21
		dc.w KnucklesAni_DeathBW-KnucklesAniData; 22
		dc.w KnucklesAni_Drown-KnucklesAniData;	23
		dc.w KnucklesAni_Death-KnucklesAniData;	24
		dc.w KnucklesAni_OilSlide-KnucklesAniData; 25
		dc.w KnucklesAni_Hurt-KnucklesAniData; 26
		dc.w KnucklesAni_OilSlide_0-KnucklesAniData; 27
		dc.w KnucklesAni_Blank-KnucklesAniData;	28
		dc.w KnucklesAni_Unused_1-KnucklesAniData; 29
		dc.w KnucklesAni_Unused_2-KnucklesAniData; 30
		dc.w KnucklesAni_Transform-KnucklesAniData; 31
		dc.w KnucklesAni_Gliding-KnucklesAniData; 32
		dc.w KnucklesAni_FallFromGlide-KnucklesAniData;	33
		dc.w KnucklesAni_GetUp-KnucklesAniData;	34
		dc.w KnucklesAni_HardFall-KnucklesAniData; 35
		dc.w KnucklesAni_Badass-KnucklesAniData; 36
KnucklesAni_Walk:dc.b $FF,  7,	8,  1,	2,  3,	4,  5,	6,$FF; 0 ; ...
KnucklesAni_Run:dc.b $FF,$21,$22,$23,$24,$FF,$FF,$FF,$FF,$FF; 0	; ...
KnucklesAni_Roll:dc.b $FE,$9A,$96,$9A,$97,$9A,$98,$9A,$99,$FF; 0 ; ...
KnucklesAni_Roll2:dc.b $FE,$9A,$96,$9A,$97,$9A,$98,$9A,$99,$FF;	0 ; ...
KnucklesAni_Push:dc.b $FD,$CE,$CF,$D0,$D1,$FF,$FF,$FF,$FF,$FF; 0 ; ...
KnucklesAni_Wait:dc.b	5,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56; 0 ; ...
		dc.b $56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56; 13
		dc.b $56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56; 26
		dc.b $56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$D2; 39
		dc.b $D2,$D2,$D3,$D3,$D3,$D2,$D2,$D2,$D3,$D3,$D3,$D2,$D2; 52
		dc.b $D2,$D3,$D3,$D3,$D2,$D2,$D2,$D3,$D3,$D3,$D2,$D2,$D2; 65
		dc.b $D3,$D3,$D3,$D2,$D2,$D2,$D3,$D3,$D3,$D2,$D2,$D2,$D3; 78
		dc.b $D3,$D3,$D2,$D2,$D2,$D3,$D3,$D3,$D2,$D2,$D2,$D3,$D3; 91
		dc.b $D3,$D4,$D4,$D4,$D4,$D4,$D7,$D8,$D9,$DA,$DB,$D8,$D9; 104
		dc.b $DA,$DB,$D8,$D9,$DA,$DB,$D8,$D9,$DA,$DB,$D8,$D9,$DA; 117
		dc.b $DB,$D8,$D9,$DA,$DB,$D8,$D9,$DA,$DB,$D8,$D9,$DA,$DB; 130
		dc.b $DC,$DD,$DC,$DD,$DE,$DE,$D8,$D7,$FF; 143
KnucklesAni_Balance:dc.b   3,$9F,$9F,$A0,$A0,$A1,$A1,$A2,$A2,$A3,$A3,$A4,$A4; 0	; ...
		dc.b $A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5; 13
		dc.b $A5,$A5,$A6,$A6,$A6,$A7,$A7,$A7,$A8,$A8,$A9,$A9,$AA; 26
		dc.b $AA,$FE,  6		  ; 39
KnucklesAni_LookUp:dc.b	  5,$D5,$D6,$FE,  1	     ; 0 ; ...
KnucklesAni_Duck:dc.b	5,$9B,$9C,$FE,	1	   ; 0 ; ...
KnucklesAni_Spindash:dc.b   0,$86,$87,$86,$88,$86,$89,$86,$8A,$86,$8B,$FF; 0 ; ...
KnucklesAni_Unused:dc.b	  9,$BA,$C5,$C6,$C6,$C6,$C6,$C6,$C6,$C7,$C7,$C7,$C7; 0 ; ...
		dc.b $C7,$C7,$C7,$C7,$C7,$C7,$C7,$C7,$FD,  0; 13
KnucklesAni_Pull:dc.b  $F,$8F,$FF		   ; 0 ; ...
KnucklesAni_Balance2:dc.b   3,$A1,$A1,$A2,$A2,$A3,$A3,$A4,$A4,$A5,$A5,$A5,$A5; 0 ; ...
		dc.b $A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A6,$A6; 13
		dc.b $A6,$A7,$A7,$A7,$A8,$A8,$A9,$A9,$AA,$AA,$FE; 26
		dc.b   6
KnucklesAni_Stop:dc.b	3,$9D,$9E,$9F,$A0,$FD,	0  ; 0 ; ...
KnucklesAni_Float:dc.b	 7,$C0,$FF		    ; 0	; ...
KnucklesAni_Float2:dc.b	  5,$C0,$C1,$C2,$C3,$C4,$C5,$C6,$C7,$C8,$C9,$FF; 0 ; ...
KnucklesAni_Spring:dc.b	$2F,$8E,$FD,  0		     ; 0 ; ...
KnucklesAni_Hang:dc.b	1,$AE,$AF,$FF		   ; 0 ; ...
KnucklesAni_Unused_0:dc.b  $F,$43,$43,$43,$FE,	1      ; 0 ; ...
KnucklesAni_S3EndingPose:dc.b	5,$B1,$B2,$B2,$B2,$B3,$B4,$FE,	1,  7,$B1,$B3,$B3; 0 ; ...
		dc.b $B3,$B3,$B3,$B3,$B2,$B3,$B4,$B3,$FE,  4; 13
KnucklesAni_WFZHang:dc.b $13,$91,$FF		      ;	0 ; ...
KnucklesAni_Bubble:dc.b	 $B,$B0,$B0,  3,  4,$FD,  0  ; 0 ; ...
KnucklesAni_DeathBW:dc.b $20,$AC,$FF		      ;	0 ; ...
KnucklesAni_Drown:dc.b $20,$AD,$FF		    ; 0	; ...
KnucklesAni_Death:dc.b $20,$AB,$FF		    ; 0	; ...
KnucklesAni_OilSlide:dc.b   9,$8C,$FF		       ; 0 ; ...
KnucklesAni_Hurt:dc.b $40,$8D,$FF		   ; 0 ; ...
KnucklesAni_OilSlide_0:dc.b   9,$8C,$FF			 ; 0 ; ...
KnucklesAni_Blank:dc.b $77,  0,$FF		    ; 0	; ...
KnucklesAni_Unused_1:dc.b $13,$D0,$D1,$FF	       ; 0 ; ...
KnucklesAni_Unused_2:dc.b   3,$CF,$C8,$C9,$CA,$CB,$FE  ; 0 ; ...
		dc.b   4
KnucklesAni_Gliding:dc.b $1F,$C0,$FF		      ;	0 ; ...
KnucklesAni_FallFromGlide:dc.b	 7,$CA,$CB,$FE,	 1	    ; 0	; ...
KnucklesAni_GetUp:dc.b	$F,$CD,$FD,  0		    ; 0	; ...
KnucklesAni_HardFall:dc.b  $F,$9C,$FD,	0	       ; 0 ; ...
KnucklesAni_Badass:dc.b	  5,$D8,$D9,$DA,$DB,$D8,$D9,$DA,$DB,$D8,$D9,$DA,$DB; 0 ; ...
		dc.b $D8,$D9,$DA,$DB,$D8,$D9,$DA,$DB,$D8,$D9,$DA,$DB,$D8; 13
		dc.b $D9,$DA,$DB,$D8,$D9,$DA,$DB,$DC,$DD,$DC,$DD,$DE,$DE; 26
		dc.b $FF			  ; 39
KnucklesAni_Transform:dc.b   2,$EB,$EB,$EC,$ED,$EC,$ED,$EC,$ED,$EC,$ED,$EC,$ED;	0 ; ...
		dc.b $FD,  0,  0		  ; 13
