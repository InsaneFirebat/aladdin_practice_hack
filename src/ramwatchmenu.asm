; ---------------
; RAM Watch Menus
; ---------------

ih_prepare_ram_watch_menu:
    LDA !ram_watch_left : XBA : AND #$00FF : STA !ram_cm_watch_left_hi
    LDA !ram_watch_left : AND #$00FF : STA !ram_cm_watch_left_lo
    LDA !ram_watch_right : XBA : AND #$00FF : STA !ram_cm_watch_right_hi
    LDA !ram_watch_right : AND #$00FF : STA !ram_cm_watch_right_lo
    LDA !ram_watch_edit_left : XBA : AND #$00FF : STA !ram_cm_watch_edit_left_hi
    LDA !ram_watch_edit_left : AND #$00FF : STA !ram_cm_watch_edit_left_lo
    LDA !ram_watch_edit_right : XBA : AND #$00FF : STA !ram_cm_watch_edit_right_hi
    LDA !ram_watch_edit_right : AND #$00FF : STA !ram_cm_watch_edit_right_lo
    LDA !ram_watch_left_index : XBA : AND #$00FF : STA !ram_cm_watch_left_index_hi
    LDA !ram_watch_left_index : AND #$00FF : STA !ram_cm_watch_left_index_lo
    LDA !ram_watch_right_index : XBA : AND #$00FF : STA !ram_cm_watch_right_index_hi
    LDA !ram_watch_right_index : AND #$00FF : STA !ram_cm_watch_right_index_lo

    %setmenubank()
    JML action_submenu

RAMWatchMenu:
    dw ramwatch_enable
    dw ramwatch_bank
    dw ramwatch_write_mode
    dw ramwatch_goto_common
    dw #$FFFF
    dw ramwatch_left_hi
    dw ramwatch_left_lo
    dw ramwatch_left_index_hi
    dw ramwatch_left_index_lo
    dw ramwatch_left_edit_hi
    dw ramwatch_left_edit_lo
    dw ramwatch_execute_left
    dw ramwatch_lock_left
    dw #$FFFF
    dw ramwatch_right_hi
    dw ramwatch_right_lo
    dw ramwatch_right_index_hi
    dw ramwatch_right_index_lo
    dw ramwatch_right_edit_hi
    dw ramwatch_right_edit_lo
    dw ramwatch_execute_right
    dw ramwatch_lock_right
    dw #$0000
    %cm_header("READ AND WRITE TO MEMORY")

ramwatch_goto_common:
    %cm_submenu("Select Common Addresses", #RAMWatchCommonMenu)

RAMWatchCommonMenu:
    dw ramwatch_common_aladdin
    dw ramwatch_common_misc
    dw #$0000
    %cm_header("CHOOSE RAM CATEGORY")

ramwatch_common_aladdin:
    %cm_submenu("Aladdin Addresses", #RAMWatchCommonAladdinMenu)

ramwatch_common_misc:
    %cm_submenu("Misc Addresses", #RAMWatchCommonMiscMenu)

RAMWatchCommonAladdinMenu:
    dw ramwatch_common_aladdin_0364
    dw ramwatch_common_aladdin_0365
    dw ramwatch_common_aladdin_0367
    dw ramwatch_common_aladdin_0369
    dw ramwatch_common_aladdin_036E
    dw ramwatch_common_aladdin_0347
    dw ramwatch_common_aladdin_03F5
    dw ramwatch_common_aladdin_08E7
    dw ramwatch_common_aladdin_08E6
    dw ramwatch_common_aladdin_08EA
    dw ramwatch_common_aladdin_08E9
    dw ramwatch_common_aladdin_08F4
    dw ramwatch_common_aladdin_08F9
    dw ramwatch_common_aladdin_08EF
    dw ramwatch_common_aladdin_08F0
    dw ramwatch_common_aladdin_1773
    dw ramwatch_common_aladdin_1420
    dw ramwatch_common_aladdin_141C
    dw ramwatch_common_aladdin_0925
    dw #$0000
    %cm_header("SELECT FROM ALADDIN RAM")

ramwatch_common_aladdin_0364:
    %cm_jsl("Lives", action_select_common_address, #$0364)

ramwatch_common_aladdin_0365:
    %cm_jsl("Max Hearts", action_select_common_address, #$0365)

ramwatch_common_aladdin_0367:
    %cm_jsl("Current Hearts", action_select_common_address, #$0367)

ramwatch_common_aladdin_0369:
    %cm_jsl("Apples", action_select_common_address, #$0369)

ramwatch_common_aladdin_036E:
    %cm_jsl("Cape", action_select_common_address, #$036E)

ramwatch_common_aladdin_0347:
    %cm_jsl("Invulnerability State", action_select_common_address, #$0347)

ramwatch_common_aladdin_03F5:
    %cm_jsl("I-Frame Timer", action_select_common_address, #$03F5)

ramwatch_common_aladdin_08E7:
    %cm_jsl("X Position", action_select_common_address, #$08E7)

ramwatch_common_aladdin_08E6:
    %cm_jsl("X Subposition", action_select_common_address, #$08E6)

ramwatch_common_aladdin_08EA:
    %cm_jsl("Y Position", action_select_common_address, #$08EA)

ramwatch_common_aladdin_08E9:
    %cm_jsl("Y Subposition", action_select_common_address, #$08E9)

ramwatch_common_aladdin_08F4:
    %cm_jsl("X Speed", action_select_common_address, #$08F4)

ramwatch_common_aladdin_08F9:
    %cm_jsl("Y Speed", action_select_common_address, #$08F9)

ramwatch_common_aladdin_08EF:
    %cm_jsl("Direction Travelling", action_select_common_address, #$08EF)

ramwatch_common_aladdin_08F0:
    %cm_jsl("Direction Facing", action_select_common_address, #$08F0)

ramwatch_common_aladdin_1773:
    %cm_jsl("X Position Progress", action_select_common_address, #$1773)

ramwatch_common_aladdin_1420:
    %cm_jsl("Pose State", action_select_common_address, #$1420)

ramwatch_common_aladdin_141C:
    %cm_jsl("In Air Flag", action_select_common_address, #$141C)

ramwatch_common_aladdin_0925:
    %cm_jsl("Apple Cooldown", action_select_common_address, #$0925)

RAMWatchCommonMiscMenu:
    dw ramwatch_common_misc_032B
    dw ramwatch_common_misc_032C
    dw ramwatch_common_misc_035C
    dw ramwatch_common_misc_035D
    dw ramwatch_common_misc_035E
    dw ramwatch_common_misc_0360
    dw ramwatch_common_misc_035B
    dw ramwatch_common_misc_036B
    dw ramwatch_common_misc_0375
    dw ramwatch_common_misc_0376
    dw ramwatch_common_misc_036C
    dw ramwatch_common_misc_0B6C
    dw ramwatch_common_misc_0BBC
    dw ramwatch_common_misc_0C0C
    dw ramwatch_common_misc_0936
    dw ramwatch_common_misc_093A
    dw ramwatch_common_misc_000B
    dw ramwatch_common_misc_032D
    dw ramwatch_common_misc_032E
    dw #$0000
    %cm_header("SELECT FROM MISC RAM")

ramwatch_common_misc_032B:
    %cm_jsl("RNG $032B", action_select_common_address, #$032B)

ramwatch_common_misc_032C:
    %cm_jsl("RNG $032C", action_select_common_address, #$032C)

ramwatch_common_misc_035C:
    %cm_jsl("Current Stage (Area)", action_select_common_address, #$035C)

ramwatch_common_misc_035D:
    %cm_jsl("Current Level", action_select_common_address, #$035D)

ramwatch_common_misc_035E:
    %cm_jsl("Current Level Index", action_select_common_address, #$035E)

ramwatch_common_misc_0360:
    %cm_jsl("Checkpoint Flag", action_select_common_address, #$0360)

ramwatch_common_misc_035B:
    %cm_jsl("Credits", action_select_common_address, #$035B)

ramwatch_common_misc_036B:
    %cm_jsl("Gems", action_select_common_address, #$036B)

ramwatch_common_misc_0375:
    %cm_jsl("Rubies This Area", action_select_common_address, #$0375)

ramwatch_common_misc_0376:
    %cm_jsl("Total Rubies Collected", action_select_common_address, #$0376)

ramwatch_common_misc_036C:
    %cm_jsl("Scarab Flag", action_select_common_address, #$036C)

ramwatch_common_misc_0B6C:
    %cm_jsl("Jafar HP", action_select_common_address, #$0B6C)

ramwatch_common_misc_0BBC:
    %cm_jsl("Farouk HP", action_select_common_address, #$0BBC)

ramwatch_common_misc_0C0C:
    %cm_jsl("Snake HP", action_select_common_address, #$0C0C)

ramwatch_common_misc_0936:
    %cm_jsl("Abu X Position", action_select_common_address, #$0936)

ramwatch_common_misc_093A:
    %cm_jsl("Abu Y Position", action_select_common_address, #$093A)

ramwatch_common_misc_000B:
    %cm_jsl("No-Pause Timer", action_select_common_address, #$000B)

ramwatch_common_misc_032D:
    %cm_jsl("Game-Time Counter", action_select_common_address, #$032D)

ramwatch_common_misc_032E:
    %cm_jsl("Real-Time Counter", action_select_common_address, #$032E)

action_select_common_address:
{
    TYA : STA !ram_cm_watch_common_address
    LDY #RAMWatchCommonConfirm : %setmenubank()
    JML action_submenu
}

RAMWatchCommonConfirm:
    dw ramwatch_common_addr1
    dw ramwatch_common_addr2
    dw ramwatch_common_back
    dw #$0000
    %cm_header("WHICH RAM WATCH SIDE?")

ramwatch_common_addr1:
    %cm_jsl("Address 1 (Left)", .routine, #$0000)
  .routine
    LDA !ram_cm_watch_common_address : STA !ram_watch_left
    LDA #$0000
    STA !ram_watch_left_index : STA !ram_watch_bank
    BRA ramwatch_common_addr_done

ramwatch_common_addr2:
    %cm_jsl("Address 2 (Right)", .routine, #$0000)
  .routine
    LDA !ram_cm_watch_common_address : STA !ram_watch_right
    LDA #$0000
    STA !ram_watch_right_index : STA !ram_watch_bank

ramwatch_common_addr_done:
    LDA !ram_cm_stack_index : DEC #4
    STA !ram_cm_stack_index
    JSL cm_previous_menu
    LDY #RAMWatchMenu
    JSL ih_prepare_ram_watch_menu
    %sfxconfirm()
    RTL

ramwatch_common_back:
    %cm_jsl("Go Back", .routine, #0)
  .routine
    LDA !ram_cm_stack_index : DEC #4
    STA !ram_cm_stack_index
    JSL cm_previous_menu
    RTL

ramwatch_enable:
    %cm_jsl("Turn On RAM Watch", .routine, !HUD_MODE_RAMWATCH_INDEX)
  .routine
    TYA : STA !sram_display_mode
    %sfxconfirm()
    RTL

ramwatch_bank:
    dw !ACTION_CHOICE
    dl #!ram_cm_watch_bank
    dw #.routine
    db #$28, "Select Bank", #$FF
    db #$28, "        $7E", #$FF
    db #$28, "        $7F", #$FF
    db #$FF
  .routine
    LDA !ram_cm_watch_bank : BNE +
    LDA #$7E7E : STA !ram_watch_bank
    RTL

+   LDA #$7F7F : STA !ram_watch_bank
    RTL

ramwatch_write_mode:
    dw !ACTION_CHOICE
    dl #!ram_watch_write_mode
    dw #$0000
    db #$28, "Write Mode", #$FF
    db #$28, "16BIT HI-LO", #$FF
    db #$28, "    8BIT LO", #$FF
    db #$FF

ramwatch_left_hi:
    %cm_numfield_hex("Address 1 High", !ram_cm_watch_left_hi, 0, 255, 1, 8, #.routine)
  .routine
    XBA : ORA !ram_cm_watch_left_lo
    STA !ram_watch_left
    RTL

ramwatch_left_lo:
    %cm_numfield_hex("Address 1 Low", !ram_cm_watch_left_lo, 0, 255, 1, 8, #.routine)
  .routine
    XBA : ORA !ram_cm_watch_left_hi
    XBA : STA !ram_watch_left
    RTL

ramwatch_left_index_hi:
    %cm_numfield_hex("Offset 1 High", !ram_cm_watch_left_index_hi, 0, 255, 1, 8, #.routine)
  .routine
    XBA : ORA !ram_cm_watch_left_index_lo
    STA !ram_watch_left_index
    RTL

ramwatch_left_index_lo:
    %cm_numfield_hex("Offset 1 Low", !ram_cm_watch_left_index_lo, 0, 255, 1, 8, #.routine)
  .routine
    XBA : ORA !ram_cm_watch_left_index_hi
    XBA : STA !ram_watch_left_index
    RTL

ramwatch_left_edit_hi:
    %cm_numfield_hex("Value 1 High", !ram_cm_watch_edit_left_hi, 0, 255, 1, 8, #.routine)
  .routine
    XBA : ORA !ram_cm_watch_edit_left_lo
    STA !ram_watch_edit_left
    RTL

ramwatch_left_edit_lo:
    %cm_numfield_hex("Value 1 Low", !ram_cm_watch_edit_left_lo, 0, 255, 1, 8, #.routine)
  .routine
    XBA : ORA !ram_cm_watch_edit_left_hi
    XBA : STA !ram_watch_edit_left
    RTL

ramwatch_right_hi:
    %cm_numfield_hex("Address 2 High", !ram_cm_watch_right_hi, 0, 255, 1, 8, #.routine)
  .routine
    XBA : ORA !ram_cm_watch_right_lo
    STA !ram_watch_right
    RTL

ramwatch_right_lo:
    %cm_numfield_hex("Address 2 Low", !ram_cm_watch_right_lo, 0, 255, 1, 8, #.routine)
  .routine
    XBA : ORA !ram_cm_watch_right_hi
    XBA : STA !ram_watch_right
    RTL

ramwatch_right_index_hi:
    %cm_numfield_hex("Offset 2 High", !ram_cm_watch_right_index_hi, 0, 255, 1, 8, #.routine)
  .routine
    XBA : ORA !ram_cm_watch_right_index_lo
    STA !ram_watch_right_index
    RTL

ramwatch_right_index_lo:
    %cm_numfield_hex("Offset 2 Low", !ram_cm_watch_right_index_lo, 0, 255, 1, 8, #.routine)
  .routine
    XBA : ORA !ram_cm_watch_right_index_hi
    XBA : STA !ram_watch_right_index
    RTL

ramwatch_right_edit_hi:
    %cm_numfield_hex("Value 2 High", !ram_cm_watch_edit_right_hi, 0, 255, 1, 8, #.routine)
  .routine
    XBA : ORA !ram_cm_watch_edit_right_lo
    STA !ram_watch_edit_right
    RTL

ramwatch_right_edit_lo:
    %cm_numfield_hex("Value 2 Low", !ram_cm_watch_edit_right_lo, 0, 255, 1, 8, #.routine)
  .routine
    XBA : ORA !ram_cm_watch_edit_right_hi
    XBA : STA !ram_watch_edit_right
    RTL

ramwatch_execute_left:
    %cm_jsl("Write to Address 1", #action_ramwatch_edit_left, #$0000)

ramwatch_execute_right:
    %cm_jsl("Write to Address 2", #action_ramwatch_edit_right, #$0000)

ramwatch_lock_left:
    %cm_toggle("Lock Value 1", !ram_watch_edit_lock_left, #$0001, #action_HUD_ramwatch)

ramwatch_lock_right:
    %cm_toggle("Lock Value 2", !ram_watch_edit_lock_right, #$0001, #action_HUD_ramwatch)

action_ramwatch_edit_left:
{
    LDA !ram_watch_left : CLC : ADC !ram_watch_left_index : STA $38
    LDA !ram_watch_bank : BEQ .bank7E
    CMP #$0001 : BEQ .bank7F
    LDA #$0070 : BRA +
  .bank7E
    LDA #$007E : BRA +
  .bank7F
    LDA #$007F
+   STA $3A
    LDA !ram_watch_write_mode : BEQ +
    %a8()
+   LDA !ram_watch_edit_left : STA [$38]
    %a16()
    LDA !HUD_MODE_RAMWATCH_INDEX : STA !sram_display_mode
    %sfxconfirm()
    RTL
}

action_ramwatch_edit_right:
{
    LDA !ram_watch_right : CLC : ADC !ram_watch_right_index : STA $38
    LDA !ram_watch_bank : BEQ .bank7E
    CMP #$0001 : BEQ .bank7F
    LDA #$0070 : BRA +
  .bank7E
    LDA #$007E : BRA +
  .bank7F
    LDA #$007F
+   STA $3A
    LDA !ram_watch_write_mode : BEQ +
    %a8()
+   LDA !ram_watch_edit_right : STA [$38]
    %a16()
    LDA !HUD_MODE_RAMWATCH_INDEX : STA !sram_display_mode
    %sfxconfirm()
    RTL
}

action_HUD_ramwatch:
{
    LDA !HUD_MODE_RAMWATCH_INDEX : STA !sram_display_mode
    RTL
}

