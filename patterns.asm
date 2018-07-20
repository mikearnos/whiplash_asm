.cseg

.equ	b = 0x40
.equ	i =	0x80

.equ	flash_frames = 40
.equ	current_default_pattern = 9

whip_flashes:

;flashy					0
.db		2,		4,		6,		8,		10,		12,		14,		16,		40,		40
.db		35|i,	30|i,	25|i,	20|i,	14|i,	10|i,	6|i,	2|i,	0,		0
.db		2,		6,		10,		14,		20,		25,		30,		35,		40,		40|b
.db		2,		6,		10,		14,		20,		25,		30,		35,		40,		40|b

;reverse shrink			1
.db		40|i,	39|i,	38|i,	37|i,	36|i,	35|i,	34|i,	33|i,	32|i,	31|i
.db		30|i,	29|i,	0,		0,		26|i,	25|i,	0,		0,		0,		21|i
.db		20|i,	19|i,	18|i,	17|i,	16|i,	15|i,	14|i,	13|i,	12|i,	11|i
.db		10|i,	40|i,	8|i,	7|i,	6|i|b,	5|i,	4|i,	3|i,	2|i,	1|i

;phazer	2				2
.db		20,		20|i,	19,		19|i,	18,		18|i,	17|b,	17|i,	16,		16|i
.db		15,		15|i,	14,		14|i,	13,		13|i,	10,		12|i,	8,		11|i
.db		0,		10|i,	0,		9|i,	0,		8|i,	2,		7|b|i,	4,		6|i
.db		6,		5|i,	8,		4|i,	10,		3|i,	12,		2|i,	20|b,	1|i

;phazer					3
.db		20,		20|i,	19,		19|i,	18,		18|i,	17|b,	17|i,	12,		16|i
.db		11,		15|i,	10,		14|i,	13,		13|i,	12,		12|i,	13,		11|i
.db		14,		10|i,	15,		9|i,	17,		8|i,	20,		7|b|i,	18,		6|i
.db		12,		5|i,	8,		4|i,	3,		3|i,	2,		2|i,	1,		1|i

;switch up				4
.db		0,		2,		0,		4,		0,		6,		0,		8,		0,		10
.db		0,		12,		0,		14,		0,		16,		21|i,	18,		20|i|b,	20|b
.db		19|i,	0,		17|i,	0,		15|i,	0,		12|i,	0,		9|i,	0
.db		8|i,	0,		6|i,	0,		4|i,	0,		3|i,	0,		2|i,	0

;sparky					5
.db		20,		20,		18,		18,		16,		16,		0,		30|i,	10,		30|i
.db		8,		20|i,	8,		10|i,	20,		19,		18,		17,		16,		15
.db		13,		12,		11,		10,		0,		0,		0,		3,		4,		5
.db		5,		10|i,	6,		10|i,	6|b,	5|i,	0,		5|i,	0,		20|i

;zippy					6
.db		0,		0,		10,		20,		20,		18,		16,		14,		10,		5
.db		0,		0,		5,		10,		5,		0,		10,		20|i,	20,		0
.db		10,		0,		20|i,	15,		0,		0,		20|i,	0,		20,		5
.db		0,		5,		10,		0,		20,		40|b,	30,		20,		10,		5

;discharge				7
.db		5,		5|i,	15,		10|i,	25,		15|i,	0,		20|i,	10,		25|i
.db		20,		30|i,	40|b,	40|b,	13,		13|i,	12,		12|i,	11,		11|i
.db		10,		10|i,	9,		9|i,	8,		8|i,	7,		7|i,	6,		6|i
.db		5,		5|i,	4,		4|i,	3,		3|i,	2,		2|i,	1,		1|i

;power on				8
.db		1|b,	1|i|b,	2|b,	2|i|b,	3|b,	3|i|b,	4|b,	4|i|b,	5|b,	5|i|b
.db		6|b,	6|i|b,	7|b,	7|i|b,	8|b,	8|i|b,	9|b,	9|i|b,	10|b,	10|i|b
.db		11|b,	11|i|b,	12|b,	12|i|b,	13|b,	13|i|b,	14|b,	14|i|b,	15|b,	15|i|b
.db		16|b,	16|i|b,	17|b,	17|i|b,	18|b,	18|i|b,	19|b,	19|i|b,	40|b,	40|b

;blank					9
.db		0,		0,		0,		0,		0,		0,		0,		0,		0,		0
.db		0,		0,		0,		0,		0,		0,		0,		0,		0,		0
.db		0,		0,		0,		0,		0,		0,		0,		0,		0,		0
.db		0,		0,		0,		0,		0,		0,		0,		0,		0,		0


draw_diamond:
	;============================================
	;create pulse for chest diamond

	lds		tmp2, diamond_delay
	dec		tmp2
	sts		diamond_delay, tmp2

	brne	draw_diamond_end

	ldi		tmp2, diamond_delay_value
	sts		diamond_delay, tmp2

	lds		tmp, diamond_speed
	sts		pulse_brightness_up_value, tmp
	ldi		tmp, 4
	sts		pulse_brightness_down_value, tmp
	ldi		tmp3, front_leds + 1					; # of leds + 1 for loop effect
	ldi		ZH, high(SP_front_chest_diamond)
	ldi		ZL, low(SP_front_chest_diamond)

	rcall	draw_pulse

	lds		tmp, SP_front_chest_diamond + front_leds
	sbrc	tmp, brightness_up
	sts		SP_front_chest_diamond, tmp				; resets the spark to the beginning to continue the loop

	draw_diamond_end:

	ret


draw_ring:
	;============================================
	;create pulse for chest ring

	lds		tmp2, ring_delay
	dec		tmp2
	sts		ring_delay, tmp2

	brne	draw_ring_end

	ldi		tmp2, ring_delay_value
	sts		ring_delay, tmp2

	lds		tmp, ring_speed
	sts		pulse_brightness_up_value, tmp
	ldi		tmp, 2
	sts		pulse_brightness_down_value, tmp
	ldi		tmp3, front_leds + 1					; # of leds + 1 for loop effect
	ldi		ZH, high(SP_front_chest_ring)
	ldi		ZL, low(SP_front_chest_ring)

	rcall	draw_pulse

	lds		tmp, SP_front_chest_ring + front_leds
	sbrc	tmp, brightness_up
	sts		SP_front_chest_ring, tmp				; resets the spark to the beginning to continue the loop

	draw_ring_end:

	ret


draw_pulsars:
	sbr		rint, 1 << rint_draw_pulsars

	;============================================
	;create pulse for left pulsar
	ldi		tmp, 2									; load idle settings
	ldi		tmp2, 1

	in		tmp3, button_port_in
	sbrs	tmp3, button_left						; skip if button is pressed
	rjmp	back_left_idle

	cpi		frame, 49
	brne	skip_second_left_pulse

	ldi		ZH, high(SP_back_left)
	ldi		ZL, low(SP_back_left)
	ldi		tmp3, 0 | (1 << brightness_up)
	st		Z, tmp3

	skip_second_left_pulse:

	ldi		tmp, 8									; load full speed settings
	ldi		tmp2, 1

	back_left_idle:									; button is pressed

	sts		pulse_brightness_up_value, tmp
	sts		pulse_brightness_down_value, tmp2
	ldi		tmp3, 16
	ldi		ZH, high(SP_back_left)
	ldi		ZL, low(SP_back_left)
	rcall	draw_pulse

	;============================================
	;create pulse for right pulsar
	ldi		tmp, 2									; load idle settings
	ldi		tmp2, 1

	in		tmp3, button_port_in
	sbrs	tmp3, button_right						; skip if button is pressed
	rjmp	back_right_idle

	cpi		frame, 49
	brne	skip_second_right_pulse

	ldi		ZH, high(SP_back_right)
	ldi		ZL, low(SP_back_right)
	ldi		tmp3, 0 | (1 << brightness_up)
	st		Z, tmp3

	skip_second_right_pulse:

	ldi		tmp, 8									; load full speed settings
	ldi		tmp2, 1

	back_right_idle:								; button is pressed

	sts		pulse_brightness_up_value, tmp
	sts		pulse_brightness_down_value, tmp2
	ldi		tmp3, 16
	ldi		ZH, high(SP_back_right)
	ldi		ZL, low(SP_back_right)
	rcall	draw_pulse

	ret


draw_left_whip:
	;============================================
	;set up variables for draw_whip_flash
	lds		tmp, SP_back_left + back_leds
	tst		tmp
	breq	left_whip_enable
	sbr		aint, 1 << aint_charge_delay_left

	left_whip_enable:
	sbrs	aint, aint_charge_delay_left
	rjmp	draw_left_whip_end

	rcall	random_generator
	
	ldi		tmp, high(SP_left_whip)
	ldi		tmp2, low(SP_left_whip)
	sts		whip_flash_YH, tmp						; load the destination pointer to sram whip memory
	sts		whip_flash_YL, tmp2

	lds		tmp, whip_left_flash_frame_counter_ZH
	lds		tmp2, whip_left_flash_frame_counter_ZL
	sts		whip_flash_frame_counter_ZH, tmp
	sts		whip_flash_frame_counter_ZL, tmp2

	lds		tmp, whip_left_flash_frame_counter
	sts		whip_flash_frame_counter, tmp

	ldi		tmp, 1 << button_left
	sts		whip_flash_button, tmp

	lds		tmp2, random_number						; pick 0-7 patterns
	andi	tmp2, 7									; tmp2 = *CURRENT PATTERN*

	sbrc	aint, aint_animation_buffer_only
	ldi		tmp2, current_default_pattern

	sbrs	aint, aint_skip_powerup_left			; check if first animation is playing
	ldi		tmp2, 8									; load startup animation
	sbr		aint, 1 << aint_skip_powerup_left		; skip this next time

	rcall	draw_whip_flash

	lds		tmp, whip_flash_frame_counter
	sts		whip_left_flash_frame_counter, tmp

	lds		tmp, whip_flash_frame_counter_ZH
	lds		tmp2, whip_flash_frame_counter_ZL
	sts		whip_left_flash_frame_counter_ZH, tmp
	sts		whip_left_flash_frame_counter_ZL, tmp2

	draw_left_whip_end:

	ret


draw_right_whip:
	;============================================
	;set up variables for draw_whip_flash
	lds		tmp, SP_back_right + back_leds
	tst		tmp
	breq	right_whip_enable
	sbr		aint, 1 << aint_charge_delay_right

	right_whip_enable:
	sbrs	aint, aint_charge_delay_right
	rjmp	draw_right_whip_end

	rcall	random_generator
	
	ldi		tmp, high(SP_right_whip)
	ldi		tmp2, low(SP_right_whip)
	sts		whip_flash_YH, tmp						; load the destination pointer to sram whip memory
	sts		whip_flash_YL, tmp2

	lds		tmp, whip_right_flash_frame_counter_ZH
	lds		tmp2, whip_right_flash_frame_counter_ZL
	sts		whip_flash_frame_counter_ZH, tmp
	sts		whip_flash_frame_counter_ZL, tmp2

	lds		tmp, whip_right_flash_frame_counter
	sts		whip_flash_frame_counter, tmp

	ldi		tmp, 1 << button_right
	sts		whip_flash_button, tmp

	lds		tmp2, random_number						; pick 0-7 patterns
	andi	tmp2, 7									; tmp2 = *CURRENT PATTERN*

	sbrc	aint, aint_animation_buffer_only
	ldi		tmp2, current_default_pattern

	sbrs	aint, aint_skip_powerup_right			; check if first animation is playing
	ldi		tmp2, 8									; load startup animation
	sbr		aint, 1 << aint_skip_powerup_right		; skip this next time

	rcall	draw_whip_flash

	lds		tmp, whip_flash_frame_counter
	sts		whip_right_flash_frame_counter, tmp

	lds		tmp, whip_flash_frame_counter_ZH
	lds		tmp2, whip_flash_frame_counter_ZL
	sts		whip_right_flash_frame_counter_ZH, tmp
	sts		whip_right_flash_frame_counter_ZL, tmp2

	draw_right_whip_end:

	ret


draw_whip_flash:
	;============ tmp2 = current pattern index

	lds		ZH, whip_flash_frame_counter_ZH
	lds		ZL, whip_flash_frame_counter_ZL

	;==================== check if beginning or end of a pattern
	lds		tmp, whip_flash_frame_counter
	cpi		tmp, flash_frames
	breq	new_whip_pattern_pointer					; pattern is finished, choose new one

	lds		tmp, whip_flash_frame_counter
	cpi		tmp, 0
	brne	whip_flash_pattern_multiply_skip			; continue displaying current pattern

	;==================== set the pattern pointer
	new_whip_pattern_pointer:

	ldi		ZH, high(whip_flashes*2)					; loading from flash uses * 2
	ldi		ZL, low(whip_flashes*2)

	ldi		tmp, 0										; reset frame counter
	sts		whip_flash_frame_counter, tmp

	cpi		tmp2, 0										; if pattern 0 no need to change pointer
	breq	whip_flash_pattern_multiply_skip

	whip_flash_pattern_multiply:
	adiw	Z, flash_frames
	dec		tmp2
	brne	whip_flash_pattern_multiply

	whip_flash_pattern_multiply_skip:

	;==================== fill the whip
	lds		YH, whip_flash_YH
	lds		YL, whip_flash_YL

	ldi		tmp3, whip_leds								; default amount of LEDs to clear
	lpm		tmp2, Z+									; tmp2 = *AMOUNT OF LEDS TO FILL*
	sts		whip_flash_frame_counter_ZH, ZH				; save Z for next frame
	sts		whip_flash_frame_counter_ZL, ZL

	mov		tmp, tmp2
	cbr		tmp, i | b
	cpi		tmp, 0
	breq	whip_fill_clear								; if 0, clear all LEDs


	;==================== sets brightness of LEDs to half of random value, or full while button pressed

	in		tmp3, button_port_in
	lds		tmp, whip_flash_button
	and		tmp, tmp3
	breq	whip_idle						; branch if button not pressed

	lds		tmp, random_number
	andi	tmp, 0b00011111					; allow 5 bits of brightness if button pressed
	sbrc	tmp2, 6							; check for full brightness flag
	ldi		tmp, 31
	cbr		tmp2, b							; clear brightness flag
	rjmp	whip_button_done
	
	whip_idle:
	lds		tmp, random_number
	andi	tmp, 0b00000011					; allow 2 bits of brightness if no button pressed
	sbrc	tmp2, 6							; check for full brightness flag
	ldi		tmp, 15							; set to idle full brightness
	cbr		tmp2, b							; clear brightness flag

	whip_button_done:
	;ldi		tmp, 3						; tmp = *CURRENT FILL VALUE*
	sbrc	tmp2, 7							; check for reverse flag
	rjmp	whip_reverse_fill

	;==================== fill the LEDs to preset amount starting from whip handle
	ldi		tmp3, whip_leds + 1
	sub		tmp3, tmp2						; tmp3 will be how many LEDs to clear

	whip_fill:
	st		Y+, tmp
	dec		tmp2
	brne	whip_fill

	whip_fill_clear:						; clear the remaining LEDs, prevents flicker opposed to clearing and filling
	clr		tmp
	st		Y+, tmp
	dec		tmp3
	brne	whip_fill_clear
	rjmp	skip_fill

	;==================== reverse fill the LEDs to preset amount starting from end of whip
	whip_reverse_fill:
	cbr		tmp2, i							; clear the reverse bit
	ldi		tmp3, whip_leds + 1
	sub		tmp3, tmp2						; tmp3 will be how many LEDs to clear
	adiw	Y, whip_leds

	whip_reverse_fill_loop:
	st		-Y, tmp
	dec		tmp2
	brne	whip_reverse_fill_loop

	whip_reverse_fill_clear:				; clear the remaining LEDs, prevents flicker opposed to clearing and filling
	clr		tmp
	st		-Y, tmp
	dec		tmp3
	brne	whip_reverse_fill_clear

	;==================== no LEDs to fill
	skip_fill:
	lds		tmp, whip_flash_frame_counter
	inc		tmp
	sts		whip_flash_frame_counter, tmp

	ret
