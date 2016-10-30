@echo off
copy /Y rpak.cpp rpak_lib.c
bcc32 -c -6 -O2 -Ve -X -pr -a8 -b -d -k- -vi -tWM -r -RT- -ff rpak_lib.c
rem bcc32 -c -WD -a4 -5 rpak.c
rem bcc32 -h
pause
