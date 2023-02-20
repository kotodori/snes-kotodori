.include "../registers.inc"

; BG1 の TileMap($4000 - $4400)を 0 で埋める。起動直後に呼ばれることを期待している。
.macro clearTileMap
  rep #$30
.a16
.i16

  lda #$4000
  sta rVRamAddress

  ldy #$0400

  lda #$0000
loop:

  sta rVRamDataWrite
  dey
  bne loop
.endmacro
