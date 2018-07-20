.equ	front_leds = 8
.equ	back_leds = 16
.equ	whip_leds = 40

;595 G = low, SCLR = high

.equ	HC595_PORT = PORTA

.equ	HC595_SCK = PA0				; L -> H shift register clocked
.equ	HC595_RCK = PA1				; L -> H shift registers loaded

.equ	HC595_SERF = PA2			; chest piece       \
.equ	HC595_SERBL = PA3			; back left pulsar   |
.equ	HC595_SERBR = PA4			; back right pulsar  |	serial data bit
.equ	HC595_SERLW = PA5			; left whip          |
.equ	HC595_SERRW = PA6			; right whip        / 

.equ	HC595_SERALL = ((1 << HC595_SERF) | (1 << HC595_SERBL) | (1 << HC595_SERBR) | (1 << HC595_SERLW) | (1 << HC595_SERRW))


.dseg

	HC595_BUFFER_START:


	HC595_BUFFER_1:					; stores 5bit binary data for each 32ndths of a frame		1
	.byte		whip_leds

	HC595_BUFFER_2:					; 2
	.byte		whip_leds

	HC595_BUFFER_4:					; 4
	.byte		whip_leds

	HC595_BUFFER_8:					; 8
	.byte		whip_leds

	HC595_BUFFER_16:				; 16
	.byte		whip_leds


	SP_led_sram_start:

	SP_front_chest_diamond:
	.byte		front_leds + 2		; sram for brightness values, 1 extra byte for overflow, 1 extra byte for looping

	SP_front_chest_ring:
	.byte		front_leds + 2

	SP_back_left:
	.byte		back_leds + 1

	SP_back_right:
	.byte		back_leds + 1

	SP_left_whip:
	.byte		whip_leds + 2

	SP_right_whip:
	.byte		whip_leds + 2

	SP_left_whip2:
	.byte		whip_leds + 2

	SP_right_whip2:
	.byte		whip_leds + 2

	SP_led_sram_end:



	pulse_fade_up:
	.byte		1

	pulse_fade_down:
	.byte		1

	back_pulsars_delay:
	.byte		1

	pulse_brightness_up_value:
	.byte		1
	pulse_brightness_down_value:
	.byte		1

	left_whip_delay:
	.byte		1

	whips_delay:
	.byte		1

	left_whip_flicker_current:
	.byte		1

	left_whip_flicker_max:
	.byte		1

	left_whip_flicker_random:
	.byte		1

	static_pattern:
	.byte		5

	whip_left_flash_frame_counter:
	.byte		1
	whip_left_flash_pattern_counter:
	.byte		1
	whip_left_flash_frame_counter_ZH:
	.byte		1
	whip_left_flash_frame_counter_ZL:
	.byte		1

	whip_right_flash_frame_counter:
	.byte		1
	whip_right_flash_pattern_counter:
	.byte		1
	whip_right_flash_frame_counter_ZH:
	.byte		1
	whip_right_flash_frame_counter_ZL:
	.byte		1

	whip_flash_frame_counter:
	.byte		1
	whip_flash_pattern_counter:
	.byte		1
	whip_flash_frame_counter_ZH:
	.byte		1
	whip_flash_frame_counter_ZL:
	.byte		1
	whip_flash_YH:
	.byte		1
	whip_flash_YL:
	.byte		1
	whip_flash_button:
	.byte		1

	ring_delay:
	.byte		1

	ring_speed:
	.byte		1

	diamond_delay:
	.byte		1

	diamond_speed:
	.byte		1

	shift_array_delay:
	.byte		1

	buffer_underrun_count:
	.byte		1

	bcm_frame_count:
	.byte		1

	current_display_buffer_H:
	.byte		1

	current_display_buffer_L:
	.byte		1

	load_buffer_H:
	.byte		1

	load_buffer_L:
	.byte		1

	eternal:
	.byte		1

	crash_data:
	.byte		4					; frame, tic, bcd, buffers_ready


.cseg

clear_595:
	ldi		tmp, 0
	out		HC595_PORT, tmp

	ldi		tmp2, whip_leds
	clear_595_loop:
	sbi		HC595_PORT, HC595_SCK
	cbi		HC595_PORT, HC595_SCK
	dec		tmp2
	brne	clear_595_loop

	sbi		HC595_port, HC595_RCK	; latch
	cbi		HC595_port, HC595_RCK

	ret


set_595:
	ldi		tmp, HC595_SERALL
	out		HC595_PORT, tmp

	ldi		tmp2, whip_leds
	set_595_loop:
	sbi		HC595_PORT, HC595_SCK
	cbi		HC595_PORT, HC595_SCK
	dec		tmp2
	brne	set_595_loop

	sbi		HC595_PORT, HC595_RCK	; latch
	cbi		HC595_PORT, HC595_RCK

	lds		tmp, eternal
	cpi		tmp, 0xAA
	;breq	eternal_loop

	ret

	eternal_loop:
	nop
	rjmp	eternal_loop


low_level_test:
	rcall	set_595
	rjmp	low_level_test

blink_595:
	cli
	rcall	set_595

	clr		tmp
	set_delay:
	dec		tmp
	brne	set_delay

	rcall	clear_595
	sei
	ret
