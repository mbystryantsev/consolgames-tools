del /s /q PATCH\cmd\RUS\*
del /q PATCH\cmd\Utils\*

Utils\Tim2Jim.exe RUS\text_1_n.tm2 RUS\RUS\Tex_jimaku\data.jim
rem copy RUS\files.lst PATCH\cmd\RUS\files.lst
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