.macro loadWithAssetAddress assetLabel, destAddressWord, bytesNum
  rep #$30
.a16
.i16

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
    adc #$0007
    tcs
  plx
.endmacro
