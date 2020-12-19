.macro loadWithAssetAddress assetLabel, destAddressWord, bytesNum
  rep #$20
.a16

  phx
    ldx #.HIWORD(assetLabel)
    phx
    ldx #.LOWORD(assetLabel)
    phx

    ldx destAddressWord
    phx
    ldx bytesNum
    phx
    jsr transferBitmapDataDMA

    tsc
    adc #$0008
    tcs
  plx
.endmacro
