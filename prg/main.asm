.segment "HEADER"
    .byte "NES", $1a
    .byte $01           ; 16KiB ROM
    .byte $01           ;  8KiB ROM     [ make ram later ]
    .byte $00           ; vertical | no battery
    .byte $08           ; iNES2
    .byte $00           ; mapper/submapper
    .byte $00           ; rom amts msb
    .byte $00           ; prgram/eeprom
    .byte $00           ; chr-ram/nvram
    .byte $00           ; ntsc cpu
    .byte $00           ; no expansion
    .byte $00           ; misc roms
    .byte $3E           ; gamecube controller [ this will not work on anything other than mesen-xg ]

; summary
;   24KiB ROM with gamecube controllers as expanmsion
.segment "CODE"
reset:
    sei        ; ignore IRQs
    cld        ; disable decimal mode
    ldx #$40
    stx $4017  ; disable APU frame IRQ
    ldx #$ff
    txs        ; Set up stack
    inx        ; now X = 0
    stx $2000  ; disable NMI
    stx $2001  ; disable rendering
    stx $4010  ; disable DMC IRQs

    ; Optional (omitted):
    ; Set up mapper and jmp to further init code here.

    ; The vblank flag is in an unknown state after reset,
    ; so it is cleared here to make sure that @vblankwait1
    ; does not exit immediately.
    bit $2002

    ; First of two waits for vertical blank to make sure that the
    ; PPU has stabilized
@vblankwait1:  
    bit $2002
    bpl @vblankwait1

    ; We now have about 30,000 cycles to burn before the PPU stabilizes.
    ; One thing we can do with this time is put RAM in a known state.
    ; Here we fill it with $00, which matches what (say) a C compiler
    ; expects for BSS.  Conveniently, X is still 0.
    txa
@clrmem:
    sta $000,x
    sta $100,x
    sta $200,x
    sta $300,x
    sta $400,x
    sta $500,x
    sta $600,x
    sta $700,x
    inx
    bne @clrmem

    ; Other things you can do between vblank waits are set up audio
    ; or set up other mapper registers.
   
@vblankwait2:
    bit $2002
    bpl @vblankwait2

forever:
    jmp forever

.segment "VECTORS"
    .addr $0000
    .addr reset
    .addr $0000