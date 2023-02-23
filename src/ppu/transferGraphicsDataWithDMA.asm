.setcpu "65816"

.include "../registers.inc"
.include "../common/function.inc"

.segment "STARTUP"

; VRAMデータDMA転送
.export transferGraphicsDataWithDMA
function transferGraphicsDataWithDMA
  ; Asset address(Bank)
  lda 13 + 6
  ; Asset address(Offset)
  ldy 13 + 4
	; Dest VRAM address
  ldx 13 + 2
	stx $2116
  ; Set length(bytes)
  ldx 13 + 0
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
