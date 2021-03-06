
; -------
; Hijacks
; -------

; Hijack beginning of NMI (native) routine to maybe redraw HUD
; Start of NMI: count lag or short circuit NMI for menu
org $808118
    JML NMI_Hijack

; End of NMI: inc timers
org $80832C
    JML NMI_CountTimers


; End of fade-in loop: reset timers
org $819EB5
    JSL ResetTimers


; Set checkpoint: update HUD
org $81870E
    JML CheckPointReached
    NOP
CheckPointReached_return:

; Carpet ride progress check: update HUD
org $818787
    JML CheckCarpetRideComplete

; Level complete music call: update HUD
org $81CC01
    JSL UpdateTimersOnMusic

; Approaching Boss (Farouk) music call: update HUD
org $80A1B8
    JSL UpdateTimersOnMusic

; Approaching Jasmine music call: update HUD
org $80A225
    JSL UpdateTimersOnMusic

; Carpet awakens music call: update HUD
org $83EC87
    JSL UpdateTimersOnMusic

; Approaching lamp music call: update HUD
org $80A354
    JSL UpdateTimersOnMusic

; Approaching possessed Abu music call: update HUD
org $80A57D
    JSL UpdateTimersOnMusic

; Approaching Jafar music call: update HUD
org $80A607
    JSL UpdateTimersOnMusic

; Starting Snake fight music call: update HUD
org $849412
    JSL UpdateTimersOnMusic

; End Snake fight music call: update HUD
org $848B94
    JSL UpdateTimersOnMusic

; Aladdin Dies music call: update HUD
org $81DC0F
    JSL UpdateTimersOnMusic


; HUD tilemap transfer to VRAM
org $808469
    JML HUD_Tilemap_Transfers
HUD_Tilemap_Transfers_return:
    RTS


; ------------
; HUD Routines
; ------------

org $BF8000
print pc, " hudtimers.asm + huddisplay.asm start"

; Beginning of NMI (native)
NMI_Hijack:
{
    ; Check if a lag frame occured
    %a8()
    LDA !AL_FRAME_COUNTER : CMP !AL_RENDER_COUNTER : BEQ +
    STA !AL_RENDER_COUNTER
    LDA !ram_lag_counter : INC : STA !ram_lag_counter

    ; Jump to our "end of NMI" hijack if menu is open
+   LDA !ram_menu_active : BEQ +
    INC !AL_FRAME_COUNTER
    %ai16()
    JMP NMI_CountTimers_counter ; short circuit NMI

+   %ai16()
    CLD : LDA #$0000 ; overwritten code
    JML $80811C
}


; Increment timers and run HUD mode at end of NMI (native)
NMI_CountTimers:
{
    ; Run HUD Mode if enabled
    LDA !sram_display_mode : BEQ .counter
    ASL : TAX
    PHK : PLB ; set to bank of number gfx tables
    JSR (DisplayModeTable,X)
    %ai16()

  .counter
    ; Increment level timer
    LDA !ram_HUDTimer : INC : STA !ram_HUDTimer

  .done
    ; finish NMI from here
    PLY : PLX : PLD : PLB : PLA
    RTI
}


; Reset timer when loading a level
ResetTimers:
{
    LDA !AL_Level_index : CMP #$13 : BPL +

    %ai16()
    LDA #$0000
    STA !ram_HUDTimer : STA !ram_lag_counter
    STA !ram_HUD_1 : STA !ram_HUD_2
    STA !ram_HUD_3 : STA !ram_HUD_4
    INC !AL_HUD_tilemap_flag
    LDA !ram_TimeAttack_DoNotRecord : ORA !AL_checkpoint : STA !ram_TimeAttack_DoNotRecord
    JSL UpdateTimersLocal
    %ai8()

+   JML $81BD20 ; overwritten code, was JSL
}


; Update timers when setting 3-1 or 4-3 checkpoints
CheckPointReached:
{
    LDX #$01 : STX !AL_checkpoint
    LDX !AL_Level_index : CPX #$10 : BEQ + ; don't update on 6-3
    %ai16()
    JSL UpdateTimersLocal
+   %ai8()
    JML CheckPointReached_return
}


; Update timers when completing a carpet ride level
CheckCarpetRideComplete:
{
    BCC .complete
    JML $818778 ; return

  .complete
    PHD
    INC !AL_LevelCompleted
    JSL UpdateTimersLocal
    PLD
    JML $81879D ; JSR81879D_Inc2NextLevel
}


; Update timers on HUD on certain music changes
UpdateTimersOnMusic:
{
    PHA : %ai16() ; push 8bit A
    PHB : PHK : PLB ; set to bank of HexToNumberGFX tables

    ; Draw previous room frames
    LDA !ram_room_frames : ASL : TAX
    LDA HexToNumberGFX1,X : STA !ram_tilemap_buffer+$124
    LDA HexToNumberGFX2,X : STA !ram_tilemap_buffer+$126

    ; Draw previous room seconds
    LDA !ram_room_seconds : LDX #$011C : JSR Draw3

    JSR TimeAttack

    ; Divide timer by 60
    STZ $4205
    LDA !ram_HUDTimer : STA $4204
    STA !ram_HUDTimer_last
    %a8()
    LDA #$3C : STA $4206
    LDA !ram_update_HUD : ORA #$01 : STA !ram_update_HUD
    %a16()
;    PHA : PLA : PHA : PLA ; wait for CPU math, replaced with above
    LDA $4214 : STA !ram_room_seconds
    LDA $4216 : STA !ram_room_frames

    ; Draw frames
    ASL : TAX
    LDA HexToNumberGFX1,X : STA !ram_tilemap_buffer+$13A
    LDA HexToNumberGFX2,X : STA !ram_tilemap_buffer+$13C

    ; Draw seconds
    LDA !ram_room_seconds : LDX #$0132 : JSR Draw3

    ; Draw lag frames
    LDA !ram_lag_counter : LDX #$012A : JSR Draw3

    ; Draw decimal seperators
    LDA !TILE_DECIMAL
    STA !ram_tilemap_buffer+$138 : STA !ram_tilemap_buffer+$122

    ; Return to 8bit
    %ai8()

    ; Clear last APU command
    ; Helps decide if savestates should load music
    STZ !AL_Last_APU_Command

    PLB
    ; Pull 8bit A and jump to music
    PLA : JML !Play_Music_Prep
}

; Called by other practice hack functions
UpdateTimersLocal:
{
    PHB : PHK : PLB ; set to bank of HexToNumberGFX tables

    ; Draw previous room frames
    LDA !ram_room_frames : ASL : TAX
    LDA HexToNumberGFX1,X : STA !ram_tilemap_buffer+$124
    LDA HexToNumberGFX2,X : STA !ram_tilemap_buffer+$126

    ; Draw previous room seconds
    LDA !ram_room_seconds : LDX #$011C : JSR Draw3

    ; Divide timer by 60
    STZ $4205
    LDA !ram_HUDTimer : STA $4204
    STA !ram_HUDTimer_last
    %a8()
    LDA #$3C : STA $4206
    LDA !ram_update_HUD : ORA #$01 : STA !ram_update_HUD
;    PHA : PLA : PHA : PLA ; wait for CPU math, replaced with above
    %a16()
    LDA $4214 : STA !ram_room_seconds
    LDA $4216 : STA !ram_room_frames

    ; Draw frames
    ASL : TAX
    LDA HexToNumberGFX1,X : STA !ram_tilemap_buffer+$13A
    LDA HexToNumberGFX2,X : STA !ram_tilemap_buffer+$13C

    ; Draw seconds
    LDA !ram_room_seconds : LDX #$0132 : JSR Draw3

    ; Draw lag frames
    LDA !ram_lag_counter : LDX #$012A : JSR Draw3

    ; Draw decimal seperators
    LDA !TILE_DECIMAL
    STA !ram_tilemap_buffer+$138 : STA !ram_tilemap_buffer+$122

    ; Clear last APU command, but don't touch the value beside it
    LDA !AL_Last_APU_Command : AND #$FF00 : STA !AL_Last_APU_Command

    PLB
    RTL
}

TimeAttack:
{
    LDA !AL_Level_index : AND #$00FF : CMP #$0013 : BPL +
    ASL : TAX
    LDA !ram_TimeAttack_DoNotRecord : BNE +
    LDA !AL_LevelCompleted : AND #$00FF : BEQ +

    ; Check if PB
    LDA !sram_TimeAttack,X : CMP !ram_HUDTimer : BPL .newPB
+   RTS

  .newPB
    PLA ; pull return address, finish UpdateTimers from here
    LDA !ram_HUDTimer : STA !sram_TimeAttack,X

    ; Divide timer by 60
    STZ $4205 : STA $4204
    STA !ram_HUDTimer_last
    %a8()
    LDA #$3C : STA $4206
    LDA !ram_update_HUD : ORA #$01 : STA !ram_update_HUD
;    PHA : PLA : PHA : PLA ; wait for CPU math, replaced with above
    %a16()
    LDA $4214 : STA !ram_room_seconds
    LDA $4216 : STA !ram_room_frames

    ; Draw frames
    ASL : TAX
    LDA HexToNumberGFX1,X : ORA #$0C00 : STA !ram_tilemap_buffer+$13A
    LDA HexToNumberGFX2,X : ORA #$0C00 : STA !ram_tilemap_buffer+$13C

    ; Draw seconds
    LDA !ram_room_seconds : LDX #$0132 : JSR Draw3
    LDA !ram_tilemap_buffer+$132 : ORA #$0C00 : STA !ram_tilemap_buffer+$132
    LDA !ram_tilemap_buffer+$134 : ORA #$0C00 : STA !ram_tilemap_buffer+$134
    LDA !ram_tilemap_buffer+$136 : ORA #$0C00 : STA !ram_tilemap_buffer+$136

    ; Draw lag frames
    LDA !ram_lag_counter : LDX #$012A : JSR Draw3

    ; Draw decimal seperators
    LDA !TILE_DECIMAL
    STA !ram_tilemap_buffer+$122 : ORA #$0C00 : STA !ram_tilemap_buffer+$138

    ; Clear last APU command, but don't touch the value beside it
    LDA !AL_Last_APU_Command : AND #$FF00 : STA !AL_Last_APU_Command

    %ai8()
    PLB

    ; pull 8bit A and jump to music
    PLA : JML !Play_Music_Prep
}


; Rewrite HUD tilemap transfer and add mini-transfers for HUD display modes
HUD_Tilemap_Transfers:
{
    PHP
    LDA !AL_HUD_tilemap_flag : BEQ +

    ; Run full HUD tilemap transfer
    %a16()
    LDX #$80 : STX $2115
    LDA !AL_HUD_2116_VMADDL : STA $2116
    LDA #$1801 : STA $4300
    LDA #$D800 : STA $4302
    LDA #$007E : STA $4304
    LDA !AL_HUD_4305_DAS0L : STA $4305
    LDX #$01 : STX $420B
    LDA #$0000 : STA !ram_update_HUD

    PLP
    STZ !AL_HUD_tilemap_flag
    JML HUD_Tilemap_Transfers_return

    ; check if any sections should be transferred
    ; $80 = top and middle, $10 = top, $01 = bottom
+   %ai8()
    LDA !ram_update_HUD : BEQ .done
    TAY : AND #$F0 : BPL .top_row
    BEQ .bottom_row

    ; drawing both, start with middle row
    %a16()
    LDX #$80 : STX $2115
    LDA #$5C6B : STA $2116
    LDX #$00
-   LDA !ram_tilemap_buffer+$D6,X : STA $2118
    INX #2 : CPX #$12 : BNE -

  .top_row
    ; typically used by HUD display modes
    %a16()
    LDX #$80 : STX $2115
    LDA #$5C4B : STA $2116
    LDX #$00
-   LDA !ram_tilemap_buffer+$96,X : STA $2118
    INX #2 : CPX #$12 : BNE -

  .bottom_row
    ; Unused for now
    %a16()
    TYA : AND #$000F : BEQ .done
    LDX #$80 : STX $2115
    LDA #$5C8F : STA $2116
    LDX #$00
-   LDA !ram_tilemap_buffer+$11E,X : STA $2118
    INX #2 : CPX #$22 : BNE -

  .done
    PLP
    LDA #$00 : STA !ram_update_HUD
    JML HUD_Tilemap_Transfers_return
}


; HUD Display Modes
incsrc huddisplay.asm


; Draw routines to match numbers to tile graphics
Draw2:
{
    PHP : %ai16()
    STA $4204
    ; divide by 10
    %a8()
    LDA #$0A : STA $4206
    %a16()
    PEA $0000 : PLA
    LDA $4214 : STA !ram_tmp_1

    ; Ones digit
    LDA $4216 : ASL : TAY
    LDA.w NumberGFXTable,Y : STA !ram_tilemap_buffer,X

    ; Tens digit
    LDA !ram_tmp_1 : BEQ .blanktens
    ASL : TAY
    LDA.w NumberGFXTable,Y : STA !ram_tilemap_buffer,X

  .done
    INX #4
    PLP
    RTS

  .blanktens
    LDA !TILE_BLANK : STA !ram_tilemap_buffer,X
    BRA .done
}

Draw3:
{
    PHP : %ai16()
    STA $4204
    ; divide by 10
    %a8()
    LDA #$0A : STA $4206
    %a16()
    PEA $0000 : PLA
    LDA $4214 : STA !ram_tmp_1

    ; Ones digit
    LDA $4216 : ASL : TAY
    LDA.w NumberGFXTable,Y : STA !ram_tilemap_buffer+4,X

    LDA !ram_tmp_1 : BEQ .blanktens
    STA $4204
    ; divide by 10
    %a8()
    LDA #$0A : STA $4206
    %a16()
    PEA $0000 : PLA
    LDA $4214 : STA !ram_tmp_2

    ; Tens digit
    LDA $4216 : ASL : TAY
    LDA.w NumberGFXTable,Y : STA !ram_tilemap_buffer+2,X

    ; Hundreds digit
    LDA !ram_tmp_2 : BEQ .blankhundreds
    ASL : TAY
    LDA.w NumberGFXTable,Y : STA !ram_tilemap_buffer,X

  .done
    INX #6
    PLP
    RTS

  .blanktens
    LDA !TILE_BLANK
    STA !ram_tilemap_buffer,X : STA !ram_tilemap_buffer+2,X
    BRA .done

  .blankhundreds
    LDA !TILE_BLANK : STA !ram_tilemap_buffer,X
    BRA .done
}

Draw4:
{
    PHP : %ai16()
    STA $4204
    ; divide by 10
    %a8()
    LDA #$0A : STA $4206
    %a16()
    PEA $0000 : PLA
    LDA $4214 : STA !ram_tmp_1

    ; Ones digit
    LDA $4216 : ASL : TAY
    LDA.w NumberGFXTable,Y : STA !ram_tilemap_buffer+6,X

    LDA !ram_tmp_1 : BEQ .blanktens
    STA $4204
    ; divide by 10
    %a8()
    LDA #$0A : STA $4206
    %a16()
    PEA $0000 : PLA
    LDA $4214 : STA !ram_tmp_2

    ; Tens digit
    LDA $4216 : ASL : TAY
    LDA.w NumberGFXTable,Y : STA !ram_tilemap_buffer+4,X

    LDA !ram_tmp_2 : BEQ .blankhundreds
    STA $4204
    ; divide by 10
    %a8()
    LDA #$0A : STA $4206
    %a16()
    PEA $0000 : PLA
    LDA $4214 : STA !ram_tmp_3

    ; Hundreds digit
    LDA $4216 : ASL : TAY
    LDA.w NumberGFXTable,Y : STA !ram_tilemap_buffer+2,X

    ; Thousands digit
    LDA !ram_tmp_3 : BEQ .blankthousands
    ASL : TAY
    LDA.w NumberGFXTable,Y : STA !ram_tilemap_buffer,X

  .done
    INX #8
    PLP
    RTS

  .blanktens
    LDA !TILE_BLANK
    STA !ram_tilemap_buffer,X : STA !ram_tilemap_buffer+2,X : STA !ram_tilemap_buffer+4,X
    BRA .done

  .blankhundreds
    LDA !TILE_BLANK
    STA !ram_tilemap_buffer,X : STA !ram_tilemap_buffer+2,X
    BRA .done

  .blankthousands
    LDA !TILE_BLANK : STA !ram_tilemap_buffer,X
    BRA .done
}

Draw2Hex:
{
    PHP : %ai16()
    LDA !ram_tmp_1 : AND #$00F0        ; (00X0)
    LSR #3 : TAY
    LDA.w HexGFXTable,Y : STA !ram_tilemap_buffer,X

    LDA !ram_tmp_1 : AND #$000F        ; (000X)
    ASL : TAY
    LDA.w HexGFXTable,Y : STA !ram_tilemap_buffer+2,X
    PLP
    RTS
}

Draw4Hex:
{
    STA !ram_tmp_1 : AND #$F000        ; (X000)
    XBA : LSR #3 : TAY
    LDA.w HexGFXTable,Y : STA !ram_tilemap_buffer,X

    LDA !ram_tmp_1 : AND #$0F00        ; (0X00)
    XBA : ASL : TAY
    LDA.w HexGFXTable,Y : STA !ram_tilemap_buffer+2,X

    LDA !ram_tmp_1 : AND #$00F0        ; (00X0)
    LSR #3 : TAY
    LDA.w HexGFXTable,Y : STA !ram_tilemap_buffer+4,X

    LDA !ram_tmp_1 : AND #$000F        ; (000X)
    ASL : TAY
    LDA.w HexGFXTable,Y : STA !ram_tilemap_buffer+6,X
    RTS
}


; ----------
; Table Data
; ----------

NumberGFXTable:
    dw #$2030, #$2031, #$2032, #$2033, #$2034, #$2035, #$2036, #$2037, #$2038, #$2039

HexGFXTable:
    dw #$2030, #$2031, #$2032, #$2033, #$2034, #$2035, #$2036, #$2037, #$2038, #$2039
    dw #$203A, #$203B, #$203C, #$203D, #$203E, #$203F

HexToNumberGFX1:
    dw #$2030, #$2030, #$2030, #$2030, #$2030, #$2030, #$2030, #$2030, #$2030, #$2030
    dw #$2031, #$2031, #$2031, #$2031, #$2031, #$2031, #$2031, #$2031, #$2031, #$2031
    dw #$2032, #$2032, #$2032, #$2032, #$2032, #$2032, #$2032, #$2032, #$2032, #$2032
    dw #$2033, #$2033, #$2033, #$2033, #$2033, #$2033, #$2033, #$2033, #$2033, #$2033
    dw #$2034, #$2034, #$2034, #$2034, #$2034, #$2034, #$2034, #$2034, #$2034, #$2034
    dw #$2035, #$2035, #$2035, #$2035, #$2035, #$2035, #$2035, #$2035, #$2035, #$2035

HexToNumberGFX2:
    dw #$2030, #$2031, #$2032, #$2033, #$2034, #$2035, #$2036, #$2037, #$2038, #$2039
    dw #$2030, #$2031, #$2032, #$2033, #$2034, #$2035, #$2036, #$2037, #$2038, #$2039
    dw #$2030, #$2031, #$2032, #$2033, #$2034, #$2035, #$2036, #$2037, #$2038, #$2039
    dw #$2030, #$2031, #$2032, #$2033, #$2034, #$2035, #$2036, #$2037, #$2038, #$2039
    dw #$2030, #$2031, #$2032, #$2033, #$2034, #$2035, #$2036, #$2037, #$2038, #$2039
    dw #$2030, #$2031, #$2032, #$2033, #$2034, #$2035, #$2036, #$2037, #$2038, #$2039

ControllerInputTable:
    dw #$0800, #$0400, #$0200, #$0100
    dw #$0080, #$8000, #$0040, #$4000, #$0010

ControllerGFXTable:
    dw #$2083, #$2082, #$2081, #$2080
    dw #$208F, #$2087, #$208E, #$2086, #$208C

ControllerLayoutTable:
    ;  Dash     Jump     Throw    Hovering        
    dw !CTRL_Y, !CTRL_B, !CTRL_A, !CTRL_R ; Type 1
    dw !CTRL_Y, !CTRL_B, !CTRL_X, !CTRL_A ; Type 2
    dw !CTRL_Y, !CTRL_B, !CTRL_A, !CTRL_X ; Type 3
    dw !CTRL_Y, !CTRL_B, !CTRL_X, !CTRL_R ; Type 4

print pc, " hudtimers.asm + huddisplay.asm end"
warnpc $BFB000 ; controllerhooks.asm

