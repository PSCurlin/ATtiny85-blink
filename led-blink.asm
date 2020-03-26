;
; led-blink.asm
;
; Author : Phaedra
;
; Arduino clock speed is 16Mhz -> 1 period is 62.5ns

.include "m328pdef.inc" ;			;includes the ATmega328p definitions

.def bcnt = r16						;defines bcnt as register 16, used as counter

.equ cts = 62						;equates cts to 62, number of ticks per second

.org	0x00						;interrupt vector
		jmp	start					;commences setup

;***** beginning of ISR *****

.org	0x20	
		dec		bcnt				;decrement the counter
		brne	isrx				;checks the counter
		ldi		bcnt, cts			;reset counts to 62
		sbic	PORTB,5				;if the led bit is 0 (cleared), skips the next line of code
		jmp		clrled				;clears the led bit
		sbi		PORTB,5				;sets the led bit (sets to 1)
		jmp		isrx				;jump to interrupt

clrled:	cbi		PORTB,5				;clears the led bit (sets to 0)

isrx:	reti						;return from the interrupt

;****** end of ISR *****


;***** beginning of setup *****

		ldi		r16, 0x10
start:	ldi		r16,high(RAMEND)	;RAMEND is defined in the include file as the last address in SRAM. Must be broken into 8-bit components with the HIGH and LOW functions to be loaded into a working register
		out		SPH,r16				;stack pointer high register
		ldi		r16,low(RAMEND)		
		out		SPL,r16				;stack pointer low register

									;for this case: port pin configuration DDxn:1 PORTxn:1 PUD:X I/O: Output Pullup:No Output: High(sink)
		ldi		r16,(1<<PB5)		;Arduino pin 13 (on-board LED) is PB5
		ldi		r17,(1<<PB5)		;1<<PB5 used to make high and output
		out		PORTB,r16			;PORTB set as high
		out		DDRB,r17			;data direction, output			
		
	;timer setup
		ldi		r16, 0
		out		TCCR0A, r16			
		ldi		r16, 0b00000101		;clock prescaler - 1024, overflows every 0.016384s
		out		TCCR0B, r16			;timer/counter control, clock, no prescaling
		ldi		r16, 0x01
		sts		0x6e, r16			;timer/counter interrup mask register, overflow interrupt register

		sei							;set global interrupt enable

;***** end of setup *****

loop:	jmp loop					;loops the blink indefinitely
