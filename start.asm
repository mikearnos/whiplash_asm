.org	0x00
.cseg

	rjmp	RESET								; Reset Handler
	rjmp	EXT_INT0							; IRQ0 Handler
	rjmp	PCINT								; PCINT Handler
	rjmp	TIM1_COMPA							; Timer1 CompareA Handler
	rjmp	TIM1_COMPB							; Timer1 CompareB Handler
	rjmp	TIM1_OVF							; Timer1 Overflow Handler
	rjmp	TIM0_OVF							; Timer0 Overflow Handler
	rjmp	USI_START							; USI Start Handler
	rjmp	USI_OVF								; USI Overflow Handler
	rjmp	EE_RDY								; EEPROM Ready Handler
	rjmp	ANA_COMP							; Analog Comparator Handler
	rjmp	ADC_CONV							; ADC Conversion Handler
	rjmp	WDT									; WDT Interrupt Handler
	rjmp	EXT_INT1							; IRQ1 Handler
	rjmp	TIM0_COMPA							; Timer0 CompareA Handler
	rjmp	TIM0_COMPB							; Timer0 CompareB Handler
	rjmp	TIM0_CAPT							; Timer0 Capture Event Handler
	rjmp	TIM1_COMPD							; Timer1 CompareD Handler
	rjmp	FAULT_PROTECTION 					; Timer1 Fault Protection


.include	"extra\timestamp.txt"


EXT_INT0:
	reti
PCINT:
	reti
TIM1_COMPA:
	reti
TIM1_COMPB:
	reti
TIM1_OVF:
	reti
TIM0_OVF:
	push	tmp
	in		tmp, SREG
	push	tmp
	push	tmp2
	push	YL
	push	YH

	ldi		tmp, clock_divide_high				; reset the timer values
	out		TCNT0H, tmp
	ldi		tmp, clock_divide_low
	out		TCNT0L, tmp

	;----------------------------------------------------
	; timers below keep system time, tic 0-128 frame 0-99
	;----------------------------------------------------
	inc		tic
	cpi		tic, 128;95			128th dies 12th, 129 dies 16th 130 dies 12th
	brlo	bcd_frame_countdown

	clr		tic									; beginning of new frame (100fps, 128 tics per frame)
	sbr		rint, 1 << rint_new_frame
	inc		frame
	cpi		frame, 100 
	brlo	bcd_frame_countdown

	clr		frame								;1 second
	sbr		rint, 1 << rint_new_second
	
	;-------------------------------
	; count the length of each frame
	;-------------------------------
	bcd_frame_countdown:
	lds		tmp, bcm_frame_count				; frames left before switching bit
	dec		tmp
	sts		bcm_frame_count, tmp

	brne	skip_refresh						; only update LEDs when tmp frame_count reaches 0

	sbr		rint, 1 << rint_bcm_shift			; frame_count is up, time for a shift
	lsr		bcm
	brne	bcm_set

	ldi		bcm, bcm_default_value
	
	bcm_set:									; bcm is only ever 16, 8, 4, 2, or 1

	sbrs	bcm, 4
	rjmp	bcm_no_16

	ldi		YH, high(HC595_BUFFER_16)			; set buffer to 16
	ldi		YL, low(HC595_BUFFER_16)
	rjmp	proceed

	bcm_no_16:
	sbrs	bcm, 3
	rjmp	bcm_no_8

	ldi		YH, high(HC595_BUFFER_8)			; set buffer to 8
	ldi		YL, low(HC595_BUFFER_8)
	rjmp	proceed

	bcm_no_8:
	sbrs	bcm, 2
	rjmp	bcm_no_4

	ldi		YH, high(HC595_BUFFER_4)			; set buffer to 4
	ldi		YL, low(HC595_BUFFER_4)
	rjmp	proceed

	bcm_no_4:
	sbrs	bcm, 1
	rjmp	bcm_no_2

	ldi		YH, high(HC595_BUFFER_2)			; set buffer to 2
	ldi		YL, low(HC595_BUFFER_2)
	rjmp	proceed

	bcm_no_2:
	ldi		YH, high(HC595_BUFFER_1)			; set buffer to 1
	ldi		YL, low(HC595_BUFFER_1)

	proceed:


	sbrs	rint, 1 << rint_new_frame
	rjmp	bcm_buffer_ready
	mov		tmp, buffers_ready
	and		tmp, bcm
	brne	bcm_buffer_ready					; if current buffer is ready then refresh LEDs


	rjmp	skip_refresh

	bcm_buffer_ready:

	mov		tmp, bcm

	force_refresh:

	sts		bcm_frame_count, tmp

	sts		current_display_buffer_H, YH
	sts		current_display_buffer_L, YL
	adiw	Y, whip_leds						; start at the end of the array

	ldi		tmp2, whip_leds
	update_leds_loop:							; shift the data 5 bits at a time
	ld		tmp, -Y								; load what's in the end buffer FIFO
	out		HC595_PORT, tmp						; set SER bits
	sbi		HC595_PORT, HC595_SCK
	cbi		HC595_PORT, HC595_SCK				; clock it in

	dec		tmp2
	brne	update_leds_loop

	;lock the LEDs in place
	sbi		HC595_port, HC595_RCK				; load output latches
	cbi		HC595_port, HC595_RCK

	cbr		rint, 1 << rint_vsync				; clear bit to be detected by new_frame to detect buffer underrun

	skip_refresh:

	pop		YH
	pop		YL
	pop		tmp2
	pop		tmp
	out		SREG, tmp
	pop		tmp
	reti


USI_START:
	reti
USI_OVF:
	reti
EE_RDY:
	reti
ANA_COMP:
	reti
ADC_CONV:
	reti
WDT:
	reti
EXT_INT1:
	reti
TIM0_COMPA:
	;reti
TIM0_COMPB:
	reti
TIM0_CAPT:
	reti
TIM1_COMPD:
	reti
FAULT_PROTECTION:
	reti

clear_regs:
	clr		r0
	clr		r1
	clr		r2
	clr		r3
	clr		r4
	clr		r5
	clr		r6
	clr		r7
	clr		r8
	clr		r9
	clr		r10
	clr		r11
	clr		r12
	clr		r13
	clr		r14
	clr		r15
	clr		r16
	clr		r17
	clr		r18
	clr		r19
	clr		r20
	clr		r21
	clr		r22
	clr		r23
	clr		r24
	clr		r25
	clr		r26
	clr		r27
	clr		r28
	clr		r29
	clr		r30
	clr		r31
	ret
