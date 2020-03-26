;
; Arduino-LED-blink.asm
;
; Created: 23-Mar-20 6:42:55 PM
; Author : Phaedra
;
; Arduino clock speed is 16Mhz -> 1 period is 62.5ns

.include "m328pdef.inc" 

.def bcnt = r16		;counter

.equ cts = 62		;ticks per second

.org	0x00
	jmp	start

;***** beginning of isr *****
.org	0x20	;ISR
		dec	bcnt
		brne	isrx
		ldi	bcnt, cts		;reset counts
		sbic	PORTB,5
		jmp	clrled
		sbi	PORTB,5
		jmp	isrx
clrled:	cbi	PORTB,5
isrx:	reti	
;****** end of isr *****

	ldi	r16, 0x10
start:	ldi	r16,high(RAMEND)	;RAMEND is defined in the include file as the last address in SRAM. Must be broken into 8-bit components with the HIGH and LOW functions to be loaded into a working register
	out	SPH,r16			;stack pointer high register
	ldi	r16,low(RAMEND)		
	out	SPL,r16			;stack pointer low register

					;for this case: port pin configuration DDxn:1 PORTxn:1 PUD:X I/O: Output Pullup:No Output: High(sink)
	ldi	r16,(1<<PB5)		;Arduino pin 13 (on-board LED) is PB5
	ldi	r17,(1<<PB5)		;1<<PB5 used to make high and output
	out	PORTB,r16		;PORTB set as high
	out	DDRB,r17		;data direction, output			
	
	;setup timer
	ldi	r16, 0
	out	TCCR0A, r16
	ldi	r16, 0b00000101		;clock prescaler - 1024, overflows every 0.016384s
	out	TCCR0B, r16
	ldi	r16, 0x01
	sts	0x6e, r16

	sei				;set global interrupt enable
; end of initialization

loop:	jmp loop
