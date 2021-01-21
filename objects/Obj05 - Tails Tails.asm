; ===========================================================================
; ----------------------------------------------------------------------------
; Object 05 - Tails' tails
; ----------------------------------------------------------------------------
; Sprite_1D200:
Obj05:
	moveq	#0,d0
	move.b	routine(a0),d0
	move.w	Obj05_Index(pc,d0.w),d1
	jmp	Obj05_Index(pc,d1.w)
; ===========================================================================
; off_1D20E: Obj05_States:
Obj05_Index:	offsetTable
		offsetTableEntry.w Obj05_Init	; 0
		offsetTableEntry.w Obj05_Main	; 2
; ===========================================================================

Obj05_parent_prev_anim = objoff_30

; loc_1D212
Obj05_Init:
	addq.b	#2,routine(a0) ; => Obj05_Main
	move.l	#MapUnc_TailsTails,mappings(a0)
	move.w	#make_art_tile(ArtTile_ArtUnc_Tails_Tails,0,0),art_tile(a0)
	bsr.w	Adjust2PArtPointer
	move.b	#2,priority(a0)
	move.b	#$18,width_pixels(a0)
	move.b	#4,render_flags(a0)

; loc_1D23A:
Obj05_Main:
	movea.w	parent(a0),a2 ; a2=character
	move.b	angle(a2),angle(a0)
	move.b	status(a2),status(a0)
	move.w	x_pos(a2),x_pos(a0)
	move.w	y_pos(a2),y_pos(a0)
	andi.w	#drawing_mask,art_tile(a0)
	tst.w	art_tile(a2)
	bpl.s	+
	ori.w	#high_priority,art_tile(a0)
+
	moveq	#0,d0
	move.b	anim(a2),d0
	btst	#5,status(a2)		; is Tails about to push against something?
	beq.s	+			; if not, branch
	cmpi.b	#$A9,mapping_frame(a2)	; Is Tails in his pushing animation yet?
	blo.s	+			; If not yet, branch, and do not set tails' tail pushing animation
	cmpi.b	#$AC,mapping_frame(a2)	; ''
	bhi.s	+			; ''
	moveq	#4,d0
+
	; This is here so Obj05Ani_Flick works
	; It changes anim(a0) itself, so we don't want the below code changing it as well
	cmp.b	Obj05_parent_prev_anim(a0),d0	; Did Tails' animation change?
	beq.s	.display
	move.b	d0,Obj05_parent_prev_anim(a0)
	move.b	Obj05AniSelection(pc,d0.w),anim(a0)	; If so, update Tails' tails' animation
; loc_1D288:
.display:
	lea	(Obj05AniData).l,a1
	bsr.w	Tails_Animate_Part2
	bsr.w	LoadTailsTailsDynPLC
	movea.w	parent(a0),a1			; Move Tails' register to a1
	move.w	invulnerable_time(a1),d0	; Move Tails' invulnerable time to d0
	beq.s	.displaytailstails		; Is invulnerable_time 0?  If so, always display his tails
	addq.w	#1,d0				; Make d0 the same as old invulnerable_time's d0
	lsr.w	#3,d0				; Shift bits to the right 3 times
	bcc.s	.return				; If the Carry bit is not set, branch and do not display Tails' tails

.displaytailstails:
	jmp	(DisplaySprite).l               ; Display Tails' tails

.return:
	rts
; ===========================================================================
; animation master script table for the tails
; chooses which animation script to run depending on what Tails is doing
; byte_1D29E:
Obj05AniSelection:
	dc.b	0,0	; TailsAni_Walk,Run	->
	dc.b	3	; TailsAni_Roll		-> Directional
	dc.b	3	; TailsAni_Roll2	-> Directional
	dc.b	9	; TailsAni_Push		-> Pushing
	dc.b	1	; TailsAni_Wait		-> Swish
	dc.b	$A	; TailsAni_Balance	-> Blank
	dc.b	1	; TailsAni_LookUp	-> Flick
	dc.b	1	; TailsAni_Duck		-> Swish
	dc.b	7	; TailsAni_Spindash	-> Spindash
	dc.b	0,0,0	; TailsAni_Dummy1,2,3	->
	dc.b	8	; TailsAni_Stop		-> Skidding
	dc.b	0,0	; TailsAni_Float,2	->
	dc.b	0	; TailsAni_Spring	->
	dc.b	0	; TailsAni_Hang		->
	dc.b	0,0	; TailsAni_Blink,2	->
	dc.b	$A	; TailsAni_Hang2	-> Hanging
	dc.b	0	; TailsAni_Bubble	->
	dc.b	0,0,0,0	; TailsAni_Death,2,3,4	->
	dc.b	0,0	; TailsAni_Hurt,Slide	->
	dc.b	0	; TailsAni_Blank	->
	dc.b	0,0	; TailsAni_Dummy4,5	->
	dc.b	0	; TailsAni_HaulAss	->
	dc.b	$B	; TailsAni_Fly		->
	dc.b	0	; TailsAni_Swim		->
	dc.b	$B	; TailsAni_Tired	->
	dc.b	0	; TailsAni_SwimTired	->
	even

; ---------------------------------------------------------------------------
; Animation script - Tails' tails
; ---------------------------------------------------------------------------
; off_1D2C0:
Obj05AniData:	offsetTable
		offsetTableEntry.w Obj05Ani_Blank	;  0
		offsetTableEntry.w Obj05Ani_Swish	;  1
		offsetTableEntry.w Obj05Ani_Flick	;  2
		offsetTableEntry.w Obj05Ani_Directional	;  3
		offsetTableEntry.w Obj05Ani_DownLeft	;  4
		offsetTableEntry.w Obj05Ani_Down	;  5
		offsetTableEntry.w Obj05Ani_DownRight	;  6
		offsetTableEntry.w Obj05Ani_Spindash	;  7
		offsetTableEntry.w Obj05Ani_Skidding	;  8
		offsetTableEntry.w Obj05Ani_Pushing	;  9
		offsetTableEntry.w Obj05Ani_Hanging	; $A
		offsetTableEntry.w Obj05Ani_Fly ; $B

Obj05Ani_Blank:		dc.b $20,  0,$FF
	rev02even
Obj05Ani_Swish:		dc.b    7, $22, $23, $24, $25, $26, $FF
	rev02even
Obj05Ani_Flick:		dc.b    3, $22, $23, $24, $25, $26, $FD,   1
	rev02even
Obj05Ani_Directional:	dc.b  $FC,   5,   6,   7,   8, $FF ; Tails is moving right
	rev02even
Obj05Ani_DownLeft:	dc.b    3,   9,  $A,  $B,  $C, $FF ; Tails is moving up-right
	rev02even
Obj05Ani_Down:		dc.b    3,  $D,  $E,  $F, $10, $FF ; Tails is moving up
	rev02even
Obj05Ani_DownRight:	dc.b    3, $11, $12, $13, $14, $FF ; Tails is moving up-left
	rev02even
Obj05Ani_Spindash:	dc.b    2,   1,   2,   3,   4, $FF
	rev02even
Obj05Ani_Skidding:	dc.b    2, $1A, $1B, $1C, $1D, $FF
	rev02even
Obj05Ani_Pushing:	dc.b    9, $1E, $1F, $20, $21, $FF
	rev02even
Obj05Ani_Hanging:	dc.b    9, $29, $2A, $2B, $2C, $FF
	rev02even
Obj05Ani_Fly:	dc.b    1, $27, $28, $FF
	rev02even

; ===========================================================================

JmpTo2_KillCharacter
	jmp	(KillCharacter).l
; ===========================================================================
	align 4

