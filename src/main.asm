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

.include "./registers.inc"
.include "ppu/loadWithAssetAddress.inc"
.include "ppu/clearBG1Tile.asm"
.include "ppu/fontDisplayTileMap.asm"
.include "ppu/transfer16x16Font.inc"

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

.segment "STARTUP"
.proc Reset
  sei ; Set Interrupt flag

  clc
  xce ; Native Mode

  phk
  plb ; DB = 0

  jsr InitRegs

  rep #$30 ; A,I 16bit
.a16
.i16

  clearBG1Tile ; BG1 のタイルマップをクリアする
  fontDisplayTileMap ; BG1 にフォントを並べて表示する

  ldx #$1fff ; Stack pointer value set
  txs

  sep #$20
.a8

  lda #$40
  sta $2107 ; BG 1 Address and Size

; Copy Palettes
  phb

  stz $2121 ; Address for CG-RAM Write
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
  sta $2122 ; Data for CG-RAM Write
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
  sta $212c ; Background and Object Enable (Main Screen)
  stz $212d ; Background and Object Enable (Sub Screen)
  lda #$0f
  sta $2100 ; Screen Display Register

  sep #$20
.a8

  ; Enable NMI
  lda #$80
  sta $4200 ; NMI, V/H Count, and Joypad Enable

  rep #$20
.a16

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
  .byte $31                     ; ROM Type
  .byte $00                     ; Cartidge Type: ROM only
  .byte $0c                     ; ROM Size: 17 ~ 32MBit
  .byte $00                     ; RAM Size: No RAM
  .byte $00                     ; Destination Code: Japan
  .byte $33                     ; Fixed Value: 33H
  .byte $00                     ; Mask ROM Version
  .word $0000                   ; Complement Check
  .word $ffff                   ; Checksum
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
