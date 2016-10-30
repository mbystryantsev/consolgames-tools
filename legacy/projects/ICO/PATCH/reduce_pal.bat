@echo off
set OPTPIX=C:\Program files\OPTPiX iMageStudio\iStudio.exe

cd ..\RUS\RUS\PNG\


del /q TEMP\*
copy mc01.png TEMP\mc01.png
"%OPTPIX%" /macroq ICO_mc01.ops

del /q TEMP\*
copy mc02.png TEMP\mc02.png
"%OPTPIX%" /macroq ICO_mc02.ops

del /q TEMP\*
copy mc04.png TEMP\mc04.png
"%OPTPIX%" /macroq ICO_mc04.ops

del /q TEMP\*
copy scei.png TEMP\scei.png
"%OPTPIX%" /macroq ICO_scei.ops

del /q TEMP\*
copy stage.png TEMP\stage.png
"%OPTPIX%" /macroq ICO_stage.ops

del /q TEMP\*
copy title.png TEMP\title.png
"%OPTPIX%" /macroq ICO_title.ops

del /q TEMP\*
copy option.png TEMP\option.png

"%OPTPIX%" /macroq ICO_8bit.ops

"%OPTPIX%" /macroq ICO_Text.ops
pause