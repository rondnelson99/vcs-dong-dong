.include "defines.asm"
.RAMSECTION "render ram" SLOT "RAM"
    wLightColor: db
    wDarkColor: db


    wP1yCounter: db
    wP2yCounter: db

    wStripeCounter: db ;counts how many sets of stripes we've drawn

    wP0X: db ; these are the logical positions that the HMOVE routime will move the objects toward
    wP1X: db
    wBallX: db

    wCurP0XOffset: db ; these are the actual current TIA X positions, not the logical game positions
    wCurP1XOffset: db
    wCurBallXOffset: db


.ENDS

.equ PLAYER_HEIGHT 4 ;the height of the player sticks
.equ P1_COLOR 130
.equ P2_COLOR 66

.equ BRICK_COLOR 28

.macro check_draw_players
    ; check if we should draw the players. Call on every scanline where the players are visible.
    lda #-PLAYER_HEIGHT-1 ; the -1 avoids an off-by-one error since the the difference should be negative, not zero
    dcp wP1yCounter ;decrement the counter and check if it's between 0 and -4 (make it 4 px tall)
    bcs @skip1\@ ;all these \@ are to make sure the labels are unique. The assembles redefines this symbol on each macro call.
    ldy #$ff
    sty GRP0
    jmp @check2\@
@skip1\@
    ldy #$00
    sty GRP0
@check2\@
    dcp wP2yCounter ;decrement the counter and check if it's between 0 and -4 (make it 4 px tall)
    bcs @skip2\@
    ldy #$ff
    sty GRP1
    jmp @done\@
@skip2\@
    ldy #$00
    sty GRP1
@done\@
.endm

.SECTION "render", FREE
; for now, let's just render the striped background and walls.
.equ STRIPE_WIDTH 16
.equ WALL_COLOR $0A
RenderScreen

    ;First, we have a whole bunch of constants to write to registers

    ;set up the playfield for the grey walls and 8px wide bricks
    lda #WALL_COLOR
    sta COLUPF
    lda #$31 ; mirror the playfield, 8px wide ball
    sta CTRLPF


    ;configure the players
    lda #$07
    sta NUSIZ0
    sta NUSIZ1
    lda #$00
    sta GRP0
    sta GRP1
    lda #P1_COLOR
    sta COLUP0
    lda #P2_COLOR
    sta COLUP1

    lda wP1y ; set the temporary counters to the current player positions, which will be destroyed during the rendering
    sta wP1yCounter
    lda wP2y
    sta wP2yCounter

    ;position the player sticks and the ball
    sta WSYNC
    SLEEP 22
    sta RESP0
    SLEEP 17
    sta RESBL
    SLEEP 9
    sta RESP1
    sta WSYNC

    ;write their imprecise initial positions to the variables that the HMOVE routine will use
    lda #12-13
    sta wCurP0XOffset
    lda #116-109
    sta wCurP1XOffset
    lda #(76-3)-71
    sta wCurBallXOffset



    lda #4
    sta wStripeCounter

    ;now use the HMOVE routine to move the players to their initial positions
    jsr ComputeHMoves

    lda #0
    sta WSYNC
    sta VBLANK ;disable blanking

LightDarkStripeLoop: ;draws a light stripe, then a dark stripe
    ;now do a light stripe
    lda wLightColor
    sta COLUBK
    lda #$80 ;set the wall, clear the brick
    sta PF2
    sta ENABL ;disable the ball
    lda #WALL_COLOR ;set the PF color to the wall color
    sta COLUPF


    check_draw_players

    ldx #STRIPE_WIDTH-1
    jsr RenderSticksLoop

    ;now do a dark stripe
    sta WSYNC
    lda wDarkColor
    sta COLUBK
    lda #0 ;clear the bricks
    sta PF2
    ;and prepare to draw the brick (ball)
    lda #BRICK_COLOR
    sta COLUPF
    lda #$02
    sta ENABL



    check_draw_players

    ldx #STRIPE_WIDTH-1
    jsr RenderSticksLoop

    sta WSYNC

    dec wStripeCounter
    bne LightDarkStripeLoop

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

.SECTION "Compute HMOVEs", FREE ;computes and writes HMOVE offsets for each player and the ball
ComputeHMoves: ;careful; it uses a scanline and a half to compute the HMOVEs - not for the middle of the frame
    sta WSYNC

    ;start with player 0

    ; subtract desired x - current x
    ldx wCurP0XOffset
    lda.w HMoveTable,x ; get the HMOVE value from the table
    sta HMP0 ; write it to the HMOVE register

    and #$0F ; mask off the top 4 bits
    sec
    sbc #7 ; subtract 7 to make it a signed number. This technique saves 2 cycles compared to sign-extending the value and storing it as negative.
    
    clc
    adc wCurP0XOffset ; add the current x position
    sta wCurP0XOffset ; save the new x position

    ;now do player 1

    ; subtract desired x - current x
    ldx wCurP1XOffset
    lda.w HMoveTable,x ; get the HMOVE value from the table
    sta HMP1 ; write it to the HMOVE register

    and #$0F ; mask off the top 4 bits
    sec
    sbc #7 

    clc
    adc wCurP1XOffset ; add the current x position
    sta wCurP1XOffset ; save the new x position

    ;now do the ball

    ; subtract desired x - current x
    ldx wCurBallXOffset
    lda.w HMoveTable,x ; get the HMOVE value from the table
    sta HMBL ; write it to the HMOVE register

    and #$0F ; mask off the top 4 bits
    sec
    sbc #7

    clc
    adc wCurBallXOffset ; add the current x position
    sta wCurBallXOffset ; save the new x position

    sta WSYNC ; this barely fits in a scanline
    sta HMOVE
    rts
.ENDS

.MACRO hmove_table_byte ARGS diff ;writes a byte to the HMOVE table. Argument is the difference between the desired and current x positions.
    .IF diff < 0
        .REDEF delta max(diff, -7)
    .ELSE
        .REDEF delta min(diff, 8)
    .ENDIF
    .db (( 0 - delta) << 4) | (delta + 7)
.ENDM

.SECTION "HMOVE Table", ALIGN 256 FREE ;signed 8bit table. 
; assists with moving an entity toward the desired x position. the top 4 bits are ready to be written to HMOVE, 
; and the bottom 4 should have 7 subtracted from it (so they can be stored as positive) and added to the current x position.
; the table is indexed by the difference between the desired and current x positions.
HMoveTable:
    .REPT 128 INDEX I ;do the positive numbers
        hmove_table_byte I
    .ENDR
    .REPT 128 INDEX I ;do the negative numbers
        hmove_table_byte -128+I
    .ENDR
.ENDS







 