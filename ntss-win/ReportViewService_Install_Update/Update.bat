@echo off
rem 外部連携－レポートWebアプリのアップグレードファイル(BAT)

rem 管理者権限を取得します(XCOPYを利用します)
%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit
cd /d "%~dp0"

rem Common.batを実します。
call %~dp0\Common\Common.bat

rem ログファイルを取得します。
move /Y %logfile% %~dp0Update_%date:~0,4%%date:~5,2%%date:~8,2%.log

rem ログファイルを表示します。
type %~dp0Update_%date:~0,4%%date:~5,2%%date:~8,2%.log

echo.
echo ================================================================================
echo 実行結果は以下のロゴファイルを参照してください。
echo %~dp0Update_%date:~0,4%%date:~5,2%%date:~8,2%.log
echo ================================================================================
echo.

pause
