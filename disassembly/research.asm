; Aladdin Disassembly
; Labels and notes, mostly assumptions
; by InsaneFirebat


org $80FFB0 : GameHeader:
org $8088E7 : COP_Handler: ; COP and BRK are used
org $8088E5 : BRK_Handler:
org $808111 : NMI_Native:
org $808332 : IRQ_Interrupt:


; controller input
org $818398 : CheckForPause:
org $81838E : DecNoPauseTimer:
org $81BDB1 : ControllerReadAndHandler:
org $81BDCC : Read_Controller_Input:
org $81BDE9 : Handle_Controller_Input:

org $80B9E2 : DATA_Dash_ControlType1:
org $80B9EA : DATA_Jump_ControlType1:
org $80B9F2 : DATA_Throw_ControlType1:
org $80B9FA : DATA_Hover_ControlType1:


; Main game mode routines?
org $8182CF : GamePlayLoop:

org $828685 : CarpetRideBonusAndCredits_start:
org $828697 : CarpetRideBonusAndCredits_loop:


; Stage Clear screen
org $81F7B1 : StageClearScreen_FadeIn:
org $81F7C0 : StageClearScreen_secondLoopStart: ; draw CONGRATRULATIONS
org $81F7CB : StageClearScreen_secondLoop:
org $81F808 : StageClearScreen_thirdLoopStart: ; reveal password
org $81F813 : StageClearScreen_thirdLoop:
org $81F8B0 : StageClearScreen_fourthLoopStart: ; Genie exits
org $81F8B4 : StageClearScreen_fourthLoop:
org $81F8C2 : StageClearScreen_fifthLoopStart: ; Waiting for music?
org $81F8C6 : StageClearScreen_fifthLoop:
org $81F8D4 : StageClearScreen_sixthLoopStart: ; draw rubies
org $81F8DA : StageClearScreen_sixthLoop:
org $81F8E8 : StageClearScreen_seventhLoop: ; check for #$D0C0 input (A B X Y St)
org $81F907 : StageClearScreen_FadeOutLoop: ; until $0087 = 0


; Aladdin
org $81CDE9 : Aladdin_MaybeThrowApple:
org $81AB85 : Aladdin_DetermineDirection:

org $81B44F : MaybeHandleAladdinMovement:
org $838000 : EnemyDamageAladdin_long: ; enemies
org $838004 : EnvironmentDamageAladdin_long:
org $838008 : EnvironmentDamageAladdin: ; spikes
org $838024 : EnemyDamageAladdin:
org $838052 : KillAladdin_long:
org $838056 : KillAladdin: ; pitfall
org $81E95C : HandleIFrames:

org $8186F0 : CheckProgress4Checkpoint:
org $81872E : CheckLevelComplete:


; Abu


; Enemies
org $81AE8A : Enemy_ChooseAttack:


; common routines that execute many other routines
org $81830D : JSR818311_RunOnMultipleGameModes_long:
org $818311 : JSR818311_RunOnMultipleGameModes:


; audio
org $80B463 : SendApuCommand:
org $80B4D0 : Play_Music:
org $81FA00 : Play_SFX:
org $81FA23 : Play_Music_Prep:


; audio data
org $858000 : DATA_Audio:


; graphics
org $81F433 : HUD_Setup:
org $81F456 : CheckUpdateHUD:
org $81F47F : UpdateHUD_CheckLives:
org $81F488 : UpdateHUD_Lives:
org $81F4D0 : UpdateHUD_DrawHearts:
org $81F4F6 : UpdateHUD_Apples:
org $81F521 : UpdateHUD_Gems:
org $81F54C : UpdateHUD_Cape:

org $8195C8 : InitBG3Tilemap:
org $8195B8 : WriteAto_BG3Tilemap:
org $818668 : JSR818668_VRAMTransfer:
org $819865 : SetupScreenReg:
org $81F5FE : TransferVRAM_7FC000:
org $81F60D : JSL81F60D_VRAMTransfer:

org $80B441 : GameOver_DrawCreditsNumber:


; Graphics data
org $8B894F : AlandJasCarpetRide_SpriteGFX:
org $A08000 : HUD_BG3_Tileset:


; Level loading

org $81803A : StartOfDemoLoading:
org $818066 : SetStageLevel_Demo:
org $818095 : HandleEquipment:
org $8180A3 : HandleEquipment_Respawn:
org $8180B5 : HandleEquipment_GameOverCredit:
org $8180D3 : HandleEquipment_Demo:
org $818153 : SetStageLevelIndex_long:
org $818157 : SetStageLevelIndex:

org $8181A7 : Start_level_loading:
org $81825B : Major_loading_several_frames_long:
org $81825F : Major_loading_several_frames:
org $819647 : JSL819647_Clear_03F5_F9:
org $819607 : ClearBG3Tilemap:
org $818114 : Setup_Equipment_long:
org $818118 : Setup_Equipment:
org $8180DC : Restart_Equipment_long:
org $8180E0 : Restart_Equipment: ; contains a cheat branch, seeds RNG
org $8184B2 : Apply_CheckPoint_Position:

org $81879D : JSR81879D_Inc2NextLevel:

org $818E97 : JMP818E0E_035E_00: ; RTS for first level

org $81888B : JMP818802_index035E_00:
org $818C14 : JMP818802_index035E_10:
org $818CF3 : JMP818802_index035E_12: ; 12 is carpet ride

org $81A413 : JSL81A413_LevelStart_SetInitialSpeed:

org $80B39B : Loading_GameOver:

;org $80AC87 : StoryTime_DemoLoop:


; Cutscenes
org $818000 : PreCopyrightMessage:

org $80AD78 : StoryTime:

org $80ADE8 : StoryTime_Intro2:

org $81BD53 : DemoPlayBack_Check4Input:


; menus
org $A5E000 : Setup_TitleScreen:
org $A5E000 : TitleScreen_InitReg:
org $838979 : OptionsMenu:
org $8196CB : InitOptionsMenuRAM:
org $8195D5 : WriteE0_7EFC80x200:
org $818B61 : OptionsMenu_CycleControlType: ; carry set = inc
org $838C16 : OptionsMenu_NewControls2Tilemap:
org $80810A : CombineMenuOptions: ; $0004 + $0003 + $0005 = $0006

org $80A05C : DEBUG_LevelSelectMenu:
org $80A0B1 : DEBUG_DrawLevelSelect:



; Register maintenance
org $81969F : EnableNMI:
org $8196A8 : EnableAutoJoyRead_03B7:
org $8196B1 : EnableNMI_if4210:



; misc
org $819655 : JSL819655_Clear_mostWRAM:
org $818F47 : Maybe_major_loading_menu:
org $819D4C : STZ_7FF000_100:

org $81BCB8 : Transition_StartAndEndFrameLoop:
org $81BCF6 : MajorTransition_StartAndEndFrameLoop:
org $81BD31 : StartAndEndFrameLoop:
org $809C64 : StartOfAltStack:
org $819626 : Clear_AltStack_Variables:
org $81BC7F : Wait4NMI_LoopEntry:

org $81BE5A : SRAM_if_0331_nonZero:

org $81981B : Cycle_RNG:


; Crash loops
org $80B4F2 : WaitForSPC_2142_APUIO2:
org $83946F : CrashLoop_Unknown00: ; likely inaccessable
