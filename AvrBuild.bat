@ECHO OFF
call extra\timestamp.bat
"C:\Program Files (x86)\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "build\labels.tmp" -fI -W+iw -C V2 -o "bin\whiplash.hex" -d "build\whiplash.obj" -e "bin\whiplash.eep" -m "build\whiplash.map" "whiplash.asm"
call extra\makebin.bat
