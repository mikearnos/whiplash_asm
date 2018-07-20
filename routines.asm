.cseg


draw_pulse:
	;==============================================
	;tmp3 = how many leds Z = starting point of leds
	;destroys Y, tmp, tmp2
	;pulse_brightness_up is how many increments each loop to brighten
	;pulse_brightness_down is how many increments each loop to dim

	mov		YH, ZH
	mov		YL, ZL
	adiw	Z, 1

	pulse_loop:

	ld		tmp, Y
	
	sbrc	tmp, brightness_up
	rjmp	pulse_brightness_up
	sbrc	tmp, brightness_down
	rjmp	pulse_brightness_down
	rjmp	pulse_done


	pulse_brightness_up:
	andi	tmp, 0x1F
	lds		tmp2, pulse_brightness_up_value
	add		tmp, tmp2
	cpi		tmp, 31
	brsh	pulse_brightness_up_max
	ori		tmp, (1 << brightness_up)
	st		Y, tmp
	rjmp	pulse_done

	pulse_brightness_up_max:
	ldi		tmp, 31 | (1 << brightness_down)
	st		Y, tmp
	ldi		tmp2, 0 | (1 << brightness_up)
	st		Z, tmp2
	rjmp	pulse_done


	pulse_brightness_down:
	andi	tmp, 0x1F
	lds		tmp2, pulse_brightness_down_value
	sub		tmp, tmp2
	brge	pulse_brightness_down_positive
	ldi		tmp, 0
	st		Y, tmp
	rjmp	pulse_done

	pulse_brightness_down_positive:
	ori		tmp, (1 << brightness_down)
	st		Y, tmp

	pulse_done:
	adiw	Y, 1
	adiw	Z, 1

	dec		tmp3
	brne	pulse_loop

	ret


load_buffer:
	;======================================
	;converts LED brightness values from bytes to 32th of a frame binary values
	;load_buffer_H and load_buffer_L must be set, tmp3 = bcm buffer value
	ldi		tmp, whip_leds

	lds		ZH, load_buffer_H				; load destination binary buffer
	lds		ZL, load_buffer_L

	clear_buffer:
	ldi		tmp2, 0
	st		Z+, tmp2
	dec		tmp
	brne	clear_buffer


	;=====convert chest diamond=====
	ldi		tmp2, front_leds

	lds		ZH, load_buffer_H				; load destination binary buffer
	lds		ZL, load_buffer_L

	ldi		YH, high(SP_front_chest_diamond + front_leds + 1)
	ldi		YL, low(SP_front_chest_diamond + front_leds + 1)		; load the new byte pointer to sram memory

	;ldi		YH, high(SP_front_chest_diamond)
	;ldi		YL, low(SP_front_chest_diamond)							;load the new byte pointer to sram memory for clockwise rotation

	convert_chest_diamond:
	ld		tmp, -Y							; load new brightness value
	;ld		tmp, Y+							; load new brightness value for clockwise rotation
	andi	tmp, 0x1F						; strip control bits
	and		tmp, tmp3
	breq	chest_diamond_off

	ld		tmp, Z
	ori		tmp, 1 << HC595_SERF
	st		Z, tmp

	chest_diamond_off:
	adiw	Z, 1

	dec		tmp2
	brne	convert_chest_diamond


	;=====convert chest ring=====
	ldi		tmp2, front_leds

	lds		ZH, load_buffer_H				; load destination binary buffer
	lds		ZL, load_buffer_L

	adiw	Z, front_leds					; aim past the diamond, two patterns on one bus

	ldi		YH, high(SP_front_chest_ring)
	ldi		YL, low(SP_front_chest_ring)	; load the new byte pointer to sram memory

	convert_chest_ring:
	ld		tmp, Y+							; load new brightness value
	andi	tmp, 0x1F						; strip control bits
	and		tmp, tmp3
	breq	chest_ring_off

	ld		tmp, Z
	ori		tmp, 1 << HC595_SERF
	st		Z, tmp

	chest_ring_off:
	adiw	Z, 1

	dec		tmp2
	brne	convert_chest_ring


	;=====convert left pulsar=====
	ldi		tmp2, back_leds

	lds		ZH, load_buffer_H				; load destination binary buffer
	lds		ZL, load_buffer_L

	ldi		YH, high(SP_back_left)
	ldi		YL, low(SP_back_left)			; load the new byte pointer to sram memory

	convert_left_pulsar:
	ld		tmp, Y+							; load new brightness value
	andi	tmp, 0x1F						; strip control bits
	and		tmp, tmp3
	breq	left_pulsar_off

	ld		tmp, Z
	ori		tmp, 1 << HC595_SERBL
	st		Z, tmp

	left_pulsar_off:
	adiw	Z, 1

	dec		tmp2
	brne	convert_left_pulsar


	;=====convert right pulsar=====
	ldi		tmp2, back_leds

	lds		ZH, load_buffer_H				; load destination binary buffer
	lds		ZL, load_buffer_L

	ldi		YH, high(SP_back_right)
	ldi		YL, low(SP_back_right)			; load the new byte pointer to sram memory

	convert_right_pulsar:
	ld		tmp, Y+							; load new brightness value
	andi	tmp, 0x1F						; strip control bits
	and		tmp, tmp3
	breq	right_pulsar_off

	ld		tmp, Z
	ori		tmp, 1 << HC595_SERBR
	st		Z, tmp

	right_pulsar_off:
	adiw	Z, 1

	dec		tmp2
	brne	convert_right_pulsar


	;=====convert left whip=====
	ldi		tmp2, whip_leds

	lds		ZH, load_buffer_H				; load destination binary buffer
	lds		ZL, load_buffer_L

	ldi		YH, high(SP_left_whip)
	ldi		YL, low(SP_left_whip)			; load the new byte pointer to sram memory

	convert_left_whip:
	ld		tmp, Y+							; load new brightness value
	andi	tmp, 0x1F						; strip control bits
	and		tmp, tmp3
	breq	left_whip_off

	ld		tmp, Z
	ori		tmp, 1 << HC595_SERLW
	st		Z, tmp

	left_whip_off:
	adiw	Z, 1

	dec		tmp2
	brne	convert_left_whip


	;=====convert right whip=====
	ldi		tmp2, whip_leds

	lds		ZH, load_buffer_H				; load destination binary buffer
	lds		ZL, load_buffer_L

	ldi		YH, high(SP_right_whip)
	ldi		YL, low(SP_right_whip)			; load the new byte pointer to sram memory

	convert_right_whip:
	ld		tmp, Y+							; load new brightness value
	andi	tmp, 0x1F						; strip control bits
	and		tmp, tmp3
	breq	right_whip_off

	ld		tmp, Z
	ori		tmp, 1 << HC595_SERRW
	st		Z, tmp

	right_whip_off:
	adiw	Z, 1

	dec		tmp2
	brne	convert_right_whip

	sbr		rint, (1 << rint_vsync)

	ret


buffer_underrun:
	cbr		buffers_ready, 1 << buffers_ready_underrun

	;cli
	;ldi		tmp, (0<<CS01) | (0<<PSR0)
	;out		TCCR0B, tmp					; stop the timer

	ldi		YH, high(crash_data)
	ldi		YL, low(crash_data)

	ld		tmp, Y+
	rcall	write_eeprom

	ld		tmp, Y+
	rcall	write_eeprom

	ld		tmp, Y+
	rcall	write_eeprom

	ld		tmp, Y+
	rcall	write_eeprom

	;rcall	set_595

	;crashed:
	;nop
	;rjmp	crashed


	cpi		XL, 0xF0
	brlo	eeprom_not_full
	;cpi		XL, 0
	;brne	eeprom_not_full

	sbiw	X, 4
	ldi		tmp, 0xFF
	rcall	write_eeprom


	;ldi		tmp, 0xAA
	;sts		eternal, tmp
	;ldi		tmp, 0
	;out		TCCR0B, tmp
	rcall	set_595

	crashed2:
	nop
	rjmp	crashed2


	eeprom_not_full:

	;ldi		tmp, (1<<CS01) | (1<<PSR0)
	;out		TCCR0B, tmp					; restart the timer
	;sei

	ret


fill_buffer_16:
	ldi		tmp, high(HC595_BUFFER_16)
	sts		load_buffer_H, tmp
	ldi		tmp, low(HC595_BUFFER_16)
	sts		load_buffer_L, tmp
	ldi		tmp3, 16
	rcall	load_buffer
	sbr		buffers_ready, 1 << buffers_ready_16

	ret

fill_buffer_8:
	ldi		tmp, high(HC595_BUFFER_8)
	sts		load_buffer_H, tmp
	ldi		tmp, low(HC595_BUFFER_8)
	sts		load_buffer_L, tmp
	ldi		tmp3, 8
	rcall	load_buffer
	sbr		buffers_ready, 1 << buffers_ready_8

	ret

fill_buffer_4:
	ldi		tmp, high(HC595_BUFFER_4)
	sts		load_buffer_H, tmp
	ldi		tmp, low(HC595_BUFFER_4)
	sts		load_buffer_L, tmp
	ldi		tmp3, 4
	rcall	load_buffer
	sbr		buffers_ready, 1 << buffers_ready_4

	ret

fill_buffer_2:
	ldi		tmp, high(HC595_BUFFER_2)
	sts		load_buffer_H, tmp
	ldi		tmp, low(HC595_BUFFER_2)
	sts		load_buffer_L, tmp
	ldi		tmp3, 2
	rcall	load_buffer
	sbr		buffers_ready, 1 << buffers_ready_2

	ret

fill_buffer_1:
	ldi		tmp, high(HC595_BUFFER_1)
	sts		load_buffer_H, tmp
	ldi		tmp, low(HC595_BUFFER_1)
	sts		load_buffer_L, tmp
	ldi		tmp3, 1
	rcall	load_buffer
	sbr		buffers_ready, 1 << buffers_ready_1

	ret


shift_array:			;shifts the data in an array one byte higher in memory (towards the tip)
						;Z = memory pointer, tmp3 = how many positions, destroys tmp, tmp2, Y
	add		ZL, tmp3
	brcc	shift_array_no_carry
	inc		ZH								; memory pointer, inc the upper bits for safety
	shift_array_no_carry:

	mov		YH, ZH
	mov		YL, ZL

	sbiw	Y, 1							; Y will be 1 lower than Z, values move from Y to Z

	dec		tmp3							; the value at the end of the array gets overwritten, so 1 less shift

	shift_array_loop:
	ld		tmp, -Y
	st		-Z, tmp

	dec		tmp3
	brne	shift_array_loop


	ret


fill_pulsars:
	;----------------------------
	; quick fill the back pulsars
	;----------------------------
	ldi		YH, high(SP_back_left)
	ldi		YL, low(SP_back_left)
	ldi		tmp, 16							; how many to fill
	ldi		tmp2, 31						; value
	fill_left_pulsar:
	st		Y+, tmp2
	subi	tmp2, 2							; change value per LED
	dec		tmp
	brne	fill_left_pulsar

	ldi		YH, high(SP_back_right)
	ldi		YL, low(SP_back_right)
	ldi		tmp, 16							; how many to fill
	ldi		tmp2, 31						; value
	fill_right_pulsar:
	st		Y+, tmp2
	subi	tmp2, 2							; change value per LED
	dec		tmp
	brne	fill_right_pulsar

	ret


shift_pulsars:
	lds		tmp2, shift_array_delay
	dec		tmp2
	sts		shift_array_delay, tmp2

	brne	shift_pulsars_end				; check for delay value to slow the routine

	ldi		tmp2, shift_array_delay_value
	sts		shift_array_delay, tmp2			; reset value if zero

	ldi		ZH, high(SP_back_left)
	ldi		ZL, low(SP_back_left)
	ld		tmp, Z
	inc		tmp
	andi	tmp, 0b11111
	st		Z, tmp
	ldi		tmp3, back_leds
	rcall	shift_array

	ldi		ZH, high(SP_back_right)
	ldi		ZL, low(SP_back_right)
	ld		tmp, Z
	inc		tmp
	andi	tmp, 0x1F
	st		Z, tmp
	ldi		tmp3, back_leds
	rcall	shift_array

	shift_pulsars_end:

	ret
