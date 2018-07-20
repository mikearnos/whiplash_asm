### Whiplash costume control module A5

This is the firmware to an LED driver based off of an Atmel AVR ATtiny861 and 595 shift registers. It runs 128 LEDs at 32 levels of brightness (5 bit PWM).

I wanted minimal parts in the controller, even going as far as to ommit a crystal (16 - 20 MHz) and instead opting for the internal RC oscillator which runs approximately 8.0 MHz. I programmed this in assembly because at the time the ATtiny seemed cheap enough and with the right code it could output what I needed.

I used [AVR Studio v4.18.SP3.716](https://www.microchip.com/mplab/avr-support/avr-and-sam-downloads-archive) (install the setup.exe then the SP3.exe). Although 4.19 or somewhat later versions should still work, I just didn't like the change in the interface of 5.0.

Here's the output when I assemble it:

```
AVRASM: AVR macro assembler 2.1.42 (build 1796 Sep 15 2009 10:48:36)
Copyright (C) 1995-2009 ATMEL Corporation

whiplash.asm(1): Including file 'C:\Program Files (x86)\Atmel\AVR Tools\AvrAssembler2\Appnotes\tn861def.inc'
whiplash.asm(2): Including file 'start.asm'
start.asm(25): Including file 'extra\timestamp.txt'
whiplash.asm(3): Including file 'hc595.asm'
whiplash.asm(4): Including file 'eeprom.asm'
whiplash.asm(5): Including file 'random.asm'
whiplash.asm(6): Including file 'routines.asm'
whiplash.asm(7): Including file 'patterns.asm'

ATtiny861 memory use summary [bytes]:
Segment   Begin    End      Code   Data   Used    Size   Use%
---------------------------------------------------------------
[.cseg] 0x000000 0x0009c4   2004    496   2500    8192  30.5%
[.dseg] 0x000060 0x000236      0    470    470     512  91.8%
[.eseg] 0x000000 0x000006      0      6      6     512   1.2%

Assembly complete, 0 errors. 0 warnings
```
