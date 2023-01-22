.include "defines.asm"
.SECTION "init", FREE

.equ BG_LIGHT $02
.equ BG_DARK $00
; The CLEAN_START macro zeroes RAM and registers
Start	CLEAN_START
	lda #BG_DARK
	sta wDarkColor
	lda #BG_LIGHT
	sta wLightColor

	lda #60
	sta wP1y
	lda #12
	sta wP0X

	lda #100
	sta wP2y
	lda #116
	sta wP1X


    jmp NextFrame

.ENDS


.orga $fffc
.SECTION "vectors", FORCE
	.word Start
	.word Start
.ENDS