@echo off
setlocal

cd /d "%~dp0"

echo Mirror C:\FNW\Source to %~dp0
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Mirror-Source.ps1"
set "EXITCODE=%ERRORLEVEL%"

echo.
if not "%EXITCODE%"=="0" (
    echo Mirror failed. Exit code: %EXITCODE%
) else (
    echo Mirror completed.
)
echo.
set /p "_PRESS_ENTER=Press Enter to close..."

exit /b %EXITCODE%
