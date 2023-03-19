;----------------------------------------------------------------------------
;   SNES Startup Routine
;     Copyright (C) 2007, Tekepen
;----------------------------------------------------------------------------
.setcpu "65816"

.import InitRegs
.import printControllerInputs
.import readControllerInputs
.import transferCharacter
.import textWritePosition

.segment "RODATA"
Palette:
  .incbin "../assets/palette.bin"
FontHeader:
  .incbin "../assets/fontHeader.bin"
FontBody:
  .incbin "../assets/fontBody.bin"
Text:
  .incbin "../assets/test-utf-16le.txt"
.export FontHeader, FontBody, Text

.include "./registers.inc"
.include "ppu/loadWithAssetAddress.inc"
.include "ppu/clearBG1Tile.asm"
.include "ppu/fontDisplayTileMap.asm"
.include "ppu/transfer16x16Font.inc"

.segment "STARTUP"
.proc Reset
  sei
  clc
  xce ; Native Mode
  phk
  plb ; DB = 0

  clearBG1Tile ; BG1 のタイルマップをクリアする
  fontDisplayTileMap ; BG1 にフォントを並べて表示する

  rep #$30 ; A,I 16bit
.a16
.i16

  ldx #$1fff ; Stack pointer value set
  txs

  jsr InitRegs

  sep #$20
.a8

  lda #$40
  sta $2107

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

  rep #$30 ; A,I 16bit
.a16
.i16

  lda #$0000
  sta $0104 ; textWritePosition
  
  ldx #$0002
@transferTextLoop:
  jsr transferCharacter ; テキストの転送
  inx
  inx
  cpx #$0200
  bne @transferTextLoop

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

  ; jsr printControllerInputs
  ; jsr readControllerInputs

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
