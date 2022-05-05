; Circumventing SRAM checks
; In most cases, a few instructions are overwritten where it could have been a single byte
; STA is changed to LDA so that SRAM is never written to
; The branch at the end is changed to BRA so it is always taken
; This keeps CPU timing neutral and protects our SRAM


; Notes:
; $81A396 and $84AF8B have some sneaky DB swaps to bank $70
; $1461 = inc'd if SRAM detected
; $1475 = value loaded from SRAM
; $1476 = index to value loaded from SRAM
; $81BE5A looks like an SRAM trap but haven't seen it execute yet (runs if $0331 = 1)
; couple others I probably should have documented


; triggered manually with $0331
org $81BE69
    LDA $700000,X ;: skip 28 : BRA $12

org $81BE89
    BRA $12

org $81BE91
    LDA $700001,X : LDA $700001,X : INC ; moved INC instead of changing BRA

; leaving password screen?
org $84AF8B
    LDA $1522,Y : CMP $1522,Y : BRA $19

; level loading
org $A5E54E
    LDA $700000,X ; STA -> LDA

; carpet awaken cutscene, related to above
org $A5EE34
    BRA $03

; level loading
org $81A39E
    LDA $0000,X : CMP $0000,X
    LDA $0000,X : CMP $0000,X : BRA $1D

; guard notices Al
org $839896
    LDA $700023,X : CMP $700023,X : BRA $0E

; swinging
org $81D724
    LDA $701234 : CMP $701234
    LDA $701234,X : CMP $701234,X : BRA $03

; spawn vase
org $83CE80
    LDA $701000,X : CMP $701000,X : BRA $10

; spawn walking pot
org $83B4C3
    LDA $701000,X : CMP $701000,X : BRA $06

; scarab released
org $839F46
    LDA $702000 : CMP $702000 : BRA $0A

; scroll into first boss area
org $80A16C
    LDA $700F10 : CMP $700F10 : BNE $28

; exit stage clear / password screen
org $81F91C
    LDA $701399 : CMP $701399 : BRA $14

; kill patrolling bat
org $83A3FA
    LDA $701331 : CMP $701331 : BRA $0D

; spawn boulder
org $83B298
    LDA $701200

; small fireball, lava side-scroller
org $83D6DC
    LDA $703000,X : CMP $703000,X : BRA $06

; carpet ride lava wave
org $83F0C2
    LDA $0000,X : CMP $0000,X : BRA $0F

; spawn flying pot
org $83ECD9
    LDA $703000,X : CMP $703000,X : BRA $0B

; interaction with genie face platforms
org $83DCAC
    LDA $701000 : CMP $701000 : BRA $10

; spawn genie tongue platforms
org $83E6F0
    LDA $0000,X : CMP $0000,X : BRA $0F

; snek attacks
org $84863C
    LDA $0000,X : CMP $0000,X : BRA $0E
