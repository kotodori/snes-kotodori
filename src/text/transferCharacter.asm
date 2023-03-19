.setcpu "65816"

.import FontHeader, FontBody, Text

.include "../registers.inc"

.define utf16Word $0100
.define characterDataBank $0102
.define textWritePosition $0104
.define characterMetaData $0106 ; 8 bytes
  ; 0: 存在フラグなど
  ; 1: \
  ; 2: インデックス
  ; 3: /
  ; 4: 横幅
  ; 5: 縦幅
  ; 6: 横送り量
  ; 7: 未使用

.segment "STARTUP"

; BG1 の TileMap(#$4000 - #$4400)上に、UTF-16 テキストの内容を並べる
.export transferCharacter
.proc transferCharacter
  stz characterDataBank

  sep #$20
.a8

  lda #^Text
  pha
  plb

  rep #$30
.a16
.i16

  ldy Text, x

  lda #$00
  pha
  plb
  plb

  ; 文字が LF (U+000A)だったら？
  cpy #$000a
  bne @notLineFeed

@lineFeed:
  lda textWritePosition
  and #$fff0 ; 下位1バイトをクリアして
  clc
  adc #$0010 ; 0x10 足す
  sta textWritePosition
  rts

  ; LF じゃなかった
@notLineFeed:

  sty utf16Word

  asl utf16Word ; アドレスを 3 bits 左シフト
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
  tcd

  ; Direct Page レジスタにインデックスを指し示す 16 bit アドレスが入っている
  ; DB レジスタに Bank がセットされているので、そこから 16 bit 読み込む
  lda [$00]

  ; Glyph が存在するか
  ; TODO: 後で実装

  ; Glyph が存在するので、Glyph の Index を取得する
  lda #$0002 ; 2 bytes 先に Index があるので、ずらす量を Y にセット
  tay 

  lda[$00], y

  ; Glyph の Index 番号のデータが Big Endian なので、バイトの上位下位を反転
  xba

  ; Index * 32(5 Lsh)して、Glyph のデータを取得する
  sta utf16Word
  stz characterDataBank

  asl utf16Word ; アドレスを 5 bits 左シフト
  rol characterDataBank
  asl utf16Word
  rol characterDataBank
  asl utf16Word
  rol characterDataBank
  asl utf16Word
  rol characterDataBank
  asl utf16Word
  rol characterDataBank

  sep #$20
.a8

  clc
  lda #<FontBody
  adc utf16Word
  sta utf16Word

  lda #>FontBody
  adc utf16Word + 1
  sta utf16Word + 1

  lda #^FontBody
  adc characterDataBank
  sta characterDataBank

  rep #$20
.a16

  lda #$0000
  pha
  plb
  plb

  ; ここからタイルの転送
  lda textWritePosition
  asl
  asl
  asl
  asl
  asl
  sta rVRamAddress
  inc textWritePosition

  ldy #$0000

  lda #utf16Word
  tcd

  sep #$20
.a8

@characterTransferLoop:
  ; Direct Page レジスタが指し示す先に、Glyph データの先頭を指し示す 16 bit アドレスが入っている
  lda [$00], y
  sta rVRamDataWrite
  lda #$00
  sta rVRamDataWrite + 1

  iny

  cpy #$0020
  bne @characterTransferLoop

  rep #$20
.a16

  rts
.endproc
