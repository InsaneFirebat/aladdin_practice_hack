; SD2SNES Savestate code
; by acmlm, total, Myria
; adapted for Aladdin by InsaneFirebat


; Savestate code variables
!SS_BANK = $BFBF
!SRAM_DMA_BANK = $770000
!SRAM_SAVED_SP = $77000C
!SRAM_SAVED_RNG = $77000E
!SRAM_SAVED_SYNC = $77001C
!SRAM_SAVED_MUSIC1 = $77002C
!SRAM_SAVED_MUSIC2 = $77002E
!SRAM_SAVED_APU = $77003C
!SRAM_SAVED_LAST_APU = $77003E
!SRAM_SAVED_STATE = $77004C
!SRAM_SAVED_STACK = $770100


org $BFF000
print pc, " save.asm start"
; These can be modified to do game-specific things before and after saving and loading
; Both A and X/Y are 16-bit here

; Aladdin specific features to restore the correct music when loading a state below
pre_load_state:
{
    %a8()
    LDA !AL_SFX_sync : STA !SRAM_SAVED_SYNC
    LDA !AL_Music_flag_0371 : STA !SRAM_SAVED_MUSIC1
    LDA !AL_MusicHandler_flag : STA !SRAM_SAVED_MUSIC2
    LDA !AL_APUCommand_to2140 : STA !SRAM_SAVED_APU
    %a16()
    LDA !AL_RNG_1 : STA !SRAM_SAVED_RNG

    LDX #$0016
-   LDA $0313,X : STA !SRAM_SAVED_STACK,X
    DEX #2 : BPL -

    RTS
}

post_load_state:
{
    %ai8()
    LDA !SRAM_SAVED_SYNC : STA !AL_SFX_sync
    LDA !SRAM_SAVED_MUSIC1 : STA !AL_Music_flag_0371
    LDA !SRAM_SAVED_MUSIC2 : STA !AL_MusicHandler_flag

    LDA !SRAM_SAVED_LAST_APU : CMP #$F6 : BNE +
    LDA #$F0 : JSL !Play_SFX ; send silence command if music is faded out

+   LDA !sram_loadstate_music : BEQ +
    LDA !AL_APUCommand_to2140 : CMP !SRAM_SAVED_APU : BEQ +
    JSL !Play_Music_Prep

+   %ai16()
    LDA !sram_loadstate_rng : BEQ +
    DEC : BEQ ++
    JSL !Cycle_RNG : BRA +
++  LDA !SRAM_SAVED_RNG : STA !AL_RNG_1

+   LDX #$0016
-   LDA !SRAM_SAVED_STACK,X : STA $0313,X
    DEX #2 : BPL -

    RTS
}

; These restored registers are game-specific AND needs to be updated for different games
register_restore_return:
{
+   %a8()
    ; check $0C24 for #$8919 to detect snek
    ; set BGMode to #$02
    LDX $0C24 : CPX #$8919 : BNE +
    LDA #$02 : BRA ++
+   LDA !AL_2105_BGMode
++  STA $2105
    LDA !AL_4200_NMITIMEN : STA $4200
    LDA !AL_2100_INIDISP : STA $0F2100
    RTL
}

save_state:
{
    PEA $0000 : PLB : PLB

    ; Store DMA registers to SRAM
    %a8()
    LDY #$0000 : TYX

  .save_dma_regs
    LDA $4300,X : STA !SRAM_DMA_BANK,X
    INX
    INY : CPY #$000B : BNE .save_dma_regs
    CPX #$007B : BEQ .save_dma_regs_done
    INX #5 : LDY #$0000
    BRA .save_dma_regs

  .save_dma_regs_done
    %ai16()
    LDX #save_write_table
    JMP run_vm

save_write_table:
    ; Turn PPU off
    dw $1000|$2100, $80
    dw $1000|$4200, $00
    ; Single address, B bus -> A bus.  B address = reflector to WRAM ($2180).
    dw $0000|$4350, $8080  ; direction = B->A, byte reg, B addr = $2180
    ; Copy WRAM 7E0000-7E7FFF to SRAM 710000-717FFF.
    dw $0000|$4352, $0000  ; A addr = $xx0000
    dw $0000|$4354, $0071  ; A addr = $71xxxx, size = $xx00
    dw $0000|$4356, $0080  ; size = $80xx ($8000), unused bank reg = $00.
    dw $0000|$2181, $0000  ; WRAM addr = $xx0000
    dw $1000|$2183, $00    ; WRAM addr = $7Exxxx  (bank is relative to $7E)
    dw $1000|$420B, $20    ; Trigger DMA on channel 5
    ; Copy WRAM 7E8000-7EFFFF to SRAM 720000-727FFF.
    dw $0000|$4352, $0000  ; A addr = $xx0000
    dw $0000|$4354, $0072  ; A addr = $72xxxx, size = $xx00
    dw $0000|$4356, $0080  ; size = $80xx ($8000), unused bank reg = $00.
    dw $0000|$2181, $8000  ; WRAM addr = $xx8000
    dw $1000|$2183, $00    ; WRAM addr = $7Exxxx  (bank is relative to $7E)
    dw $1000|$420B, $20    ; Trigger DMA on channel 5
    ; Copy WRAM 7F0000-7F7FFF to SRAM 730000-737FFF.
    dw $0000|$4352, $0000  ; A addr = $xx0000
    dw $0000|$4354, $0073  ; A addr = $73xxxx, size = $xx00
    dw $0000|$4356, $0080  ; size = $80xx ($8000), unused bank reg = $00.
    dw $0000|$2181, $0000  ; WRAM addr = $xx0000
    dw $1000|$2183, $01    ; WRAM addr = $7Fxxxx  (bank is relative to $7E)
    dw $1000|$420B, $20    ; Trigger DMA on channel 5
    ; Copy WRAM 7F8000-7FFFFF to SRAM 740000-747FFF.
    dw $0000|$4352, $0000  ; A addr = $xx0000
    dw $0000|$4354, $0074  ; A addr = $74xxxx, size = $xx00
    dw $0000|$4356, $0080  ; size = $80xx ($8000), unused bank reg = $00.
    dw $0000|$2181, $8000  ; WRAM addr = $xx8000
    dw $1000|$2183, $01    ; WRAM addr = $7Fxxxx  (bank is relative to $7E)
    dw $1000|$420B, $20    ; Trigger DMA on channel 5
    ; Address pair, B bus -> A bus.  B address = VRAM read ($2139).
    dw $0000|$4350, $3981  ; direction = B->A, word reg, B addr = $2139
    dw $1000|$2115, $0000  ; VRAM address increment mode.
    ; Copy VRAM 0000-7FFF to SRAM 750000-757FFF.
    dw $0000|$2116, $0001  ; VRAM address >> 1.
    dw $9000|$2139, $0000  ; VRAM dummy read.
    dw $0000|$4352, $0000  ; A addr = $xx0000
    dw $0000|$4354, $0075  ; A addr = $75xxxx, size = $xx00
    dw $0000|$4356, $0080  ; size = $80xx ($0000), unused bank reg = $00.
    dw $1000|$420B, $20    ; Trigger DMA on channel 5
    ; Copy VRAM 8000-7FFF to SRAM 760000-767FFF.
    dw $0000|$2116, $4001  ; VRAM address >> 1.
    dw $9000|$2139, $0000  ; VRAM dummy read.
    dw $0000|$4352, $0000  ; A addr = $xx0000
    dw $0000|$4354, $0076  ; A addr = $76xxxx, size = $xx00
    dw $0000|$4356, $0080  ; size = $80xx ($0000), unused bank reg = $00.
    dw $1000|$420B, $20    ; Trigger DMA on channel 5
    ; Copy CGRAM 000-1FF to SRAM 772000-7721FF.
    dw $1000|$2121, $00    ; CGRAM address
    dw $0000|$4350, $3B80  ; direction = B->A, byte reg, B addr = $213B
    dw $0000|$4352, $2000  ; A addr = $xx2000
    dw $0000|$4354, $0077  ; A addr = $77xxxx, size = $xx00
    dw $0000|$4356, $0002  ; size = $02xx ($0200), unused bank reg = $00.
    dw $1000|$420B, $20    ; Trigger DMA on channel 5
    ; Done
    dw $0000, .save_return

  .save_return:
    PEA $0000
    PLB
    PLB

    %ai16()
    TSC : STA !SRAM_SAVED_SP
    LDA !AL_Last_APU_Command : STA !SRAM_SAVED_LAST_APU
    LDA #$5AFE : STA !SRAM_SAVED_STATE
    JMP register_restore_return
}

load_state:
{
    LDA !SRAM_SAVED_STATE : CMP #$5AFE : BEQ +
    %sfxfail()
    RTL

+   JSR pre_load_state
    PEA $0000 : PLB : PLB

    %a8()
    LDX #load_write_table
    JMP run_vm

load_write_table:
    ; Disable HDMA
    dw $1000|$420C, $00
    ; Turn PPU off
    dw $1000|$2100, $80
    dw $1000|$4200, $00
    ; Single address, A bus -> B bus.  B address = reflector to WRAM ($2180).
    dw $0000|$4350, $8000  ; direction = A->B, B addr = $2180
    ; Copy SRAM 710000-717FFF to WRAM 7E0000-7E7FFF.
    dw $0000|$4352, $0000  ; A addr = $xx0000
    dw $0000|$4354, $0071  ; A addr = $71xxxx, size = $xx00
    dw $0000|$4356, $0080  ; size = $80xx ($8000), unused bank reg = $00.
    dw $0000|$2181, $0000  ; WRAM addr = $xx0000
    dw $1000|$2183, $00    ; WRAM addr = $7Exxxx  (bank is relative to $7E)
    dw $1000|$420B, $20    ; Trigger DMA on channel 5
    ; Copy SRAM 720000-727FFF to WRAM 7E8000-7EFFFF.
    dw $0000|$4352, $0000  ; A addr = $xx0000
    dw $0000|$4354, $0072  ; A addr = $72xxxx, size = $xx00
    dw $0000|$4356, $0080  ; size = $80xx ($8000), unused bank reg = $00.
    dw $0000|$2181, $8000  ; WRAM addr = $xx8000
    dw $1000|$2183, $00    ; WRAM addr = $7Exxxx  (bank is relative to $7E)
    dw $1000|$420B, $20    ; Trigger DMA on channel 5
    ; Copy SRAM 730000-737FFF to WRAM 7F0000-7F7FFF.
    dw $0000|$4352, $0000  ; A addr = $xx0000
    dw $0000|$4354, $0073  ; A addr = $73xxxx, size = $xx00
    dw $0000|$4356, $0080  ; size = $80xx ($8000), unused bank reg = $00.
    dw $0000|$2181, $0000  ; WRAM addr = $xx0000
    dw $1000|$2183, $01    ; WRAM addr = $7Fxxxx  (bank is relative to $7E)
    dw $1000|$420B, $20    ; Trigger DMA on channel 5
    ; Copy SRAM 740000-747FFF to WRAM 7F8000-7FFFFF.
    dw $0000|$4352, $0000  ; A addr = $xx0000
    dw $0000|$4354, $0074  ; A addr = $74xxxx, size = $xx00
    dw $0000|$4356, $0080  ; size = $80xx ($8000), unused bank reg = $00.
    dw $0000|$2181, $8000  ; WRAM addr = $xx8000
    dw $1000|$2183, $01    ; WRAM addr = $7Fxxxx  (bank is relative to $7E)
    dw $1000|$420B, $20    ; Trigger DMA on channel 5
    ; Address pair, A bus -> B bus.  B address = VRAM write ($2118).
    dw $0000|$4350, $1801  ; direction = A->B, B addr = $2118
    dw $1000|$2115, $0000  ; VRAM address increment mode.
    ; Copy SRAM 750000-757FFF to VRAM 0000-7FFF.
    dw $0000|$2116, $0000  ; VRAM address >> 1.
    dw $0000|$4352, $0000  ; A addr = $xx0000
    dw $0000|$4354, $0075  ; A addr = $75xxxx, size = $xx00
    dw $0000|$4356, $0080  ; size = $80xx ($0000), unused bank reg = $00.
    dw $1000|$420B, $20    ; Trigger DMA on channel 5
    ; Copy SRAM 760000-767FFF to VRAM 8000-7FFF.
    dw $0000|$2116, $4000  ; VRAM address >> 1.
    dw $0000|$4352, $0000  ; A addr = $xx0000
    dw $0000|$4354, $0076  ; A addr = $76xxxx, size = $xx00
    dw $0000|$4356, $0080  ; size = $80xx ($0000), unused bank reg = $00.
    dw $1000|$420B, $20    ; Trigger DMA on channel 5
    ; Copy SRAM 772000-7721FF to CGRAM 000-1FF.
    dw $1000|$2121, $00    ; CGRAM address
    dw $0000|$4350, $2200  ; direction = A->B, byte reg, B addr = $2122
    dw $0000|$4352, $2000  ; A addr = $xx2000
    dw $0000|$4354, $0077  ; A addr = $77xxxx, size = $xx00
    dw $0000|$4356, $0002  ; size = $02xx ($0200), unused bank reg = $00.
    dw $1000|$420B, $20    ; Trigger DMA on channel 5
    ; Done
    dw $0000, load_return

load_return:
    %ai16()
    LDA !SRAM_SAVED_SP : TCS

    PEA $0000 : PLB : PLB

    ; rewrite inputs so that holding load won't keep loading, as well as rewriting saving input to loading input
    LDA !AL_CONTROLLER_PRI : EOR !sram_ctrl_save_state : ORA !sram_ctrl_load_state
    STA !AL_CONTROLLER_PRI : STA !AL_CONTROLLER_PRI_NEW : STA !AL_Current_Inputs

    %a8()
    LDX #$0000 : TXY

  .load_dma_regs
    LDA !SRAM_DMA_BANK,X : STA $4300,X
    INX
    INY : CPY #$000B : BNE .load_dma_regs
    CPX #$007B : BEQ .load_dma_regs_done
    INX #5 : LDY #$0000
    JMP .load_dma_regs

  .load_dma_regs_done
    ; Restore registers AND return.
    %ai16()
    JSR post_load_state
    JMP register_restore_return
}

run_vm:
; Data format: xx xx yy yy
; xxxx = little-endian address to write to .vm's bank
; yyyy = little-endian value to write
; If xxxx has high bit set, read AND discard instead of write.
; If xxxx has bit 12 set ($1000), byte instead of word.
; If yyyy has $DD in the low half, it means that this operation is a byte
; write instead of a word write.  If xxxx is $0000, end the VM.
{
    PEA !SS_BANK : PLB : PLB

  .vm
    %ai16()
    ; Read address to write to
    LDA $0000,X : BEQ .vm_done
    TAY
    INX #2
    ; Check for byte mode
    BIT #$1000 : BEQ .vm_word_mode
    AND #$EFFF : TAY
    %a8()

  .vm_word_mode
    ; Read value
    LDA $0000,X
    INX #2

  .vm_write
    ; Check for read mode (high bit of address)
    CPY #$8000 : BCS .vm_read
    STA $0000,Y
    BRA .vm

  .vm_read
    ; "Subtract" $8000 from y by taking advantage of bank wrapping.
    LDA $8000,Y
    BRA .vm

  .vm_done
    ; A, X AND Y are 16-bit at exit.
    ; Return to caller.  The word in the table after the terminator is the
    ; code address to return to.
    JMP ($0002,x)
}

print pc, " save.asm end"
