; --------------------- ;
; Aladdin Practice Hack ;
;   by InsaneFirebat    ;
; --------------------- ;

; forked from https://github.com/tewtal/sm_practice_hack

lorom

; Expand the rom to 2MB
; Free space starts at bank $A8
org $BFFFFF
    db #$FF

table ../resources/normal.tbl
incsrc macros.asm
incsrc defines.asm
incsrc ../disassembly/research.asm ; for exporting symbols with asar

incsrc init.asm ; $BFE000
incsrc controllerhooks.asm ; $BFB000
incsrc hudtimers.asm ; $BF8000
incsrc menu.asm ; $BE8000
incsrc mainmenu.asm ; $BEC000
incsrc misc.asm ; $BFC000
incsrc rng.asm ; $BFD000

if !FEATURE_SAVESTATES
incsrc save.asm ; $BFF000
endif
