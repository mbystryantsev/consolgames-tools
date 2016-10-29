@echo off
Tools\FFA_TextExtract.exe	-b russian.txt russian.msg Tables\Table_RUS.tbl
Tools\ExtraPaster.exe		_datascript.txt
Tools\ImageConv.exe -text data\playlist.txt $70953C 68 $3EDCF0 "Final Fantasy V.gba"
pause