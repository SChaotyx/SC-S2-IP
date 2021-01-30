LevEvents_GHZ:
		moveq	#0,d0
		move.b	(Current_Act).w,d0
        cmpi.b  #green_hill_zone_2,(Current_Zone).w
        bne.s   +
        addi.b  #2,d0   ; it's act 3....
+
		add.w	d0,d0
		move.w	DLE_GHZx(pc,d0.w),d0
		jmp	DLE_GHZx(pc,d0.w)
; ===========================================================================
DLE_GHZx:	
        dc.w GHZACT1-DLE_GHZx
		dc.w GHZACT2-DLE_GHZx
		dc.w GHZACT3-DLE_GHZx
; ===========================================================================

GHZACT1:
		move.w	#$300,(Camera_Max_Y_pos).w ; set lower y-boundary
		cmpi.w	#$1780,(Camera_X_pos).w ; has the camera reached $1780 on x-axis?
		bcs.s	+	; if not, branch
		move.w	#$400,(Camera_Max_Y_pos).w ; set lower y-boundary
		move.w	#$400,(Camera_Max_Y_pos_now).w ; set lower y-boundary
		move.w	#$400,(Tails_Max_Y_pos).w ; set lower y-boundary
+
		rts	
; ===========================================================================

GHZACT2:
		move.w	#$300,(Camera_Max_Y_pos).w
		cmpi.w	#$ED0,(Camera_X_pos).w
		bcs.s	+
		move.w	#$200,(Camera_Max_Y_pos).w
		cmpi.w	#$1600,(Camera_X_pos).w
		bcs.s	+
		move.w	#$400,(Camera_Max_Y_pos).w
		cmpi.w	#$1D60,(Camera_X_pos).w
		bcs.s	+
		move.w	#$300,(Camera_Max_Y_pos).w
+
		rts	
; ===========================================================================

GHZACT3:
		moveq	#0,d0
		move.b	(Dynamic_Resize_Routine).w,d0
		move.w	off_6E4A(pc,d0.w),d0
		jmp	off_6E4A(pc,d0.w)
; ===========================================================================
off_6E4A:	
        dc.w GHZACT3main-off_6E4A   ;0
		dc.w GHZACT3boss-off_6E4A   ;2
		dc.w GHZACT3end-off_6E4A    ;4
; ===========================================================================

GHZACT3main:
		move.w	#$300,(Camera_Max_Y_pos).w
		cmpi.w	#$380,(Camera_X_pos).w
		bcs.s	locret_6E96
		move.w	#$310,(Camera_Max_Y_pos).w
		cmpi.w	#$960,(Camera_X_pos).w
		bcs.s	locret_6E96
		cmpi.w	#$280,(Camera_Y_pos).w
		bcs.s	loc_6E98
		move.w	#$400,(Camera_Max_Y_pos).w
		cmpi.w	#$1380,(Camera_X_pos).w
		bcc.s	loc_6E8E
		move.w	#$4C0,(Camera_Max_Y_pos).w
		move.w	#$4C0,(v_limitbtm2).w

loc_6E8E:
		cmpi.w	#$1700,(Camera_X_pos).w
		bcc.s	loc_6E98

locret_6E96:
		rts	
; ===========================================================================

loc_6E98:
		move.w	#$300,(Camera_Max_Y_pos).w
		addq.b	#2,(Dynamic_Resize_Routine).w
		rts	
; ===========================================================================

GHZACT3boss:
		cmpi.w	#$960,(Camera_X_pos).w
		bcc.s	loc_6EB0
		subq.b	#2,(Dynamic_Resize_Routine).w

loc_6EB0:
		cmpi.w	#$2960,(Camera_X_pos).w
		blt.s	locret_6EE8
		;bsr.w	FindFreeObj
		;bne.s	loc_6ED0
		;move.b	#id_BossGreenHill,0(a1) ; load GHZ boss	object
		;move.w	#$2A60,obX(a1)
		;move.w	#$280,obY(a1)

loc_6ED0:
		;music	bgm_Boss,0,1,0	; play boss music
		;move.b	#1,(f_lockscreen).w ; lock screen
		addq.b	#2,(Dynamic_Resize_Routine).w
		;moveq	#plcid_Boss,d0
		;bra.w	AddPLC		; load boss patterns
; ===========================================================================

locret_6EE8:
		rts	
; ===========================================================================

GHZACT3end:
        cmpi.w	#$2AC0,(Camera_Max_X_pos).w
		beq.s	+
		addq.w	#2,(Camera_Max_X_pos).w
+  
        move.w	(Camera_X_pos).w,(Camera_Min_X_pos).w
		rts	
; ===========================================================================