set PATH_VAR=%~dp0%
set DIR=%PATH_VAR:~0,2%
%DIR%
cd %PATH_VAR%
InstallUtil.exe /u NKKAccessCardService.exe
pause