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

  ldx #$00
  ldy #$20

transferLoop:
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
  bne transferLoop

  pla
  ply
  plx
  plb
.endmacro
