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
  ldy #$000f

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
  rep #$20
  .a16

  lda #$0000
  pha
  plb

  lda rControllerPort1
  sta gControllerInput1
endFunction
