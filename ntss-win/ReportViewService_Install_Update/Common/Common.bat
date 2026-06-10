@echo off
rem 外部連携－レポートWebアプリの更新ファイル(BAT)

rem 管理者権限を取得します(XCOPYを利用します)
rem %1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit
cd /d "%~dp0"

set logfile=%~dp0%date:~0,4%%date:~5,2%%date:~8,2%.log

echo ================================================================================>> %logfile%
echo 更新開始時間：%date:~0,4%-%date:~5,2%-%date:~8,2% %time:~0,2%:%time:~3,2%:%time:~6,2%>> %logfile%
echo -------------------------------------------------------------------------------->> %logfile%
echo 外部連携－レポートWebアプリ（ReportViewService）を更新します。>> %logfile%
echo -------------------------------------------------------------------------------->> %logfile%
echo.>> %logfile%

rem 更新ファイルのパスを取得します
for /f "tokens=1,2 delims==" %%i in (Common.ini) do (
  if "%%i"=="SrcDir" set SrcPath=%%j
  if "%%i"=="SrcFileName" set FileName=%%j
  if "%%i"=="DesDir" set DesPath=%%j
 )
if "%FileName%"=="" (
  set FileName=ReportViewService.zip
)
if "%DesPath%"=="" (
  set FileName=C:\inetpub\wwwroot\ReportViewService
)

echo -------------------------------------------------------------------------------->> %logfile%
echo 更新設定INIファイル[Common.ini]>> %logfile%
echo.>> %logfile%
echo 更新ファイルパス[%SrcPath%]>> %logfile%
echo 更新ファイル名[%FileName%]>> %logfile%
echo.>> %logfile%
echo IISパス[%DesPath%]>> %logfile%
echo -------------------------------------------------------------------------------->> %logfile%
echo.>> %logfile%

rem 更新ファイルのパスの存在判断
if not exist "%SrcPath%" (
echo -------------------------------------------------------------------------------->> %logfile%
echo 更新ファイルパス[%SrcPath%]が存在しません。>> %logfile%
echo 更新設定INIファイル[Common.ini]を確認してください。>> %logfile%
echo -------------------------------------------------------------------------------->> %logfile%
echo.>> %logfile%
exit /b 1
)

rem 更新ファイルの存在判断
if not exist "%SrcPath%\%FileName%" (
echo -------------------------------------------------------------------------------->> %logfile%
echo 更新ファイル[%FileName%]が存在しません。>> %logfile%
echo 更新設定INIファイル[Common.ini]を確認してください。>> %logfile%
echo -------------------------------------------------------------------------------->> %logfile%
echo.>> %logfile%
exit /b 1
)

rem 古い解凍パスを削除します
if exist "%SrcPath%\ReportViewService" (
echo -------------------------------------------------------------------------------->> %logfile%
echo 古い解凍パスを削除します。>> %logfile%
echo -------------------------------------------------------------------------------->> %logfile%
echo.>> %logfile%
   rd /S /Q "%SrcPath%\ReportViewService">> %logfile%
)

rem 更新ZIPファイルを解凍する
echo -------------------------------------------------------------------------------->> %logfile%
echo 更新ZIPファイルを解凍する>> %logfile%
echo -------------------------------------------------------------------------------->> %logfile%
set pscommand='powershell.exe -command "&{Expand-Archive -Path "%SrcPath%\%FileName%" -DestinationPath "%SrcPath%\ReportViewService" -Force; echo $? }"'
for /f %%a in (%pscommand%) do (set var=%%a)
if "%var%" == "True" (
echo 更新ファイル[%SrcPath%\%FileName%]の解凍に成功しました>> %logfile%
echo -------------------------------------------------------------------------------->> %logfile%
echo.>> %logfile%
) else (
echo 更新ファイル[%SrcPath%\%FileName%]の解凍に失敗しました。>> %logfile%
echo 圧縮ファイルが正しいか確認してください。>> %logfile%
echo -------------------------------------------------------------------------------->> %logfile%
echo.>> %logfile%
exit /b 1
)

rem 解凍したファイルをコピーする
rem XCOPYのパラメータ説明。
rem /W :ファイルのコピーを開始する前にメッセージ「続行するには何かキーを押してください」を表示し、応答を待っています。
rem /Q :「xcopy」のメッセージの表示を禁止します。
rem /E :空のディレクトリを含むすべてのサブディレクトリをコピーします。
rem /C :エラーを無視します。
rem /R :読み取り専用ファイルをコピーします。
rem /Y :既存のターゲットファイルを上書きするようにメッセージを禁止します。
echo -------------------------------------------------------------------------------->> %logfile%
echo 解凍したファイルをコピーする>> %logfile%
echo -------------------------------------------------------------------------------->> %logfile%
if exist "%SrcPath%\ReportViewService\ReportViewService" (
   XCOPY "%SrcPath%\ReportViewService\ReportViewService\*.*" "%DesPath%" /E /C /R /Y >> %logfile%
) else (
   XCOPY "%SrcPath%\ReportViewService\*.*" "%DesPath%" /E /C /R /Y >> %logfile% >> %logfile%
)

if %errorlevel% == 0 (
echo -------------------------------------------------------------------------------->> %logfile%
echo ファイルコピーに成功しました。>> %logfile%
echo -------------------------------------------------------------------------------->> %logfile%
echo.>> %logfile%
) else (
echo -------------------------------------------------------------------------------->> %logfile%
echo ファイルコピーに失敗しました。>> %logfile%
echo システム管理者に連絡してください。>> %logfile%
echo -------------------------------------------------------------------------------->> %logfile%
echo.>> %logfile%
exit /b 1
)

rem 本機のIPアドレスを取得します
for /f "tokens=4" %%a in ('route print^|findstr 0.0.0.0.*0.0.0.0') do (
 set IP=%%a
)

echo -------------------------------------------------------------------------------->> %logfile%
echo 更新に成功しました。下記のURLにアクセスしてください。>> %logfile%
echo http://%IP%/ReportViewService/>> %logfile%
echo -------------------------------------------------------------------------------->> %logfile%
echo.>> %logfile%

exit /b 0
