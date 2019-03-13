@Echo Off
set APP=D:\_job\SH\Utils\
set DELPHI=D:\Program files\Borland\Delphi7\
set PATCH=F:\_job\_SH\RUS\PATCH\code\
set LIB=%DELPHI%Lib\
set ARC=D:\Program files\7-Zip\7z.exe

del /q RUS\TXD\*
%APP%SHTXD.exe -ce RUS\TEX ARC RUS\TXD
%APP%SHTXD.exe -rt RUS\TEX RUS\TXD


del /q RUS\IPS\*
del /q RUS\PATCH\ips.lst
cd RUS\TXD
For %%f In (*) Do (
  ..\..\UIPS.EXE c ..\IPS\%%f.IPS ..\..\ARC\%%f %%f
  echo %%f.IPS n>>..\PATCH\ips.lst
)
cd ..\PIC
For %%f In (*) Do echo ..\PIC\%%f n>>..\PATCH\ips.lst
cd ..\CMI
For %%f In (*.CMI) Do echo ..\CMI\%%f n>>..\PATCH\ips.lst
cd ..\..

echo ..\SRC\Config.xml n>>RUS\PATCH\ips.lst
echo ..\SRC\Embeded.LST n>>RUS\PATCH\ips.lst

%APP%SHTextBuild.exe RUS\Strings.Eng.txt RUS\PATCH\Strings.Eng
echo ..\PATCH\Strings.Eng n>>RUS\PATCH\ips.lst


set OPTPIX=D:\Program files\OPTPiX iMageStudio\iStudio.exe
"%OPTPIX%" /macroq SH0_Locale.ops
del /q RUS\PATCH\LOCALE\LocaleUIEng
copy /Y RUS\SRC\LocaleUIEng RUS\PATCH\LOCALE\LocaleUIEng
%APP%SHTXD.exe -rt RUS\PIC\LOCALE RUS\PATCH\LOCALE
echo ..\PATCH\LOCALE\LocaleUIEng n>>RUS\PATCH\ips.lst


%APP%SHPack.exe RUS\PATCH\ips.lst RUS\PATCH\IPS.ARC RUS\IPS
cd RUS\PSP_GAME\
%APP%SHPack.exe -p -s .\ ..\PATCH\PSP_GAME.ARC
cd ..\..\

"%DELPHI%Bin\brcc32.exe" -32 -foRUS\PATCH\code\IPS_ARC.RES RUS\PATCH\IPS_ARC.RC
"%DELPHI%Bin\DCC32.EXE" -B "-U%LIB%ZLib;%LIB%TBX\PFolder;%LIB%DelphiX" "%PATCH%SH0Patch.dpr"


del /q _release\SH0Patch.7z
cd RUS\PATCH\code\
"%ARC%" a -mx=9 ..\..\..\_release\SH0Patch.7z SH0Patch.exe


pause 