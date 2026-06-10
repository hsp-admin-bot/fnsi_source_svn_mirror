set PATH_VAR=%~dp0%
set DIR=%PATH_VAR:~0,2%
%DIR%
cd %PATH_VAR%
InstallUtil.exe NKKAccessCardService.exe
pause