@echo off
set OPTPIX=C:\Program files\OPTPiX iMageStudio\iStudio.exe

cd ..\RUS\RUS\PNG\


del /q TEMP\*
copy option.png TEMP\option.png
"%OPTPIX%" /macroq ICO_4bit.ops
"%OPTPIX%" /macroq ICO_8bit.ops
"%OPTPIX%" /macroq ICO_Text.ops
pause