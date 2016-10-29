@echo off

set ARC=D:\Program files\7-Zip\7z.exe
set ipsname=FF5_RUS_cg

"Final Fantasy V.exe"
call gconvert.bat
call build.bat
Tools\uips.exe c _release\ff5_rus_cg.ips "2564 - Final Fantasy V Advance (U).gba" "Final Fantasy V.gba"
cd _release
del %ipsname%.7z
"%ARC%" a -mx=9 %ipsname%.7z %ipsname%.ips
pause