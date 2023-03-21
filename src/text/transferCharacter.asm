.setcpu "65816"

.import FontHeader, FontBody, Text

.include "../registers.inc"

.define utf16Word $0100
.define characterDataBank $0102
.define textWritePosition $0104

.segment "STARTUP"

; BG1 の TileMap(#$4000 - #$4400)上に、UTF-16 テキストの内容を並べる
.export transferCharacter
.proc transferCharacter
  sep #$20
.a8

  lda #^Text
  pha
  plb

  rep #$30
.a16
.i16

  ldy Text, x

  pea $0000
  plb
  plb

  ; 文字が LF (U+000A)かどうか
  cpy #$000a
  bne @notLineFeed

@lineFeed: ; LF だった場合
  lda textWritePosition
  and #$fff0 ; 下位 4 bits だけををクリアして
  clc
  adc #$0010 ; 0x10 足す
  sta textWritePosition ; 次の行の先頭に描画位置を移動する
  rts

@calculateGlyphAddress:
@notLineFeed: ; LF でない場合
  sty utf16Word
  stz characterDataBank

  asl utf16Word ; アドレスを 3 bits 左シフト
  rol characterDataBank
  asl utf16Word
  rol characterDataBank
  asl utf16Word
  rol characterDataBank

  clc
  lda #.LOWORD(FontHeader)
  adc utf16Word
  sta utf16Word

  lda #.HIWORD(FontHeader)
  adc characterDataBank
  sta characterDataBank

  lda #utf16Word
  tcd

  ; Direct Page レジスタにインデックスを指し示す 16 bit アドレスが入っている
  ; DB レジスタに Bank がセットされているので、そこから 16 bit 読み込む
  lda [$00]

  and #$0001 ; Glyph が存在するか
  bne @glyphExists

@glyphNotExist: ; Glyph が存在しない場合
  ldy #$3000 ; 全角スペース "　" のコードポイント

  pea $0000
  plb
  plb

  jmp @calculateGlyphAddress

@glyphExists: ; Glyph が存在する場合
  ; Glyph が存在するので、Glyph の Index を取得する
  lda #$0002 ; Index があるので、offset 量を Y にセット
  tay

  lda[$00], y

  xba ; Glyph の Index 番号のデータが Big Endian なので、バイトの上位下位を反転

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

  clc
  lda #.LOWORD(FontBody)
  adc utf16Word
  sta utf16Word

  lda #.HIWORD(FontBody)
  adc characterDataBank
  sta characterDataBank

  pea $0000
  plb
  plb

  ; ここからタイルの転送
  lda textWritePosition
  asl ; 5 bits 左シフトで VRAM Address に変換する
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
