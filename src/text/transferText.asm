.setcpu "65816"

.define utf16Word $0100
.define characterDataBank $0102

; BG1 の TileMap(#$4000 - #$4400)上に、UTF-16 テキストの内容を並べる
.macro transferText
  sep #$20
.a8

  lda #$00
  sta characterDataBank
  pha

  lda #^Text
  pha
  plb

  rep #$30
.a16
.i16

  lda Text + 2 ; 0 文字目が BOM なので 1 文字目から読む

  plb

  sta utf16Word

  asl utf16Word
  rol characterDataBank
  asl utf16Word
  rol characterDataBank
  asl utf16Word
  rol characterDataBank

  sep #$20
.a8

  clc
  lda #<FontHeader
  adc utf16Word
  sta utf16Word

  lda #>FontHeader
  adc utf16Word + 1
  sta utf16Word + 1

  lda #^FontHeader
  adc characterDataBank
  sta characterDataBank

  rep #$20
.a16

  lda #utf16Word 
  tad

  ; Direct Page レジスタにインデックスを指し示す 16 bit アドレスが入っている
  ; DB レジスタに Bank がセットされているので、そこから 16 bit 読み込む
  lda [$00]

  ; Glyph が存在するか
  ; TODO: 後で実装

  ; Glyph が存在するので、Glyph の Index を取得する
  lda #$0002
  tay

  lda[$00], y

  ; Index * 32(5 Lsh)して、Glyph のデータを取得する

  ; ここからタイルマップの転送

  ldx #$4000
  stx rVRamAddress

  ldy #$0100

  lda #$0000
@loop:
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
  bne @skip
  clc
  adc #$0020 ; 1行分下に移動させる
@skip:

  tax
  pla

  stx rVRamAddress ; 演算終了した X レジスタの内容をセット

  dey

  bne @loop
.endmacro
