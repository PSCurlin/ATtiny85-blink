;
; Arduino-LED-blink.asm
;
; Created: 23-Mar-20 6:42:55 PM
; Author : Phaedra
;
; Arduino clock speed is 16Mhz -> 1 period is 62.5ns

start:
    ldi r16,high(RAMEND)	;RAMEND is defined in the include file as the last address in SRAM. Must be broken into 8-bit components with the HIGH and LOW functions to be loaded into a working register
	out SPH,r16				;stack pointer high register
	ldi r16,low				
	out SPL,r16				;stack pointer low register

	jmp ports
	jmp timer			

	sei						;set global interrupt enable
		
loop:
	jmp loop

ports:
						    ;for this case: port pin configuration DDxn:1 PORTxn:1 PUD:X I/O: Output Pullup:No Output: High(sink)
	ldi r16,(1<<PB5)		;Arduino pin 13 (on-board LED) is PB5
	ldi r17,(1<<PB5)		;1<<PB5 used to make high and output
	out PORTB,r16			;PORTB set as high
	out DDRB,r17			;data direction, output
	nop						;used for synchronization				

timer:					

	