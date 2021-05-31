@echo off
setlocal
set WORK_DIR=%~dp0
set PATH_A=%~1%
set PATH_B=%~2%
if not defined ZFDIRDIFF_VIM goto :usage
if not defined PATH_A goto :usage
if not defined PATH_B goto :usage
goto :run
:usage
echo usage:
echo   setup env ZFDIRDIFF_VIM, and:
echo   ZFDirDiff.bat PATH_A PATH_B
exit /b 1
:run

for %%t in (%ZFDIRDIFF_VIM%) do (
    set ZFDIRDIFF_VIM=%%~t
)
"%ZFDIRDIFF_VIM%" -c "call ZF_DirDiff(\"%PATH_A%\", \"%PATH_B%\")"

