.define characterDataBank $0100
.define utf16Word $0102

; BG1 の TileMap(#$4000 - #$4400)上に、UTF-16 テキストの内容を並べる
.macro transferText
  sep #$20
.a8

  lda #$00
  sta characterDataBank
  sta characterDataBank + 1
  pha

  lda #^Text
  pha
  plb

  rep #$30
.a16
.i16

  lda Text + 2

  plb

  sta utf16Word

  asl utf16Word
  rol characterDataBank
  asl utf16Word
  rol characterDataBank
  asl utf16Word
  rol characterDataBank

  ; アドレスセットする
  ldx utf16Word

  sep #$20
.a8
  lda characterDataBank
  pha
  plb

  rep #$20
.a16

  ; インデックスにアクセス
  lda FontHeader, x

  ; ここからタイルマップの転送

  ldx #$4000
  stx rVRamAddress

  ldy #$0100

  lda #$0000
loop:
  sta rVRamDataWrite
  inc a

  sta rVRamDataWrite
  inc a

  pha
  txa
  clc
  adc #$0020 ; 16×16 の下半分の描画に移る
  tax
  pla

  stx rVRamAddress

  sta rVRamDataWrite
  inc a

  sta rVRamDataWrite
  inc a

  pha
  txa
  sec
  sbc #$001e

  bit #$001f ; 32 で割り切れる(1行描画が終了している)場合は、スキップ
  bne skip
  clc
  adc #$0020 ; 1行分下に移動させる
skip:

  tax
  pla

  stx rVRamAddress ; 演算終了した X レジスタの内容をセット

  dey

  bne loop
.endmacro
