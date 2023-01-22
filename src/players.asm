.include "defines.asm"
.RAMSECTION "Player Ram" SLOT "RAM"
    wP1y: db
    wP2y: db
    wPlayerFlags: db ; bit 7: set if P1 is going up, bit 6: set if P2 is going up

.ENDS

.equ PLAYFIELD_BOTTOM 112
.equ PLAYFIELD_TOP 0
.equ PLAYER_HEIGHT 4
.SECTION "update players", FREE
UpdatePlayers:
    ; move the players
    bit wPlayerFlags
    bmi @P1Up
    inc wP1y
    jmp @CheckP2
@P1Up:
    dec wP1y
@CheckP2:
    bvs @P2Up
    inc wP2y
    jmp CheckReversePlayers

@P2Up:
    dec wP2y
    
CheckReversePlayers:
    ;now check if either player is at the top or bottom of the screen, and needs to be reversed
    lda wPlayerFlags

    ldx wP1y
    cpx #PLAYFIELD_BOTTOM-PLAYER_HEIGHT
    beq @reverseP1
    cpx #PLAYFIELD_TOP
    beq @reverseP1
    jmp @CheckP2Reverse
@reverseP1
    eor #$80

@CheckP2Reverse:
    ldx wP2y
    cpx #PLAYFIELD_BOTTOM-PLAYER_HEIGHT
    beq @reverseP2
    cpx #PLAYFIELD_TOP
    beq @reverseP2
    jmp @P2Done

@reverseP2
    eor #$40

@P2Done
    sta wPlayerFlags
    rts


    

.ENDS