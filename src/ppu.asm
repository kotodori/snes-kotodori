.setcpu "65816"

.include "registers.inc"
.include "global_variables.inc"
.include "common.inc"

.segment "STARTUP"

; NMI 有効化(自動パッド読み取り有効)
.proc enableNMI
.a16
.i16
	pha

  sep #$20
	.a8
		lda #$81
		sta $4200
	rep #$20
	.a16

	pla
	rts
.endproc


; VRAMデータDMA転送
.proc transferBitmapDataDMA
.a16
.i16
  function transfer

  ; Asset address(Bank)
  lda 12 + 6
  ; Asset address(Offset)
  ldy 12 + 4
	; Dest VRAM address
  ldx 12 + 2
	stx $2116
  ; Set length(bytes)
  ldx 12 + 0
	stx rDMA0ByteCountW

	sep #$20
.a8
  sta rDMA0SourceBank
  sty rDMA0SourceOffsetW

  ; Set DMA target
  lda #$18
  sta rDMA0Dest

  ; Write a word
  lda #$01
  sta rDMA0Config

  ; Start
  lda #$01
  sta rDMATrigger

	rep #$20
.a16

  endFunction
.endproc
