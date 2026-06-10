@echo off

:: ===============================
:: 管理者権限を自動でリクエストする
:: ===============================
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb runAs"
    exit
)

setlocal enabledelayedexpansion

:: ===============================
:: LOG ファイル
:: ===============================
set LOGFILE=%~dp0oracle_install_log.txt

echo ===================================== >> %LOGFILE%
echo Start Time: %date% %time% >> %LOGFILE%
echo ===================================== >> %LOGFILE%

echo ===============================
echo Oracle Instant Client Auto Config
echo ===============================

echo Oracle Instant Client Auto Config >> %LOGFILE%

:: ===============================
:: 現在のカレントディレクトリのドライブの取得
:: ===============================
set DRIVE=%~d0

:: ===============================
:: Oracle Client ディレクトリ
:: ===============================
set ORACLE_PATH=%DRIVE%\FNWSiTools\FNW2FNSI_Converter\oracle_Client\instantclient_23_0

echo Checking Oracle Client Path... >> %LOGFILE%
echo %ORACLE_PATH% >> %LOGFILE%

:: ===============================
:: ディレクトリの確認
:: ===============================
if not exist "%ORACLE_PATH%" (
    echo [ERROR] Oracle Instant Client path not found!
    echo [ERROR] Oracle Instant Client path not found! >> %LOGFILE%
    pause
    exit /b
)

echo [OK] Oracle Client Found.
echo [OK] Oracle Client Found. >> %LOGFILE%

:: ===============================
:: PATH追加
:: ===============================
echo Adding Oracle Client to SYSTEM PATH...
echo Adding Oracle Client to SYSTEM PATH... >> %LOGFILE%

set REG_KEY=HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment

for /f "tokens=2*" %%a in ('reg query "%REG_KEY%" /v PATH') do set SYS_PATH=%%b

:: ===============================
:: セキュリティチェック：PATH読み取りに成功したことを確認する
:: ===============================
if "!SYS_PATH!"=="" (
    echo [ERROR] Failed to read SYSTEM PATH
    echo [ERROR] Failed to read SYSTEM PATH >> %LOGFILE%
    pause
    exit /b
)

:: ===============================
:: Oracle PATHがすでに存在するかどうかをチェック
:: ===============================
echo;!SYS_PATH!; | find /I ";%ORACLE_PATH%;" >nul

if !errorlevel! == 0 (
    echo [INFO] Oracle Client already exists in PATH
    echo [INFO] Oracle Client already exists in PATH >> %LOGFILE%
) else (
    set NEW_PATH=%ORACLE_PATH%;!SYS_PATH!

    reg add "%REG_KEY%" /v PATH /t REG_EXPAND_SZ /d "!NEW_PATH!" /f >> %LOGFILE%

    echo [OK] SYSTEM PATH updated
    echo [OK] SYSTEM PATH updated >> %LOGFILE%
)

:: ===============================
:: NLS_LANGの設置
:: ===============================
echo Setting SYSTEM NLS_LANG...
echo Setting SYSTEM NLS_LANG... >> %LOGFILE%

reg add "%REG_KEY%" /v NLS_LANG /t REG_SZ /d Japanese_Japan.JA16SJIS /f >> %LOGFILE%

echo [OK] NLS_LANG set.
echo [OK] NLS_LANG set. >> %LOGFILE%

:: ===============================
::  ODBCインストール
:: ===============================
echo.
echo Installing Oracle ODBC Driver...
echo Installing Oracle ODBC Driver... >> %LOGFILE%

set ODBC_INSTALL=%ORACLE_PATH%\odbc_install.exe

if exist "%ODBC_INSTALL%" (

    echo Running odbc_install.exe >> %LOGFILE%

    cd /d "%ORACLE_PATH%"
    odbc_install.exe >> %LOGFILE% 2>&1

    if !errorlevel! == 0 (
        echo [OK] ODBC Driver Installed
        echo [OK] ODBC Driver Installed >> %LOGFILE%
    ) else (
        echo [ERROR] ODBC Install Failed
        echo [ERROR] ODBC Install Failed >> %LOGFILE%
    )

) else (
    echo [ERROR] odbc_install.exe not found!
    echo [ERROR] odbc_install.exe not found! >> %LOGFILE%
)

:: ===============================
:: 環境変数を更新（再起動不要）
:: ===============================
echo Refreshing Environment Variables...
echo Refreshing Environment Variables... >> %LOGFILE%

RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters

:: ===============================
:: 完了
:: ===============================
echo.
echo ====================================
echo Configuration Completed Successfully
echo ====================================

echo ==================================== >> %LOGFILE%
echo Configuration Completed Successfully >> %LOGFILE%
echo End Time: %date% %time% >> %LOGFILE%
echo ==================================== >> %LOGFILE%

pause