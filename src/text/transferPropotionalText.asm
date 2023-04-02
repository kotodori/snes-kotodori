.setcpu "65816"

.import Text, transferPropotionalCharacter

.segment "STARTUP"

.export transferPropotionalText
.proc transferPropotionalText
  .a16
  .i16

  ; テキストを描画する位置(px)
  pea $0000

  ; UTF-16LE テキスト先頭からの offset 量(bytes)
  ldx #$0002 ; 先頭には BOM があるため 2 bytes ずらす

  @loop:
    sep #$20
    .a8

    lda #^Text
    pha
    plb

    rep #$20
    .a16

    lda Text, x

    beq @textTransferEnd ; 0x0000(NUL)だったときは終了

    cpa #$000a ; 改行(LF)かどうか
    bne @notLineFeed

    @lineFeed: ; LF の場合
      lda $01, s
      and #$ff00 ; 下位 4 bits だけをクリアして
      clc
      adc #$0100 ; 0x20 足す
      sta $01, s ; 次の行の先頭に描画位置を移動する
      jmp @characterTransferEnd

    @notLineFeed: ; LF でない場合
      pha ; Code point を Stack に積む
      jsr transferPropotionalCharacter
      pla

      lda $01, s
      clc
      adc #$0c
      sta $01, s

  @characterTransferEnd:
    inx
    inx
    cpx #$0004 ; 1文字読み込んだら終わり(最初に BOM が 2 bytes あることに注意)
    bne @loop

  @textTransferEnd:

  pla
  rts
.endproc
