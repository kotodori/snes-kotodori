.setcpu "65816"

.import FontHeader, FontBody, Text

.include "../registers.inc"

.define utf16Word $0100
.define characterDataBank $0102
.define tempArea $0104
.define tempCharacterSetArea $0110

.segment "STARTUP"

; BG1 の Tile(#$4000 - #$4400)上に、UTF-16 テキストの内容を並べる
.export transferPropotionalCharacter
.proc transferPropotionalCharacter
  .a16
  .i16

  pea $0000
  plb
  plb

  lda $03, s; Code point を読み込む

  @calculateGlyphAddress:
  sta utf16Word
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
  lda [$00] ; Glyph の Header を読み込む

  and #$0001 ; Glyph が存在するか
  bne @glyphExists

  @glyphNotExist: ; Glyph が存在しない場合
    lda #$3000 ; 全角スペース "　" のコードポイント

    pea $0000
    plb
    plb

    jmp @calculateGlyphAddress

  @glyphExists: ; Glyph が存在する場合
    ; Glyph が存在するので、Glyph の Index を取得する
    lda #$0002 ; Index がある位置にずらす offset 量を Y にセット
    tay
    lda [$00], y ; Glyph の Index を取得

    xba ; Glyph の Index 番号のデータが Big Endian なので、バイトの上位下位を反転

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
    lda $05, s
    asl ; 5 bits 左シフトで VRAM Address に変換する
    sta rVRamAddress

    lda #utf16Word
    tcd

    sep #$20
    .a8

    ldy #$00 ; Counter
    @loopABlock:
      ; tempArea 4bytes
      ; 00_00_00_00
      ; A  B  C  D

      ; Get glyph data & place to tempArea
      lda [$00], y
      sta tempArea
      iny

      lda [$00], y
      sta tempArea + 1
      iny

      stz tempArea + 2
      stz tempArea + 3

      dey
      dey

      ; TODO: ここで良しなにビットシフト(3 bytes まるごと)

      ; Write to temp character area
      lda #$FF
      sta tempCharacterSetArea, y

      lda #$FF
      sta tempCharacterSetArea + 8, y

      iny
      iny

      cpy #$04
      bne @loopABlock

  rep #$20
  .a16

  rts
.endproc
