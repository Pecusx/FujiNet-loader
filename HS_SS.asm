           icl 'lib/ATARISYS.ASM'

	org $0600

    PLA     ; BASIC?

    SEI
    TSX
    STX BFENHI
    LDA #$0D
    STA $36
J74F
    LDA #$28    ; standard SIO speed
    STA AUDF3
    LDA #$00
    STA AUDF4
    STA STATUS
    LDA #$34
    STA PBCTL
    LDX #$80
J762
    DEX
    BNE J762
    LDA #$23
    JSR JS81A              ;[expand]
    LDA #$31
    STA CHKSUM
    STA SEROUT
    LDA #$52
    JSR JS826              ;[expand]
    LDA BUFRFL
    JSR JS826              ;[expand]
    LDA RECVDN
    JSR JS826              ;[expand]
    LDA CHKSUM
    JSR JS826              ;[expand]
J785
    LDA IRQST
    AND #$08
    BNE J785
    STA IRQEN
    JSR JS7E3              ;[expand]
    JSR JS7FE              ;[expand]
    LDY #$00
    STY CHKSUM
J799
    JSR JS7C6              ;[expand]
    STA (BUFRLO),Y
    JSR JS83A              ;[expand]
    INY
    CPY BFENLO
    BNE J799
    JSR JS7C6              ;[expand]
    CMP CHKSUM
    BEQ J7B8
J7AD
    LDY #$90
    STY STATUS
    LDX BFENHI
    TXS
    DEC $36
    BNE J74F
J7B8
    LDA #$00
    STA AUDC4
    LDA POKMSK
    STA IRQEN
    CLI
    LDY STATUS
    RTS
;--------------------------------------------------
JS7C6
J7C6
    LDA IRQST
    AND #$20
    BNE J7C6
    STA IRQEN
    LDA #$20
    STA IRQEN
    LDA SKSTAT
    STA SKRES
    AND #$20
    BEQ J7AD
    LDA SERIN
    RTS
;--------------------------------------------------
JS7E3
    LDY #$03
    JSR JS7ED              ;[expand]
    JSR JS7FE              ;[expand]
    LDY #$00
JS7ED
    LDA #<J7AD
    STA CDTMA1
    LDA #>J7AD
    STA CDTMA1+1
    LDA #$01
    LDX #$00
    JMP SETVBV             ;[expand]
;--------------------------------------------------
JS7FE
    LDA #$13
    JSR JS81A              ;[expand]
    LDA #$3C
    STA PBCTL
    JSR JS7C6              ;[expand]
    CMP #$44
    BCS J7AD
    LDA #$28
    STA AUDCTL
    LDA #$A8
    STA AUDC4
    RTS
;--------------------------------------------------
JS81A
    STA SKCTL
    STA SKRES
    LDA #$38
    STA IRQEN
    RTS
;--------------------------------------------------
JS826
    TAX
J827
    LDA IRQST
    AND #$10
    BNE J827
    STA IRQEN
    LDA #$10
    STA IRQEN
    TXA
    STA SEROUT
JS83A
    CLC
    ADC CHKSUM
    ADC #$00
    STA CHKSUM
    RTS