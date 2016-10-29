@echo off
set e=Tools\ImageConv.exe
set b=data\logo\bmp
set r=data\logo\res
set l=data\logo

%e% -l -8 %b%\title_fixed.bmp %r%\title.map %r%\title.lz
%e% -l -8 %b%\logo_RUS.bmp %r%\logo.map %r%\logo.lz
%e% -l -8 %b%\logo2_RUS.bmp %r%\logo2.map %r%\logo2.lz
%e% -l -8 -s %b%\logo3_RUS.bmp %r%\logo3.map %r%\logo3.lz
%e% -l -4 %b%\present.bmp %r%\present.map %r%\present.lz
%e% -l -4 -mh -mc -F%l%\mplayer_fixed.chr %b%\mplayer.bmp %r%\mplayer.map.lz %r%\mplayer.chr.lz

rem THE END
%e% -l -8 -s %b%\the_end\the_end.bmp %r%\the_end.map %r%\the_end.lz
%e% -bmp2chr %b%\the_end\the_end_shine.bmp %r%\the_end_shine.lz

rem 
rem %e% -s 
rem %e% -compress %r%\menu.lz


set r=data\menu\res
set b=data\menu

%e% -s -c 428 248 %b%\press.bmp %r%\press.oam %r%\press.lz
%e% -ss 0 248 %b%\menu.bmp %r%\menu.oam %r%\menu.lz

%e% -bmp2chr %b%\miss.bmp %r%\miss.chr

set r=data\screen\res
set b=data\screen\bmp

%e% -l -4 -mh -h -c -fdata\screen\screen_tiles.chr %b%\job_screen.bmp %r%\job_screen.map %r%\temp.bin
%e% -l -4 -mh -h -c -fdata\screen\screen_tiles.chr %b%\battle_screens.bmp %r%\battle_screens.map %r%\temp.bin

rem INTRO
%e% -intro data\intro\intro.bmp data\intro\intro.lzhuff data\intro\intro.gbapal

rem TILES
%e% -compress data\tiles\tiles_pub_inn.bin data\tiles\tiles_pub_inn.lz
%e% -compress data\tiles\tiles_inn_inside.bin data\tiles\tiles_inn_inside.lz

rem STAFF FONT
%e% -bmp2chr data\fonts\staff_font_rus.bmp data\fonts\staff_font_rus.chr
%e% -bmp2chr data\fonts\staff_font_small_rus.bmp data\fonts\staff_font_small_rus.chr

rem STAFF TEXT
%e% -staff data\staff\staff_big.tbl data\staff\staff3.txt data\staff\staff3.bin
%e% -staff data\staff\staff_big.tbl data\staff\staff2.txt data\staff\staff2.bin
%e% -staff data\staff\staff_small.tbl data\staff\staff1.txt data\staff\staff1.bin

%e% -text -p -f60 tables\Names_Rus.tbl data\name_input_ru.txt data\name_input.bin

pause