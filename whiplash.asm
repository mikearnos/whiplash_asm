.include "tn861def.inc"
.include "start.asm"
.include "hc595.asm"
.include "eeprom.asm"
.include "random.asm"
.include "routines.asm"
.include "patterns.asm"

.cseg
;X register pattern pointer for flash mem
;Y register led values stored in sram

.def	button_status = r14
;.def	input_debounce_press = r15

.equ	button_port = PORTB
.equ	button_port_in = PINB
.equ	button_left = PB3
.equ	button_right = PB4

.def	tmp = r16
.def	tmp2 = r17
.def	tmp3 = r18
.def	aint = r19
.def	bcm = r20
.def	frame = r21
.def	tic = r22
.def	rint = r23
.def	input_timer = r24
.def	buffers_ready = r25


.equ	clock_divide = 52;49;78;312;78;100;310;78;271;310;520;					; 8mhz / 600 / 32 / 8		49 = 600hz
.equ	clock_divide_high = high(0xFFFF - clock_divide)
.equ	clock_divide_low = low(0xFFFF - clock_divide)

.equ	rint_new_frame =				1
.equ	rint_new_second =				2
.equ	rint_vsync =					3
.equ	rint_flip = 					4
.equ	rint_8_frame = 					5
.equ	rint_draw_pulsars = 			6
.equ	rint_bcm_shift =				7

.equ	aint_animation_buffer_only = 	3
.equ	aint_charge_delay_left = 		4
.equ	aint_charge_delay_right = 		5
.equ	aint_skip_powerup_left = 		6	
.equ	aint_skip_powerup_right = 		7

.equ	buffers_ready_1 = 	0
.equ	buffers_ready_2 = 	1
.equ	buffers_ready_4 = 	2
.equ	buffers_ready_8 = 	3
.equ	buffers_ready_16 = 	4
.equ	buffers_ready_underrun = 	5
.equ	buffer_16_preload =	6

.equ	brightness_up = 7
.equ	brightness_down = 6

.equ	dim_up = 5
.equ	dim_down = 4
.equ	dim_value = 2

.equ	diamond_delay_value = 5				; must be at least 1
.equ	diamond_speed_value = 6				; brightness increments this much

.equ	ring_delay_value = 2				; must be at least 1
.equ	ring_speed_value = 4
.equ	left_whip_delay_value = 10
.equ	shift_array_delay_value = 3			; must be at least 1

.equ	bcm_default_value = 0b00010000		; binary coded modulation we'll start with the MSB to buy some time

.equ	button_press_delay = 3
.equ	button_hold_delay = 20
.equ	button_release_delay = 1

.equ	button_left_pressed = 1
.equ	button_left_released = 2
.equ	button_left_hold = 3
.equ	button_left_previous = 4
.equ	button_right_pressed = 5
.equ	button_right_released = 6
.equ	button_right_hold = 7
.equ	button_right_previous = 8


RESET:
	ldi		r16, low(RAMEND)
	ldi		r17, high(RAMEND)
	out		SPL, r16						; Set Stack Pointer to top of RAM
	out		SPH, r17						; Tiny861 also has SPH

	ldi		tmp, HC595_SERALL | (1 << HC595_RCK) | (1 << HC595_SCK)		; 5 data output lines, rck and sck outputs
	out		DDRA, tmp

	ldi		tmp, 0xFF ^ ((1 << button_left) | (1 << button_right))		; all output except input for whip buttons
	out		DDRB, tmp

	rcall	clear_595						; clear LEDs to reduce surge upon power up

	in		tmp3, button_port_in
	ldi		tmp, 1 << button_left
	and		tmp, tmp3
	breq	skip_hw_test					; skip low_level_test if left button pressed

	rjmp	low_level_test

	skip_hw_test:

	rcall	load_seed
	rcall	clear_regs


	;------------------------------
	; load some variables into sram
	;------------------------------
	ldi		tmp, diamond_delay_value
	sts		diamond_delay, tmp

	ldi		tmp, diamond_speed_value
	sts		diamond_speed, tmp

	ldi		tmp, ring_delay_value
	sts		ring_delay, tmp

	ldi		tmp, ring_speed_value
	sts		ring_speed, tmp
	
	ldi		tmp, flash_frames							; initial value, causes new pattern to be chosen
	sts		whip_left_flash_frame_counter, tmp			; 0-19 which frame of the whip flash pattern to display
	ldi		tmp, 0
	sts		whip_left_flash_pattern_counter, tmp		; 0-7 which set of 20 frames to use

	ldi		tmp, flash_frames							; initial value, causes new pattern to be chosen
	sts		whip_right_flash_frame_counter, tmp			; 0-19 how which frame of the whip flash pattern to display
	ldi		tmp, 0
	sts		whip_right_flash_pattern_counter, tmp		; 0-7 which set of 20 frames to use

	ldi		tmp, high(whip_flashes*2)
	sts		whip_left_flash_frame_counter_ZH, tmp
	sts		whip_right_flash_frame_counter_ZH, tmp
	ldi		tmp, low(whip_flashes*2)
	sts		whip_left_flash_frame_counter_ZL, tmp
	sts		whip_right_flash_frame_counter_ZL, tmp

	lds		ZL, whip_left_flash_frame_counter_ZL

	ldi		tmp, shift_array_delay_value
	sts		shift_array_delay, tmp

	ldi		tmp, 0
	sts		buffer_underrun_count, tmp
	sts		eternal, tmp

	ldi		XH, 0
	ldi		XL, 0

	ldi		tic, 127
	ldi		frame, 99
	ldi		tmp, 1
	sts		bcm_frame_count, tmp


	;----------------------------
	; clear memory for LED values
	;----------------------------
	ldi		YH, high(SP_led_sram_start)					; load the base pointer to sram memory
	ldi		YL, low(SP_led_sram_start)

	ldi		tmp2, SP_led_sram_end - SP_led_sram_start
	ldi		tmp, 0
	clear_buffer1:
	st		Y+, tmp
	dec		tmp2
	brne	clear_buffer1

	;--------------------------------------------
	; clear the 40 byte buffers to be shifted out
	;--------------------------------------------
	ldi		tmp2, whip_leds * 5
	ldi		tmp, 0

	ldi		YH, high(HC595_BUFFER_START)
	ldi		YL, low(HC595_BUFFER_START)

	clear_mem:
	st		Y+, tmp
	dec		tmp2
	brne	clear_mem


	;------------------------------------------
	; set initial spark pulse for chest diamond
	;------------------------------------------
	ldi		YH, high(SP_front_chest_diamond + front_leds)
	ldi		YL, low(SP_front_chest_diamond + front_leds)
	ldi		tmp, 0 | (1 << brightness_up)
	st		Y, tmp							; set first LED on
	sbiw	Y, 4
	st		Y, tmp							; set 4th LED on (diamond is reverse order)


	;---------------------------------------
	; set initial spark pulse for chest ring
	;---------------------------------------
	ldi		YH, high(SP_front_chest_ring)
	ldi		YL, low(SP_front_chest_ring)
	ldi		tmp, 0 | (1 << brightness_up)
	st		Y, tmp


	;-----------------------
	; set up interrupt timer
	;-----------------------
	ldi		tmp, 0xFF						; clock_divide_high
	out		TCNT0H, tmp						; set the timer high
	ldi		tmp, 0xFF						; clock_divide_low
	out		TCNT0L, tmp						; set the timer low

	ldi		tmp, (1<<TOIE0)					; enable TIM0_OVF interrupt
	out		TIMSK, tmp

	ldi		tmp, (1<<TCW0)					; 16bit timer/counter0
	out		TCCR0A, tmp

	;ldi		tmp, (1<<CS01) | (1<<PSR0)		; set the prescaler bit | enable timer div 8 | reset timer
	ldi		tmp, 1 << CS01					; reset timer with 0 clock divide
	out		TCCR0B, tmp

	sei


	;=========== *debug* uncomment below to skip whip delay ===========
	sbr		aint, (1 << aint_charge_delay_left) | (1 << aint_charge_delay_right)

	;=========== *debug* uncomment below to skip whip powerup animation ===========
	sbr		aint, (1 << aint_skip_powerup_left) | (1 << aint_skip_powerup_right)

	ldi		buffers_ready, 1 << buffer_16_preload
	sbr		rint, 1 << rint_bcm_shift
	sbr		rint, 1 << rint_new_second
	sbr		rint, 1 << rint_new_frame


main:
	sbrc	rint, rint_new_second
	rcall	new_second						; do this at the start of every second

	sbrc	rint, rint_new_frame
	rcall	new_frame						; do this at the start of every 100fps

	sbrc	rint, rint_bcm_shift
	rcall	bcm_shift						; do this every time the LEDs get refreshed

	rjmp	main


new_second:
	cbr		rint, (1<<rint_new_second)		; clear flag that is set about every second

	ldi		tmp, 1 << rint_flip				; can be read and used to flip things every second
	eor		rint, tmp

	;call	blink_595

	;-------- used to ignite the draw_pulsar code
	ldi		YH, high(SP_back_left)
	ldi		YL, low(SP_back_left)
	ldi		tmp, 0 | (1 << brightness_up)				; sets a 0 that will increase in brightness at the base
	sbrc	rint, rint_draw_pulsars
	st		Y, tmp

	ldi		YH, high(SP_back_right)
	ldi		YL, low(SP_back_right)
	ldi		tmp, 0 | (1 << brightness_up)				; sets a 0 that will increase in brightness at the base
	sbrc	rint, rint_draw_pulsars
	st		Y, tmp


	;------
	ldi		YH, high(SP_left_whip2)
	ldi		YL, low(SP_left_whip2)
	ldi		tmp, 0 | (1 << brightness_up)
	;st		Y, tmp

	ldi		YH, high(SP_right_whip2)
	ldi		YL, low(SP_right_whip2)
	ldi		tmp, 0 | (1 << brightness_up)
	;st		Y, tmp

	ret


new_frame:									; draws patterns every 100th of a second
	cbr		rint, (1<<rint_new_frame)
	;rcall	check_input

	rcall	draw_pulsars					; default pulsar animation
	;rcall	fill_pulsars					; set pulsars to constant values
	;rcall	shift_pulsars

	rcall	draw_diamond
	rcall	draw_ring

	sbr		aint, (1 << aint_animation_buffer_only)

	rcall	draw_left_whip
	rcall	draw_right_whip

	ret


bcm_shift:
	cbr		rint, 1 << rint_bcm_shift

	sbrs	buffers_ready, buffer_16_preload
	rjmp	bcm_shift_16					; preload buffer_16 only for faster startup

	;=======
	preload:
	cbr		buffers_ready, 1 << buffer_16_preload

	rcall	fill_buffer_16

	ldi		bcm, bcm_default_value	+ 1		; start off with MSB of 5 bits
	;lsl		bcm							; increase for initial start
	sts		bcm_frame_count, bcm
	dec		bcm

	ldi		tic, 128						; pre max value for interrupt
	ldi		frame, 100						; pre max the frame counter

	;ldi		tmp, (1<<CS01) | (1<<PSR0)
	;out		TCCR0B, tmp						; set the prescaler bit/enable timer/8 / reset timer

	sei

	;============
	bcm_shift_16:
	sbrs	bcm, 4
	rjmp	bcm_shift_8
											; on 10000, buffer_16 will be displayed, fill buffer_8 first
	rcall	fill_buffer_8
	rcall	fill_buffer_4
	rcall	fill_buffer_2
	rcall	fill_buffer_1


	;===========
	bcm_shift_8:
	sbrs	bcm, 3
	ret										; refill buffers 4, 2, 1, 16 in that order

	rcall	fill_buffer_16

	ret


check_input:
  	mov		tmp3, button_status

	in		tmp, button_port_in
	sbrs	tmp, button_left				; skip if button pressed
	rjmp	check_release

	inc		input_timer

	cpi		input_timer, button_press_delay				; frames per second held
	brne	check_hold

	check_release:
	;mov		tmp3, button_status
	;sbrs	tmp3, button_left
	;rjmp	button_pressed

	check_hold:
	cpi		input_timer, button_hold_delay
	brge	check_input_end

	;button_pressed:
	ldi		YH, high(SP_left_whip + 38)		; load the base pointer to sram memory
	ldi		YL, low(SP_left_whip + 38)
	ldi		tmp, 31
	st		Y, tmp
	;clr		input_timer

	check_input_end:

	ret


	;dec		tmp2
	sbrc	tmp2, dim_up
	subi	tmp, -dim_value					; add

	sbrc	tmp2, dim_down
	subi	tmp, dim_value					; subtract

	cpi		tmp, 0
	brge	test_upper2
	ldi		tmp, 0							; set to 0 if negative
	cbr		tmp2, 1 << dim_down
	sbr		tmp2, 1 << dim_up
	rjmp	yadda2

	test_upper2:
	cpi		tmp, 32
	ldi		tmp, 31
	cbr		tmp2, 1 << dim_up
	sbr		tmp2, 1 << dim_down

	yadda2:
	or		tmp, tmp2

	;mov		input_debounce_hold, tmp2
	;***************************************
	;sbrc	tmp2, dim_up
	;subi	tmp2, -2

	;sbrc	tmp2, dim_down
	;subi	tmp2, 1
	;subi	dim, 2			;steps in levels of brightness
	;brlt	reset_dim

	;reset_dim:
	;ldi		dim, 31



check_for_single:							; tmp = shifts for press, tmp2 = shifts for hold

	;mov		tmp, input_debounce_press	
	cpi		tmp2, 2			;pressing the button
	breq	single_press
	ret



	single_press:
	;ldi		YH, high(LED_START*2 + 38)	; load the base pointer to sram memory
	;ldi		YL, low(LED_START*2 + 38)

	;ldi		tmp, 31
	;st		Y, tmp

	;inc		tmp
	;inc		tmp
	;inc		tmp
	;cpi		tmp, 3
	;breq	change_power_state
	;ldi		tmp, 0


	no_input:
	;ldi		YH, high(SP_left_whip + 38)	; load the base pointer to sram memory
	;ldi		YL, low(SP_left_whip + 38)
	;ldi		tmp, 0
	;st		Y, tmp


	dec		tmp2
	brlt	missed_one2
	rjmp	next
	missed_one2:
	ldi		tmp2, 0

	next:
	;mov		tmp, input_debounce_press
	dec		tmp
	brlt	missed_one3
	rjmp	finish_up

	missed_one3:
	ldi		tmp, 0

	finish_up:
	;mov		input_debounce_press, tmp2
	;mov		input_debounce_hold, tmp

	ret
