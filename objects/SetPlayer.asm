; ===========================================================================
; ----------------------------------------------------------------------------
; Set of subroutines to establish the correct configuration for each character
; ----------------------------------------------------------------------------
; ===========================================================================

    ; a0 = object
    ; d0 = Player_MainChar or Player_Sidekick if Obj02 use it
    ; d0 = Player_Sidekick or Player_MainChar if Obj02 use it

; ---------------------------------------------------------------------------
; detect object
; ---------------------------------------------------------------------------
DetectObj_Player:
    move.b  (Player_MainChar).w,d0
    move.b  (Player_Sidekick).w,d1
    _cmpi.b	#ObjID_MainPlayer,id(a0)	; is this object ID Player_MainChar (obj01)?
	beq.s	+   ; if not, define Player_Sidekick on d0
    move.b  (Player_Sidekick).w,d0
    move.b  (Player_MainChar).w,d1
+   rts

; ---------------------------------------------------------------------------
; detect object controller read (Main character or Sidekick)
; ---------------------------------------------------------------------------
DetectPlayerCtrl:
	move.b	(Ctrl_1_Press_Logical).w,(Ctrl_Press_Logical).w
	move.b	(Ctrl_1_Held_Logical).w,(Ctrl_Held_Logical).w
	_cmpi.b	#ObjID_MainPlayer,id(a0)	; is this object ID Player_MainChar (obj01)?
	beq.s	+   ; if not, define Player_Sidekick on d0
	move.b	(Ctrl_2_Press_Logical).w,(Ctrl_Press_Logical).w
	move.b	(Ctrl_2_Held_Logical).w,(Ctrl_Held_Logical).w
+	rts

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
; Set player art tile
; ---------------------------------------------------------------------------
SetPlayer_ArtTile:
    bsr.w   DetectObj_Player
    cmpi.b  #2,d0
    bne.s   +
	move.w	#make_art_tile(ArtTile_ArtUnc_Tails,0,0),art_tile(a0)
+   cmpi.b  #2,d0
    beq.s   +
	move.w	#make_art_tile(ArtTile_ArtUnc_Sonic,0,0),art_tile(a0)
+   cmpi.b	#3,d0
	bne.s	+
	cmpi.b	#1,d1
	bne.s	+
	move.w	#make_art_tile(ArtTile_ArtUnc_Tails,0,0),art_tile(a0)
+   rts

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
; Set player pattern loading subroutine
; ---------------------------------------------------------------------------
LoadPlayerDynPLC:
    bsr.w   DetectObj_Player
	cmpi.b	#1,d0
	beq.w	LoadSonicDynPLC
	cmpi.b	#2,d0
	beq.w	LoadTailsDynPLC
	cmpi.b	#3,d0
	beq.w	LoadKnucklesDynPLC
LoadPlayerDynPLC_Part2:
	cmpi.b	#1,d0
	beq.w	LoadSonicDynPLC_Part2
	cmpi.b	#2,d0
	beq.w	LoadTailsDynPLC_Part2
	cmpi.b	#3,d0
	beq.w	LoadKnucklesDynPLC_Part2
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