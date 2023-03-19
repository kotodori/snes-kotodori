.macro transfer16x16Font tileAddress, fontOffset
  phb
  phx
  phy
  pha

  lda #$00 ; DRAM 書き込み用のバンク $00 をここで指定しておく
  pha
  plb

  rep #$30
.a16
.i16

  lda tileAddress ; タイルの位置
  sta rVRamAddress

  ldx #$0000 ; 上半分の伝送をするので 0x00
  ldy #$4000 ; 転送する量

  sep #$20
.a8

transferLoop:
  lda #^FontBody
  pha
  plb

  lda FontBody + fontOffset, x

  plb

  sta rVRamDataWrite

  lda #$00 ; 2 bpp なので、残りのパレット分を埋める

  sta rVRamDataWrite + 1

  lda #$00
  pha

  inx
  dey
  bne transferLoop

  pla
  ply
  plx
  plb
.endmacro
