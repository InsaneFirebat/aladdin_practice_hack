; -------------
; Practice Menu
; -------------

; DP usage
; $38 = JSL target, temp usage
; $39 = JSL target, temp usage
; $3A = JSL target, temp usage
; $3B = JSL target, temp usage
; $3C = toggle value, increment
; $3D = toggle value, increment
; $3E = Palette byte for text
; $3F = Palette byte for text
; $40 = menu indices, !ram_cm_menu_stack,X
; $41 = menu indices, !ram_cm_menu_stack,X
; $42 = menu bank
; $43 = menu bank
; $44 = menu item address
; $45 = menu item address
; $46 = menu item bank
; $47 = menu item bank
; $48 = RAM address, minimum value
; $49 = RAM address, minimum value
; $4A = RAM bank, maximum value
; $4B = RAM bank, maximum value

org $BE8000
print pc, " menu start"

cm_start:
{
    PHP : %ai16()
    PHD
    PHB
    PHX
    PHY
    PHK : PLB
    LDA #$0000 : PHA : PLD

    %ai16()
    JSR cm_init

    JSL cm_draw
    JSR cm_loop

    JSR cm_exit

    PLY
    PLX
    PLB
    PLD
    PLP
    RTL
}

cm_init:
{
    %a8() : %i16()
    LDA #$80 : STA $802100
    LDA !AL_420C_HDMAEnable : STA !cm_AL_420C_HDMAEnable
    STZ $420C : STZ !AL_420C_HDMAEnable
    LDA #$A1 : STA $4200
    LDA #$09 : STA $2105
    STZ $2112 : STZ $2112
    LDA #$0F : STA $0F2100 ; $0F bank and duplicate are intentional
    LDA #$0F : STA $0F2100 ; prevents hardware bug with INIDISP register

    ; Set up menu state
    %ai16()
    LDA #$0000 : JSR cm_tilemap_swap ; backup

    LDA #$0000
    STA !ram_cm_stack_index
    STA !ram_cm_cursor_stack
    STA !ram_cm_leave
    STA !ram_cm_ctrl_mode
    STA !ram_cm_ctrl_timer
    STA !AL_CONTROLLER_PRI_NEW
    STA !ram_HUD_1 : STA !ram_HUD_2
    STA !ram_HUD_3 : STA !ram_HUD_4

    LDA !AL_FRAME_COUNTER : STA !ram_cm_input_counter

    LDA #$0001 : STA !ram_menu_active ; this tells NMI to swap out wram before and after executing normal routines

    LDA.l #MainMenu : STA !ram_cm_menu_stack
    LDA.l #MainMenu>>16 : STA !ram_cm_menu_bank

    %a8()
    LDA !AL_cape : STA !cm_AL_cape
    LDA !AL_scarab : STA !cm_AL_scarab
    LDA !AL_lives : DEC : STA !cm_AL_lives
    LDA !AL_hearts : STA !cm_AL_hearts
    LDA !AL_hearts_max : STA !cm_AL_hearts_max
    LDA !AL_apples : STA !cm_AL_apples
    LDA !AL_gems : STA !cm_AL_gems
    LDA !AL_rubies_area : STA !cm_AL_rubies_area
    LDA !AL_rubies_total : STA !cm_AL_rubies_total

    LDA !AL_Level_index : CMP #$13 : BMI +
    LDA #$00
+   STA !cm_levelselect_level_index

    LDA !AL_Level : INC : STA !cm_levelselect_level
    LDA !AL_checkpoint : STA !cm_levelselect_checkpoint

    LDA !AL_Stage : STA !cm_levelselect_stage : CMP #$07 : BNE +
    LDA #$05 : STA !cm_levelselect_stage

+   LDA !AL_CheatCode : STA !sram_cheat_code

    LDA !AL_Invul_State : AND #$80 : BEQ +
    LDA #$01
+   STA !cm_AL_Invul_State

+   %a16()
    JSL cm_calculate_max
    RTS
}

cm_exit:
{
    LDA #$0000
    STA !ram_HUD_1 : STA !ram_HUD_2
    STA !ram_HUD_3 : STA !ram_HUD_4

    ; Redraw HUD
    LDA #$2020 : JSL $8195B8 ; WriteAto_BG3Tilemap
    JSL cm_redraw_BG3_tilemap
    JSR cm_clear_lower_tilemap
    LDA #$0001 : JSR cm_tilemap_swap ; restore
    %a8()
    INC !AL_HUD_tilemap_flag

+   LDA !sram_cheat_code : STA !AL_CheatCode
    LDA !cm_AL_Invul_State : BEQ +
    LDA #$80 : STA !AL_Invul_State

+   JSL wait_for_NMI  ; Wait for next frame

    ; restore registers
    LDA !cm_AL_420C_HDMAEnable : STA !AL_420C_HDMAEnable : STA $420C
    LDA !AL_2105_BGMode : STA $2105
    LDA !AL_4200_NMITIMEN : STA $4200
    LDA !AL_2100_INIDISP : STA $2100
    LDA !AL_2100_INIDISP : STA $2100 ; intentionally duplicated
    %a16()

    JSL UpdateTimersLocal  ; do this after the lag frame
    LDA !ram_lag_counter : DEC : STA !ram_lag_counter

    LDA #$0000 : STA !ram_menu_active

    RTS
}

cm_tilemap_swap:
{
    PHP : %a16()
    BEQ .backup
    ; restore
    LDX #$013E
-   LDA !ram_tilemap_backup,X : STA !ram_tilemap_buffer+$40,X
    DEX #2 : BPL -

    LDX #$0080
-   LDA !ram_tilemap_backup+$180,X : STA !ram_tilemap_buffer+$780,X
    DEX #2 : BPL -
    PLP
    RTS

  .backup
    LDX #$013E
-   LDA !ram_tilemap_buffer+$40,X : STA !ram_tilemap_backup,X
    DEX #2 : BPL -

    LDX #$0080
-   LDA !ram_tilemap_buffer+$780,X : STA !ram_tilemap_backup+$180,X
    DEX #2 : BPL -
    PLP
    RTS
}

wait_for_NMI:
{
    PHP : %a8()
    LDA !AL_FRAME_COUNTER
-   CMP !AL_FRAME_COUNTER : BEQ -
    PLP
    RTL
}

cm_handle_sfx:
{
    PHP : %ai8()
    LDA !AL_Music_flag_0371 : BNE .done
    LDX !AL_SFX_RingBuffer_index : CPX !AL_SFX_RingBuffer_maxindex : BEQ .done
    LDA !AL_SFX_sync : CMP $2142 : BNE .done
    INC !AL_MusicHandler_flag : INC !AL_SFX_sync
    LDA !AL_SFX_RingBuffer,X : CMP #$F5 : BEQ .sfx_is_F5
    CMP #$F6 : BNE .sfx_is_not_F6

  .sfx_is_F5
    PHA
    TXA : INC : AND #$1F : STA !AL_SFX_RingBuffer_index : TAX
    LDA !AL_SFX_RingBuffer,X : STA $2143
    STZ $2142
    PLA

  .sfx_is_not_F6
    STA $2140
    TXA : INC : AND #$1F : STA !AL_SFX_RingBuffer_index
    STZ !AL_MusicHandler_flag

  .done
    PLP
    RTL
}

cm_clear_lower_tilemap:
{
    ; clear tilemap
    LDA #$2000 : LDX #$05FE
-   STA !ram_tilemap_buffer+$200 : DEX #2 : BPL -
    ; transfer tilemap
    JSL NMI_tilemap_transfer
    RTS
}

cm_redraw_BG3_tilemap:
{
    LDX #$0000
    LDA #$0400 : STA $3C
    LDA #$2020
-   STA $7ED800,X
    INX #2
    DEC $3C : BNE -
    RTL 
}


; ----------
; Drawing
; ----------

cm_draw:
{
    PHP : %ai16()
    JSR cm_tilemap_bg
    JSR cm_tilemap_menu
    JSL NMI_tilemap_transfer
    PLP
    RTL
}

cm_tilemap_bg:
{
    ; top left corner  = $042
    ; top right corner = $07C
    ; bot left corner  = $682
    ; bot right corner = $6BC
    ; Empty out !ram_tilemap_buffer
    LDA #$000E : LDX #$07FE
-   STA !ram_tilemap_buffer,X
    DEX #2 : BPL -

    ; Vertical edges
    LDY #$0018 : LDX #$0000
-   LDA #$2489 : STA !ram_tilemap_buffer+$082,X
    LDA #$2488 : STA !ram_tilemap_buffer+$0BC,X
    TXA : CLC : ADC #$0040 : TAX
    DEY : BPL -

    ; Horizontal edges
    LDX #$0000 : LDY #$001B

-   LDA #$248A : STA !ram_tilemap_buffer+$044,X
    LDA #$2411 : STA !ram_tilemap_buffer+$6C4,X

    INX #2
    DEY : BPL -

    ; $80 = vertical flip
    ; $40 = horizontal flip
    

    ; Corners
    LDA #$248B : STA !ram_tilemap_buffer+$042 ; top left
    LDA #$648B : STA !ram_tilemap_buffer+$07C ; top right
    LDA #$A48B : STA !ram_tilemap_buffer+$6C2 ; bottom left
    LDA #$E48B : STA !ram_tilemap_buffer+$6FC ; bottom right

    ; Interior
    LDA #$281F : LDX #$0000 : LDY #$001B

-   STA !ram_tilemap_buffer+$004,X
    STA !ram_tilemap_buffer+$084,X
    STA !ram_tilemap_buffer+$0C4,X
    STA !ram_tilemap_buffer+$104,X
    STA !ram_tilemap_buffer+$144,X
    STA !ram_tilemap_buffer+$184,X
    STA !ram_tilemap_buffer+$1C4,X
    STA !ram_tilemap_buffer+$204,X
    STA !ram_tilemap_buffer+$244,X
    STA !ram_tilemap_buffer+$284,X
    STA !ram_tilemap_buffer+$2C4,X
    STA !ram_tilemap_buffer+$304,X
    STA !ram_tilemap_buffer+$344,X
    STA !ram_tilemap_buffer+$384,X
    STA !ram_tilemap_buffer+$3C4,X
    STA !ram_tilemap_buffer+$404,X
    STA !ram_tilemap_buffer+$444,X
    STA !ram_tilemap_buffer+$484,X
    STA !ram_tilemap_buffer+$4C4,X
    STA !ram_tilemap_buffer+$504,X
    STA !ram_tilemap_buffer+$544,X
    STA !ram_tilemap_buffer+$584,X
    STA !ram_tilemap_buffer+$5C4,X
    STA !ram_tilemap_buffer+$604,X
    STA !ram_tilemap_buffer+$644,X
    STA !ram_tilemap_buffer+$684,X

    INX #2
    DEY : BPL -

    RTS
}

cm_tilemap_menu:
{
    ; $40[0x4] = menu indices
    ; $44[0x4] = current menu item index
    ; $3E[0x2] = palette ORA for tilemap entry (for indicating selected menu)
    LDX !ram_cm_stack_index
    LDA !ram_cm_menu_stack,X : STA $40
    LDA !ram_cm_menu_bank : STA $42
    LDA !ram_cm_menu_bank : STA $46

    LDY #$0000
  .loop
    TYA : CMP !ram_cm_cursor_stack,X : BEQ .selected
    LDA #$0000
    BRA .continue

  .selected
    LDA #$0024

  .continue
    STA $3E

    LDA [$40],Y : BEQ .header
    CMP #$FFFF : BEQ .blank
    STA $44

    PHY : PHX

    ; X = action index (action type)
    LDA [$44] : TAX

    INC $44 : INC $44

    JSR (cm_draw_action_table,X)

    PLX : PLY

  .blank
    ; skip drawing blank lines
    INY : INY
    BRA .loop

  .header
    ; Draw menu header
    STZ $3E
    TYA : CLC : ADC $40 : INC #2 : STA $44
    LDX #$00C6
    JSR cm_draw_text

    ; Optional footer
    TYA : CLC : ADC $44 : INC : STA $44
    LDA [$44] : CMP #$F007 : BNE .done

    INC $44 : INC $44 : STZ $3E
    LDX #$0646
    JSR cm_draw_text
    RTS

  .done
    DEC $44 : DEC $44
    RTS
}

NMI_tilemap_transfer:
{
    JSL wait_for_NMI  ; Wait for next frame
    PHP : %a8()
    LDA #$80 : STA $2115
    %a16()
    LDA #$5C00 : STA $2116 ; vram word addr
    LDA #$1801 : STA $4300
    LDA #$D800 : STA $4302 ; source addr
    LDA #$007E : STA $4304 ; source bank
    LDA #$0700 : STA $4305 ; size
    %a8()
    LDA #$01 : STA $420B
    PLP
    RTL
}

cm_draw_action_table:
    dw draw_toggle
    dw draw_toggle_bit
    dw draw_jsl
    dw draw_numfield
    dw draw_choice
    dw draw_ctrl_shortcut
    dw draw_numfield_hex
    dw draw_numfield_word
    dw draw_toggle_inverted
    dw draw_numfield_color
    dw draw_numfield_hex_word
    dw draw_numfield_sound
    dw draw_controller_input
    dw draw_toggle_bit_inverted
    dw draw_jsl_submenu
    dw draw_numfield_8bit
    dw draw_numfield_decimal

draw_toggle:
{
    ; grab the memory address (long)
    LDA [$44] : INC $44 : INC $44 : STA $48
    LDA [$44] : INC $44 : STA $4A

    ; grab the toggle value
    LDA [$44] : AND #$00FF : INC $44 : STA $3C

    ; increment past JSL
    INC $44 : INC $44

    ; Draw the text
    %item_index_to_vram_index()
    PHX : JSR cm_draw_text : PLX

    ; Set position for ON/OFF
    TXA : CLC : ADC #$002C : TAX

    %a8()
    ; set palette
    LDA $3E
    STA !ram_tilemap_buffer+1,X
    STA !ram_tilemap_buffer+3,X
    STA !ram_tilemap_buffer+5,X

    ; grab the value at that memory address
    LDA [$48] : CMP $3C : BEQ .checked

    ; Off
    %a16()
    LDA #$244F : STA !ram_tilemap_buffer+0,X
    LDA #$2446 : STA !ram_tilemap_buffer+2,X
    LDA #$2446 : STA !ram_tilemap_buffer+4,X
    RTS

  .checked
    ; On
    %a16()
    LDA #$244F : STA !ram_tilemap_buffer+2,X
    LDA #$244E : STA !ram_tilemap_buffer+4,X
    RTS
}

draw_toggle_inverted:
{
    ; grab the memory address (long)
    LDA [$44] : INC $44 : INC $44 : STA $48
    LDA [$44] : INC $44 : STA $4A

    ; grab the toggle value
    LDA [$44] : AND #$00FF : INC $44 : STA $3C

    ; increment past JSL
    INC $44 : INC $44

    ; Draw the text
    %item_index_to_vram_index()
    PHX : JSR cm_draw_text : PLX

    ; Set position for ON/OFF
    TXA : CLC : ADC #$002C : TAX

    %a8()
    ; set palette
    LDA $3E
    STA !ram_tilemap_buffer+1,X
    STA !ram_tilemap_buffer+3,X
    STA !ram_tilemap_buffer+5,X

    ; grab the value at that memory address
    LDA [$48] : CMP $3C : BNE .checked

    ; Off
    %a16()
    LDA #$244F : STA !ram_tilemap_buffer+0,X
    LDA #$243F : STA !ram_tilemap_buffer+2,X
    LDA #$243F : STA !ram_tilemap_buffer+4,X
    RTS

  .checked
    ; On
    %a16()
    LDA #$244F : STA !ram_tilemap_buffer+2,X
    LDA #$244E : STA !ram_tilemap_buffer+4,X
    RTS
}

draw_toggle_bit:
{
    ; grab the memory address (long)
    LDA [$44] : INC $44 : INC $44 : STA $48
    LDA [$44] : INC $44 : STA $4A

    ; grab bitmask
    LDA [$44] : INC $44 : INC $44 : STA $3C

    ; increment past JSL
    INC $44 : INC $44

    ; Draw the text
    %item_index_to_vram_index()
    PHX : JSR cm_draw_text : PLX

    ; Set position for ON/OFF
    TXA : CLC : ADC #$002C : TAX

    ; grab the value at that memory address
    LDA [$48] : AND $3C : BNE .checked

    ; Off
    LDA #$244F : STA !ram_tilemap_buffer+0,X
    LDA #$243F : STA !ram_tilemap_buffer+2,X
    LDA #$243F : STA !ram_tilemap_buffer+4,X
    RTS

  .checked
    ; On
    %a16()
    LDA #$244F : STA !ram_tilemap_buffer+2,X
    LDA #$244E : STA !ram_tilemap_buffer+4,X
    RTS
}

draw_toggle_bit_inverted:
{
    ; grab the memory address (long)
    LDA [$44] : INC $44 : INC $44 : STA $48
    LDA [$44] : INC $44 : STA $4A

    ; grab bitmask
    LDA [$44] : INC $44 : INC $44 : STA $3C

    ; increment past JSL
    INC $44 : INC $44

    ; Draw the text
    %item_index_to_vram_index()
    PHX : JSR cm_draw_text : PLX

    ; Set position for ON/OFF
    TXA : CLC : ADC #$002C : TAX

    ; grab the value at that memory address
    LDA [$48] : AND $3C : BEQ .checked

    ; Off
    LDA #$244F : STA !ram_tilemap_buffer+0,X
    LDA #$243F : STA !ram_tilemap_buffer+2,X
    LDA #$243F : STA !ram_tilemap_buffer+4,X
    RTS

  .checked
    ; On
    %a16()
    LDA #$244F : STA !ram_tilemap_buffer+2,X
    LDA #$244E : STA !ram_tilemap_buffer+4,X
    RTS
}

draw_jsl_submenu:
draw_jsl:
{
    ; skip JSL address
    INC $44 : INC $44

    ; skip argument
    INC $44 : INC $44

    ; draw text normally
    %item_index_to_vram_index()
    JSR cm_draw_text
    RTS
}

draw_numfield_8bit:
draw_numfield:
{
    ; grab the memory address (long)
    LDA [$44] : INC $44 : INC $44 : STA $48
    LDA [$44] : INC $44 : STA $4A

    ; skip bounds and increment values
    INC $44 : INC $44 : INC $44 : INC $44

    ; increment past JSL
    INC $44 : INC $44

    ; Draw the text
    %item_index_to_vram_index()
    PHX : JSR cm_draw_text : PLX

    ; set position for the number
    TXA : CLC : ADC #$002C : TAX

    LDA [$48] : AND #$00FF : JSR cm_hex2dec

    ; Clear out the area (black tile)
    LDA #$281F : STA !ram_tilemap_buffer+0,X
                 STA !ram_tilemap_buffer+2,X
                 STA !ram_tilemap_buffer+4,X

    ; Set palette
    %a8()
    LDA.b #$20 : ORA $3E : STA $3F
    LDA.b #$30 : STA $3E

    ; Draw numbers
    %a16()
    ; ones
    LDA !ram_hex2dec_third_digit : CLC : ADC $3E : STA !ram_tilemap_buffer+4,X

    ; tens
    LDA !ram_hex2dec_second_digit : ORA !ram_hex2dec_first_digit : BEQ .done
    LDA !ram_hex2dec_second_digit : CLC : ADC $3E : STA !ram_tilemap_buffer+2,X

    LDA !ram_hex2dec_first_digit : BEQ .done
    CLC : ADC $3E : STA !ram_tilemap_buffer,X

  .done
    RTS
}

draw_numfield_decimal:
{
    ; grab the memory address (long)
    LDA [$44] : INC $44 : INC $44 : STA $48
    LDA [$44] : INC $44 : STA $4A

    ; skip bounds and increment values
    INC $44 : INC $44 : INC $44 : INC $44

    ; increment past JSL
    INC $44 : INC $44

    ; Draw the text
    %item_index_to_vram_index()
    PHX : JSR cm_draw_text : PLX

    ; set position for the number
    TXA : CLC : ADC #$002E : TAX

    ; Clear out the area (black tile)
    LDA #$281F : STA !ram_tilemap_buffer+0,X
                 STA !ram_tilemap_buffer+2,X

    ; Set palette
    %a8()
    LDA.b #$20 : ORA $3E : STA $3F
    LDA.b #$30 : STA $3E

    LDA [$48] : TAY
    %a16()

    ; Draw numbers
    ; ones
    AND #$000F : CLC : ADC $3E : STA !ram_tilemap_buffer+2,X

    ; tens
    TYA : AND #$00F0 : BEQ .done
    LSR #4 : CLC : ADC $3E : STA !ram_tilemap_buffer,X

  .done
    RTS
}

draw_numfield_word:
{
    ; grab the memory address (long)
    LDA [$44] : INC $44 : INC $44 : STA $48
    LDA [$44] : INC $44 : STA $4A

    ; skip bounds and increment values
    INC $44 : INC $44 : INC $44 : INC $44
    INC $44 : INC $44 : INC $44 : INC $44

    ; increment past JSL
    INC $44 : INC $44

    ; Draw the text
    %item_index_to_vram_index()
    PHX : JSR cm_draw_text : PLX

    ; set position for the number
    TXA : CLC : ADC #$002A : TAX

    LDA [$48] : JSR cm_hex2dec

    ; Clear out the area (black tile)
    LDA #$281F : STA !ram_tilemap_buffer+0,X
                 STA !ram_tilemap_buffer+2,X
                 STA !ram_tilemap_buffer+4,X
                 STA !ram_tilemap_buffer+6,X

    ; Set palette
    %a8()
    LDA.b #$20 : ORA $3E : STA $3F
    LDA.b #$30 : STA $3E

    ; Draw numbers
    %a16()
    ; ones
    LDA !ram_hex2dec_third_digit : CLC : ADC $3E : STA !ram_tilemap_buffer+6,X

    ; tens
    LDA !ram_hex2dec_second_digit : ORA !ram_hex2dec_first_digit
    ORA !ram_hex2dec_rest : BEQ .done
    LDA !ram_hex2dec_second_digit : CLC : ADC $3E : STA !ram_tilemap_buffer+4,X

    LDA !ram_hex2dec_first_digit : ORA !ram_hex2dec_rest : BEQ .done
    LDA !ram_hex2dec_first_digit : CLC : ADC $3E : STA !ram_tilemap_buffer+2,X

    LDA !ram_hex2dec_rest : BEQ .done
    CLC : ADC $3E : STA !ram_tilemap_buffer,X

  .done
    RTS
}

draw_numfield_sound:
draw_numfield_hex:
{
    ; grab the memory address (long)
    LDA [$44] : INC $44 : INC $44 : STA $48
    LDA [$44] : INC $44 : STA $4A

    ; skip bounds and increment values
    INC $44 : INC $44 : INC $44 : INC $44

    ; increment past JSL
    INC $44 : INC $44

    ; Draw the text
    %item_index_to_vram_index()
    PHX : JSR cm_draw_text : PLX

    ; set position for the number
    TXA : CLC : ADC #$002E : TAX

    LDA [$48] : AND #$00FF : STA $38

    ; Clear out the area (black tile)
    LDA #$281F : STA !ram_tilemap_buffer+0,X
                 STA !ram_tilemap_buffer+2,X

    ; Draw numbers
    ; (00X0)
    LDA $38 : AND #$00F0 : LSR #3 : TAY
    LDA.w HexMenuGFXTable,Y : STA !ram_tilemap_buffer,X
    
    ; (000X)
    LDA $38 : AND #$000F : ASL : TAY
    LDA.w HexMenuGFXTable,Y : STA !ram_tilemap_buffer+2,X

  .done
    RTS
}

draw_numfield_color:
{
    ; grab the memory address (long)
    LDA [$44] : INC $44 : INC $44 : STA $48
    LDA [$44] : INC $44 : STA $4A

    ; increment past JSL
    INC $44 : INC $44

    ; Draw the text
    %item_index_to_vram_index()
    PHX : JSR cm_draw_text : PLX

    ; set position for the number
    TXA : CLC : ADC #$002E : TAX

    LDA [$48] : AND #$00FF : STA $38

    ; Clear out the area (black tile)
    LDA #$281F : STA !ram_tilemap_buffer+0,X
                 STA !ram_tilemap_buffer+2,X

    ; Draw numbers
    ; (00X0)
    LDA $38 : AND #$001E : TAY
    LDA.w HexMenuGFXTable,Y : STA !ram_tilemap_buffer,X

    ; (000X)
    LDA $38 : AND #$0001 : ASL #4 : STA $3E
    LDA $38 : AND #$001C : LSR : CLC : ADC $3E : TAY
    LDA.w HexMenuGFXTable,Y : STA !ram_tilemap_buffer+2,X

  .done
    RTS
}

draw_numfield_hex_word:
{
    ; grab the memory address (long)
    LDA [$44] : INC $44 : INC $44 : STA $48
    LDA [$44] : INC $44 : STA $4A

    ; Draw the text
    %item_index_to_vram_index()
    PHX : JSR cm_draw_text : PLX

    ; set position for the number
    TXA : CLC : ADC #$002C : TAX

    LDA [$48] : STA $38

    ; Clear out the area (black tile)
    LDA #$281F : STA !ram_tilemap_buffer+0,X
                 STA !ram_tilemap_buffer+2,X
                 STA !ram_tilemap_buffer+4,X
                 STA !ram_tilemap_buffer+6,X

    ; Draw numbers
    ; (X000)
    LDA $38 : AND #$F000 : XBA : LSR #3 : TAY
    LDA.w HexMenuGFXTable,Y : STA !ram_tilemap_buffer,X
    
    ; (0X00)
    LDA $38 : AND #$0F00 : XBA : ASL : TAY
    LDA.w HexMenuGFXTable,Y : STA !ram_tilemap_buffer+2,X

    ; (00X0)
    LDA $38 : AND #$00F0 : LSR #3 : TAY
    LDA.w HexMenuGFXTable,Y : STA !ram_tilemap_buffer+4,X
    
    ; (000X)
    LDA $38 : AND #$000F : ASL : TAY
    LDA.w HexMenuGFXTable,Y : STA !ram_tilemap_buffer+6,X

  .done
    RTS
}

draw_choice:
{
    ; $44[0x3] = address
    ; $48[0x3] = JSL target

    ; grab the memory address (long)
    LDA [$44] : INC $44 : INC $44 : STA $48
    LDA [$44] : INC $44 : STA $4A

    ; grab JSL target
    ; why are we doing this? maybe copy/paste fluff
    LDA [$44] : INC $44 : INC $44 : STA $3C

    ; Draw the text first
    %item_index_to_vram_index()
    PHX : JSR cm_draw_text : PLX

    ; set position for choice
    TXA : CLC : ADC #$001C : TAX

    LDY #$0000
    LDA #$0000

    ; grab the value at that memory address
    LDA [$48] : TAY

    ; find the correct text that should be drawn (the selected choice)
    INY : INY ; uh, skipping the first text that we already drew..
  .loop_choices
    DEY : BEQ .found

  .loop_text
    LDA [$44] : %a16() : INC $44 : %a8()
    CMP.b #$FF : BEQ .loop_choices
    BRA .loop_text

  .found
    %a16()
    JSR cm_draw_text

    %a16()
    RTS
}

draw_ctrl_shortcut:
{
    LDA [$44] : INC $44 : INC $44 : STA $48
    LDA [$44] : STA $4A : INC $44

    %item_index_to_vram_index()
    PHX
    JSR cm_draw_text
    PLA : CLC : ADC #$0022 : TAX

    LDA [$48]
    JSR menu_ctrl_input_display

    RTS
}

draw_controller_input:
{
    ; grab the memory address (long)
    LDA [$44] : INC $44 : INC $44 : STA $48
    STA !ram_cm_ctrl_assign
    LDA [$44] : INC $44 : STA $4A

    ; grab JSL target
    ; why are we doing this? maybe copy/paste fluff
    LDA [$44] : INC $44 : INC $44 : STA $3C

    ; skip JSL argument
    INC $44 : INC $44

    ; Draw the text
    %item_index_to_vram_index()
    PHX : JSR cm_draw_text : PLX

    ; set position for the input
    TXA : CLC : ADC #$0020 : TAX

    LDA ($48) : AND #$E0F0 : BEQ .unbound

    ; determine which input to draw, using Y to refresh A
    TAY : AND #$0080 : BEQ + : LDY #$0000 : BRA .draw
+   TYA : AND #$8000 : BEQ + : LDY #$0002 : BRA .draw
+   TYA : AND #$0040 : BEQ + : LDY #$0004 : BRA .draw
+   TYA : AND #$4000 : BEQ + : LDY #$0006 : BRA .draw
+   TYA : AND #$0020 : BEQ + : LDY #$0008 : BRA .draw
+   TYA : AND #$0010 : BEQ + : LDY #$000A : BRA .draw
+   TYA : AND #$2000 : BEQ .unbound : LDY #$000C

  .draw
    LDA.w CtrlMenuGFXTable,Y : STA !ram_tilemap_buffer,X
    RTS

  .unbound
    LDA #$281F : STA !ram_tilemap_buffer,X
    RTS

CtrlMenuGFXTable:
    ;  A      B      X      Y      L      R      Select
    ;  0080   8000   0040   4000   0020   0010   2000
    dw $288F, $2887, $288E, $2886, $288D, $288C, $2885
}

cm_draw_text:
{
    ; X = pointer to tilemap area (STA !ram_tilemap_buffer,X)
    ; $44[0x4] = address
    %a8()
    LDY #$0000
    ; terminator
    LDA [$44],Y : INY : CMP #$FF : BEQ .end
    ; ORA with palette info
    ORA $3E : STA $3E

  .loop
    LDA [$44],Y : CMP #$FF : BEQ .end       ; terminator
    STA !ram_tilemap_buffer,X : INX         ; tile
    LDA $3E : STA !ram_tilemap_buffer,X : INX   ; palette
    INY : JMP .loop

  .end
    %a16()
    RTS
}

; --------------
; Input Display
; --------------

menu_ctrl_input_display:
{
    ; X = pointer to tilemap area (STA !ram_tilemap_buffer,X)
    ; A = Controller word
    JSR menu_ctrl_clear_input_display

    XBA
    LDY #$0000
  .loop
    PHA
    BIT #$0001 : BEQ .no_draw

    TYA : CLC : ADC #$0080
    XBA : ORA $3E : XBA
    STA !ram_tilemap_buffer,X : INX #2

  .no_draw
    PLA
    INY : LSR : BNE .loop

  .done
    RTS
}


menu_ctrl_clear_input_display:
{
    ; X = pointer to tilemap area
    PHA
    LDA #$281F
    STA !ram_tilemap_buffer+0,X
    STA !ram_tilemap_buffer+2,X
    STA !ram_tilemap_buffer+4,X
    STA !ram_tilemap_buffer+6,X
    STA !ram_tilemap_buffer+8,X
    STA !ram_tilemap_buffer+10,X
    STA !ram_tilemap_buffer+12,X
    STA !ram_tilemap_buffer+14,X
    STA !ram_tilemap_buffer+16,X
    PLA
    RTS
}


; ---------
; Logic
; ---------

cm_loop:
{
    %a8()
    JSL wait_for_NMI  ; Wait for next frame
    LDA #$0F : STA $0F2100
    %a16()

    JSL cm_handle_sfx

    LDA !ram_cm_leave : BEQ +
    RTS ; Exit menu loop

+   LDA !ram_cm_ctrl_mode : BEQ +
    JSR cm_ctrl_mode
    BRA cm_loop

+   JSR cm_get_inputs : STA !ram_cm_controller : BEQ cm_loop

    BIT #$0080 : BNE .pressedA
    BIT #$8000 : BNE .pressedB
    BIT #$0040 : BNE .pressedX
    BIT #$4000 : BNE .pressedY
    BIT #$2000 : BNE .pressedSelect
    BIT #$1000 : BNE .pressedStart
    BIT #$0800 : BNE .pressedUp
    BIT #$0400 : BNE .pressedDown
    BIT #$0100 : BNE .pressedRight
    BIT #$0200 : BNE .pressedLeft
    BIT #$0020 : BNE .pressedL
    BIT #$0010 : BNE .pressedR
    BRA cm_loop

  .firstLoop
    JSL cm_draw
    JSL wait_for_NMI  ; Wait for next frame
    BRA cm_loop

  .pressedB
    JSL cm_go_back
    JSL cm_calculate_max
    BRA .redraw

  .pressedDown
    LDA #$0002
    JSR cm_move
    BRA .redraw

  .pressedUp
    LDA #$FFFE
    JSR cm_move
    BRA .redraw

  .pressedA
  .pressedY
  .pressedX
  .pressedLeft
  .pressedRight
    JSR cm_execute
    BRA .redraw

  .pressedStart
  .pressedSelect
    LDA #$0001 : STA !ram_cm_leave
    JMP cm_loop
    BRA .redraw

  .pressedL
    LDX !ram_cm_stack_index
    LDA #$0000 : STA !ram_cm_cursor_stack,X
    %sfxmove()
    BRA .redraw

  .pressedR
    LDX !ram_cm_stack_index
    LDA !ram_cm_cursor_max : DEC #2 : STA !ram_cm_cursor_stack,X
    %sfxmove()

  .redraw
    JSL cm_draw
    JMP cm_loop
}

cm_ctrl_mode:
{
    JSL MenuReadControllers
    LDA !AL_CONTROLLER_PRI

    %a8() : LDA #$28 : STA $3E : %a16()

    LDA !AL_CONTROLLER_PRI : BEQ .clear_and_draw
    CMP !ram_cm_ctrl_last_input : BNE .clear_and_draw

    ; Holding an input for more than one second
    LDA !ram_cm_ctrl_timer : INC : STA !ram_cm_ctrl_timer : CMP.w #0060 : BNE .next_frame

    LDA !AL_CONTROLLER_PRI : STA [$38]
    PHP : %a8()
    LDA #$1D : JSL !Play_SFX
    PLP
    BRA .exit

  .clear_and_draw
    STA !ram_cm_ctrl_last_input
    LDA #$0000 : STA !ram_cm_ctrl_timer

    ; Put text cursor in X
    LDX !ram_cm_stack_index
    LDA !ram_cm_cursor_stack,X : ASL #5 : CLC : ADC #$0168 : TAX

    ; Input display
    LDA !AL_CONTROLLER_PRI
    JSR menu_ctrl_input_display
    JSL NMI_tilemap_transfer

  .next_frame
    RTS

  .exit
    LDA #$0000
    STA !ram_cm_ctrl_last_input
    STA !ram_cm_ctrl_mode
    STA !ram_cm_ctrl_timer
    JSL cm_draw
    RTS
}

cm_previous_menu:
{
    JSL cm_go_back
    JSL cm_calculate_max
    RTL
}

cm_go_back:
{
    ; make sure next time we go to a submenu, we start on the first line.
    LDX !ram_cm_stack_index
    LDA #$0000 : STA !ram_cm_cursor_stack,X

    ; make sure we dont set a negative number
    LDA !ram_cm_stack_index : DEC : DEC : BPL .done

    ; leave menu 
    LDA #$0001 : STA !ram_cm_leave

    LDA #$0000
  .done
    STA !ram_cm_stack_index    
    LDA !ram_cm_stack_index
    BNE +
    LDA.l #MainMenu>>16       ; Reset submenu bank when back at main menu
    STA !ram_cm_menu_bank
  +
  .end
    %sfxgoback()
    RTL
}

cm_calculate_max:
{
    LDX !ram_cm_stack_index
    LDA !ram_cm_menu_stack,X : STA $40
    LDA !ram_cm_menu_bank : STA $42

    LDX #$0000
  .loop
    LDA [$40] : BEQ .done
    INC $40 : INC $40
    INX #2
    BRA .loop

  .done
    TXA : STA !ram_cm_cursor_max
    RTL
}

cm_get_inputs:
{
    ; Make sure we don't read joysticks twice in the same frame
;    LDA !AL_NMI_COUNTER : CMP !ram_cm_input_counter : PHP : STA !ram_cm_input_counter : PLP : BNE +

    JSL MenuReadControllers

+   LDA !AL_CONTROLLER_PRI_NEW : BEQ .check_holding

    ; Initial delay of 15 frames
    LDA #$000E : STA !ram_cm_input_timer

    ; Return the new input
    LDA !AL_CONTROLLER_PRI
    RTS

  .check_holding
    ; Check if we're holding the dpad
    LDA !AL_CONTROLLER_PRI : AND #$0F00 : BEQ .noinput

    ; Decrement delay timer and check if it's zero
    LDA !ram_cm_input_timer : DEC : STA !ram_cm_input_timer : BNE .noinput

    ; Set new delay to two frames and return the input we're holding
    LDA #$0002 : STA !ram_cm_input_timer
    LDA !AL_CONTROLLER_PRI : AND #$4F00 : ORA #$0001
    RTS

  .noinput
    LDA #$0000
    RTS
}

cm_move:
{
    STA $38
    LDX !ram_cm_stack_index
    CLC : ADC !ram_cm_cursor_stack,X : BPL .positive
    LDA !ram_cm_cursor_max : DEC #2 : BRA .inBounds

  .positive
    CMP !ram_cm_cursor_max : BNE .inBounds
    LDA #$0000

  .inBounds
    STA !ram_cm_cursor_stack,X : TAY

    ; check for blank menu line ($FFFF)
    LDA [$40],Y : CMP #$FFFF : BNE .end

    LDA $38 : BRA cm_move

  .end
    %sfxmove()
    RTS
}

MenuReadControllers:
{
    PHP : %ai8()

    ; loop until autojoy flag is pushed into carry
-   LDA $4212 : LSR : BCS -

    LDX #$03
-   LDA !AL_CONTROLLER_PRI,X : EOR #$FF : AND $4218,X : STA !AL_CONTROLLER_PRI_NEW,X
    LDA $4218,X : STA !AL_CONTROLLER_PRI,X
    DEX : BPL -
    PLP
    RTL
}


; --------
; Execute
; --------

cm_execute:
{
    ; $40 = submenu item
    LDX !ram_cm_stack_index
    LDA !ram_cm_menu_stack,X : STA $40
    LDA !ram_cm_menu_bank : STA $42
    LDA !ram_cm_cursor_stack,X : TAY
    LDA [$40],Y : STA $40

    ; Increment past the action index
    LDA [$40] : INC $40 : INC $40 : TAX

    ; Safety net incase blank line selected
    CPX #$FFFF : BEQ +

    ; Execute action
    JSR (cm_execute_action_table,X)
+   RTS
}

cm_execute_action_table:
    dw execute_toggle
    dw execute_toggle_bit
    dw execute_jsl
    dw execute_numfield
    dw execute_choice
    dw execute_ctrl_shortcut
    dw execute_numfield_hex
    dw execute_numfield_word
    dw execute_toggle
    dw execute_numfield_color
    dw execute_numfield_word
    dw execute_numfield_sound
    dw execute_controller_input
    dw execute_toggle_bit
    dw execute_jsl_submenu
    dw execute_numfield_8bit
    dw execute_numfield_decimal

execute_toggle:
{
    ; Grab address
    LDA [$40] : INC $40 : INC $40 : STA $44
    LDA [$40] : INC $40 : STA $46

    ; Load which bit(s) to toggle
    LDA [$40] : INC $40 : AND #$00FF : STA $48

    ; Grab JSL target
    LDA [$40] : INC $40 : INC $40 : STA $38

    %a8()
    LDA [$44] : CMP $48 : BEQ .toggleOff

    LDA $48 : STA [$44]
    BRA .jsl

  .toggleOff
    LDA #$00 : STA [$44]

  .jsl
    %a16()
    LDA $38 : BEQ .end

    ; Set return address for indirect JSL
    LDA !ram_cm_menu_bank : STA $3A
    PHK : PEA .end-1

    LDA [$44]
    LDX #$0000
    JML [$0038]

  .end
    %ai16()
    %sfxtoggle()
    RTS
}

execute_toggle_bit:
{
    ; Load the address
    LDA [$40] : INC $40 : INC $40 : STA $44
    LDA [$40] : INC $40 : STA $46

    ; Load which bit(s) to toggle
    LDA [$40] : INC $40 : INC $40 : STA $48

    ; Load JSL target
    LDA [$40] : INC $40 : INC $40 : STA $38

    ; Toggle the bit
    LDA [$44] : EOR $48 : STA [$44]

    LDA $38 : BEQ .end

    ; Set return address for indirect JSL
    LDA !ram_cm_menu_bank : STA $3A
    PHK : PEA .end-1

    LDA [$44]
    LDX #$0000
    JML [$0038]

  .end
    %ai16()
    %sfxtoggle()
    RTS
}

execute_jsl_submenu:
{
    ; <, > and X should do nothing here
    ; also ignore input held flag
    LDA !ram_cm_controller : BIT #$0341 : BNE .end

    ; $44 = JSL target
    LDA [$40] : INC $40 : INC $40 : STA $38

    ; Set bank of action_submenu
    ; instead of the menu we're jumping to
    LDA.l #action_submenu>>16 : STA $3A

    ; Set return address for indirect JSL
    PHK : PEA .end-1

    ; Y = Argument
    LDA [$40] : TAY

    LDX #$0000
    JML [$0038]

  .end
    %ai16()
    RTS
}

execute_jsl:
{
    ; <, > and X should do nothing here
    ; also ignore input held flag
    LDA !ram_cm_controller : BIT #$0341 : BNE .end

    ; $44 = JSL target
    LDA [$40] : INC $40 : INC $40 : STA $38

    ; Set return address for indirect JSL
    LDA !ram_cm_menu_bank : STA $3A
    PHK : PEA .end-1

    ; Y = Argument
    LDA [$40] : TAY

    LDX #$0000
    JML [$0038]

  .end
    %ai16()
    RTS
}

execute_numfield_hex:
execute_numfield:
{
    ; $44[0x3] = memory address to manipulate
    ; $48[0x1] = min
    ; $4A[0x1] = max
    ; $3C[0x1] = increment (normal)
    ; $3C[0x1] = increment (input held)
    ; $38[0x3] = JSL target
    LDA [$40] : INC $40 : INC $40 : STA $44
    LDA [$40] : INC $40 : STA $46

    LDA [$40] : INC $40 : AND #$00FF : STA $48
    LDA [$40] : INC $40 : AND #$00FF : INC : STA $4A ; INC for convenience

    LDA !ram_cm_controller : BIT #$0001 : BNE .input_held
    LDA [$40] : INC $40 : INC $40 : AND #$00FF : STA $3C
    BRA .load_jsl_target

  .input_held
    INC $40 : LDA [$40] : INC $40 : AND #$00FF : STA $3C

  .load_jsl_target
    LDA [$40] : INC $40 : INC $40 : STA $38

    LDA !ram_cm_controller : BIT #$0200 : BNE .pressed_left

    LDA [$44] : CLC : ADC $3C

    CMP $4A : BCS .set_to_min

    STA [$44] : BRA .jsl

  .pressed_left
    LDA [$44] : SEC : SBC $3C
    CMP $48 : BMI .set_to_max

    CMP $4A : BCS .set_to_max

    STA [$44] : BRA .jsl

  .set_to_min
    LDA $48 : STA [$44] : CLC : BRA .jsl

  .set_to_max
    LDA $4A : DEC : STA [$44] : CLC

  .jsl
    LDA $38 : BEQ .end

    ; Set return address for indirect JSL
    LDA !ram_cm_menu_bank : STA $3A
    PHK : PEA .end-1

    LDA [$44]
    LDX #$0000
    JML [$0038]

  .end
    %ai16()
    %sfxnumber()
    RTS
}

execute_numfield_8bit:
{
    ; $44[0x3] = memory address to manipulate
    ; $48[0x1] = min
    ; $4A[0x1] = max
    ; $3C[0x1] = increment (normal)
    ; $3C[0x1] = increment (input held)
    ; $38[0x3] = JSL target
    LDA [$40] : INC $40 : INC $40 : STA $44
    LDA [$40] : INC $40 : STA $46

    LDA [$40] : INC $40 : AND #$00FF : STA $48
    LDA [$40] : INC $40 : AND #$00FF : INC : STA $4A ; INC for convenience

    LDA !ram_cm_controller : BIT #$0001 : BNE .input_held
    LDA [$40] : INC $40 : INC $40 : AND #$00FF : STA $3C
    BRA .load_jsl_target

  .input_held
    INC $40 : LDA [$40] : INC $40 : AND #$00FF : STA $3C

  .load_jsl_target
    LDA [$40] : INC $40 : INC $40 : STA $38

    LDA !ram_cm_controller : BIT #$0200 : BNE .pressed_left

    LDA [$44] : AND #$00FF : CLC : ADC $3C

    CMP $4A : BCS .set_to_min

    PHP : %a8() : STA [$44] : PLP
    BRA .jsl

  .pressed_left
    LDA [$44] : AND #$00FF : SEC : SBC $3C
    CMP $48 : BMI .set_to_max

    CMP $4A : BCS .set_to_min

    PHP : %a8() : STA [$44] : PLP
    BRA .jsl

  .set_to_min
    LDA $48
    PHP : %a8() : STA [$44] : PLP
    CLC : BRA .jsl

  .set_to_max
    LDA $4A : DEC
    PHP : %a8() : STA [$44] : PLP
    CLC

  .jsl
    LDA $38 : BEQ .end

    ; Set return address for indirect JSL
    LDA !ram_cm_menu_bank : STA $3A
    PHK : PEA .end-1

    LDA [$44] : AND #$00FF
    LDX #$0000
    JML [$0038]

  .end
    %ai16()
    %sfxnumber()
    RTS
}

execute_numfield_decimal:
{
    ; $44[0x3] = memory address to manipulate
    ; $48[0x1] = min
    ; $4A[0x1] = max
    ; $3C[0x1] = increment (normal)
    ; $3C[0x1] = increment (input held)
    ; $38[0x3] = JSL target
    LDA [$40] : INC $40 : INC $40 : STA $44
    LDA [$40] : INC $40 : STA $46

    LDA [$40] : INC $40 : AND #$00FF : STA $48
    LDA [$40] : INC $40 : AND #$00FF : INC : STA $4A ; INC for convenience

    LDA !ram_cm_controller : BIT #$0001 : BNE .input_held
    LDA [$40] : INC $40 : INC $40 : AND #$00FF : STA $3C
    BRA .inc_or_dec

  .input_held
    INC $40 : LDA [$40] : INC $40 : AND #$00FF : STA $3C

  .inc_or_dec
    LDA !ram_cm_controller : BIT #$0200 : BNE .pressed_left
    LDA [$44] : AND #$00FF : JSR cm_dec2hex
    
    CLC : ADC $3C
    CMP $4A : BCS .set_to_min

    JSR cm_hex2dec
    LDA !ram_hex2dec_second_digit : ASL #4
    ORA !ram_hex2dec_third_digit

    STA [$44] : BRA .jsl

  .pressed_left
    LDA [$44] : AND #$00FF : JSR cm_dec2hex
    
    SEC : SBC $3C : CMP $48 : BMI .set_to_max
    CMP $4A : BCS .set_to_max

    JSR cm_hex2dec
    LDA !ram_hex2dec_second_digit : ASL #4
    ORA !ram_hex2dec_third_digit

    STA [$44] : BRA .jsl

  .set_to_min
    LDA $48 : JSR cm_hex2dec
    LDA !ram_hex2dec_second_digit : ASL #4
    ORA !ram_hex2dec_third_digit

    STA [$44] : BRA .jsl

  .set_to_max
    LDA $4A : DEC : JSR cm_hex2dec
    LDA !ram_hex2dec_second_digit : ASL #4
    ORA !ram_hex2dec_third_digit

    STA [$44]

  .jsl
    LDA [$40] : INC $40 : INC $40 : STA $38
    LDA $38 : BEQ .end

    ; Set return address for indirect JSL
    LDA !ram_cm_menu_bank : STA $3A
    PHK : PEA .end-1

    LDA [$44]
    LDX #$0000
    JML [$0038]

  .end
    %ai16()
    %sfxnumber()
    RTS
}

execute_numfield_word:
{
    ; $44[0x3] = memory address to manipulate
    ; $48[0x2] = min
    ; $4A[0x2] = max
    ; $3C[0x2] = increment (normal)
    ; $3C[0x2] = increment (input held)
    ; $38[0x3] = JSL target
    LDA [$40] : INC $40 : INC $40 : STA $44
    LDA [$40] : INC $40 : STA $46

    LDA [$40] : INC $40 : INC $40 : STA $48
    LDA [$40] : INC $40 : INC $40 : INC : STA $4A ; INC for convenience

    LDA !ram_cm_controller : BIT #$0001 : BNE .input_held
    LDA [$40] : INC $40 : INC $40 : INC $40 : INC $40 : STA $3C
    BRA .load_jsl_target

  .input_held
    INC $40 : INC $40 : LDA [$40] : INC $40 : INC $40 : STA $3C

  .load_jsl_target
    LDA [$40] : INC $40 : INC $40 : STA $38

    LDA !ram_cm_controller : BIT #$0200 : BNE .pressed_left

    LDA [$44] : CLC : ADC $3C

    CMP $4A : BCS .set_to_min

    STA [$44] : BRA .jsl

  .pressed_left
    LDA [$44] : SEC : SBC $3C : BMI .set_to_max

    CMP $4A : BCS .set_to_max

    STA [$44] : BRA .jsl

  .set_to_min
    LDA $48 : STA [$44] : CLC : BRA .jsl

  .set_to_max
    LDA $4A : DEC : STA [$44] : CLC

  .jsl
    LDA $38 : BEQ .end

    ; Set return address for indirect JSL
    LDA !ram_cm_menu_bank : STA $3A
    PHK : PEA .end-1

    LDA [$44]
    LDX #$0000
    JML [$0038]

  .end
    %ai16()
    %sfxnumber()
    RTS
}

execute_numfield_color:
{
    ; $44[0x3] = memory address to manipulate
    ; $38[0x3] = JSL target
    LDA [$40] : INC $40 : INC $40 : STA $44
    LDA [$40] : INC $40 : STA $46

    LDA [$40] : INC $40 : INC $40 : STA $38

    LDA !ram_cm_controller : BIT #$0200 : BNE .pressed_left

    LDA [$44] : INC : CMP #$0020 : BCS .set_to_min
    STA [$44] : LDA !ram_cm_controller : BIT !CTRL_LEFT : BEQ .jsl

    LDA [$44] : INC : CMP #$0020 : BCS .set_to_min
    STA [$44] : BRA .jsl

  .pressed_left
    LDA [$44] : DEC : CMP $48 : BMI .set_to_max
    STA [$44] : LDA !ram_cm_controller : BIT !CTRL_LEFT : BEQ .jsl

    LDA [$44] : DEC : BMI .set_to_max
    STA [$44] : BRA .jsl

  .set_to_min
    LDA #$0000 : STA [$44] : CLC : BRA .jsl

  .set_to_max
    LDA #$001F : STA [$44] : CLC

  .jsl
    LDA $38 : BEQ .end

    ; Set return address for indirect JSL
    LDA !ram_cm_menu_bank : STA $3A
    PHK : PEA .end-1

    LDA [$44]
    LDX #$0000
    JML [$0038]

  .end
    %ai16()
    %sfxnumber()
    RTS
}

execute_numfield_sound:
{
    ; $44[0x3] = memory address to manipulate
    ; $48[0x1] = min
    ; $4A[0x1] = max
    ; $3C[0x1] = increment
    ; $38[0x2] = JSR target
    LDA [$40] : INC $40 : INC $40 : STA $44
    LDA [$40] : INC $40 : STA $46

    LDA [$40] : INC $40 : AND #$00FF : STA $48
    LDA [$40] : INC $40 : AND #$00FF : INC : STA $4A ; INC for convenience
    LDA [$40] : INC $40 : AND #$00FF : STA $3C

    ; 4x scroll speed if Y held
    LDA !AL_CONTROLLER_PRI : AND #$4000 : BEQ +
    LDA $3C : ASL #2 : STA $3C

+   INC $40 : LDA [$40] : STA $38

    LDA !ram_cm_controller : BIT #$4000 : BNE .jsr ; check for Y pressed
    LDA !ram_cm_controller : BIT #$0200 : BNE .pressed_left

    LDA [$44] : CLC : ADC $3C
    CMP $4A : BCS .set_to_min
    STA [$44] : BRA .end

  .pressed_left
    LDA [$44] : SEC : SBC $3C : CMP $48 : BMI .set_to_max
    CMP $4A : BCS .set_to_max
    STA [$44] : BRA .end

  .set_to_min
    LDA $48 : STA [$44] : CLC : BRA .end

  .set_to_max
    LDA $4A : DEC : STA [$44] : CLC : BRA .end

  .jsr
    LDA $38 : BEQ .end

    ; Set return address for indirect JSL
    LDA !ram_cm_menu_bank : STA $3A
    PHK : PEA .end-1

    LDA [$44]
    LDX #$0000
    JML [$0038]

  .end
    %ai16()
    RTS
}

execute_numfield_hex_word:
{
    ; do nothing
    RTS
}

execute_choice:
{
    ; $44[0x3] = memory to manipulate
    ; $38[0x3] = JSL target
    %a16()
    LDA [$40] : INC $40 : INC $40 : STA $44
    LDA [$40] : INC $40 : STA $46

    LDA [$40] : INC $40 : INC $40 : STA $38

    ; we either increment or decrement
    LDA !ram_cm_controller : BIT #$0200 : BNE .pressed_left
    LDA [$44] : INC : BRA .bounds_check

  .pressed_left
    LDA [$44] : DEC

  .bounds_check
    TAX     ; X = new value
    LDY #$0000  ; Y will be set to max

    %a8()
  .loop_choices
    LDA [$40] : %a16() : INC $40 : %a8() : CMP.b #$FF : BEQ .loop_done

  .loop_text
    LDA [$40] : %a16() : INC $40 : %a8()
    CMP.b #$FF : BNE .loop_text
    INY : BRA .loop_choices

  .loop_done
    ; X = new value (might be out of bounds)
    ; Y = maximum + 2
    ; We need to make sure X is between 0-maximum.

    ; for convenience so we can use BCS. We do one more DEC in `.set_to_max`
    ; below, so we get the actual max.
    DEY

    %a16()
    TXA : BMI .set_to_max
    STY $4A
    CMP $4A : BCS .set_to_zero

    BRA .store

  .set_to_zero
    LDA #$0000 : BRA .store

  .set_to_max
    TYA : DEC

  .store
    STA [$44]

    LDA $38 : BEQ .end

    ; Set return address for indirect JSL
    LDA !ram_cm_menu_bank : STA $3A
    PHK : PEA .end-1

    LDA [$44]
    LDX #$0000
    JML [$0038]

  .end
    %ai16()
    %sfxtoggle()
    RTS
}

execute_ctrl_shortcut:
{
    ; < and > should do nothing here
    ; also ignore the input held flag
    LDA !ram_cm_controller : BIT #$0301 : BNE .end

    LDA [$40] : STA $38 : INC $40 : INC $40
    LDA [$40] : STA $3A : INC $40

    LDA !ram_cm_controller : BIT #$0040 : BNE .reset_shortcut

    LDA #$0001 : STA !ram_cm_ctrl_mode
    LDA #$0000 : STA !ram_cm_ctrl_timer
    RTS

  .reset_shortcut
    LDA.w #!sram_ctrl_menu : CMP $38 : BEQ .end
    %sfxfail()

    LDA #$0000 : STA [$38]

  .end
    %ai16()
    RTS
}

execute_controller_input:
{
    ; <, > and X should do nothing here
    ; also ignore input held flag
    LDA !ram_cm_controller : BIT #$0341 : BNE .end

    ; store long address as short address for now
    LDA [$40] : INC $40 : INC $40 : INC $40
    STA !ram_cm_ctrl_assign

    ; $44 = JSL target
    LDA [$40] : INC $40 : INC $40 : STA $38

    ; Set bank of action_submenu
    ; instead of the menu we're jumping to
    LDA.l #action_submenu>>16 : STA $3A

    ; Set return address for indirect JSL
    PHK : PEA .end-1

    ; Y = Argument
    LDA [$40] : TAY

    LDX #$0000
    JML [$0038]

  .end
    %ai16()
    RTS
}

cm_hex2dec:
{
    STA $4204

    %a8()
    LDA #$64 : STA $4206
    PHA : PLA : PHA : PLA

    %a16()
    LDA $4214 : STA !ram_hex2dec_rest
    LDA $4216 : STA $4204

    %a8()
    LDA #$0A : STA $4206
    PHA : PLA : PHA : PLA

    %a16()
    LDA $4214 : STA !ram_hex2dec_second_digit
    LDA $4216 : STA !ram_hex2dec_third_digit
    LDA !ram_hex2dec_rest : STA $4204

    %a8()
    LDA #$0A : STA $4206
    PHA : PLA : PHA : PLA

    %a16()
    LDA $4214 : STA !ram_hex2dec_rest
    LDA $4216 : STA !ram_hex2dec_first_digit

    RTS
}

cm_dec2hex:
{
    TAY
    %a8()
    AND #$F0 : LSR #4 : STA $4202
    LDA #$0A : STA $4203
    TYA : AND #$0F : CLC
    %a16()
    ADC $4216
    RTS
}


; ----------
; Resources
; ----------

HexMenuGFXTable:
    dw $2830, $2831, $2832, $2833, $2834, $2835, $2836, $2837, $2838, $2839, $283A, $283B, $283C, $283D, $283E, $283F

print pc, " menu end"