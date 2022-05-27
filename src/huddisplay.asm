

DisplayModeTable:
    dw #DisplayMode_OFF
    dw #DisplayMode_inputdisplay
    dw #DisplayMode_bossHP
    dw #DisplayMode_position
    dw #DisplayMode_speed
    dw #DisplayMode_iframes
    dw #DisplayMode_RNG
    dw #DisplayMode_rubies
    dw #DisplayMode_checkpoint
    dw #DisplayMode_ramwatch

DisplayMode_OFF:
    ; we shouldn't be here, but just in case...
    RTS

DisplayMode_bossHP:
{
    %a8()
    LDA !AL_Level_index : CMP #$11 : BEQ .Snake
    CMP #$10 : BEQ .Jafar
    CMP #$03 : BNE .done
    LDA !AL_Farouk_HP : BRA .checkHP

  .Snake
    LDA !AL_Snake_HP : INC : BRA .checkHP

  .Jafar
    LDA !AL_Jafar_HP

  .checkHP
    %a16()
    CMP !ram_HUD_1 : BEQ .done
    STA !ram_HUD_1 : ASL : TAX
    LDA.l NumberGFXTable,X : STA !ram_tilemap_buffer+$9C
    LDA !ram_update_HUD : ORA #$0010 : STA !ram_update_HUD

  .done
    RTS
}

DisplayMode_RNG:
{
    LDA !AL_RNG_1 : AND #$00FF : CMP !ram_HUD_1 : BEQ +
    STA !ram_HUD_1 : TAY : AND #$00F0 : LSR #3 : TAX
    LDA.l HexGFXTable,X : STA !ram_tilemap_buffer+$9A
    TYA : AND #$000F : ASL : TAX
    LDA.l HexGFXTable,X : STA !ram_tilemap_buffer+$9C
    LDA !ram_update_HUD : ORA #$0010 : STA !ram_update_HUD

+   LDA !AL_RNG_2 : AND #$00FF : CMP !ram_HUD_2 : BEQ +
    STA !ram_HUD_2 : TAY : AND #$00F0 : LSR #3 : TAX
    LDA.l HexGFXTable,X : STA !ram_tilemap_buffer+$A4
    TYA : AND #$000F : ASL : TAX
    LDA.l HexGFXTable,X : STA !ram_tilemap_buffer+$A6
    LDA !ram_update_HUD : ORA #$0010 : STA !ram_update_HUD

+   RTS
}

DisplayMode_position:
{
    LDA !AL_X_Position : CMP !ram_HUD_1 : BEQ +
    STA !ram_HUD_1
    LDX #$0096 : JSR Draw4
    LDA !ram_update_HUD : ORA #$0010 : STA !ram_update_HUD

+   LDA !AL_Y_Position : CMP !ram_HUD_2 : BEQ +
    STA !ram_HUD_2
    LDX #$00A0 : JSR Draw4
    LDA !ram_update_HUD : ORA #$0010 : STA !ram_update_HUD

+   RTS
}

DisplayMode_speed:
{
    LDA !AL_X_Speed : CMP !ram_HUD_1 : BEQ +
    STA !ram_HUD_1
    LDX #$0096 : JSR Draw4
    LDA !ram_update_HUD : ORA #$0010 : STA !ram_update_HUD

+   LDA !AL_Y_Speed : CMP !ram_HUD_2 : BEQ +
    STA !ram_HUD_2
    AND #$FFFF : BPL .drawPositive

    EOR #$FFFF : INC
    LDX #$00A0 : JSR Draw4
    LDA !TILE_HYPHEN : STA !ram_tilemap_buffer+$A2
    LDA !ram_update_HUD : ORA #$0010 : STA !ram_update_HUD
    RTS

  .drawPositive
    LDX #$00A0 : JSR Draw4
    LDA !ram_update_HUD : ORA #$0010 : STA !ram_update_HUD

+   RTS
}

DisplayMode_iframes:
{
    LDA !AL_Invul_State : AND #$00FF : CMP !ram_HUD_1 : BEQ +
    STA !ram_HUD_1 : AND #$00F0 : ASL : TAX
    LDA HexGFXTable,X : STA !ram_tilemap_buffer+$9A
    LDA !AL_Invul_State : AND #$000F : ASL : TAX
    LDA HexGFXTable,X : STA !ram_tilemap_buffer+$9C
    LDA !ram_update_HUD : ORA #$0010 : STA !ram_update_HUD

+   LDA !AL_iframe_timer : AND #$00FF : CMP !ram_HUD_2 : BEQ +
    STA !ram_HUD_2
    LDX #$00A2 : JSR Draw3
    LDA !ram_update_HUD : ORA #$0010 : STA !ram_update_HUD

+   RTS
}

DisplayMode_rubies:
{
    LDA !AL_rubies_area : AND #$00FF : CMP !ram_HUD_1 : BEQ +
    STA !ram_HUD_1 : ASL : TAX
    LDA HexToNumberGFX1,X : STA !ram_tilemap_buffer+$9A
    LDA HexToNumberGFX2,X : STA !ram_tilemap_buffer+$9C
    LDA !ram_update_HUD : ORA #$0010 : STA !ram_update_HUD

+   LDA !AL_rubies_total : AND #$00FF : CMP !ram_HUD_1 : BEQ +
    STA !ram_HUD_1 : ASL : TAX
    LDA HexToNumberGFX1,X : STA !ram_tilemap_buffer+$A0
    LDA HexToNumberGFX2,X : STA !ram_tilemap_buffer+$A2
    LDA !ram_update_HUD : ORA #$0010 : STA !ram_update_HUD

+   RTS
}

DisplayMode_inputdisplay:
{
    LDA !AL_CONTROLLER_PRI : CMP !ram_HUD_1 : BEQ .done

    TAY : LDX #$0000

-   TYA : AND ControllerInputTable,X : BEQ .blankTile
    LDA ControllerGFXTable,X
    BRA +

  .blankTile
    LDA !TILE_BLANK

+   STA !ram_tilemap_buffer+$96,X
    INX #2 : CPX #$0012 : BNE -

    TYA : STA !ram_HUD_1
    LDA !ram_update_HUD : ORA #$0010 : STA !ram_update_HUD

  .done
    RTS
}

DisplayMode_checkpoint:
{
    LDA !AL_X_Position : CMP !ram_HUD_1 : BEQ +
    STA !ram_HUD_1
    LDX #$0096 : JSR Draw4
    LDA !ram_update_HUD : ORA #$0010 : STA !ram_update_HUD

+   LDA !ram_HUD_3 : BNE .done
    LDA !sram_custom_checkpoint : CMP !ram_HUD_2 : BEQ +
    STA !ram_HUD_2
    LDX #$00A0 : JSR Draw4
    LDA !ram_update_HUD : ORA #$0010 : STA !ram_update_HUD

+   LDA !AL_X_Position : CMP !sram_custom_checkpoint : BMI .done
    LDA !ram_HUD_3 : BNE .done
    JSL UpdateTimersLocal
    LDA #$0001 : STA !ram_HUD_3

  .done
    RTS
}

DisplayMode_ramwatch:
{
    ; Store addresses
    LDA !ram_watch_bank : STA $42 : STA $4A
    LDA !ram_watch_left : CLC : ADC !ram_watch_left_index : STA $40
    LDA !ram_watch_right : CLC : ADC !ram_watch_right_index : STA $48

    ; Draw if watched value changed
    LDA [$40] : CMP !ram_HUD_1 : BEQ .drawRight
    STA !ram_HUD_1 : LDX #$0096 : JSR Draw4Hex
    LDA !ram_update_HUD : ORA #$0010 : STA !ram_update_HUD

  .drawRight
    LDA [$48] : CMP !ram_HUD_2 : BEQ .checkBlank
    STA !ram_HUD_2 : LDX #$00A0 : JSR Draw4Hex
    LDA !ram_update_HUD : ORA #$0010 : STA !ram_update_HUD

  .checkBlank
    ; Redraw if HUD is blank
    LDA !ram_tilemap_buffer+$96 : CMP !TILE_BLANK : BNE .checkRight
    LDA !ram_HUD_1 : LDX #$0096 : JSR Draw4Hex
    LDA !ram_update_HUD : ORA #$0010 : STA !ram_update_HUD

  .checkRight
    LDA !ram_tilemap_buffer+$A0 : CMP !TILE_BLANK : BNE .writeLock
    LDA !ram_HUD_2 : LDX #$00A0 : JSR Draw4Hex
    LDA !ram_update_HUD : ORA #$0010 : STA !ram_update_HUD

  .writeLock
    ; Write 8 or 16 bit values
    LDA !ram_watch_write_mode : BEQ .edit16bit
    %a8()
    LDA !ram_watch_edit_lock_left : BEQ +
    LDA !ram_watch_edit_left : STA [$40]

+   LDA !ram_watch_edit_lock_right : BEQ +
    LDA !ram_watch_edit_right : STA [$48]

+   %a16()
    LDA !ram_watch_write_mode : BEQ +
    ; Erase extra byte if 8-bit mode
    LDA !TILE_BLANK
    STA !ram_tilemap_buffer+$96 : STA !ram_tilemap_buffer+$98
    STA !ram_tilemap_buffer+$A0 : STA !ram_tilemap_buffer+$A2
    RTS

  .edit16bit
    LDA !ram_watch_edit_lock_left : BEQ +
    LDA !ram_watch_edit_left : STA [$40]

+   LDA !ram_watch_edit_lock_right : BEQ +
    LDA !ram_watch_edit_right : STA [$48]

+   LDA !ram_watch_write_mode : BEQ +
    ; Erase extra byte if 8-bit mode
    LDA !TILE_BLANK
    STA !ram_tilemap_buffer+$96 : STA !ram_tilemap_buffer+$98
    STA !ram_tilemap_buffer+$A0 : STA !ram_tilemap_buffer+$A2

+   RTS
}
