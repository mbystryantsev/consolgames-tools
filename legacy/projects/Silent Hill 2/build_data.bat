@echo off
set MSGDIR=rus\data\etc\message\
rem echo !MSGDIR:~0,-1!
rem pause


rem For %%f In (%MSGDIR%*_e.mes) Do echo %%f
rem copy /y %FILE% %%f
rem pause

SH2Text.exe -b %MSGDIR% tables\english.tbl sh2_rus.txt
pause
For %%l in (j, f, g, i, s) do (
  For /f %%f in (msglist.txt) do (
   copy /y %MSGDIR%%%f_msg_e.mes %MSGDIR%%%f_msg_%%l.mes
  )
)

SH2_data.exe -b SLPM_650.98 rus\;arc\ arc_test\
echo Done!
pause