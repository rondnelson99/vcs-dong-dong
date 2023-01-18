.include "defines.asm"
.SECTION "init", FREE
; for now, let's just render the striped background.
.equ BG_LIGHT $02
.equ BG_DARK $00
.equ STRIPE_WIDTH 16

RenderScreen
    lda #BG_LIGHT ; draw 16 lines of the light color
    sta COLUBK
    lda #0
    sta VBLANK ;disable blanking
    ldx #STRIPE_WIDTH
@loop1
    sta WSYNC
    dex
    bne @loop1

    ;now do a dark stripe
    lda #BG_DARK
    sta COLUBK
    ldx #STRIPE_WIDTH
@loop2
    sta WSYNC
    dex
    bne @loop2

    ;now do a light stripe
    lda #BG_LIGHT
    sta COLUBK
    ldx #STRIPE_WIDTH
@loop3
    sta WSYNC
    dex
    bne @loop3

    ;now do a dark stripe
    lda #BG_DARK
    sta COLUBK
    ldx #STRIPE_WIDTH
@loop4
    sta WSYNC
    dex
    bne @loop4

    ;now do a light stripe
    lda #BG_LIGHT
    sta COLUBK
    ldx #STRIPE_WIDTH
@loop5 
    sta WSYNC
    dex
    bne @loop5

    ;now do a dark stripe
    lda #BG_DARK
    sta COLUBK
    ldx #STRIPE_WIDTH
@loop6
    sta WSYNC
    dex
    bne @loop6

    ;the last light stripe will be twice as long
    lda #BG_LIGHT
    sta COLUBK
    ldx #STRIPE_WIDTH*2
@loop7
    sta WSYNC
    dex
    bne @loop7
        
    ;now return to the main loop
    rts
.ENDS