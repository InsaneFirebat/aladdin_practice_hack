
; Jafar
org $84A18B
    JSL RNGControl_Jafar


; Snake
org $8488C9
    JSL RNGControl_Snake


; Snake Floor
org $848861
    JSL RNGControl_SnakeFloor


org $BFD000
print pc, " rng.asm start"

RNGControl_Jafar:
{
    LDA !ram_rng_jafar : BEQ .normalRNG
    CMP #$01 : BEQ .staff
    CMP #$02 : BEQ .summon

  .staff
    JSL $81AE8A ; Enemy_ChooseAttack
    LDA #$00
    RTL

  .summon
    JSL $81AE8A ; Enemy_ChooseAttack
    LDA #$02
    RTL

  .normalRNG
    JML $81AE8A ; Enemy_ChooseAttack
    
}

RNGControl_Snake:
{
    LDA !ram_rng_snake : BEQ .normalRNG
    CMP #$01 : BEQ .eggs
    CMP #$02 : BEQ .strike

  .strike
    JSL $81AE8A ; Enemy_ChooseAttack
    LDA #$00
    RTL

  .eggs
    JSL $81AE8A ; Enemy_ChooseAttack
    LDA #$02
    RTL
  
  .normalRNG
    JML $81AE8A ; Enemy_ChooseAttack
}

RNGControl_SnakeFloor:
{
    LDA !ram_rng_snakefloor : BEQ .normalRNG
    CMP #$01 : BEQ .slow
    CMP #$02 : BEQ .fast

  .slow
    JSL $81AE8A ; Enemy_ChooseAttack
    LDA #$01
    RTL

  .fast
    JSL $81AE8A ; Enemy_ChooseAttack
    LDA #$02
    RTL
  
  .normalRNG
    JML $81AE8A ; Enemy_ChooseAttack
}


print pc, " rng.asm end"
warnpc $BFE000 ; init.asm
