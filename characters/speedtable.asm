; ===========================================================================
; ----------------------------------------------------------------------------
; Speed Settings Array

; This array defines what speeds the character should be set to
; ----------------------------------------------------------------------------
;		top_speed	acceleration	deceleration	; #	; Comment
Speedsettings:
	dc.w	$600,		$C,		$80		    ; $00	; Normal
	dc.w	$C00,		$18,		$80		; $08	; Normal Speedshoes
	dc.w	$300,		$6,		$40		    ; $16	; Normal Underwater
	dc.w	$600,		$C,		$40		    ; $24	; Normal Underwater Speedshoes
	dc.w	$A00,		$30,		$100	; $32	; Super
	dc.w	$C00,		$30,		$100	; $40	; Super Speedshoes
	dc.w	$500,		$18,		$80		; $48	; Super Underwater
	dc.w	$A00,		$30,		$80		; $56	; Super Underwater Speedshoes
; ===========================================================================

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to collect the right speed setting for a character
; a0 must be character
; a1 will be the result and have the correct speed settings
; a2 is characters' speed
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

ApplySpeedSettings:
	moveq	#0,d0				; Quickly clear d0
	tst.w	speedshoes_time(a0)		; Does character have speedshoes?
	beq.s	+				; If not, branch
	addq.b	#6,d0				; Quickly add 6 to d0
+
	btst	#6,status(a0)			; Is the character underwater?
	beq.s	+				; If not, branch
	addi.b	#12,d0				; Add 12 to d0
+
	cmpa.w	#MainCharacter,a0		; Is it Tails currently following this code?
	bne.s	+				; If so, branch and ignore next question
	tst.b	(Super_Sonic_flag).w		; Is the character Super?
	beq.s	+				; If not, branch
	addi.b	#24,d0				; Add 24 to d0
+
	lea	Speedsettings(pc,d0.w),a1	; Load correct speed settings into a1
	move.l	(a1)+,(a2)+			; Set character's new top speed and acceleration
	move.w	(a1),(a2)			; Set character's deceleration
	rts					; Finish subroutine
; ===========================================================================