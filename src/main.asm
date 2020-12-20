;----------------------------------------------------------------------------
;   SNES Startup Routine
;     Copyright (C) 2007, Tekepen
;----------------------------------------------------------------------------
.setcpu "65816"

.include "common.inc"

.import InitRegs
.import printControllerInput
.import readControllerInputs

.segment "RODATA"
Palette:
  .incbin "palette.bin"
Pattern:
  .incbin "tile.bin"
String:
  .asciiz "HELLO, WORLD!"

.segment "STARTUP"
.proc Reset
  sei
  clc
  xce ; Native Mode
  phk
  plb ; DB = 0

  rep #$30 ; A,I 16bit
.a16
.i16
  ldx #$1fff
  txs

  jsr InitRegs

  sep #$20
.a8
  lda #$40
  sta $2107
  stz $210b

; Copy Palettes
  phb

  stz $2121
  ldy #$0200
  ldx #$0000

  lda #$00
  pha

copypal:
  lda #^Palette
  pha
  plb

  lda Palette, x
  plb
  sta $2122
  lda #$00
  pha

  inx
  dey
  bne copypal
  plb

; Copy Patterns
  lda #$00
  pha
  plb

  rep #$20
.a16
  lda #$0000
  sta $2116
  ldy #$2000
  ldx #$0000

  lda #$00
  pha

copyptn:
  lda #^Pattern
  pha
  plb

  lda Pattern, x

  plb
  plb
  plb

  sta $2118

  lda #$00
  pha

  inx
  inx
  dey
  bne copyptn
  plb


; Copy NameTable
  lda #$00
  pha

  lda #$41a9
  sta $2116
  ldy #$000d
  ldx #$0000
  lda #$0000
copyname:
  sep #$20
.a8
  lda #^String
  pha
  plb

  lda String, x

  plb

  rep #$20
.a16
  sta $2118

  lda #$00
  pha
  plb

  inx
  dey
  bne copyname

  plb


  lda #$01
  sta $212c
  stz $212d
  lda #$0f
  sta $2100

  sep #$20
.a8

  ; Enable NMI
  lda #$80
  sta $4200

  rep #$20
.a16


mainloop:
  jmp mainloop

  rti
.endproc

.proc VBlank
  pha
  phx
  php

  jsr printControllerInput
  jsr readControllerInputs

  plp
  plx
  pla
  rti
.endproc

.proc EmptyInt
  rti
.endproc

; カートリッジ情報
.segment "TITLE"
  .byte "KOTODORI             " ; Game Title
.segment "HEADER"
  .byte $31                     ; 0x01:HiRom, 0x30:FastRom(3.57MHz)
  .byte $00                     ; ROM only
  .byte $0c                     ; 32KB=256KBits
  .byte $00                     ; RAM Size (8KByte * N)
  .byte $00                     ; NTSC
  .byte $01                     ; Licensee
  .byte $00                     ; Version
  .word $CDCD
  .word $3232
  .byte $ff, $ff, $ff, $ff      ; unknown

  .word .loword(EmptyInt)       ; Native:COP
  .word .loword(EmptyInt)       ; Native:BRK
  .word .loword(EmptyInt)       ; Native:ABORT
  .word .loword(VBlank)         ; Native:NMI
  .word $0000
  .word .loword(EmptyInt)       ; Native:IRQ

  .word $0000
  .word $0000

  .word .loword(EmptyInt)       ; Emulation:COP
  .word .loword(EmptyInt)
  .word .loword(EmptyInt)       ; Emulation:ABORT
  .word .loword(VBlank)         ; Emulation:NMI
  .word .loword(Reset)          ; Emulation:RESET
  .word .loword(EmptyInt)       ; Emulation:IRQ/BRK
