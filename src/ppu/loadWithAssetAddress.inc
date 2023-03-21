.import transferGraphicsDataWithDMA

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

    jsr transferGraphicsDataWithDMA

    tsc
    clc
    adc #$0008
    tcs
  plx
.endmacro
