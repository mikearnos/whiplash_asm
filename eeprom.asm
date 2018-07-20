.cseg

write_eeprom:				;address = X data = r16
	cli						;disable interrupts

	write_eeprom_1:
	sbic	EECR, EEPE		;wait until EEPE becomes zero
	rjmp	write_eeprom_1

	cbi		EECR, EEPM0
	cbi		EECR, EEPM1		;Set Programming mode to erase and write in one operation (3.4ms)

	out		EEARH, XH		; Set up address (r18:r17) in address register
	out		EEARL, XL

	out		EEDR, r16		;write EEPROM data to EEDR

	sbi		EECR, EEMPE		;enable write (clears in four clock cycles)
	sbi		EECR, EEPE		;write eeprom

	adiw	X, 1

	sei
	ret


read_eeprom:	;address = r18:r17 returns data = r16
	sbic	EECR, EEPE		;make sure there's no writing going on
	rjmp	read_eeprom

	out		EEARH, r18		; Set up address (r18:r17) in address register
	out		EEARL, r17

	sbi		EECR, EERE		; Start eeprom read by writing EERE
	in		R16, EEDR		; Read data from data register
	ret

.eseg

begin_eeprom:
.db		"eeprom"
