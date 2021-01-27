; ----------------------------------------------------------------------------
; Character Art, Mappings, DPLC etc


; ============================================================================
; SONIC
;-----------------------------------------------------------------------------
; Uncompressed art - Patterns for Sonic  ; ArtUnc_50000:
	align $20
ArtUnc_Sonic:			BINCLUDE	"objects/characters/Char01 - Sonic/Art/Sonic Art.bin"
	align $20
ArtUnc_SuperSonic:		BINCLUDE	"objects/characters/Char01 - Sonic/Art/SuperSonic Art.bin"
;-----------------------------------------------------------------------------
; Sprite Mappings - Sonic			; MapUnc_6FBE0: SprTbl_Sonic:
Mapunc_Sonic:			BINCLUDE	"mappings/sprite/Sonic.bin"
Mapunc_SuperSonic:		BINCLUDE	"mappings/sprite/SonicSuper.bin"
;-----------------------------------------------------------------------------
; Sprite Dynamic Pattern Reloading - Sonic DPLCs   		; MapRUnc_714E0:
MapRUnc_Sonic:			BINCLUDE	"mappings/spriteDPLC/Sonic.bin"
MapRUnc_SuperSonic:		BINCLUDE	"mappings/spriteDPLC/SonicSuper.bin"
;-----------------------------------------------------------------------------
; Sonic Art and Mappings for Special Stage
	align $20
ArtUnc_SSSonic:			BINCLUDE	"objects/characters/Char01 - Sonic/Art/Sonic Art SS.bin"
MapUnc_SonicSS:			BINCLUDE 	"mappings/sprite/SonicSS.bin"
MapRUnc_SonicSS:		BINCLUDE 	"mappings/spriteDPLC/SonicSS.bin"
; ============================================================================


; ============================================================================
; TAILS
;-----------------------------------------------------------------------------
; Uncompressed art - Patterns for Tails  ; ArtUnc_64320:
	align $20
ArtUnc_Tails:			BINCLUDE	"objects/characters/Char02 - Tails/Art/Tails Art.bin"
	align $20
ArtUnc_TailsTails:		BINCLUDE	"objects/characters/Char02 - Tails/Art/Tails Tails Art.bin"
;-----------------------------------------------------------------------------
; Sprite Mappings - Tails			; MapUnc_739E2:
MapUnc_Tails:			BINCLUDE	"mappings/sprite/Tails.bin"
MapUnc_TailsTails:		BINCLUDE	"mappings/sprite/Tails Tails.bin"
;-----------------------------------------------------------------------------
; Sprite Dynamic Pattern Reloading - Tails DPLCs	; MapRUnc_7446C:
MapRUnc_Tails:			BINCLUDE	"mappings/spriteDPLC/Tails.bin"
MapRUnc_TailsTails:		BINCLUDE	"mappings/spriteDPLC/Tails Tails.bin"
;-----------------------------------------------------------------------------
; Tails Art and Mappings for Special Stage
	align $20
ArtUnc_SSTails:			BINCLUDE 	"objects/characters/Char02 - Tails/Art/Tails Art SS.bin"
MapUnc_TailsSS:			BINCLUDE 	"mappings/sprite/TailsSS.bin"
MapRUnc_TailsSS:		BINCLUDE 	"mappings/spriteDPLC/TailsSS.bin"
; ============================================================================


; ============================================================================
; KNUCKLES
;-----------------------------------------------------------------------------
; Uncompressed art - Patterns for Knuckles
	align $20
ArtUnc_Knuckles:		BINCLUDE	"objects/characters/Char03 - Knuckles/Art/Knuckles Art.bin"
;-----------------------------------------------------------------------------
; Sprite Mappings - Knuckles
MapUnc_Knuckles:		BINCLUDE	"mappings/sprite/Knuckles.bin"
;-----------------------------------------------------------------------------
; Sprite Dynamic Pattern Reloading - Knuckles DPLCs
MapRUnc_Knuckles:		BINCLUDE	"mappings/spriteDPLC/Knuckles.bin"
;-----------------------------------------------------------------------------
; Knuckles Art and Mappings for Special Stage
	align $20
ArtUnc_SSKnuckles:		BINCLUDE 	"objects/characters/Char03 - Knuckles/Art/Knuckles Art SS.bin"
MapUnc_KnucklesSS:		BINCLUDE 	"mappings/sprite/KnucklesSS.bin"
MapRUnc_KnucklesSS:		BINCLUDE 	"mappings/spriteDPLC/KnucklesSS.bin"
; ============================================================================