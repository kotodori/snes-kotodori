.setcpu "65816"

.include "common.inc"
.include "controller.inc"
.include "registers.inc"

.segment "STARTUP"

.export printControllerInput
function printControllerInput
  rep #$20
  .a16

  lda #$0000
  pha
  plb

  lda gControllerInput1
  .define buffer $01
  sta buffer

  lda #$41a9
  sta rVRamAddress

  .i16
  ldy #$0010

  copyInput:
    .define ascii0 $0030
    .define ascii1 $0031
    lda #ascii0

    asl buffer
    bcc store

    lda #ascii1

    store:
    sta $2118

    dey
    bne copyInput

endFunction

.export readControllerInputs
; コントローラーの入力を読み、 gControllerInput1 に保存する。 VBlank の最後に呼ばれることを期待している。
function readControllerInputs
  sep #$20
  .a8

  lda #$00
  pha
  plb

  lda #$01
  sta $4016

  stz $4016
  nop
  nop

  ldx #$0010
  loop:
    lda $4016

    rep #$20
    .a16

    lsr
    rol gControllerInput1

    sep #$20
    .a8

    dex
    bne loop

endFunction
