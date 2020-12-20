.setcpu "65816"

.include "common.inc"
.include "controller.inc"
.include "registers.inc"

.segment "STARTUP"

.macro renderWord addr
  .define ascii0 $0030
  .define ascii1 $0031
  .local ascii0
  .local ascii1
  .local loop
  .local store

  ldy #$0010
  loop:
    lda #ascii0

    asl addr, x
    bcc store

    lda #ascii1

    store:
    sta rVRamDataWrite

    dey
    bne loop
.endmacro

.export printControllerInput
function printControllerInput
  rep #$30
  .a16
  .i16

  lda #$0000
  pha
  plb

  .define buffer1 $03
  .define buffer2 $01
  lda gControllerInput1
  pha
  lda gControllerInput2
  pha
  tsx

  phd
  lda #$0000
  pha
  pld

  lda #$41a9
  sta rVRamAddress

  renderWord buffer1

  lda #$41e9
  sta rVRamAddress

  renderWord buffer2

  pld
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
  sta rNesControllerPort1

  stz rNesControllerPort1
  nop
  nop

  ldx #$0010
  loop:
    lda rNesControllerPort1
    rep #$20
    .a16
    lsr
    rol gControllerInput1

    sep #$20
    .a8
    lda rNesControllerPort2
    rep #$20
    .a16
    lsr
    rol gControllerInput2

    sep #$20
    .a8

    dex
    bne loop
endFunction
