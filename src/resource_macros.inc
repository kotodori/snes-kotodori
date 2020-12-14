; Asset pointer
.macro ldstx_long label
  ldx #.HIWORD(label)
  stx gAssetBankTemp
  ldx #.LOWORD(label)
  stx gAssetOffsetTemp
.endmacro

.macro loadWithAssetAddress asset_label, dest_addr_w, size_b
  phx
  phy
    ldstx_long asset_label

    ldx dest_addr_w
    ldy size_b
    jsr transferBitmapDataDMA
  ply
  plx
.endmacro
