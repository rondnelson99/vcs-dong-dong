.include "defines.asm"
.RAMSECTION "render ram" SLOT "RAM"
    wLightColor: db
    wDarkColor: db

    wSegmentCount: db
.ENDS



.SECTION "render", FREE
; for now, let's just render the striped background and walls.
.equ STRIPE_WIDTH 16
.equ WALL_COLOR $0A
RenderScreen

    ;set COLUPF to grey for the walls
    lda #WALL_COLOR
    sta COLUPF
    ;and set up the PF
    lda #$01
    sta CTRLPF
    lda #$80
    sta PF2

    lda wLightColor ; draw 16 lines of the light color
    sta COLUBK
    lda #0
    sta WSYNC
    sta VBLANK ;disable blanking

    ldx #STRIPE_WIDTH
@loop1
    sta WSYNC
    dex
    bne @loop1

    ;now do a dark stripe
    lda wDarkColor
    sta COLUBK
    ldx #STRIPE_WIDTH
@loop2
    sta WSYNC
    dex
    bne @loop2

    ;now do a light stripe
    lda wLightColor
    sta COLUBK
    ldx #STRIPE_WIDTH
@loop3
    sta WSYNC
    dex
    bne @loop3

    ;now do a dark stripe
    lda wDarkColor
    sta COLUBK
    ldx #STRIPE_WIDTH
@loop4
    sta WSYNC
    dex
    bne @loop4

    ;now do a light stripe
    lda wLightColor
    sta COLUBK
    ldx #STRIPE_WIDTH
@loop5 
    sta WSYNC
    dex
    bne @loop5

    ;now do a dark stripe
    lda wDarkColor
    sta COLUBK
    ldx #STRIPE_WIDTH
@loop6
    sta WSYNC
    dex
    bne @loop6

    ;the last light stripe will be twice as long
    lda wLightColor
    sta COLUBK
    ldx #STRIPE_WIDTH*2
@loop7
    sta WSYNC
    dex
    bne @loop7
        
    ;now return to the main loop
    rts
.ENDS

.SECTION "Render sticks loop", FREE

.ENDS