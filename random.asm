.dseg
	random_numbers:
	.byte		1
	random_number:
	.byte		1

.cseg

.equ	seed_1 = 0xAA
.equ	seed_2 = 0x55


random_generator:						; returns random number in random_numbers
	push	r16
	push	r17
	push	r18
	push	r19

	lds		r17, random_numbers			; in r27,17  ;L  reg17 is L
	lds		r16, random_numbers + 1		; in r26,18  ;H  reg 18 is H

	mov		r19,r17						; AL=L
	mov		r18,r16						; AH=H

	lsl		r19
	rol		r18							; AH:AL <<1

	eor		r16,r18						; AH=AH eor H
	ldi		r18, 0

	lsl		r16							; C<-AH.7, AH<<1   new L byte
	adc		r17,r18						; L.0 <-C

	sts		random_numbers, r16			; out 17,r26  ; new L.1-7 is eor product0-6 (msb eor is in r27.0)
	sts		random_numbers + 1, r17		; out 18,r27  ;old L is new H   also return value (top 8 bits HL)

	pop		r19
	pop		r18
	pop		r17
	pop		r16

	ret



load_seed:
	ldi		r16, seed_1
	sts		random_numbers, r16
	ldi		r16, seed_2
	sts		random_numbers + 1, r16

	ret
