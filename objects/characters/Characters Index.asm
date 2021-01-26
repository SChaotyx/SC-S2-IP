; ----------------------------------------------------------------------------
; CHARACTERS
; Here I usually include code for animations or special abilities

	include "objects/characters/Char01 - Sonic/Main.asm"	; codigo incluido exclusivo para el uso de Sonic
	include "objects/characters/Char02 - Tails/Main.asm"	; codigo incluido exclusivo para el uso de Tails
	include "objects/characters/Char03 - Knuckles/Main.asm"	; codigo incluido exclusivo para el uso de Knuckles

; ----------------------------------------------------------------------------
; UNIVERSAL USE
; Code used by Obj01(MainCharacter) and Obj02(Sidekick) simultaneously

	include "objects/characters/Speed Table.asm"	; subroutine to choose the correct statistics of the main and secondary player
    include "objects/characters/SetPlayer.asm"	; subroutines to set mappings, art and other jumps to subroutines for each character
    include "objects/characters/DPLC.asm"	; subroutine for character pattern load cues
