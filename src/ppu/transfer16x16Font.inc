.macro transfer16x16Font tileAddress, fontOffset
  phb
  phx
  phy
  pha

  rep #$30
.a16
.i16

  lda tileAddress ; タイルの位置
  sta rVRamAddress

  ; TODO: 16 bit のほうが手間が減りそうか考える
  sep #$30
.a8
.i8

  ldx #$00 ; 上半分の伝送をするので 0x00
  ldy #$10 ; 転送する量

  lda #$00 ; DRAM 書き込み用のバンク $00 をここで指定しておく
  pha
  plb

transferUpperBlock:
  lda #^Font
  pha
  plb

  lda Font + fontOffset, x

  plb

  sta rVRamDataWrite

  lda #$00 ; 2 bpp なので、残りのパレット分を埋める

  sta rVRamDataWrite + 1

  pha

  inx
  dey
  bne transferUpperBlock

  rep #$30
.a16
.i16

  lda tileAddress + $0080 ; 下半分の 8x16 分の大きさのタイルは 0x0080 先
  sta rVRamAddress

  sep #$30
.a8
.i8

  ldx #$10 ; 下半分の伝送をするので 0x10
  ldy #$10 ; 転送する量

  lda #$00 ; DRAM 書き込み用のバンク $00 をここで指定しておく
  pha
  plb

transferLowerBlock:
  lda #^Font
  pha
  plb

  lda Font + fontOffset, x

  plb

  sta rVRamDataWrite

  lda #$00 ; 2 bpp なので、残りのパレット分を埋める
  sta rVRamDataWrite + 1

  pha

  inx
  dey
  bne transferLowerBlock

  pla
  ply
  plx
  plb
.endmacro
