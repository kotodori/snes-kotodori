.macro transfer16x16Font
  phb
  phx
  phy
  pha

  rep #$30
.a16
.i16

  lda #$0000
  sta rVRamAddress

  sep #$30
.a8
.i8

  ldx #$10
  ldy #$10

transferUpperBlock:
  lda #^Font
  pha
  plb

  lda Font, x

  plb

  sta rVRamDataWrite

  lda #$00
  sta rVRamDataWrite + 1

  pha

  inx
  dey
  bne transferUpperBlock

  rep #$30
.a16
.i16

  lda #$0080
  sta rVRamAddress

  sep #$30
.a8
.i8

  ldx #$00
  ldy #$10

transferLowerBlock:
  lda #^Font
  pha
  plb

  lda Font, x

  plb

  sta rVRamDataWrite

  lda #$00
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
