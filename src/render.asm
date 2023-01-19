.include "defines.asm"
.RAMSECTION "render ram" SLOT "RAM"
    wLightColor: db
    wDarkColor: db


    wP1yCounter: db
    wP2yCounter: db



.ENDS

.macro check_draw_players
    ; check if we should draw the players. Call on every scanline where the players are visible.
    lda #-4
    dcp wP1yCounter ;decrement the counter and check if it's between 0 and -4 (make it 4 px tall)
    bcs @skip1
    ldy #$ff
    sty GRP0
    jmp @check2
@skip1
    ldy #$00
    sty GRP0
@check2
    dcp wP2yCounter ;decrement the counter and check if it's between 0 and -4 (make it 4 px tall)
    bcs @skip2
    ldy #$ff
    sty GRP1
    jmp @done
@skip2
    ldy #$00
    sty GRP1
@done
.endm

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

    ;configure the players
    lda #$07
    sta NUSIZ0
    sta NUSIZ1
    lda #$00
    sta GRP0
    sta GRP1
    lda #130
    sta COLUP0
    lda #66
    sta COLUP1

    lda wP1y
    sta wP1yCounter
    lda wP2y
    sta wP2yCounter

    ;position the player sticks
    sta WSYNC
    SLEEP 25
    sta RESP0
    SLEEP 20
    sta RESP1
    sta WSYNC

    lda wLightColor ; draw 16 lines of the light color
    sta COLUBK
    lda #0
    sta WSYNC
    sta VBLANK ;disable blanking

    ldx #STRIPE_WIDTH-1
    jsr RenderSticksLoop


    ;now do a dark stripe
    sta WSYNC
    lda wDarkColor
    sta COLUBK

    ldx #STRIPE_WIDTH-1
    jsr RenderSticksLoop


    ;now do a light stripe
    sta WSYNC
    lda wLightColor
    sta COLUBK

    ldx #STRIPE_WIDTH-1
    jsr RenderSticksLoop

    ;now do a dark stripe
    sta WSYNC
    lda wDarkColor
    sta COLUBK

    ldx #STRIPE_WIDTH-1
    jsr RenderSticksLoop

    ;now do a light stripe
    sta WSYNC
    lda wLightColor
    sta COLUBK

    ldx #STRIPE_WIDTH-1
    jsr RenderSticksLoop

    ;now do a dark stripe
    sta WSYNC
    lda wDarkColor
    sta COLUBK
    ldx #STRIPE_WIDTH-1
    jsr RenderSticksLoop

    ;the last light stripe will be twice as long
    sta WSYNC
    lda wLightColor
    sta COLUBK
    
    ldx #STRIPE_WIDTH*2
    jsr RenderSticksLoop
        
    ;now return to the main loop
    rts
.ENDS

.SECTION "Render sticks loop", FREE ;call this to render the sticks while delaying for x scanlines
RenderSticksLoop:
@loop
    sta WSYNC
    
    check_draw_players

    dex
    bne @loop
    rts

.ENDS