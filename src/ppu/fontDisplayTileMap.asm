; BG1 の TileMap(#$4000 - #$4400)を 16×16 フォント表示用の配列に並び替える
.macro fontDisplayTileMap
  pea $0000
  plb
  plb

  ldx #$4000
  stx rVRamAddress

  ldy #$0400

  lda #$0000
loop:
  sta rVRamDataWrite
  inc a

  dey
  bne loop
.endmacro
