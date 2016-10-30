@echo off
set DELPHI=C:\Program files\Borland\Delphi7\
set PATCH=src\
set LIB=%DELPHI%Lib\
set ARC=C:\Program files\7-Zip\7z.exe
set OPTPIX=C:\Program files\OPTPiX iMageStudio\iStudio.exe


cd ..
del /s /q PATCH\cmd\RUS\*
del /q PATCH\cmd\Utils\*

call reduce.bat

Utils\Tim2Jim.exe RUS\RUS\text_1_n.tm2 RUS\RUS\Tex_jimaku\data.jim
copy RUS\RUS\Tex_jimaku\data.jim PATCH\cmd\RUS\RUS\Tex_jimaku\data.jim
copy RUS\RUS\Tex_menu01\mc01.tm2 PATCH\cmd\RUS\RUS\Tex_menu01\mc01.tm2
copy RUS\RUS\Tex_menu01\mc02.tm2 PATCH\cmd\RUS\RUS\Tex_menu01\mc02.tm2
copy RUS\RUS\Tex_menu01\mc04.tm2 PATCH\cmd\RUS\RUS\Tex_menu01\mc04.tm2
copy RUS\RUS\Tex_menu01\scei.tm2 PATCH\cmd\RUS\RUS\Tex_menu01\scei.tm2
copy RUS\RUS\Tex_menu01\stage.tm2 PATCH\cmd\RUS\RUS\Tex_menu01\stage.tm2
copy RUS\RUS\Tex_menu01\title.tm2 PATCH\cmd\RUS\RUS\Tex_menu01\title.tm2
copy RUS\RUS\Tex_menu01\option.tm2 PATCH\cmd\RUS\RUS\Tex_menu01\option.tm2
copy Utils\DFExtract.exe PATCH\cmd\Utils\DFExtract.exe
copy Utils\Extract.exe PATCH\cmd\Utils\Extract.exe

cd PATCH\cmd\RUS\RUS\
..\..\..\..\Utils\Extract.exe -b -dir -sp -sf . ..\..\..\PATCH.DF
cd ..\..\..\..\

"%DELPHI%Bin\brcc32.exe" -32 -foPATCH\code\PATCH.RES PATCH\PATCH_DF.RC
"%DELPHI%Bin\DCC32.EXE" -B "-U%LIB%TBX\PFolder;%LIB%PasZLib-SG;%LIB%PasZLib-SG\paszlib" "%PATCH%ICOPatch.dpr"

del /q _release\SH0Patch.7z
cd PATCH\code\
"%ARC%" a -mx=9 ..\..\_release\ICOPatch.7z ICOPatch.exe



pause