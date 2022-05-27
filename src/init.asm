
; Hijack boot routine to initialize practice hack RAM
org $80803A
    JSL InitRAM


org $BFE000
print pc, " init.asm start"

InitRAM:
{
    %ai16()

    ; Zero RAM from $7FFF00 onward for practice hack use
    LDA #$0000 : LDX !WRAM_SIZE-2
-   STA !WRAM_START,X : DEX #2 : BPL -

    ; check if SRAM has been initialized
    LDA !sram_initialized : CMP !SRAM_VERSION : BEQ .nonZeroValues
    CMP #$0003 : BEQ UpdateSRAM_version03
    CMP #$0004 : BEQ UpdateSRAM_version04
    JSR InitSRAM

  .nonZeroValues
    ; Non-zero default values
    LDA #$08E7 : STA !ram_watch_left   ; Al X Position
    LDA #$08EA : STA !ram_watch_right  ; Al Y Position

    LDA !sram_cheat_code : STA !AL_CheatCode

    %ai8()
    LDX #$01 : LDY #$0B ; overwritten code
    RTL
}

UpdateSRAM:
{
  .version03
    LDA #$01F4 : STA !sram_custom_checkpoint

  .version04
    ; addresses introduced in version 5 go here

    LDA !SRAM_VERSION : STA !sram_initialized
    JMP InitRAM_nonZeroValues
}

InitSRAM:
{
    ; menu settings
    LDA #$0000 : STA !sram_display_mode
    LDA #$0000 : STA !sram_infinite_hearts
    LDA #$0000 : STA !sram_infinite_apples
    LDA #$0000 : STA !sram_infinite_lives
    LDA #$0000 : STA !sram_infinite_credits
    LDA #$0001 : STA !sram_default_cape
    LDA #$0007 : STA !sram_default_hearts
    LDA #$0099 : STA !sram_default_apples
    LDA #$0003 : STA !sram_default_lives
    LDA #$0003 : STA !sram_default_credits
    LDA #$0000 : STA !sram_cheat_code
    LDA #$000C : STA !sram_customsfx_move
    LDA #$0006 : STA !sram_customsfx_toggle
    LDA #$003B : STA !sram_customsfx_number
    LDA #$000B : STA !sram_customsfx_confirm
    LDA #$0008 : STA !sram_customsfx_goback
    LDA #$0002 : STA !sram_customsfx_fail
    LDA #$004A : STA !sram_customsfx_reset
    LDA #$0001 : STA !sram_options_control_type
    LDA #$0000 : STA !sram_options_sound
    LDA #$0001 : STA !sram_stage_clear_skip
    LDA #$0001 : STA !sram_story_time_skip
    LDA #$0000 : STA !sram_disable_music
    LDA #$0001 : STA !sram_loadstate_music
    LDA #$0000 : STA !sram_loadstate_rng

    ; $30 bytes for Time Attack
    LDA #$7FFF : LDX #$002E
-   STA !sram_TimeAttack,X : DEX #2 : BPL -

    ; controller shortcuts
    LDA #$2000 : STA !sram_ctrl_menu  ; Select
    LDA #$6010 : STA !sram_ctrl_save_state  ; Select + Y + R
    LDA #$6020 : STA !sram_ctrl_load_state  ; Select + Y + L
    LDA #$0000 : STA !sram_ctrl_next_level
    LDA #$0000 : STA !sram_ctrl_kill_Aladdin
    LDA #$0000 : STA !sram_ctrl_refill
    LDA #$0000 : STA !sram_ctrl_update_timers
    LDA #$3030 : STA !sram_ctrl_soft_reset  ; Select + Start + L + R
    LDA #$0000 : STA !sram_ctrl_test_code

    LDA !SRAM_VERSION : STA !sram_initialized
    RTS

    ; Input Cheat Sheet  ($4218)
    ; $8000 = B
    ; $4000 = Y
    ; $2000 = Select
    ; $1000 = Start
    ; $0800 = Up
    ; $0400 = Down
    ; $0200 = Left
    ; $0100 = Right
    ; $0080 = A
    ; $0040 = X
    ; $0020 = L
    ; $0010 = R
}

print pc, " init.asm end"
warnpc $BFF000 ; save.asm
