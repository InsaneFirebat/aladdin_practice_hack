
; Set cart type and SRAM size
org $00FFD6 : GameHeader_CartridgeType:
    db $02 ; ROM, RAM and battery

org $00FFD8 : GameHeader_SRAMSize:
if !FEATURE_SAVESTATES
    db $08 ; 256kb
else
    db $05 ; 64kb
endif

incsrc antipiracy.asm ; bypass SRAM checks


; Enable Level Select
org $809F7A
    db #$00

org $809FC7
    db #$00


; Allow soft reset during demo playback (credits)
org $81BD5C
    PHP : %a16()
    LDA !AL_CONTROLLER_PRI : CMP !sram_ctrl_soft_reset : BNE +
    PLP
    JML $008000 ; soft reset
+   PLP


; Modified and recompressed HUD graphics
org $A08000
incbin ../resources/Graphics_HUD_Compressed.bin


; Hijack starting equipment to set our own
org $81814C
    JSL StartingEquipment : NOP #2


; Infinite Hearts
org $838031
    JML InfiniteHearts1
    NOP #2

org $838048
InfiniteHearts1_return:

org $838008
    JML InfiniteHearts2
InfiniteHearts2_return:
    RTS


; Infinite Apples
org $81CE4F
    JML InfiniteApples
    NOP #12
InfiniteApples_return:


; Infinite Lives
org $81DC67
    JML InfiniteLives
    NOP #4
InfiniteLives_return:


; Infinite Credits
org $80B300
    JML InfiniteCredits1
    NOP #5
InfiniteCredits1_return:

org $80B338
    JML InfiniteCredits2
    NOP

org $80B3A4
    JML InfiniteCredits3
    NOP
InfiniteCredits3_return:

org $839D74
    JML InfiniteCredits4
    NOP

org $80B3EF
    JML InfiniteCredits5
    NOP #2
InfiniteCredits5_return:


; Stage Clear Screen skip
org $81F7A8
    JSL StageClearSkip


; Story Time skip
org $81F180
    JSL StoryTimeSkip


; Music toggle
org $80B4D0
    PHP
    JSL MusicToggle


org $BFC000
print pc, " misc.asm start"

StartingEquipment:
{
    LDA !sram_default_cape : STA !AL_cape : STA !AL_cape_HUD
    LDA !sram_default_hearts : STA !AL_hearts_max : STA !AL_hearts : STA !AL_hearts_HUD
    LDA !sram_default_apples : STA !AL_apples : STA !AL_apples_HUD
    LDA !sram_default_lives : STA !AL_lives
    LDA !sram_default_credits : STA !AL_credits

    LDA !sram_disable_music : STA !ram_disable_music

    STZ !AL_scarab : STZ !AL_Chests_Opened ; overwritten code
    RTL
}


InfiniteHearts1:
; this routine remains CPU neutral regardless of setting used
{
    LDA !sram_infinite_hearts : BNE .enabled
    DEC !AL_hearts
    LDA $08E3 : ORA #$80 : STA $08E3
    LDA !AL_Invul_State : ORA #$02 : STA !AL_Invul_State
    %a16() ; cutting out JSL $81AB85 and its return
    LDX #$00
    LDA !AL_X_Position : CMP $0C : BCS +
    INX
+   %a8()
    %a8() ; waste 3 cycles
    TXA
    JML InfiniteHearts1_return

  .enabled
    STZ !AL_hearts_HUD ; ensure HUD is still updated
    LDA $08E3 : ORA #$80 : STA $08E3
    LDA !AL_Invul_State : ORA #$02 : STA !AL_Invul_State
    %a16() ; cutting out JSL $81AB85 and its return
    LDX #$00
    LDA !AL_X_Position : CMP $0C : BCS +
    INX
+   %a8()
    %a8() ; waste 3 cycles
    TXA
    NOP ; waste 2 cycles
    JML InfiniteHearts1_return
}

InfiniteHearts2:
{
    LDA !sram_infinite_hearts : BNE .enabled
    LDA #$8C : STA $08DB
    INC !AL_DamageTaken_141B : DEC !AL_hearts
    LDA !AL_DamageTaken_08E3 : ORA #$80 : STA !AL_DamageTaken_08E3
    LDA !AL_Invul_State : ORA #$02 : STA !AL_Invul_State
    JML InfiniteHearts2_return

  .enabled
    LDA #$8C : STA $08DB
    INC !AL_DamageTaken_141B : STZ !AL_hearts_HUD
    LDA !AL_DamageTaken_08E3 : ORA #$80 : STA !AL_DamageTaken_08E3
    LDA !AL_Invul_State : ORA #$02 : STA !AL_Invul_State
    JML InfiniteHearts2_return
}


InfiniteApples:
{
    PHA : PHA
    LDA !sram_infinite_apples : BNE .enabled
    PLA : AND #$0F : BNE +
    PLA : SEC : SBC #$07 : BRA ++
+   PLA : DEC
++  STA !AL_apples
    JML InfiniteApples_return

  .enabled
    PLA : PLA
    JML InfiniteApples_return
}


InfiniteLives:
{
    LDA !sram_infinite_lives : BNE .enabled
    DEC !AL_lives : BEQ .gameover ; overwritten code

  .enabled
    JML InfiniteLives_return

  .gameover
    JML $81DC76
}


InfiniteCredits1:
{
    LDA !sram_infinite_credits : BNE .return06
    LDA !AL_credits : BNE .return06
    LDA #$0F
    JML InfiniteCredits1_return

  .return06
    LDA #$06
    JML InfiniteCredits1_return
}

InfiniteCredits2:
{
    LDA !sram_infinite_credits : BNE .done
    LDA !AL_credits : BNE .done
    LDX #$77
    JSL $81F60D
    JML $80B34B

  .done
    JML $80B345
}

InfiniteCredits3:
{
    LDA !sram_infinite_credits : BNE .done
    LDA !AL_credits : BNE .done
    JML InfiniteCredits3_return

  .done
    JML $80B3CE
}

InfiniteCredits4:
{
    LDA !sram_infinite_credits : BNE .done
    LDA !AL_credits : BNE .done
    JML $8396CA

  .done
    JML $839D7C
}

InfiniteCredits5:
{
    LDA !sram_infinite_credits : BNE .draw
    DEC !AL_credits

  .draw
    LDA !AL_credits : CLC : ADC #$30 : STA $7EDEBA
    INC !AL_HUD_tilemap_flag
    JML InfiniteCredits5_return
}


StageClearSkip:
{
    LDA !sram_stage_clear_skip : BNE .enabled
    LDA #$01
    JML $81BCB8 ; StageClearScreen_StartAndEndFrameLoop

  .enabled
    PLA : PLA : PLA
    JML $81F93A
}


StoryTimeSkip:
{
    LDA !sram_story_time_skip : BNE .enabled
    JML $8196A8

  .enabled
    PLA : PLA : PLA
    JML $81F2D3
}


MusicToggle:
{
    STA $34
    LDA !ram_disable_music : BNE .skip

  .play
    %ai16()
    RTL

  .skip
    LDA !AL_InitialSPCDataUploaded_maybe : BEQ .play
    PLA : PLA : PLA
    JML $80B56C
}


print pc, " misc.asm end"
warnpc $BFE000 ; init.asm


; $30 bytes of freespace in bank $80
; due to hijacked HUD tilemap transfer
org $80846E
;print pc, " freespace bank80 start"
;print pc, " freespace bank80 end"
warnpc $80849E


; $04 bytes of freespace in bank $81
; due to InfiniteLives hijack
; $0C more bytes in InfiniteApples if needed
org $81DC6B
;print pc, " freespace bank81 start"
;Routine_long:
;    JSR Routine
;    RTL
;print pc, " freespace bank81 end"
warnpc $81DC6F


; $17 bytes of freespace in bank $83
; due to InfiniteHearts2 hijack
org $83800D
; print pc, " freespace bank83 start"
; print pc, " freespace bank83 end"
warnpc $838024


; Blank area to write test code while in the debugger
; Executed by controller shortcut
org $BFBFBF ; the end
TestCodeArea:
{
    NOP #64
    RTL
}

