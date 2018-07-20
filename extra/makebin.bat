@echo off
extra\hex2bin.exe bin\whiplash.hex >nul
extra\hex2bin.exe -e .eep.bin bin\whiplash.eep >nul
