echo off
echo "[1/4]"
Utils\Tim2Jim.exe RUS\text_1_n.tm2 RUS\RUS\Tex_jimaku\data.jim
echo "[2/4]"
pause
Utils\DFExtract.exe -ba RUS\COMMON\LIST.HDS RUS\DF RUS\RUS RUS\COMMON
echo "[3/4]"
Utils\Extract.exe -b RUS\FILES.LST RUS\DATA.DF ARC.HD RUS\DF RUS\RUS\Tex_jimaku DATA
rem echo "[4/4]"
rem iml2iso.exe ICO.iml ICO.iso
echo "Done!"