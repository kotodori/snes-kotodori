;----------------------------------------------------------------------------
;			SNES Startup Routine
;					Copyright (C) 2007, Tekepen
;----------------------------------------------------------------------------
.setcpu		"65816"

.import	InitRegs

.segment "BSS_LOW"
scrollX:
    .word $0000

.segment "STARTUP"

; リセット割り込み
.proc	Reset
    sei
    clc
    xce	; Native Mode
    phk
    plb	; DB = 0

    rep	#$30	; A,I 16bit
.a16
.i16
    ldx	#$1fff
    txs
    
    jsr	InitRegs

    sep	#$20
.a8
    lda	#$40
    sta	$2107
    stz	$210b

    rep	#$20
.a16

; Init memory
    lda #$ffff
    sta scrollX

    lda	#$01
    sta	$212c
    stz	$212d
    lda	#$0f
    sta	$2100

    jsr initSystemStates

mainloop:	
    jmp	mainloop

    rti
.endproc


; == Sub
; MUST UNDER: A16, I16
.proc initSystemStates
    pha

    ; VSync and Joypad
    sep	#$20
.a8

    stz $4016

    lda #$81
    sta $4200

    rep	#$20
.a16	

    pla
    rts
.endproc

.proc VBlank
    pha
    phx
    php


    sep	#$20
.a8
    lda scrollX
    sta $210D
    inc scrollX

    rep	#$20
.a16

    plp
    plx
    pla
    rti
.endproc

.proc EmptyInt
    rti
.endproc

; カートリッジ情報
.segment "CARTINFO"
    .byte	"KOTODORI             "	; Game Title
    .byte	$00				; 0x01:HiRom, 0x30:FastRom(3.57MHz)
    .byte	$00				; ROM only
    .byte	$08				; 32KB=256KBits
    .byte	$00				; RAM Size (8KByte * N)
    .byte	$00				; NTSC
    .byte	$01				; Licensee
    .byte	$00				; Version
    .byte	$9a, $46, $65, $b9		; checksum(empty here)
    .byte	$ff, $ff, $ff, $ff		; unknown

    .word	EmptyInt	; Native:COP
    .word	EmptyInt	; Native:BRK
    .word	EmptyInt	; Native:ABORT
    .word	VBlank		; Native:NMI
    .word	$0000		; 
    .word	EmptyInt	; Native:IRQ

    .word	$0000	; 
    .word	$0000	; 

    .word	EmptyInt	; Emulation:COP
    .word	EmptyInt	; 
    .word	EmptyInt	; Emulation:ABORT
    .word	VBlank		; Emulation:NMI
    .word	Reset		; Emulation:RESET
    .word	EmptyInt	; Emulation:IRQ/BRK
