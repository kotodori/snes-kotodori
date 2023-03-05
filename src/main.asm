;----------------------------------------------------------------------------
;   SNES Startup Routine
;     Copyright (C) 2007, Tekepen
;----------------------------------------------------------------------------
.setcpu "65816"

.import InitRegs
.import printControllerInputs
.import readControllerInputs

.segment "RODATA"
Palette:
  .incbin "../assets/palette.bin"
Font:
  .incbin "../assets/font.bin"

.include "ppu/loadWithAssetAddress.inc"
.include "ppu/clearBG1TileMap.asm"
.include "ppu/transfer16x16Font.inc"

.segment "STARTUP"
.proc Reset
  sei
  clc
  xce ; Native Mode
  phk
  plb ; DB = 0

  clearBG1TileMap ; BG1 のタイルマップをクリアする

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
  plb

  transfer16x16Font #$0000, $0000

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

  jsr printControllerInputs
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
