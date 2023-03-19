; BG1 の Tile(#$0000 - #$4000)を 0 で埋めてクリアする。起動直後に呼ばれることを期待している。
.macro clearBG1Tile
  rep #$30 ; A,I 16bit
.a16
.i16

  lda #$0000
  sta rVRamAddress

  ldy #$4000

  lda #$0000

@loop:
  sta rVRamDataWrite
  dey
  bne @loop
.endmacro
