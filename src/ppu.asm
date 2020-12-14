.setcpu "65816"

.include "ports.inc"
.include "common_macros.inc"
.include "global_variables.inc"

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
; A16, I16
; in X: Dest word address
; in Y: Size (in BYTES)
.proc transferBitmapDataDMA
.a16
.i16
	save_paxy

	; Set dest VRAM address
	stx $2116

	; Set length(bytes)
	sty pDMA0ByteCountW

	; load address(long)
	lda gAssetBankTemp
	ldy gAssetOffsetTemp

	sep #$20
	.a8
		; Set DMA source address
		sta pDMA0SourceBank    ; bank (8bit)
		sty pDMA0SourceOffsetW ; offset(16bit)

		; Set DMA target
		; write to $2118(VRAM channel)
		lda #$18
		sta pDMA0Dest

		; Write a word
		lda #$01
		sta pDMA0Config

		; Start - - - - - - - - - - - - -
		lda #$01
		sta pDMATrigger

	rep #$20
	.a16

	restore_paxy
	rts
.endproc
