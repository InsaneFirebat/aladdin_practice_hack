
macro a8()
    SEP #$20
endmacro

macro a16()
    REP #$20
endmacro

macro i8()
    SEP #$10
endmacro

macro ai8()
    SEP #$30
endmacro

macro ai16()
    REP #$30
endmacro

macro i16()
    REP #$10
endmacro

macro item_index_to_vram_index()
    ; Find screen position from Y (item number)
    TYA : ASL #5
    CLC : ADC #$0146 : TAX
endmacro


; ----------------
; Main Menu Macros
; ----------------

macro cm_header(title)
    table ../resources/header.tbl
    db #$24, "<title>", #$FF
    table ../resources/normal.tbl
endmacro

macro cm_footer(title)
    table ../resources/header.tbl
    dw #$F007 : db #$20, "<title>", #$FF
    table ../resources/normal.tbl
endmacro

macro cm_version_header(title, major, minor, build, rev_1, rev_2)
    table ../resources/header.tbl
if !VERSION_REV_1
    db #$24, "<title> <major>.<minor>.<build>.<rev_1><rev_2>", #$FF
else
if !VERSION_REV_2
    db #$24, "<title> <major>.<minor>.<build>.<rev_2>", #$FF
else
    db #$24, "<title> <major>.<minor>.<build>", #$FF
endif
endif
    table ../resources/normal.tbl
endmacro

macro cm_numfield(title, addr, start, end, increment, heldincrement, jsltarget)
    dw !ACTION_NUMFIELD
    dl <addr>
    db <start>, <end>, <increment>, <heldincrement>
    dw <jsltarget>
    db #$28, "<title>", #$FF
endmacro

macro cm_numfield_8bit(title, addr, start, end, increment, heldincrement, jsltarget)
    dw !ACTION_NUMFIELD_8BIT
    dl <addr>
    db <start>, <end>, <increment>, <heldincrement>
    dw <jsltarget>
    db #$28, "<title>", #$FF
endmacro

macro cm_numfield_decimal(title, addr, start, end, increment, heldincrement, jsltarget)
    dw !ACTION_NUMFIELD_DECIMAL
    dl <addr>
    db <start>, <end>, <increment>, <heldincrement>
    dw <jsltarget>
    db #$28, "<title>", #$FF
endmacro

macro cm_numfield_word(title, addr, start, end, increment, heldincrement, jsltarget)
    dw !ACTION_NUMFIELD_WORD
    dl <addr>
    dw <start>, <end>, <increment>, <heldincrement>
    dw <jsltarget>
    db #$28, "<title>", #$FF
endmacro

macro cm_numfield_hex(title, addr, start, end, increment, heldincrement, jsltarget)
    dw !ACTION_NUMFIELD_HEX
    dl <addr>
    db <start>, <end>, <increment>, <heldincrement>
    dw <jsltarget>
    db #$28, "<title>", #$FF
endmacro

macro cm_numfield_hex_word(title, addr)
    dw !ACTION_NUMFIELD_HEX_WORD
    dl <addr>
    db #$28, "<title>", #$FF
endmacro

macro cm_numfield_color(title, addr, jsltarget)
    dw !ACTION_NUMFIELD_COLOR
    dl <addr>
    dw <jsltarget>
    db #$28, "<title>", #$FF
endmacro

macro cm_numfield_sound(title, addr, start, end, increment, heldincrement, jsltarget)
    dw !ACTION_NUMFIELD_SOUND
    dl <addr>
    db <start>, <end>, <increment>, <heldincrement>
    dw <jsltarget>
    db #$28, "<title>", #$FF
endmacro

macro cm_toggle(title, addr, value, jsltarget)
    dw !ACTION_TOGGLE
    dl <addr>
    db <value>
    dw <jsltarget>
    db #$28, "<title>", #$FF
endmacro

macro cm_toggle_inverted(title, addr, value, jsltarget)
    dw !ACTION_TOGGLE_INVERTED
    dl <addr>
    db <value>
    dw <jsltarget>
    db #$28, "<title>", #$FF
endmacro

macro cm_toggle_bit(title, addr, mask, jsltarget)
    dw !ACTION_TOGGLE_BIT
    dl <addr>
    dw <mask>
    dw <jsltarget>
    db #$28, "<title>", #$FF
endmacro

macro cm_toggle_bit_inverted(title, addr, mask, jsltarget)
    dw !ACTION_TOGGLE_BIT_INVERTED
    dl <addr>
    dw <mask>
    dw <jsltarget>
    db #$28, "<title>", #$FF
endmacro

macro cm_jsl(title, routine, argument)
    dw !ACTION_JSL
    dw <routine>
    dw <argument>
    db #$28, "<title>", #$FF
endmacro

macro cm_jsl_submenu(title, routine, argument)
    dw !ACTION_JSL_SUBMENU
    dw <routine>
    dw <argument>
    db #$28, "<title>", #$FF
endmacro

macro cm_mainmenu(title, target)
    %cm_jsl("<title>", #action_mainmenu, <target>)
endmacro

macro cm_submenu(title, target)
    %cm_jsl_submenu("<title>", #action_submenu, <target>)
endmacro

macro cm_preset(title, target)
    %cm_jsl_submenu("<title>", #action_load_preset, <target>)
endmacro

macro cm_ctrl_shortcut(title, addr)
    dw !ACTION_CTRL_SHORTCUT
    dl <addr>
    db #$28, "<title>", #$FF
endmacro

macro cm_ctrl_input(title, addr, routine, argument)
    dw !ACTION_CTRL_INPUT
    dl <addr>
    dw <routine>
    dw <argument>
    db #$28, "<title>", #$FF
endmacro

macro setmenubank()
    PHK : PHK : PLA
    STA !ram_cm_menu_bank
endmacro


; ----------
; SFX Macros
; ----------

macro sfxmove() ; Move Cursor
    PHP : %a8()
    LDA !sram_customsfx_move : JSL !Play_SFX
    PLP
endmacro

macro sfxconfirm() ; Confirm Selection
    PHP : %a8()
    LDA !sram_customsfx_confirm : JSL !Play_SFX
    PLP
endmacro

macro sfxtoggle() ; Toggle
    PHP : %a8()
    LDA !sram_customsfx_toggle : JSL !Play_SFX
    PLP
endmacro

macro sfxnumber() ; Number Selection
    PHP : %a8()
    LDA !sram_customsfx_number : JSL !Play_SFX
    PLP
endmacro

macro sfxgoback() ; Go Back
    PHP : %a8()
    LDA !sram_customsfx_goback : JSL !Play_SFX
    PLP
endmacro

macro sfxfail()
    PHP : %a8()
    LDA !sram_customsfx_fail : JSL !Play_SFX
    PLP
endmacro

macro sfxquake()
    PHP : %a8()
    LDA #$2B : JSL !Play_SFX
    PLP
endmacro

macro sfxsave()
    PHP : %a8()
    LDA #$09 : JSL !Play_SFX
    PLP
endmacro

