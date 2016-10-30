echo off
rem Укажите после знака "=" путь к файлу DATA.DF
set DFPATH=DATA.DF

rem Далее код сделает всё сам

if not exist %DFPATH% (
	echo File %DFPATH% not found!
	exit
)

echo Step 1 of 4 - extracting all data from main archive
..\..\Utils\Extract.exe -e %DFPATH% DATA
rem pause

echo Step 2 of 4 - extracting data from DF-archives
..\..\Utils\DFExtract.exe -ea DATA RUS\COMMON
rem pause

echo Step 3 of 4 - building DF-archives
..\..\Utils\DFExtract.exe -ba RUS\COMMON\LIST.HDS RUS\DF RUS\RUS RUS\COMMON
rem pause

echo Step 4 of 4 - building main archive
..\..\Utils\Extract.exe -b DATA\FILES.LST DATA.DF RUS\DF RUS\RUS\Tex_jimaku DATA
rem pause

echo Deleting temporary files...
del /q DATA\*
del /q /s RUS\COMMON\*
del /q RUS\DF\*
rd /q /s RUS\COMMON
mkdir RUS\COMMON
rem pause

echo Done! Use CDmage for import DATA.DF file into image.
echo And visit http://consolgames.ru/ ;)
pause