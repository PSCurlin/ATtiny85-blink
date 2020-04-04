;
; led-blink.asm
;
; Author : Phaedra
;
; clock speed is 8	Mhz -> 1 period is 12.5ns

.include "tn85def.inc" ;			;includes the ATtiny45 definitions

.def bcnt = r16						;defines bcnt as register 16, used as counter

.equ cts = 2						;equates cts to 124, number of ticks per second

.org	0x00						;interrupt vector
		rjmp	start					;commences setup

;***** beginning of ISR *****


.org	 0x0005						;TIM0_OVF_ISR
isr:	
		dec		bcnt				;decrement the counter
		brne	isrx				;checks the counter
		ldi		bcnt, cts			;reset counts to 62
		sbic	PORTB,2				;if the led bit is 0 (cleared), skips the next line of code
		rjmp	clrled				;clears the led bit
		sbi		PORTB,2				;sets the led bit (sets to 1)
		rjmp	isrx				;jump to interrupt

clrled:	cbi		PORTB,2				;clears the led bit (sets to 0)

isrx:	reti						;return from the interrupt

;****** end of ISR *****


;***** beginning of setup *****

		ldi		r16, 0x10
start:	ldi		r16,high(RAMEND)	;RAMEND is defined in the include file as the last address in SRAM. Must be broken into 8-bit components with the HIGH and LOW functions to be loaded into a working register
		out		SPH,r16				;stack pointer high register
		ldi		r16,low(RAMEND)		
		out		SPL,r16				;stack pointer low register

									;for this case: port pin configuration DDxn:1 PORTxn:1 PUD:X I/O: Output Pullup:No Output: High(sink)
		ldi		r16,(1<<PB2)
		ldi		r17,(1<<PB2)		;1<<PB2 used to make high and output
		out		PORTB,r16			;PORTB set as high
		out		DDRB,r17			;data direction, output			
		
	;timer setup

		
		ldi		r16, 0				;sets to normal mode
		out		TCCR0A, r16	
				
		ldi		r16, 0b0000101		;clock prescaler - 256
		out		TCCR0B, r16			;timer/counter control, clock, no prescaling

		ldi		r16, 0x02
		out		0x39, r16			;timer/counter interrup mask register, overflow interrupt register

		sei							;set global interrupt enable

;***** end of setup *****

loop:	rjmp loop					;loops the blink indefinitely
