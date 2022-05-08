
org $BEE000
print pc, " mainmenu.asm start"

action_mainmenu:
{
    PHB
    ; Set bank of new menu
    LDA !ram_cm_cursor_stack : TAX
    LDA.l MainMenuBanks,X : STA !ram_cm_menu_bank
    STA $42 : STA $46

    BRA action_submenu+1
}

action_submenu:
{
    PHB
    ; Increment stack pointer by 2, then store current menu
    LDA !ram_cm_stack_index : INC #2 : STA !ram_cm_stack_index : TAX
    TYA : STA !ram_cm_menu_stack,X
}

action_submenu_jump:
{
    LDA #$0000 : STA !ram_cm_cursor_stack,X

    %sfxmove()
    JSL cm_calculate_max
    JSL cm_draw

    PLB
    RTL
}


MainMenu:
    dw #mm_goto_equipment
    dw #mm_goto_levelselect
    dw #mm_goto_hud
    dw #mm_goto_settings
    dw #mm_goto_ctrl
    dw #mm_goto_audio
if !DEV_BUILD
    dw #$FFFF
    dw #test_thing
endif
    dw #$0000
    %cm_version_header("Aladdin Practice", !VERSION_MAJOR, !VERSION_MINOR, !VERSION_BUILD, !VERSION_REV_1, !VERSION_REV_2)
    %cm_footer("  ALPRACTICE.SPAZER.LINK")

MainMenuBanks:
    dw #EquipmentMenu>>16
    dw #LevelSelectMenu>>16
    dw #HUDDisplayMenu>>16
    dw #SettingsMenu>>16
    dw #CtrlMenu>>16
    dw #AudioMenu>>16
if !DEV_BUILD
    dw #$FFFF ; dummy
    dw #test_thing>>16 ; dummy
endif

mm_goto_equipment:
    %cm_mainmenu("EQUIPMENT", EquipmentMenu)

mm_goto_levelselect:
    %cm_mainmenu("LEVEL SELECT", LevelSelectMenu)

mm_goto_hud:
    %cm_mainmenu("HUD DISPLAY", HUDDisplayMenu)

mm_goto_settings:
    %cm_mainmenu("SETTINGS", SettingsMenu)

mm_goto_ctrl:
    %cm_mainmenu("CONTROLLER SHORTCUTS", CtrlMenu)

mm_goto_audio:
    %cm_mainmenu("AUDIO MENU", AudioMenu)

if !DEV_BUILD
test_thing:
    %cm_jsl("Test Code", .routine, #$0000)
  .routine
    ; for editing in debugger
    NOP #32
    NOP #32
    RTL
endif


EquipmentMenu:
    dw #eq_refill
    dw #eq_hearts
    dw #eq_hearts_max
    dw #eq_apples
    dw #eq_cape
    dw #eq_scarab
    dw #eq_lives
    dw #eq_credits
    dw #eq_gems
    dw #eq_rubies_area
    dw #eq_rubies_total
    dw #$0000
    %cm_header("EQUIPMENT")

eq_refill:
    %cm_jsl("Quick Refill", .routine, #$0099)
  .routine
    %a8()
    TYA : STA !cm_AL_apples : STA !AL_apples
    LDA !AL_hearts_max : STA !cm_AL_hearts : STA !AL_hearts
    LDA !AL_lives : CMP #$0A : BPL +
    INC !AL_lives
    LDA !cm_AL_lives : INC : STA !cm_AL_lives
+   RTL

eq_hearts:
    %cm_numfield_8bit("Current Hearts", !cm_AL_hearts, 1, 10, 1, 2, .routine)
  .routine
    %a8()
    LDA !cm_AL_hearts : STA !AL_hearts
    INC !AL_HUD_tilemap_flag
    RTL

eq_hearts_max:
    %cm_numfield_8bit("Max Hearts", !cm_AL_hearts_max, 3, 10, 1, 2, .routine)
  .routine
    %a8()
    LDA !cm_AL_hearts_max : STA !AL_hearts_max
    LDA !AL_hearts : DEC : CMP !AL_hearts_max : BMI +
    LDA !AL_hearts_max : STA !AL_hearts : STA !cm_AL_hearts
+   INC !AL_HUD_tilemap_flag
    RTL

eq_apples:
    %cm_numfield_decimal("Apples", !cm_AL_apples, 0, 99, 1, 4, .routine)
  .routine
    %a8()
    LDA !cm_AL_apples : STA !AL_apples
    INC !AL_HUD_tilemap_flag
    RTL

eq_cape:
    %cm_toggle_bit("Cape", !cm_AL_cape, #$0001, .routine)
  .routine
    %a8()
    LDA !cm_AL_cape : STA !AL_cape
    INC !AL_HUD_tilemap_flag
    RTL

eq_scarab:
    %cm_toggle_bit("Scarab", !cm_AL_scarab, #$0001, .routine)
  .routine
    %a8()
    LDA !cm_AL_scarab : STA !AL_scarab
    RTL

eq_gems:
    %cm_numfield_decimal("Gems", !cm_AL_gems, 0, 99, 1, 4, .routine)
  .routine
    %a8()
    LDA !cm_AL_gems : STA !AL_gems
    INC !AL_HUD_tilemap_flag
    RTL

eq_rubies_area:
    %cm_numfield_8bit("Rubies (Area)", !cm_AL_rubies_area, 0, 10, 1, 4, .routine)
  .routine
    %a8()
    LDA !cm_AL_rubies_area : STA !AL_rubies_area
    INC !AL_HUD_tilemap_flag
    RTL

eq_rubies_total:
    %cm_numfield_8bit("Rubies (Total)", !cm_AL_rubies_total, 0, 50, 1, 4, .routine)
  .routine
    %a8()
    LDA !cm_AL_rubies_total : STA !AL_rubies_total
    INC !AL_HUD_tilemap_flag
    RTL

eq_lives:
    %cm_numfield_8bit("Lives", !cm_AL_lives, 0, 10, 1, 2, .routine)
  .routine
    %a8()
    LDA !cm_AL_lives : INC : STA !AL_lives
    INC !AL_HUD_tilemap_flag
    RTL

eq_credits:
    %cm_numfield_8bit("Credits", !cm_AL_credits, 0, 9, 1, 2, .routine)
  .routine
    %a8()
    LDA !cm_AL_lives : INC : STA !AL_lives
    INC !AL_HUD_tilemap_flag
    RTL


; -----------------
; Level Select Menu
; -----------------

LevelSelectMenu:
    dw levelselect_list
    dw #$FFFF
    dw levelselect_select_stage
    dw levelselect_select_level
    dw levelselect_checkpoint
    dw levelselect_load_target
    dw #$FFFF
    dw levelselect_kill_Al
    dw levelselect_next_level
    dw #$0000
    %cm_header("LEVEL SELECT")

levelselect_list:
    %cm_submenu("Level Select List View", LevelSelectListMenu)

levelselect_select_stage:
    dw !ACTION_CHOICE
    dl #!cm_levelselect_stage
    dw #.routine                 ; Stage  * = it's $07, but we use $05 for menu convenience
    db #$28, "Target Stage", #$FF; Index  Level Index
    db #$28, "    AGRABAH", #$FF ; 0      0 1 2 3
    db #$28, "       CAVE", #$FF ; 1      4 5
    db #$28, "       FIRE", #$FF ; 2      6 7
    db #$28, "      GENIE", #$FF ; 3      8 9 A
    db #$28, "    PYRAMID", #$FF ; 4      B C D
    db #$28, "     PALACE", #$FF ; 5*     E F 10 11
    db #$28, "      BONUS", #$FF ; 6      12
    db #$FF
  .routine
    LDA #$0001 : STA !cm_levelselect_level
    JML levelselect_menu_sync

levelselect_select_level:
    %cm_numfield("Target Level", !cm_levelselect_level, 1, 4, 1, 1, levelselect_menu_sync)

levelselect_checkpoint:
    %cm_toggle("Toggle Checkpoint", !cm_levelselect_checkpoint, #$0001, levelselect_menu_sync)

levelselect_load_target:
    %cm_jsl("Load Target", .routine, #0)
  .routine
    %a8()
    LDA !cm_levelselect_level_index : STA !AL_Level_index
    LDA !cm_levelselect_stage : STA !AL_Stage
    LDA !cm_levelselect_level_index : STA !AL_Level
    LDA !cm_levelselect_checkpoint : STA !AL_checkpoint
    JMP levelselect_kill_Al_routine

levelselect_kill_Al:
    %cm_jsl("Restart Level (Kill Al)", .routine, #$0001)
  .routine
    %ai8()
    LDA !AL_Level_index : CMP #$13 : BPL +
    INC !AL_lives
    LDA #$01 : STA !ram_cm_leave
    JSL $838052 ; KillAladdin_long
    RTL

+   %sfxfail()
    RTL

levelselect_next_level:
    %cm_jsl("Load Next Level", Inc2NextLevel, #$0001)

Inc2NextLevel:
; This is mostly a copy of a vanilla routine, $81879D
{
    PHP : %a8() : %i16()

    ; maybe check !AL_LevelCompletePosition_flag instead?
    LDA !AL_Level_index : CMP #$13 : BPL .fail
    CMP #$12 : BEQ .bonus

    LDX !AL_LevelCompletePosition_index
    LDA $80EC24,X : PHA
    AND #$7F : STA !AL_Level
    BNE +

    LDX !AL_Stage
    LDA $80B988,X : STA !AL_Stage

+   PLA : ASL : BCC +
    INX

+   LDX !AL_Level_index
    LDA $80B96B,X : BEQ .Y_CBF9
    LDY #$E730 : BRA .store_Y

  .Y_CBF9
    LDY #$CBF9

  .store_Y
    STY !AL_Pointer_08DE
    %ai8()
    LDX #$00 : STZ !AL_checkpoint
    STZ !AL_direction_facing : STZ !AL_direction_travelling
    INC !AL_StageCompleted : INC $1454

    ; ensure we're not dead
    LDA #$80 : STA !AL_Invul_State
    LDA !AL_hearts : BNE .done
    LDA !AL_hearts_max : STA !AL_hearts

  .done
    PLP
    LDA #$0001 : STA !ram_cm_leave
    RTL

  .fail
    %sfxfail()
    PLP
    RTL

  .bonus
    LDY #$3000 : STY !AL_Xpos_Progress
    BRA .done
}

levelselect_menu_sync:
{
    ; keep stage-level values within bounds
    LDA !cm_levelselect_stage : ASL : TAX
    LDA.l MaxLevelTable,X : TAX
    CMP !cm_levelselect_level : BPL +
    TXA : STA !cm_levelselect_level ; cap at max

    ; lookup level index
+   LDA !cm_levelselect_stage : ASL : TAX
    LDA StageTable,X : STA $40
    LDA !cm_levelselect_level : DEC : ASL : TAY
    LDA ($40),Y : STA !cm_levelselect_level_index

    ; allow/disallow checkpoints
    LDA !cm_levelselect_checkpoint : BEQ +
    LDA !cm_levelselect_level_index : CMP #$000A : BEQ .checkpoint
    CMP #$0010 : BEQ .checkpoint
+   LDA #$0000 : STA !cm_levelselect_checkpoint
    RTL

  .checkpoint
    LDA #$0001 : STA !cm_levelselect_checkpoint
    RTL
}


LevelSelectListMenu:
    dw levelselectlist_Agrabah_01
    dw levelselectlist_Agrabah_02
    dw levelselectlist_Agrabah_03
    dw levelselectlist_Agrabah_04
    dw levelselectlist_Cave_01
    dw levelselectlist_Cave_02
    dw levelselectlist_Fire_01
    dw levelselectlist_Fire_02
    dw levelselectlist_Genie_01
    dw levelselectlist_Genie_02
    dw levelselectlist_Genie_03
    dw levelselectlist_Genie_03_cp
    dw levelselectlist_Pyramid_01
    dw levelselectlist_Pyramid_02
    dw levelselectlist_Pyramid_03
    dw levelselectlist_Bonus
    dw levelselectlist_Palace_01
    dw levelselectlist_Palace_02
    dw levelselectlist_Palace_03
    dw levelselectlist_Palace_03_cp
    dw levelselectlist_Palace_04
    dw #$0000
    %cm_header("JUMP TO SELECTED LEVEL")

levelselectlist_Agrabah_01:
    %cm_jsl("Agrabah - 1", #levelselect_list_load, #$0001)

levelselectlist_Agrabah_02:
    %cm_jsl("Agrabah - 2", #levelselect_list_load, #$0002)

levelselectlist_Agrabah_03:
    %cm_jsl("Agrabah - 3", #levelselect_list_load, #$0003)

levelselectlist_Agrabah_04:
    %cm_jsl("Agrabah - 4", #levelselect_list_load, #$0004)

levelselectlist_Cave_01:
    %cm_jsl("Cave - 1", #levelselect_list_load, #$0101)

levelselectlist_Cave_02:
    %cm_jsl("Cave - 2", #levelselect_list_load, #$0102)

levelselectlist_Fire_01:
    %cm_jsl("Fire - 1", #levelselect_list_load, #$0201)

levelselectlist_Fire_02:
    %cm_jsl("Fire - 2", #levelselect_list_load, #$0202)

levelselectlist_Genie_01:
    %cm_jsl("Genie - 1", #levelselect_list_load, #$0301)

levelselectlist_Genie_02:
    %cm_jsl("Genie - 2", #levelselect_list_load, #$0302)

levelselectlist_Genie_03:
    %cm_jsl("Genie - 3", #.routine, #$0303)
  .routine
    LDA #$0000 : STA !cm_levelselect_checkpoint
    JML levelselect_list_load

levelselectlist_Genie_03_cp:
    %cm_jsl("Genie - 3 Checkpoint", #.routine, #$0303)
  .routine
    LDA #$0001 : STA !cm_levelselect_checkpoint
    JML levelselect_list_load

levelselectlist_Pyramid_01:
    %cm_jsl("Pyramid - 1", #levelselect_list_load, #$0401)

levelselectlist_Pyramid_02:
    %cm_jsl("Pyramid - 2", #levelselect_list_load, #$0402)

levelselectlist_Pyramid_03:
    %cm_jsl("Pyramid - 3", #levelselect_list_load, #$0403)

levelselectlist_Bonus:
    %cm_jsl("Bonus Carpet Ride", #levelselect_list_load, #$0601)

levelselectlist_Palace_01:
    %cm_jsl("Palace - 1", #levelselect_list_load, #$0501)

levelselectlist_Palace_02:
    %cm_jsl("Palace - 2", #levelselect_list_load, #$0502)

levelselectlist_Palace_03:
    %cm_jsl("Palace - 3", #.routine, #$0503)
  .routine
    LDA #$0000 : STA !cm_levelselect_checkpoint
    JML levelselect_list_load

levelselectlist_Palace_03_cp:
    %cm_jsl("Palace - 3 Jafar Fight", #.routine, #$0503)
  .routine
    LDA #$0001 : STA !cm_levelselect_checkpoint
    JML levelselect_list_load

levelselectlist_Palace_04:
    %cm_jsl("Palace - 4 Snake Fight", #levelselect_list_load, #$0504)

levelselect_list_load:
{
    TYA
    %ai8()
    STA !cm_levelselect_level : XBA : STA !cm_levelselect_stage

    ASL : TAX
    %a16()
    LDA StageTable,X : STA $40
    LDA !cm_levelselect_level : DEC : ASL : TAY
    LDA ($40),Y : STA !cm_levelselect_level_index

    LDA !cm_levelselect_level_index : CMP #$0010 : BEQ +
    LDA #$0000 : STA !cm_levelselect_checkpoint

+   JML levelselect_load_target_routine
}


MaxLevelTable:
    dw $0004
    dw $0002
    dw $0002
    dw $0003
    dw $0003
    dw $0004
    dw $0001

StageTable:
    dw LevelTableAgrabah
    dw LevelTableCave
    dw LevelTableFire
    dw LevelTableGenie
    dw LevelTablePyramid
    dw LevelTablePalace
    dw LevelTableBonus

LevelTableAgrabah:
    dw $0000, $0001, $0002, $0003

LevelTableCave:
    dw $0004, $0005

LevelTableFire:
    dw $0006, $0007

LevelTableGenie:
    dw $0008, $0009, $000A

LevelTablePyramid:
    dw $000B, $000C, $000D

LevelTablePalace:
    dw $000E, $000F, $0010, $0011

LevelTableBonus:
    dw #$0012


; ----------------
; HUD Display Menu
; ----------------

HUDDisplayMenu:
    dw #HUD_display_mode_list
    dw #HUD_display_mode_choice
    dw #$FFFF
    dw #HUD_ram_watch
    dw #$0000
    %cm_header("HUD DISPLAY MENU")

HUD_display_mode_list:
    %cm_submenu("Select HUD Display Mode", #HUDDisplayList)

HUDDisplayList:
    dw #HUD_list_off
    dw #$FFFF
    dw #HUD_list_inputdisplay
    dw #HUD_list_bossHP
    dw #HUD_list_position
    dw #HUD_list_speed
    dw #HUD_list_iframes
    dw #HUD_list_rng
    dw #HUD_list_rubies
    dw #HUD_list_ramwatch
    dw #$0000
    %cm_header("SELECT DISPLAY MODE")

HUD_list_off:
    %cm_jsl("Disable HUD Display", #select_infohud_mode, #$0000)

HUD_list_inputdisplay:
    %cm_jsl("Input Display", #select_infohud_mode, #$0001)

HUD_list_bossHP:
    %cm_jsl("Boss Hits Remaining", #select_infohud_mode, #$0002)

HUD_list_position:
    %cm_jsl("Aladdin Position", #select_infohud_mode, #$0003)

HUD_list_speed:
    %cm_jsl("Aladdin Speed", #select_infohud_mode, #$0004)

HUD_list_iframes:
    %cm_jsl("Aladdin I-Frames", #select_infohud_mode, #$0005)

HUD_list_rng:
    %cm_jsl("RNG Values", #select_infohud_mode, #$0006)

HUD_list_rubies:
    %cm_jsl("Rubies Collected", #select_infohud_mode, #$0007)

!HUD_MODE_RAMWATCH_INDEX = #$0008
HUD_list_ramwatch:
    %cm_jsl("RAM Watch", #select_infohud_mode, !HUD_MODE_RAMWATCH_INDEX)

HUD_display_mode_choice:
    dw !ACTION_CHOICE
    dl #!sram_display_mode
    dw #Clear_InfoHUD
    db #$28, "CURRENT MODE", #$FF
    db #$28, "        OFF", #$FF
    db #$28, "     INPUTS", #$FF
    db #$28, "    BOSS HP", #$FF
    db #$28, "   POSITION", #$FF
    db #$28, "      SPEED", #$FF
    db #$28, "   I-FRAMES", #$FF
    db #$28, "        RNG", #$FF
    db #$28, "     RUBIES", #$FF
    db #$28, "  RAM WATCH", #$FF
    db #$FF

HUD_ram_watch:
    %cm_submenu("Configure RAM Watch", #RAMWatchMenu)

incsrc ramwatchmenu.asm

select_infohud_mode:
{
    TYA : STA !sram_display_mode

    JSL Clear_InfoHUD

    JSL cm_previous_menu
    RTL
}

Clear_InfoHUD:
{
    LDA #$0000 : STA !ram_update_HUD
    LDA #$5A5A
    STA !ram_HUD_1 : STA !ram_HUD_2
    STA !ram_HUD_3 : STA !ram_HUD_4

    LDA !TILE_BLANK : LDX #$0012
-   STA !ram_tilemap_buffer+$96,X
    DEX #2 : BPL -

    LDX #$0012
-   STA !ram_tilemap_buffer+$D6,X
    DEX #2 : BPL -

    RTL
}


; --------
; Settings
; --------

SettingsMenu:
if !FEATURE_SAVESTATES
    dw #settings_goto_savestate
    dw #$FFFF
endif
    dw #settings_goto_options
    dw #settings_goto_equip
    dw #settings_goto_infinite
    dw #$FFFF
    dw #settings_invulnerability
    dw #settings_cheat_code
    dw #$FFFF
    dw #settings_stage_clear_skip
    dw #settings_story_time_skip
    dw #$FFFF
    dw #settings_customize_sfx
    dw #$0000
    %cm_header("SETTINGS MENU")

settings_goto_options:
    %cm_submenu("Game Options", GameOptiosnMenu)

settings_goto_equip:
    %cm_submenu("Starting Equipment", StartEquipMenu)

settings_goto_infinite:
    %cm_submenu("Unlimited Items", InfiniteMenu)

settings_invulnerability:
    %cm_toggle("Invulnerability", !cm_AL_Invul_State, #$0001, #0)

settings_cheat_code:
    %cm_toggle("Cheat Code", !sram_cheat_code, #$0001, #0)

settings_goto_savestate:
    %cm_submenu("Savestate Settings", SavestateMenu)

settings_stage_clear_skip:
    %cm_toggle("Skip Stage Clear", !sram_stage_clear_skip, #$0001, #0)

settings_story_time_skip:
    %cm_toggle("Skip Story Time", !sram_story_time_skip, #$0001, #0)

settings_customize_sfx:
    %cm_submenu("Customize Menu SFX", CustomizeSFXMenu)


GameOptiosnMenu:
    dw #options_control_type
    dw #$FFFF
    dw #options_control_dash
    dw #options_control_jump
    dw #options_control_throw
    dw #options_control_hovering
    dw #$FFFF
    dw #options_sound
    dw #$0000
    %cm_header("Game Options Menu")

options_control_type:
    %cm_numfield("Control-Type", !sram_options_control_type, 1, 4, 1, 1, .routine)
  .routine
    LDA !sram_options_control_type : BEQ +
    DEC
+   STA !AL_ControlType
    ASL #3 : TAX
    LDA !AL_ControlType : ORA !AL_AudioType : CLC : ADC !AL_05_SomethingAboutStage : STA !AL_CombinedOptions
    LDA.l ControllerLayoutTable,X : STA !AL_Dash_Input
    LDA.l ControllerLayoutTable+2,X : STA !AL_Jump_Input
    LDA.l ControllerLayoutTable+4,X : STA !AL_Throw_Input
    LDA.l ControllerLayoutTable+6,X : STA !AL_Hover_Input
    RTL
}

options_control_dash:
    %cm_ctrl_input("        DASH", $7E0000+!AL_Dash_Input, action_submenu, #AssignControlsMenu)

options_control_jump:
    %cm_ctrl_input("        JUMP", $7E0000+!AL_Jump_Input, action_submenu, #AssignControlsMenu)

options_control_throw:
    %cm_ctrl_input("       THROW", $7E0000+!AL_Throw_Input, action_submenu, #AssignControlsMenu)

options_control_hovering:
    %cm_ctrl_input("    HOVERING", $7E0000+!AL_Hover_Input, action_submenu, #AssignControlsMenu)

AssignControlsMenu:
    dw #options_control_assign_A
    dw #options_control_assign_B
    dw #options_control_assign_X
    dw #options_control_assign_Y
    dw #options_control_assign_Select
    dw #options_control_assign_L
    dw #options_control_assign_R
    dw #$0000
    %cm_header("ASSIGN AN INPUT")
    %cm_footer("ANY INPUT IS ALLOWED HERE")

options_control_assign_A:
    %cm_jsl("A", assign_input, !CTRL_A)

options_control_assign_B:
    %cm_jsl("B", assign_input, !CTRL_B)

options_control_assign_X:
    %cm_jsl("X", assign_input, !CTRL_X)

options_control_assign_Y:
    %cm_jsl("Y", assign_input, !CTRL_Y)

options_control_assign_Select:
    %cm_jsl("Select", assign_input, !CTRL_SELECT)

options_control_assign_L:
    %cm_jsl("L", assign_input, !CTRL_L)

options_control_assign_R:
    %cm_jsl("R", assign_input, !CTRL_R)

assign_input:
{
    LDA !ram_cm_ctrl_assign : STA $38 : TAX  ; input address in $38 and X
    LDA $7E0000,X : STA !ram_cm_ctrl_swap    ; save old input for later
    TYA : STA $7E0000,X                      ; store new input
    STY $3A                                  ; saved new input for later

    JSL check_duplicate_inputs

    ; determine which sfx to play
    INC : BEQ .undetected
    %sfxconfirm()
    BRA +

  .undetected
    %sfxfail()

+   LDA #$0000 : STA !sram_options_control_type
    JSL cm_previous_menu
    RTL
}

check_duplicate_inputs:
{
    ; ram_cm_ctrl_assign = word address of input being assigned
    ; ram_cm_ctrl_swap = previous input bitmask being moved
    ; X / $38 = word address of new input
    ; Y / $3A = new input bitmask

    LDA #!AL_Throw_Input : CMP $38 : BEQ .check_jump  ; check if we just assigned throw
    LDA !AL_Throw_Input : BEQ +                       ; check if throw is unassigned
    CMP $3A : BNE .check_jump                         ; skip to check_jump if not a duplicate assignment
+   JMP .throw                                        ; swap with throw

  .check_jump
    LDA #!AL_Jump_Input : CMP $38 : BEQ .check_dash
    LDA !AL_Jump_Input : BEQ +
    CMP $3A : BNE .check_dash
+   JMP .jump

  .check_dash
    LDA #!AL_Dash_Input : CMP $38 : BEQ .check_hover
    LDA !AL_Dash_Input : BEQ +
    CMP $3A : BNE .check_hover
+   JMP .dash

  .check_hover
    LDA #!AL_Hover_Input : CMP $38 : BEQ .not_detected
    LDA !AL_Hover_Input : BEQ +
    CMP $3A : BNE .not_detected
+   JMP .hover

  .not_detected
    LDA #$FFFF
    RTL

  .throw
+   LDA !ram_cm_ctrl_swap : STA !AL_Throw_Input
    RTL

  .jump
+   LDA !ram_cm_ctrl_swap : STA !AL_Jump_Input
    RTL

  .dash
+   LDA !ram_cm_ctrl_swap : STA !AL_Dash_Input
    RTL

  .hover
+   LDA !ram_cm_ctrl_swap : STA !AL_Hover_Input
    RTL
}

options_sound:
    dw !ACTION_CHOICE
    dl #!sram_options_sound
    dw #.routine
    db #$28, "Sound Type", #$FF
    db #$28, "     STEREO", #$FF
    db #$28, "   MONAURAL", #$FF
    db #$FF
  .routine
    %a8()
    LDA !sram_options_sound : BNE +
    LDA #$80 : STA !AL_AudioType
    LDA !AL_ControlType : ORA !AL_05_SomethingAboutStage : STA !AL_CombinedOptions
    RTL
+   LDA #$00 : STA !AL_AudioType
    LDA !AL_ControlType : ORA !AL_AudioType : CLC : ADC !AL_05_SomethingAboutStage : STA !AL_CombinedOptions
    RTL


StartEquipMenu:
    dw #StartEquip_cape
    dw #StartEquip_hearts_max
    dw #StartEquip_apples
    dw #StartEquip_lives
    dw #StartEquip_credits
    dw #$FFFF
    dw #StartEquip_default
    dw #$0000
    %cm_header("STARTING EQUIPMENT MENU")

StartEquip_cape:
    %cm_toggle("Cape", !sram_default_cape, #$0001, #0)

StartEquip_hearts_max:
    %cm_numfield("Max Hearts", !sram_default_hearts, 3, 10, 1, 4, #0)

StartEquip_apples:
    %cm_numfield_decimal("Apples", !sram_default_apples, 0, 99, 1, 4, #0)

StartEquip_lives:
    %cm_numfield("Lives", !sram_default_lives, 0, 9, 1, 4, #0)

StartEquip_credits:
    %cm_numfield("Credits", !sram_default_credits, 3, 10, 1, 2, #0)

StartEquip_default:
    %cm_jsl("Original Defaults", .routine, #$1003)
  .routine
    TYA
    %a8()
    STA !sram_default_hearts : STA !sram_default_lives
    STA !sram_default_credits
    XBA : STA !sram_default_apples
    LDA #$00 : STA !sram_default_cape
    %sfxquake()
    RTL


InfiniteMenu:
    dw #infinite_hearts
    dw #infinite_apples
    dw #infinite_lives
    dw #infinite_credits
    dw #$0000
    %cm_header("      ABSOLUTE POWER")

infinite_hearts:
    %cm_toggle("Unlimited Hearts", !sram_infinite_hearts, #$0001, #0)

infinite_apples:
    %cm_toggle("Unlimited Apples", !sram_infinite_apples, #$0001, #0)

infinite_lives:
    %cm_toggle("Unlimited Lives", !sram_infinite_lives, #$0001, #0)

infinite_credits:
    %cm_toggle("Unlimited Credits", !sram_infinite_credits, #$0001, #0)


SavestateMenu:
    dw #settings_loadstate_music
    dw #settings_loadstate_rng
    dw #$0000
    %cm_header("SAVESTATE SETTINGS")

settings_loadstate_music:
    %cm_toggle("Loadstate Music Check", !sram_loadstate_music, #$0001, #0)

settings_loadstate_rng:
    dw !ACTION_CHOICE
    dl #!sram_loadstate_rng
    dw #$0000
    db #$28, "RNG Setting", #$FF
    db #$28, " FROM STATE", #$FF
    db #$28, "   PRESERVE", #$FF
    db #$28, "      CYCLE", #$FF
    db #$FF


CustomizeSFXMenu:
    dw #customize_sfx_move
    dw #customize_sfx_toggle
    dw #customize_sfx_number
    dw #customize_sfx_confirm
    dw #customize_sfx_goback
    dw #sram_customsfx_fail
    dw #$FFFF
    dw #customize_sfx_reset
    dw #$0000
    %cm_header("CUSTOMIZE MENU SOUND FX")
    %cm_footer("PRESS Y TO PLAY SOUNDS")

customize_sfx_move:
    %cm_numfield_sound("Move Cursor", !sram_customsfx_move, 0, 80, 1, 4, .routine)
  .routine
    %a8()
    LDA !sram_customsfx_move : JML !Play_SFX

customize_sfx_toggle:
    %cm_numfield_sound("Toggle", !sram_customsfx_toggle, 0, 80, 1, 4, .routine)
  .routine
    %a8()
    LDA !sram_customsfx_toggle : JML !Play_SFX

customize_sfx_number:
    %cm_numfield_sound("Number Select", !sram_customsfx_number, 0, 80, 1, 4, .routine)
  .routine
    %a8()
    LDA !sram_customsfx_number : JML !Play_SFX

customize_sfx_confirm:
    %cm_numfield_sound("Confirm Selection", !sram_customsfx_confirm, 0, 80, 1, 4, .routine)
  .routine
    %a8()
    LDA !sram_customsfx_confirm : JML !Play_SFX

customize_sfx_goback:
    %cm_numfield_sound("Go Back", !sram_customsfx_goback, 0, 80, 1, 4, .routine)
  .routine
    %a8()
    LDA !sram_customsfx_goback : JML !Play_SFX

sram_customsfx_fail:
    %cm_numfield_sound("Fail", !sram_customsfx_fail, 0, 80, 1, 4, .routine)
  .routine
    %a8()
    LDA !sram_customsfx_fail : JML !Play_SFX

customize_sfx_reset:
    %cm_jsl("Reset to Defaults", .routine, #$0000)
  .routine
    LDA #$000C : STA !sram_customsfx_move
    LDA #$0006 : STA !sram_customsfx_toggle
    LDA #$003B : STA !sram_customsfx_number
    LDA #$000B : STA !sram_customsfx_confirm
    LDA #$0008 : STA !sram_customsfx_goback
    LDA #$0002 : STA !sram_customsfx_fail
    %sfxquake()
    RTL


; ----------
; Ctrl Menu
; ----------

CtrlMenu:
    dw #ctrl_menu
if !FEATURE_SAVESTATES
    dw #ctrl_save_state
    dw #ctrl_load_state
endif
    dw #ctrl_next_level
    dw #ctrl_kill_Aladdin
    dw #ctrl_refill
    dw #ctrl_update_timers
    dw #ctrl_soft_reset
if !DEV_BUILD
    dw #ctrl_test_code
endif
    dw #$FFFF
    dw #ctrl_clear_shortcuts
    dw #ctrl_reset_defaults
    dw #$0000
    %cm_header("CONTROLLER SHORTCUTS")
    %cm_footer("PRESS AND HOLD FOR 2 SEC")

ctrl_menu:
    %cm_ctrl_shortcut("Open Menu", !sram_ctrl_menu)

ctrl_save_state:
    %cm_ctrl_shortcut("Save State", !sram_ctrl_save_state)

ctrl_load_state:
    %cm_ctrl_shortcut("Load State", !sram_ctrl_load_state)

ctrl_next_level:
    %cm_ctrl_shortcut("Load Next Level", !sram_ctrl_next_level)

ctrl_kill_Aladdin:
    %cm_ctrl_shortcut("Kill Aladdin", !sram_ctrl_kill_Aladdin)

ctrl_refill:
    %cm_ctrl_shortcut("Refill Equipment", !sram_ctrl_refill)

ctrl_update_timers:
    %cm_ctrl_shortcut("Update HUD Timers", !sram_ctrl_update_timers)

ctrl_soft_reset:
    %cm_ctrl_shortcut("Soft Reset", !sram_ctrl_soft_reset)

ctrl_test_code:
    %cm_ctrl_shortcut("Test Code", !sram_ctrl_test_code)

ctrl_clear_shortcuts:
    %cm_jsl("Clear Shortcuts", .routine, #$0000)
  .routine
    TYA
    STA !sram_ctrl_save_state
    STA !sram_ctrl_load_state
    STA !sram_ctrl_next_level
    STA !sram_ctrl_kill_Aladdin
    STA !sram_ctrl_refill
    STA !sram_ctrl_update_timers
    STA !sram_ctrl_soft_reset
    STA !sram_ctrl_test_code
    ; menu to default, Start + Select
    LDA #$2000 : STA !sram_ctrl_menu
    %sfxquake()
    RTL

ctrl_reset_defaults:
    %cm_jsl("Reset to Defaults", .routine, #$0000)
  .routine
    LDA #$2000 : STA !sram_ctrl_menu                   ; Select
    LDA #$6010 : STA !sram_ctrl_save_state             ; Select + Y + R
    LDA #$6020 : STA !sram_ctrl_load_state             ; Select + Y + L
    LDA #$0000 : STA !sram_ctrl_next_level
    LDA #$0000 : STA !sram_ctrl_kill_Aladdin
    LDA #$0000 : STA !sram_ctrl_refill
    LDA #$0000 : STA !sram_ctrl_update_timers
    LDA #$3030 : STA !sram_ctrl_soft_reset             ; Select + Start + L + R
    LDA #$0000 : STA !sram_ctrl_test_code
    %sfxquake()
    RTL


; ----------
; Audio Menu
; ----------

AudioMenu:
    dw audio_music_toggle
    dw audio_music_index
    dw audio_play_music
    dw #$FFFF
    dw audio_sfx_index
    dw audio_play_sfx
    dw #$FFFF
    dw audio_silence_audio
    dw #options_sound
    dw #$0000
    %cm_header("SOUND TEST MENU")
    %cm_footer("PRESS Y TO PLAY SFX")

audio_music_toggle:
    %cm_toggle_inverted("Toggle Music", !sram_disable_music, #$0001, .routine)
  .routine
    %a8()
    LDA !sram_disable_music : BEQ +
    LDA #$F0 : JML !Play_SFX ; silence audio
+   LDA !AL_Last_APU_Command : CMP #$F6 : BEQ +
    LDA !AL_APUCommand_to2140 : JML !Play_Music_Prep
+   RTL

audio_music_index:
    %cm_numfield_sound("Select Music", !ram_cm_music_test, 0, 34, 1, 3, play_test_music)

audio_play_music:
    %cm_jsl("Play Music", .routine, #$0000)
  .routine
    %ai8()
    LDA !ram_cm_music_test : CLC : ADC #$10
    JML !Play_Music_Prep

audio_sfx_index:
    %cm_numfield_sound("Select SFX", !ram_cm_sfx_test, 0, 80, 1, 4, play_test_sfx)
    
audio_play_sfx:
    %cm_jsl("Play SFX", play_test_sfx, #$0000)

audio_silence_audio:
    %cm_jsl("Silence Audio", .routine, #$F0F0)
  .routine
    %a8()
    TYA : JML !Play_SFX

play_test_music:
{
    LDA !ram_disable_music : PHA
    LDA #$0000 : STA !ram_disable_music
    %ai8()
    LDA !ram_cm_music_test : CLC : ADC #$10
    JSL !Play_Music_Prep
    %ai16()
    PLA : STA !ram_disable_music
    RTL
}

play_test_sfx:
{
    %a8()
    LDA !ram_cm_sfx_test : JML !Play_SFX
}

print pc, " mainmenu end"
