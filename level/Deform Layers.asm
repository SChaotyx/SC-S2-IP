; ===========================================================================
; ---------------------------------------------------------------------------
; Deform BG Green Hill Zone
; ---------------------------------------------------------------------------

SwScrl_GHZ:
    ; block 3 - distant mountains
		move.w	(v_scrshiftx).w,d4
		ext.l	d4
		asl.l	#5,d4
		move.l	d4,d1
		asl.l	#1,d4
		add.l	d1,d4
		moveq	#0,d6
		bsr.w	SetHorizScrollFlagsBG3
	; block 2 - hills & waterfalls
		move.w	(v_scrshiftx).w,d4
		ext.l	d4
		asl.l	#7,d4
		moveq	#0,d6
		bsr.w	SetHorizScrollFlagsBG2
	; calculate Y position
		lea	(v_hscrolltablebuffer).w,a1
		move.w	(v_screenposy).w,d0
		andi.w	#$7FF,d0
		lsr.w	#5,d0
		neg.w	d0
		addi.w	#$20,d0
		bpl.s	limitY
		moveq	#0,d0
limitY:
		move.w	d0,d4
		move.w	d0,(v_bgscrposy_dup).w
		move.w	(v_screenposx).w,d0
		neg.w	d0
		swap	d0
	; auto-scroll clouds
		lea	(v_bgscroll_buffer).w,a2
		addi.l	#$10000,(a2)+
		addi.l	#$C000,(a2)+
		addi.l	#$8000,(a2)+
	; calculate background scroll	
		move.w	(v_bgscroll_buffer).w,d0
		add.w	(v_bg3screenposx).w,d0
		neg.w	d0
		move.w	#$1F,d1
		sub.w	d4,d1
		bcs.s	gotoCloud2
cloudLoop1:		; upper cloud (32px)
		move.l	d0,(a1)+
		dbf	d1,cloudLoop1

gotoCloud2:
		move.w	(v_bgscroll_buffer+4).w,d0
		add.w	(v_bg3screenposx).w,d0
		neg.w	d0
		move.w	#$F,d1
cloudLoop2:		; middle cloud (16px)
		move.l	d0,(a1)+
		dbf	d1,cloudLoop2

		move.w	(v_bgscroll_buffer+8).w,d0
		add.w	(v_bg3screenposx).w,d0
		neg.w	d0
		move.w	#$F,d1
cloudLoop3:		; lower cloud (16px)
		move.l	d0,(a1)+
		dbf	d1,cloudLoop3

		move.w	#$2F,d1
		move.w	(v_bg3screenposx).w,d0
		neg.w	d0
mountainLoop:		; distant mountains (48px)
		move.l	d0,(a1)+
		dbf	d1,mountainLoop

		move.w	#$27,d1
		move.w	(v_bg2screenposx).w,d0
		neg.w	d0
hillLoop:			; hills & waterfalls (40px)
		move.l	d0,(a1)+
		dbf	d1,hillLoop

		move.w	(v_bg2screenposx).w,d0
		move.w	(v_screenposx).w,d2
		sub.w	d0,d2
		ext.l	d2
		asl.l	#8,d2
		divs.w	#$68,d2
		ext.l	d2
		asl.l	#8,d2
		moveq	#0,d3
		move.w	d0,d3
		move.w	#$47,d1
		add.w	d4,d1
waterLoop:			; water deformation
		move.w	d3,d0
		neg.w	d0
		move.l	d0,(a1)+
		swap	d3
		add.l	d2,d3
		swap	d3
		dbf	d1,waterLoop
		rts
; End of function Deform_GHZ


