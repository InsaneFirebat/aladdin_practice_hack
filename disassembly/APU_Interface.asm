; by P.JBoy
; 

org $80B463
SendApuCommand:
{
; F0h..FDh are special commands
; F2h: Stop music? Used by Options menu
; F3h: Pause music
; F4h: Unpause music
; F5h: is used when loading story time
; F6h: Fade out music?
; F9h: is used during boot
; FAh: loading music?

; $0002 is a sequence number? APU IO 2 probably reports back the sequence number of the last command it processed
; $03BF..DE is a ring buffer of commands
; $03BB is the ring buffer index
; $03BD is some kind of max index
; $03F8 is the special command

    LDA $0371 : BNE .ret
    LDX $03BB : CPX $03BD : BEQ .ret
    LDA $0002 : CMP !apuIo2 : BNE .ret

    INC $0372 ; Talking to APU flag?
    INC $0002 ; Sequence number?

    ; A = [$03BF + [X]]
    LDA $03BF,x
    CMP #$F5 : BEQ +
    CMP #$F6 : BNE ++

    ; If [$03BF + [X]] = F5h/F6h:
    ;     X = ([X] + 1) % 20h
    ;     $03BB = [X]
    ;     APU IO 2 = 0
    ;     APU IO 3 = [$03BF + [X]]
+   PHA
    TXA : INC : AND #$1F : STA $03BB : TAX
    LDA $03BF,x : STZ !apuIo2 : STA !apuIo3
    PLA

    ; APU IO 0 = [A]
    ; $03BB = ([X] + 1) % 20h
++  STA !apuIo0
    TXA : INC : AND #$1F : STA $03BB

  .ret
    STZ $0372
    RTS
}

org $80B4D0
UploadApuData:
{
    ; $34 = [A]
    STA $34
    PHP

    ; $0C = $80:8000 | [$85:8000 + [X] + 2] << 10h (source data bank base address)
    ; Y = [$85:8000 + [X]] & 7FFFh (source data address offset)
    %ai16()
    LDA #$8000 : STA $0C
    LDA $858000,X : AND #$7FFF : TAY
    %a8()
    LDA $858002,X : ORA #$80 : STA $0E
    TXA : BEQ .end_aladdin_hack

    ; Aladdin specific:
    ; If [X] != 0:
    ;     Wait until APU IO 2 = [$0002]
    ; APU IO 0 = [$34]
    LDA $0002
-   CMP $2142 : BNE -

-   LDA $34 : STA $2140

  .end_aladdin_hack
    ; Wait until [APU IO 0..1] = AAh BBh
    %a16() : LDA #$BBAA : CMP $2140 : %a8() : BNE -

    ; Kick = CCh
    LDA #$CC
    BRA .process_data_block

  .loop_next_data_block
    ; Data = [[Y++]]
    ; Index = 0
    LDA [$0C],Y : INY : XBA
    LDA #$00
    BRA .upload_data

  .loop_next_data
    ; Data = [[Y++]]
    ; Wait until APU IO 0 echoes
    ; Increment index
    XBA
    LDA [$0C],Y
    INY : BPL + : INC $0E : LDY #$0000 : +
    XBA
-   CMP $2140 : BNE -
    INC

  .upload_data
    ; APU IO 0..1 = [index] [data]
    ; Decrement X (block size)
    ; Wait until APU IO 0 echoes
    ; Kick = [index] + 4
    ; Ensure kick != 0
    %a16() : STA $2140 : %a8()
    DEX : BNE .loop_next_data
-   CMP $2140 : BNE -
-   ADC #$03 : BEQ -

  .process_data_block
    ; X = [[$0C] + [Y]] (block size)
    ; Y += 2
    ; APU IO 2..3 = [[$0C] + [Y]] (destination address)
    ; Y += 2
    ; If block size = 0:
    ;     APU IO 1 = 0 (EOF)
    ;     Clear overflow
    ; Else:
    ;     APU IO 1 = 1 (arbitrary non-zero value)
    ;     Set overflow
    PHA
    %a16()
    LDA [$0C],Y : INY : INY : TAX
    LDA [$0C],Y : INY : INY : STA $2142
    %a8()

    CPX #$0001 : LDA #$00 : ROL : STA $2141
    ADC #$7F
    PLA

    ; APU IO 0 = kick
    ; Wait until APU IO 0 echoes
    STA $2140
-   CMP $2140 : BNE -

    ; If block size != 0: loop
    BVS .loop_next_data_block

    ; Aladdin specific:
    ; Wait until [APU IO 2] = 1
    ; $0002 = 1
    %ai8()
    LDA #$01
-   CMP $2142 : BNE -
    STA $0002

    PLP
    RTL
}


; Music List
; LDA #$FA : LDX #$xx : JSL $80B4D0

; A = APU Command
; X = Music Track
; Hex De In
; $00 01 30  Capcom intro
; $01 02 33  BGM 02
; $02 03 36  Genie title screen
; $03 04 39  Friend Like Me
; $04 05 3C  Title screen
; $05 06 3F  BGM 06 - Agrabah
; $06 07 42  BGM 07 - Caverns
; $07 08 45  BGM 08 - Cave Escape
; $08 09 48  BGM 09 - Genie stage?
; $09 10 4B  BGM 10
; $0A 11 4E  BGM 11
; $0B 12 51  Magic Carpet Ride
; $0C 13 54  First story time
; $0D 14 57  BGM 14
; $0E 15 5A  BGM 15 - Credits? no
; $0F 16 5D  BGM 16
; $10 17 60  BGM 17 - sample?
; $11 18 63  BGM 18 - First boss music
; $12 19 66  BGM 19 - Final boss music
; $13 20 69  BGM 20 - Endgame sample?
; $14 21 6C  A Whole New World
; $15 22 6F  BGM 22
; $16 23 72  BGM 23 - Credits
; $17 24 75  Stage clear screen
; $18 25 78  Level clear
; $19 26 7B  Bonus screen
; $1A 27 7E  Death sample
; $1B 28 81  BGM 28 - Story time?
; $1C 29 84  BGM 29 - Finish bonus wheel?
; $1D 30 87  BGM 30
; $1E 31 8A  BGM 31 - Story time?
; $1F 32 8D  BGM 32
; $20 33 90  BGM 33
; $21 34 93  BGM 34 - sample, continue?
; $22 35 96  BGM 35 - Jafar?


; SFX List
; LDA #$0F : JSL $81FA00

; A = Sound Effect
; 00  Nothing?
; 01  Aladdin Jump
; 02  Aladdin Hurt
; 03  Apple Thrown
; 04  Aladdin Big Slide
; 05  Nothing?
; 06  Ledge Grab
; 07  Alternate $12?
; 08  Apple Hit
; 09  1-Up/Heart Piece
; 0A  Aladdin Small Slide
; 0B  Item Pickup
; 0C  Menu Sound
; 0D  Nothing
; 0E  Pause
; 0F  Bounce
; 10  Aladdin Landing
; 11  Arrow Shot
; 12  Bounce on Pole/Vase/Chest
; 13  Guard Footstep
; 14  Barrel Bounce
; 15  Barrel Break
; 16  Walking Pot Awakens
; 17  Apple Hits Farouk
; 18  Stalagtite Landing
; 19  Nothing
; 1A  Cave Floor Crumbling
; 1B  maybe Boulder Bounce
; 1C  ???, almost like brief static
; 1D  ???, familiar, enchanting
; 1E  ???, sounds like gunfire?
; 1F  ???
; 20  Farouk Sword Swipe
; 21  Farouk Sword Frenzy
; 22  Farouk Bounce 1
; 23  ???, long explosion sound?
; 24  ??? sounds like skeleton, or skull bounce
; 25  ???, quiet and brief
; 26  ???
; 27  ???
; 28  Finish Level
; 29  ???
; 2A  ???, fade-in endless earthquake sound?
; 2B  ???, earthquake collapse
; 2C  ???, quick slide?
; 2D  Bonus Shot Pop
; 2E  Ping/Beep
; 2F  Palace Guard Boomerang
; 30  Bouncing Skull
; 31  Collect Gem
; 32  Collect Something?
; 33  Immediate Endless Earthquake
; 34  ???
; 35  ???, higher pitch $34
; 36  Activate Scarab
; 37  Release Scarab
; 38  ???
; 39  Ceiling Smasher Thing
; 3A  Bonus Wheel Bounce
; 3B  Bonus Wheel Beep
; 3C  Vase Landing
; 3D  ???
; 3E  Lightning?
; 3F  ???, endless chain sound? Ceiling Smasher?
; 40  Rope Slide
; 41  Genie Pulls Bonus Rope (Springy Sound)
; 42  Genie Finger Gun Shot (Beep)
; 43  Genie Finger Gun Charge
; 44  ???, evil magic sound
; 45  Farouk Defeated
; 46  Jafar Vanish or Appear?
; 47  Jafar Summon
; 48  ???
; 49  Snake Hiss?
; 4A  from start of final boss fight
; 4B  ???, static?
; 4C  ???
; 4D  ???
; 4E  ???
; 4F  Collect Scarab
; 50  Jafar Vanish or Appear?

; list seems to repeat beyond that

