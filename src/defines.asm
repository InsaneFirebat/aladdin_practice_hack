
!DEV_BUILD ?= 0 ; outputs debugging symbols
if !DEV_BUILD
!FEATURE_SAVESTATES ?= 1
else
!FEATURE_SAVESTATES ?= 0
endif
!SRAM_VERSION = #$0003 ; inc this to force new SRAM initialization

!VERSION_MAJOR = 1
!VERSION_MINOR = 0
!VERSION_BUILD = 0
!VERSION_REV_1 = 0
!VERSION_REV_2 = 3

!TILE_BLANK = #$2000
!TILE_DECIMAL = #$2029
!TILE_HYPHEN = #$202E

!CTRL_B = #$8000
!CTRL_Y = #$4000
!CTRL_SELECT = #$2000
!CTRL_START = #$1000
!CTRL_VERT = #$0C00
!CTRL_UP = #$0800
!CTRL_DOWN = #$0400
!CTRL_HORIZ = #$0300
!CTRL_LEFT = #$0200
!CTRL_RIGHT = #$0100
!CTRL_A = #$0080
!CTRL_X = #$0040
!CTRL_L = #$0020
!CTRL_R = #$0010

!ACTION_TOGGLE              = #$0000
!ACTION_TOGGLE_BIT          = #$0002
!ACTION_JSL                 = #$0004
!ACTION_NUMFIELD            = #$0006
!ACTION_CHOICE              = #$0008
!ACTION_CTRL_SHORTCUT       = #$000A
!ACTION_NUMFIELD_HEX        = #$000C
!ACTION_NUMFIELD_WORD       = #$000E
!ACTION_TOGGLE_INVERTED     = #$0010
!ACTION_NUMFIELD_COLOR      = #$0012
!ACTION_NUMFIELD_HEX_WORD   = #$0014
!ACTION_NUMFIELD_SOUND      = #$0016
!ACTION_CTRL_INPUT          = #$0018
!ACTION_TOGGLE_BIT_INVERTED = #$001A
!ACTION_JSL_SUBMENU         = #$001C
!ACTION_NUMFIELD_8BIT       = #$001E
!ACTION_NUMFIELD_DECIMAL    = #$0020
!ACTION_NUMFIELD_TIME       = #$0022


; ------------
; Hack Defines
; ------------

!ram_tilemap_buffer = $7ED800
!ram_tilemap_backup = $7EE200

!HUD_TILEMAP = $7ED840
!DRAW_HUD_TIMER = $7ED932

!ram_cm_stack_index = $0170


!WRAM_START = $7FFF00
!WRAM_SIZE = #$0100

!ram_HUDTimer = !WRAM_START+$00
!ram_update_HUD = !WRAM_START+$02
!ram_HUDTimer_last = !WRAM_START+$04
!ram_lag_counter = !WRAM_START+$06
!ram_room_seconds = !WRAM_START+$08
!ram_room_frames = !WRAM_START+$0A
!ram_TimeAttack_DoNotRecord = !WRAM_START+$0C

!ram_cm_menu_stack = !WRAM_START+$10 ; 0x10
!ram_cm_cursor_stack = !WRAM_START+$20 ; 0x10
!ram_cm_cursor_max = !WRAM_START+$30
!ram_cm_input_timer = !WRAM_START+$32
!ram_cm_controller = !WRAM_START+$34
!ram_cm_menu_bank = !WRAM_START+$36

!ram_disable_music = !WRAM_START+$38
!ram_menu_active = !WRAM_START+$3A
!ram_cm_leave = !WRAM_START+$3C
!ram_cm_input_counter = !WRAM_START+$3E
!ram_cm_last_nmi_counter = !WRAM_START+$40

!ram_cm_ctrl_mode = !WRAM_START+$42
!ram_cm_ctrl_timer = !WRAM_START+$44
!ram_cm_ctrl_last_input = !WRAM_START+$46
!ram_cm_ctrl_assign = !WRAM_START+$48
!ram_cm_ctrl_swap = !WRAM_START+$4A

!ram_cm_music_test = !WRAM_START+$54
!ram_cm_sfx_test = !WRAM_START+$56
!ram_hex2dec_first_digit = !WRAM_START+$58
!ram_hex2dec_second_digit = !WRAM_START+$5A
!ram_hex2dec_third_digit = !WRAM_START+$5C
!ram_hex2dec_rest = !WRAM_START+$5E

!cm_AL_credits = !WRAM_START+$60
!cm_AL_lives = !WRAM_START+$62
!cm_AL_hearts_max = !WRAM_START+$64
!cm_AL_hearts = !WRAM_START+$66
!cm_AL_apples = !WRAM_START+$68
!cm_AL_gems = !WRAM_START+$6A
!cm_AL_scarab = !WRAM_START+$6C
!cm_AL_cape = !WRAM_START+$6E
!cm_AL_rubies_area = !WRAM_START+$70
!cm_AL_rubies_total = !WRAM_START+$72
!cm_levelselect_stage = !WRAM_START+$74
!cm_levelselect_level = !WRAM_START+$76
!cm_levelselect_level_index = !WRAM_START+$78
!cm_levelselect_checkpoint = !WRAM_START+$7A
!cm_AL_Invul_State = !WRAM_START+$7C

!cm_AL_420C_HDMAEnable = !WRAM_START+$80

!ram_HUD_1 = !WRAM_START+$C0
!ram_HUD_2 = !WRAM_START+$C2
!ram_HUD_3 = !WRAM_START+$C4
!ram_HUD_4 = !WRAM_START+$C6
!ram_tmp_1 = !WRAM_START+$C8
!ram_tmp_2 = !WRAM_START+$CA
!ram_tmp_3 = !WRAM_START+$CC
!ram_tmp_4 = !WRAM_START+$CE

!ram_watch_left_index = !WRAM_START+$D0
!ram_watch_right_index = !WRAM_START+$D2
!ram_watch_write_mode = !WRAM_START+$D4
!ram_watch_bank = !WRAM_START+$D6
!ram_watch_left = !WRAM_START+$D8
!ram_watch_right = !WRAM_START+$DA
!ram_watch_edit_left = !WRAM_START+$DC
!ram_watch_edit_right = !WRAM_START+$DE
!ram_watch_edit_lock_left = !WRAM_START+$E0
!ram_watch_edit_lock_right = !WRAM_START+$E2
!ram_cm_watch_left_hi = !WRAM_START+$E4
!ram_cm_watch_left_lo = !WRAM_START+$E6
!ram_cm_watch_right_hi = !WRAM_START+$E8
!ram_cm_watch_right_lo = !WRAM_START+$EA
!ram_cm_watch_left_index_lo = !WRAM_START+$EC
!ram_cm_watch_left_index_hi = !WRAM_START+$EE
!ram_cm_watch_right_index_lo = !WRAM_START+$F0
!ram_cm_watch_right_index_hi = !WRAM_START+$F2
!ram_cm_watch_edit_left_hi = !WRAM_START+$F4
!ram_cm_watch_edit_left_lo = !WRAM_START+$F6
!ram_cm_watch_edit_right_hi = !WRAM_START+$F8
!ram_cm_watch_edit_right_lo = !WRAM_START+$FA
!ram_cm_watch_bank = !WRAM_START+$FC
!ram_cm_watch_common_address = !WRAM_START+$FE


; ----
; SRAM
; ----

!SRAM_START = $707F00
!SRAM_SIZE = #$0100

!sram_initialized = !SRAM_START+$00

!sram_display_mode = !SRAM_START+$10

!sram_infinite_apples = !SRAM_START+$20
!sram_infinite_lives = !SRAM_START+$22
!sram_infinite_credits = !SRAM_START+$24
!sram_cheat_code = !SRAM_START+$26
!sram_stage_clear_skip = !SRAM_START+$28
!sram_story_time_skip = !SRAM_START+$2A
!sram_disable_music = !SRAM_START+$2C
!sram_infinite_hearts = !SRAM_START+$2E

!sram_default_cape = !SRAM_START+$30
!sram_default_hearts = !SRAM_START+$32
!sram_default_apples = !SRAM_START+$34
!sram_default_lives = !SRAM_START+$36
!sram_default_credits = !SRAM_START+$38
!sram_options_control_type = !SRAM_START+$3A
!sram_options_sound = !SRAM_START+$3C
!sram_loadstate_music = !SRAM_START+$3E
!sram_loadstate_rng = !SRAM_START+$40

!sram_customsfx_move = !SRAM_START+$90
!sram_customsfx_toggle = !SRAM_START+$92
!sram_customsfx_number = !SRAM_START+$94
!sram_customsfx_confirm = !SRAM_START+$96
!sram_customsfx_goback = !SRAM_START+$98
!sram_customsfx_fail = !SRAM_START+$9A
!sram_customsfx_reset = !SRAM_START+$9C

!sram_TimeAttack = !SRAM_START+$A0 ; 0x30

!sram_ctrl_menu = !SRAM_START+$D0
!sram_ctrl_save_state = !SRAM_START+$D2
!sram_ctrl_load_state = !SRAM_START+$D4
!sram_ctrl_refill = !SRAM_START+$D6
!sram_ctrl_update_timers = !SRAM_START+$D8
!sram_ctrl_soft_reset = !SRAM_START+$DA
!sram_ctrl_test_code = !SRAM_START+$DC
!sram_ctrl_next_level = !SRAM_START+$DE
!sram_ctrl_kill_Aladdin = !SRAM_START+$E0


; ---------------
; Aladdin Defines
; ---------------

; in hindsight, using defines as my RAM map probably wasn't a good idea
; https://datacrystal.romhacking.net/wiki/Disney%27s_Aladdin:RAM_map

!Play_Music = $80B4D0
!Cycle_RNG = $81981B
!Play_SFX = $81FA00
!Play_Music_Prep = $81FA23

!AL_SFX_sync = $0002
!AL_ControlType = $0003
!AL_AudioType = $0004
!AL_05_SomethingAboutStage = $0005
!AL_CombinedOptions = $0006
!AL_CheatCode = $0009 ; 0 = disabled
!AL_InitialSPCDataUploaded_maybe = $000A
!AL_NoPause_timer = $000B
!AL_temp_0C = $0C ; variable use: often a loop counter, indirect addressing
!AL_temp_0E = $0E ; variable use: indirect bank

!AL_temp_16 = $0016
!AL_temp_17 = $0017
!AL_temp_18 = $0018
!AL_temp_19 = $0019
!AL_temp_1A = $001A
!AL_temp_1B = $001B
!AL_temp_37 = $0037

; $38-$4B are unused dp
; now used by practice hack
; all of it by the menu, $38-3B variable use

!AL_Sprite_StunTimer = $004D

!AL_StoryTime_Tilemap_index = $004E
!AL_StoryTime_Pointer = $0050
!AL_StoryTime_Timer = $0052

; $65/67 = indirect addressing
; $69 = loop counter during boot
!AL_MultiStack_SP = $0071 ; a stack pointer
!AL_DemoStoryTime_index = $0075 ; which story scene to load
!AL_DemoStoryTime_Timer = $0076 ; 0x02

; Checked in the Wait4Something loop
; 6F
; 87
; 9F
; B7
; CF
; E7
; FF
; 117
; 12F

!AL_PasswordCursor = $00A5
!AL_Password4th = $00A6
!AL_Password3rd = $00A7
!AL_Password2nd = $00A8
!AL_Password1st = $00A9

!AL_MultiStack_index = $0327
!AL_NumberOfIdleLoops = $0328 ; always $08, stored to $0329
!AL_LoopCounter_0329 = $0329 ; loop counter
!AL_NMI_flag = $032A ; cleared in the idle loop @ $81BC6D
!AL_RNG_1 = $032B
!AL_RNG_2 = $032C
!AL_RENDER_COUNTER = $032D
!AL_FRAME_COUNTER = $032E
!AL_032F_NAME = $032F ; inc'd from 0->23h then reset @ @8394A4
!AL_0330_NAME = $0330 ; dec'd from 23h->0 then set to 23h @ @8394A4
!AL_0331_SomethingAboutInputs = $0331 ; $02 = demo playback

!AL_Demo_Data_index = $033B ; 0x02 index to next demo inputs/timer
!AL_Demo_Input = $033D ; 0x01, Demo input, $80 = Jump, $40 = Dash, $20 = Select, $10 = Start, $08 = Up, $04 = Down, $02 = Left, $01 = Right
!AL_Demo_InputTimer = $033E ; 0x01, set to 1 when loading demo stage/level/checkpoint data
!AL_Demo_index = $033F ; 0x01, used to load demo stage/level/checkpoint data, inc'd afterwards
;!AL_0340_UNUSED = $0340 ; 0x01, unused?
!AL_Demo_ExitTimer = $0341 ; 0x02, set to $04EC at demo loading
!AL_Demo_Timer = $0343 ; 0x02, Time until demo starts, demo exit timer if secret credits

!AL_Invul_State = $0347 ; $02 during knockback, then $04 during i-frames, $80 at level complete, $7F at credits
!AL_Jump_Input = $0348
!AL_Dash_Input = $034A
!AL_Throw_Input = $034C
!AL_Hover_Input = $034E

;!AL_Name_0359 = $0359 ; 0x01 ; zero'd @ level loading
!AL_Chests_Opened = $035A ; 0x01
!AL_credits = $035B ; 0x01  ; dec'd @ $80B3EC
!AL_Stage = $035C
!AL_Level = $035D
!AL_Level_index = $035E
!AL_EquipSetup_flag = $035F ; 0x01, zeroed at HandleEquipment unless demo
!AL_checkpoint = $0360

!AL_credit_lives = $0362 ; 0x01 stored to lives after game over
!AL_lives_HUD = $0363 ; 0x01
!AL_lives = $0364 ; 0x01
!AL_hearts_max = $0365 ; 0x01
!AL_hearts_HUD = $0366 ; 0x01
!AL_hearts = $0367 ; 0x01
!AL_apples_HUD = $0368 ; 0x01
!AL_apples = $0369 ; 0x01
!AL_gems_HUD = $036A ; 0x01
!AL_gems = $036B ; 0x01
!AL_scarab = $036C ; 0x01
!AL_cape_HUD = $036D ; 0x01
!AL_cape = $036E ; 0x01
!AL_GameOver_flag = $036F ; set to 1 after equipment setup, or if game over credit used, 0 if no selected at game over

!AL_Music_flag_0371 = $0371
!AL_MusicHandler_flag = $0372
; $0373 and $0374 zero'd with $0375
!AL_rubies_area = $0375
!AL_rubies_total = $0376

!AL_CONTROLLER_PRI = $0377
!AL_CONTROLLER_SEC = $0379
!AL_CONTROLLER_PRI_NEW = $037B
!AL_CONTROLLER_SEC_NEW = $037D
!AL_Current_Inputs = $037F
!AL_New_Inputs = $0381
!AL_InputHeld_Jump = $0383
!AL_InputHeld_Dash = $0384
!AL_InputHeld_Throw = $0385
!AL_InputHeld_Hover = $0386
!AL_InputNew_Jump = $0387
!AL_InputNew_Dash = $0388
!AL_InputNew_Throw = $0389
!AL_InputNew_Hover = $038A

!AL_212E_MainScreenWindowMask = $038B
!AL_212F_SubScreenWindowMask = $038C

;!AL_Name = $03BD ; a counter? -Zarby89

!AL_211F_Mode7CenterX = $0395 ;0x02
!AL_2120_Mode7CenterY = $0397 ;0x02
!AL_212C_MainScreenDesignation = $0399
!AL_212D_SubScreenDesignation = $039A

!AL_2105_BGMode = $039D

!AL_2107_BG1TilemapAddrSize = $03A0
!AL_2108_BG2TilemapAddrSize = $03A1
!AL_2109_BG3TilemapAddrSize = $03A2
!AL_UNUSED_03A3 = $03A3
!AL_210B_BG12CharacterAddr = $03A4
!AL_210C_BG34CharacterAddr = $03A5
!AL_2126_Window1Left = $03A6
!AL_2127_Window1Right = $03A7
!AL_2128_Window2Left = $03A8
!AL_2129_Window1Left = $03A9
!AL_2123_Window12Select = $03AA
!AL_2124_Window34Select = $03AB
!AL_2125_WindowColorObj = $03AC
!AL_212A_BGWindowMask = $03AD
!AL_212B_ColorOBJWindowMask = $03AE
!AL_2130_ColorAddSelect = $03AF
!AL_2131_ColorMath = $03B0
!AL_2106_Mosaic = $03B1
!AL_2132_ColorIntensityRed = $03B2
!AL_2132_ColorIntensityGreen = $03B3
!AL_2132_ColorIntensityBlue = $03B4

!AL_420C_HDMAEnable = $03B6
!AL_4200_NMITIMEN = $03B7
!AL_2100_INIDISP = $03B8 ; $2100 0x01, see $819EAE (fade in)
!AL_APUCommand_to2140 = $03B9

!AL_SFX_RingBuffer_index = $03BB
!AL_SFX_RingBuffer_UNUSED = $03BC
!AL_SFX_RingBuffer_maxindex = $03BD ; 0x02
!AL_SFX_RingBuffer = $03BF ; 0x20
;!AL_Block_index = $03C0 ; from lua

!AL_HUD_2116_VMADDL = $03DF ; see $808469
!AL_HUD_4305_DAS0L = $03E1 ; see $808469

!AL_DisablePause = $03FA ; 0x01

!AL_iframe_timer = $03F5 ; timer

!AL_Last_APU_Command = $03F8 ; SFX sound?
!AL_03F9_PauseSetsTo_01 = $03F9

!AL_LevelCompletePosition_flag = $0821 ; see $81872E and $818716
!AL_LevelCompletePosition_index = $0822 ; see $81872E and $818716

!AL_HUD_tilemap_flag = $0835 ; 0x01, see $808469

!AL_0844_flag = $0844 ; 0x01, see $8198EF

!AL_TitleMenu_Cursor0 = $0849
!AL_TitleMenu_Cursor1 = $084A

!AL_something1_DMA_flag = $0858 ; 0x01, see $80841E
!AL_something2_DMA_flag = $0859 ; 0x01, see $80841E
!AL_REG_2116_VRAMaddr = $085A ; $2116 vram address low
!AL_REG_4302_srcAddr = $085C ; $4302 ram address low
!AL_REG_4304_srcBank = $085E ; $4304 ram bank, 0x01
!AL_REG_4305_DMAsize = $085F ; $4305 DMA size
!AL_REG_2115_VRAMcontrol = $0861 ; $2115 vram control, probably 0x01
!AL_REG_2116_VRAMaddr = $0863 ; $2116 vram address low
!AL_REG_4302_srcAddr = $0865 ; $4302 ram address low
!AL_REG_4304_srcBank = $0867 ; $4304 ram bank, 0x01
!AL_REG_4305_DMAsize = $0868 ; $4305 DMA size
!AL_REG_2115_VRAMcontrol = $086A ; $2115 vram control, probably 0x01

!AL_NAME_08DB = $08DB ; is the start of some chunk of RAM (DP), set to $8C in EnvironmentDamageAladdin
!AL_Pointer_08DE = $08DE ; is a pointer involved in level loading

!AL_name_08E2 = $08E2 ; $06 if credits remaining, $0F if zero credits
!AL_DamageTaken_08E3 = $08E3 ; ORA #$80 if damage taken

!AL_X_Subpos = $08E6 ; 0x01
!AL_X_Position = $08E7
!AL_X_Position_hi = $08E8
!AL_Y_Subpos = $08E9 ; 0x01
!AL_Y_Position = $08EA
!AL_Y_Position_hi = $08EB

!AL_direction_travelling = $08EF
!AL_direction_facing = $08F0

!AL_X_Speed = $08F4 ; 0x02 maybe

!AL_Y_Speed = $08F9 ; 0x02 maybe

!AL_Apple_Cooldown_Timer = $0925

!AL_Abu_X_Position = $0936
!AL_Abu_Y_Position = $093A

!AL_SpriteRAM_Start = $0B50

!AL_Jafar_HP = $0B6C

!AL_Farouk_HP = $0BBC

!AL_Snake_HP = $0C0C

!AL_Hearts_0CF8 = $0CF8

!AL_DamageTaken_141B = $141B
!AL_Movement_InAir_flag = $141C

!AL_Pose_State = $1420 ; ? -Zarby89  ~  pose -IFB

!AL_LevelCompleted = $1423 ; see $81879D
!AL_IncdWhenKillAl = $1424 ; see $83805B

!AL_X_Subposition_143A = $143A
!AL_X_Position_hi_143C = $143C
!AL_Y_Subposition_143D = $143D
!AL_Y_Position_hi_143F = $143F

; $145A is set to $FF if hearts = 0

!AL_Abu_X_Position_extra = $1471
!AL_Abu_Y_Position_extra = $1473
!AL_PiracyTrap_1475 = $1475

!AL_X_Pos_extra = $1484
!AL_Y_Pos_extra = $1486 ; ?? both were listed as $1484

!AL_Xpos_Progress = $1773 ; 0x02

!AL_Screen_X = $19ED
!AL_Screen_Y = $19F1

; Options RAM has other uses
!AL_Options_Cursor = $1B14
!AL_Options_BGM = $1B15
;!AL_NAME_1B16 = $1B16 ; used as an index in $848D07
!AL_Options_ControlType = $1B17


; --------------
; Symbols Export
; --------------

if !DEV_BUILD
; see disassembly/WRAM_symbols.txt
; for more manually generated madness

org $7ED800 : ram_tilemap_buffer:
org $7EE200 : ram_tilemap_backup:
org $7ED840 : HUD_TILEMAP:
org $7ED932 : DRAW_HUD_TIMER:

org !WRAM_START+$00 : ram_HUDTimer:
org !WRAM_START+$02 : ram_update_HUD:
org !WRAM_START+$04 : ram_HUDTimer_last:
org !WRAM_START+$06 : ram_lag_counter:
org !WRAM_START+$08 : ram_room_seconds:
org !WRAM_START+$0A : ram_room_frames:
org !WRAM_START+$0C : ram_TimeAttack_DoNotRecord:

org !WRAM_START+$10 : ram_cm_menu_stack:
org !WRAM_START+$20 : ram_cm_cursor_stack:
org !WRAM_START+$30 : ram_cm_cursor_max:
org !WRAM_START+$32 : ram_cm_input_timer:
org !WRAM_START+$34 : ram_cm_controller:
org !WRAM_START+$36 : ram_cm_menu_bank:
org !WRAM_START+$38 : ram_disable_music:
org !WRAM_START+$3A : ram_menu_active:
org !WRAM_START+$3C : ram_cm_leave:
org !WRAM_START+$3E : ram_cm_input_counter:
org !WRAM_START+$40 : ram_cm_last_nmi_counter:
org !WRAM_START+$42 : ram_cm_ctrl_mode:
org !WRAM_START+$44 : ram_cm_ctrl_timer:
org !WRAM_START+$46 : ram_cm_ctrl_last_input:
org !WRAM_START+$48 : ram_cm_ctrl_assign:
org !WRAM_START+$4A : ram_cm_ctrl_swap:

org !WRAM_START+$54 : ram_cm_music_test:
org !WRAM_START+$56 : ram_cm_sfx_test:
org !WRAM_START+$58 : ram_hex2dec_first_digit:
org !WRAM_START+$5A : ram_hex2dec_second_digit:
org !WRAM_START+$5C : ram_hex2dec_third_digit:
org !WRAM_START+$5E : ram_hex2dec_rest:

org !WRAM_START+$60 : cm_AL_credits:
org !WRAM_START+$62 : cm_AL_lives:
org !WRAM_START+$64 : cm_AL_hearts_max:
org !WRAM_START+$66 : cm_AL_hearts:
org !WRAM_START+$68 : cm_AL_apples:
org !WRAM_START+$6A : cm_AL_gems:
org !WRAM_START+$6C : cm_AL_scarab:
org !WRAM_START+$6E : cm_AL_cape:
org !WRAM_START+$70 : cm_AL_rubies_area:
org !WRAM_START+$72 : cm_AL_rubies_total:
org !WRAM_START+$74 : cm_levelselect_stage:
org !WRAM_START+$76 : cm_levelselect_level:
org !WRAM_START+$78 : cm_levelselect_level_index:
org !WRAM_START+$7A : cm_levelselect_checkpoint:
org !WRAM_START+$7C : cm_AL_Invul_State:

org !WRAM_START+$80 : cm_AL_420C_HDMAEnable:

org !WRAM_START+$C0 : ram_HUD_1:
org !WRAM_START+$C2 : ram_HUD_2:
org !WRAM_START+$C4 : ram_HUD_3:
org !WRAM_START+$C6 : ram_HUD_4:
org !WRAM_START+$C8 : ram_tmp_1:
org !WRAM_START+$CA : ram_tmp_2:
org !WRAM_START+$CC : ram_tmp_3:
org !WRAM_START+$CE : ram_tmp_4:

org !WRAM_START+$D0 : ram_watch_left_index:
org !WRAM_START+$D2 : ram_watch_right_index:
org !WRAM_START+$D4 : ram_watch_write_mode:
org !WRAM_START+$D6 : ram_watch_bank:
org !WRAM_START+$D8 : ram_watch_left:
org !WRAM_START+$DA : ram_watch_right:
org !WRAM_START+$DC : ram_watch_edit_left:
org !WRAM_START+$DE : ram_watch_edit_right:
org !WRAM_START+$E0 : ram_watch_edit_lock_left:
org !WRAM_START+$E2 : ram_watch_edit_lock_right:
org !WRAM_START+$E4 : ram_cm_watch_left_hi:
org !WRAM_START+$E6 : ram_cm_watch_left_lo:
org !WRAM_START+$E8 : ram_cm_watch_right_hi:
org !WRAM_START+$EA : ram_cm_watch_right_lo:
org !WRAM_START+$EC : ram_cm_watch_left_index_lo:
org !WRAM_START+$EE : ram_cm_watch_left_index_hi:
org !WRAM_START+$F0 : ram_cm_watch_right_index_lo:
org !WRAM_START+$F2 : ram_cm_watch_right_index_hi:
org !WRAM_START+$F4 : ram_cm_watch_edit_left_hi:
org !WRAM_START+$F6 : ram_cm_watch_edit_left_lo:
org !WRAM_START+$F8 : ram_cm_watch_edit_right_hi:
org !WRAM_START+$FA : ram_cm_watch_edit_right_lo:
org !WRAM_START+$FC : ram_cm_watch_bank:
org !WRAM_START+$FE : ram_cm_watch_common_address:

endif

