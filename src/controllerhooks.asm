
; Hijack after gameplay processing?
org $8182E6
    JSL ControllerHooks


org $BFB000
print pc, " controller hooks end"
ControllerHooks:
{
    PHP : PHB
    PEA $8080 : PLB : PLB
    %ai16() : PHA
    LDA !AL_CONTROLLER_PRI_NEW : BNE +

  .done
    ; No shortcuts configured
    PLA
    PLB : PLP
    JML $81BD31 ; overwritten JSL

+   LDA !AL_CONTROLLER_PRI : CMP !sram_ctrl_save_state : BNE +
    AND !AL_CONTROLLER_PRI_NEW : BEQ +
if !FEATURE_SAVESTATES
    JMP .save_state
endif

+   LDA !AL_CONTROLLER_PRI : CMP !sram_ctrl_load_state : BNE +
    AND !AL_CONTROLLER_PRI_NEW : BEQ +
if !FEATURE_SAVESTATES
    JMP .load_state
endif

+   LDA !AL_CONTROLLER_PRI : CMP !sram_ctrl_next_level : BNE +
    AND !AL_CONTROLLER_PRI_NEW : BEQ +
    JMP .next_level

+   LDA !AL_CONTROLLER_PRI : CMP !sram_ctrl_kill_Aladdin : BNE +
    AND !AL_CONTROLLER_PRI_NEW : BEQ +
    JMP .kill_Aladdin

+   LDA !AL_CONTROLLER_PRI : CMP !sram_ctrl_refill : BNE +
    AND !AL_CONTROLLER_PRI_NEW : BEQ +
    JMP .refill

+   LDA !AL_CONTROLLER_PRI : CMP !sram_ctrl_update_timers : BNE +
    AND !AL_CONTROLLER_PRI_NEW : BEQ +
    JMP .update_timers

+   LDA !AL_CONTROLLER_PRI : CMP !sram_ctrl_soft_reset : BNE +
    AND !AL_CONTROLLER_PRI_NEW : BEQ +
    JMP .soft_reset

if !DEV_BUILD
+   LDA !AL_CONTROLLER_PRI : CMP !sram_ctrl_test_code : BNE +
    AND !AL_CONTROLLER_PRI_NEW : BEQ +
    JMP .test_code
endif

+   LDA !AL_CONTROLLER_PRI : CMP !sram_ctrl_menu : BNE +
    AND !AL_CONTROLLER_PRI_NEW : BEQ +
    JMP .menu

+   JMP .done

if !FEATURE_SAVESTATES
  .save_state
    JSL save_state
    %ai16()
    JMP .done

  .load_state
    JSL load_state
    %ai16()
    JMP .done
endif

  .next_level
    LDA !AL_Level_index : AND #$00FF : CMP #$0013 : BPL +
    JSL Inc2NextLevel
+   JMP .done

  .kill_Aladdin
    PHP : %a8()
    %ai8()
    LDA !AL_Level_index : CMP #$13 : BPL +
    INC !AL_lives
    JSL $838052 ; KillAladdin_long
+   PLP
    JMP .done

  .refill
    LDA #$0099 : STA !cm_AL_apples : STA !AL_apples
    LDA !AL_hearts_max : STA !cm_AL_hearts : STA !AL_hearts
    LDA !AL_lives : CMP #$000A : BPL +
    INC !AL_lives
    LDA !cm_AL_lives : INC : STA !cm_AL_lives
+   JMP .done

  .update_timers
    JSL UpdateTimersLocal
    JMP .done

  .soft_reset
    %ai8()
    JML $008000

  .test_code
    PHP : %ai16()
    JSL TestCodeArea
    PLP
    JMP .done

  .menu
    JSL cm_start
    JMP .done
}

print pc, " controller hooks end"
warnpc $BFBFBF ; misc.asm