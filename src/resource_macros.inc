.macro loadWithAssetAddress asset_label, dest_addr_w, size_b
  phx
  phy
    ldx #.HIWORD(asset_label)
    phx
    ldx #.LOWORD(asset_label)
    phx

    ldx dest_addr_w
    ldy size_b
    jsr transferBitmapDataDMA
  ply
  plx
.endmacro
