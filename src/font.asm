.setcpu "65816"

.export Palette
.export Pattern

.segment "RODATA"
Palette:
  .incbin "palette.bin"
Pattern:
  .incbin "tile.bin"
