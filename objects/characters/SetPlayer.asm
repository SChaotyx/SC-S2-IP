; ===========================================================================
; ----------------------------------------------------------------------------
; Set of subroutines to establish the correct configuration for each character
; ----------------------------------------------------------------------------
; ===========================================================================

    ; a0 = object
    ; d0 = 0000 Sidekick -> 0000 Main Character

; ---------------------------------------------------------------------------
; detect object
; ---------------------------------------------------------------------------
DetectObj_Player:
	moveq	#0,d0
	_cmpi.b	#ObjID_MainPlayer,id(a0)	; is this object ID Player_MainChar (obj01)?
	bne.s	+   ; if not, define Player_Sidekick on d0
    move.b  (Player_MainChar).w,d0
	swap	d0
    move.b  (Player_Sidekick).w,d0
	swap	d0
	rts
+  
    move.b  (Player_Sidekick).w,d0
	swap	d0
    move.b  (Player_MainChar).w,d0
	swap	d0
	rts

; ---------------------------------------------------------------------------
; detect object controller read (Main character or Sidekick)
; ---------------------------------------------------------------------------
DetectPlayerCtrl:
	_cmpi.b	#ObjID_MainPlayer,id(a0)	; is this object ID Player_MainChar (obj01)?
	bne.s	+   ; if not, define Player_Sidekick on d0
	move.b	(Ctrl_1_Press_Logical).w,(Ctrl_Press_Logical).w
	move.b	(Ctrl_1_Held_Logical).w,(Ctrl_Held_Logical).w
	rts
+
	move.b	(Ctrl_2_Press_Logical).w,(Ctrl_Press_Logical).w
	move.b	(Ctrl_2_Held_Logical).w,(Ctrl_Held_Logical).w
	rts

; ---------------------------------------------------------------------------
; Set player radius
; ---------------------------------------------------------------------------
SetPlayer_Radius:
    bsr.w   DetectObj_Player
    move.b	#9,x_radius(a0)
    move.b	#$13,y_radius(a0) ; this sets Sonic's | Knuckles' collision height (2*pixels)
    cmpi.b  #2,d0
    bne.s   +
	move.b	#$F,y_radius(a0) ; this sets Tails' collision height (2*pixels)
+   rts

; ---------------------------------------------------------------------------
; Set player mappings
; ---------------------------------------------------------------------------
SetPlayer_Mappings:
    bsr.w   DetectObj_Player
    ;Sonic
	cmpi.b  #1,d0
    bne.s   +
	move.l	#Mapunc_Sonic,mappings(a0)
	tst.b	(Super_Sonic_flag).w
	beq.s	+
	move.l	#Mapunc_SuperSonic,mappings(a0)
+   ;Tails
    cmpi.b  #2,d0
    bne.s   +
	move.l	#MapUnc_Tails,mappings(a0)
+   ;Knuckles
	cmpi.b  #3,d0
    bne.s   +
	move.l	#MapUnc_Knuckles,mappings(a0)
+   rts

; ---------------------------------------------------------------------------
; Set player pattern loading subroutine
; ---------------------------------------------------------------------------
LoadPlayerDynPLC:
	bsr.w	LoadCharDynPLC
	rts
LoadPlayerDynPLC_Part2:
	bsr.w	LoadCharDynPLC_Part2
	rts

; ---------------------------------------------------------------------------
; Set player DPLC
; ---------------------------------------------------------------------------
SetPlayerDPLC:
	move.l 	d0,d1	; backup d0 on d1
    bsr.w   DetectObj_Player
	cmpi.b	#1,d0
	bne.s	++
	tst.b	(Super_Sonic_flag).w	; super Sonic?
	beq.s	+
	lea	(MapRUnc_SuperSonic).l,a2
	bra.s	++
+
	lea	(MapRUnc_Sonic).l,a2
+
	cmpi.b	#2,d0
	bne.s	+
	lea	(MapRUnc_Tails).l,a2
+
	cmpi.b	#3,d0
	bne.s	+
	lea	(MapRUnc_Knuckles).l,a2
+
	move.l 	d1,d0	; restore d0
	rts

; ---------------------------------------------------------------------------
; Set player DPLC
; ---------------------------------------------------------------------------
SetPlayerArt:
	bsr.w   DetectObj_Player
	cmpi.b	#1,d0
	bne.s	++
	tst.b	(Super_Sonic_flag).w	; super Sonic?
	beq.s	+
	addi.l	#ArtUnc_SuperSonic,d1
	bra.s	++
+	
	addi.l	#ArtUnc_Sonic,d1
+
	cmpi.b	#2,d0
	bne.s	+
	addi.l	#ArtUnc_Tails,d1
+
	cmpi.b	#3,d0
	bne.s	+
	addi.l	#ArtUnc_Knuckles,d1
+
	rts

; ---------------------------------------------------------------------------
; Set player animate subroutine
; ---------------------------------------------------------------------------
SetPlayer_Animate:
    bsr.w   DetectObj_Player
	cmpi.b	#1,d0
	beq.w	Sonic_Animate
	cmpi.b	#2,d0
	beq.w	Tails_Animate
	cmpi.b	#3,d0
	beq.w	Knuckles_Animate
	rts

; ---------------------------------------------------------------------------
; Subroutine to load the special moves of each character 
; (not including those used by all characters like the Spindash)
; ---------------------------------------------------------------------------
SetPlayer_Move:
    bsr.w   DetectObj_Player
    ; Sonic
	cmpi.b	#1,d0
	bne.s	+
	rts
+   ; Tails
	cmpi.b	#2,d0
	bne.s	+
	rts
+   ; Knuckles
	cmpi.b	#3,d0
	bne.s	+
	rts
+  	
	rts
; ---------------------------------------------------------------------------
SetPlayer_AirMove:
    bsr.w   DetectObj_Player
    ; Sonic
	cmpi.b	#1,d0
	bne.s	+
	rts
+   ; Tails
	cmpi.b	#2,d0
	bne.s	+
	bsr.w	Tails_CheckFly
	rts
+   ; Knuckles
	cmpi.b	#3,d0
	bne.s	+
	bsr.w	Knuckles_CheckGlide
+   rts

; ---------------------------------------------------------------------------
; MdAir double jump check
; ---------------------------------------------------------------------------
DoubleJump_Check:
    bsr.w   DetectObj_Player
	cmpi.b	#2,d0
	bne.s	+
	bra.w	Tails_Flying
+
	cmpi.b	#3,d0
	bne.s	+
	bra.w	Obj01_MdAir_Gliding
+
	rts