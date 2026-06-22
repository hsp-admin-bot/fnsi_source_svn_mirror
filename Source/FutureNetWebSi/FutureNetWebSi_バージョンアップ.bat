@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 932 >nul
rem =============================================================================================
rem 【バッチ概要】
rem FutureNetWeb+Si バージョンアップ用バッチ
rem 1) PostgreSQL / MongoDB / WebApp / Device サーバへの資源転送と遠隔シェル実行を自動化します。
rem 2) パスワードはサーバごとに対話入力します。
rem ---------------------------------------------------------------------------------------------
rem 【前提条件】
rem 1) OpenSSH Client（scp / ssh）がインストールされ、PATH が通っていること。
rem 2) システムは運用中・治療中ではないこと。
rem ---------------------------------------------------------------------------------------------
rem 【注意事項】
rem 1) 処理中は画面を閉じないでください。
rem =============================================================================================

rem =============================================================================================
rem 【環境設定】
rem バージョンアップ処理に必要な接続情報・転送設定・パッケージ構成を定義します。
rem 編集することで環境に合わせたカスタマイズが可能です。
rem =============================================================================================
rem --- 共通接続設定 ---
rem SSH/SCPで使用するユーザ名とポート番号
set "USER=root"
set "PORT=22"
rem SCPとSSHで異なるポート指定オプション
set "SCPPORTOPT=-P %PORT%"
set "SSHPORTOPT=-p %PORT%"
rem --- 既定ホスト ---
rem 各サーバのIPアドレス（既定）
set "DEFAULT_DB=192.168.2.202"        rem 業務LAN経由
set "DEFAULT_MONGO=192.168.2.203"     rem 業務LAN経由
set "DEFAULT_WEBAPP=192.168.2.204"    rem 業務LAN経由
set "DEFAULT_DEVICE=192.168.2.205"    rem 業務LAN経由
set "HOSTS_ENV_FILE=%~dp0FutureNetWebSi.hosts.env"
rem .env からの読込
if exist "%HOSTS_ENV_FILE%" (
  call :LOAD_ENV_FILE "%HOSTS_ENV_FILE%"
  if defined DB_HOST     set "DEFAULT_DB=!DB_HOST!"
  if defined MONGO_HOST  set "DEFAULT_MONGO=!MONGO_HOST!"
  if defined WEB_HOST    set "DEFAULT_WEBAPP=!WEB_HOST!"
  if defined DEVICE_HOST set "DEFAULT_DEVICE=!DEVICE_HOST!"
)
rem --- 転送設定 ---
rem リモート側の作業ルートディレクトリ
set "DEFAULT_WORK_ROOT=/root/"
rem DB転送先ディレクトリ
set "DST_DB=/root/flyway/sql/"
set "DST_MONGO=/root/mongo_pkg/"
rem ローカル側の転送元パス（ベースフォルダ）
set "SRC_BASE=30_UpdateResource"
rem DB関連ファイル
set "SRC_DB=%SRC_BASE%\31_migration\db*"
set "SRC_MONGO=%SRC_BASE%\31_migration\mongo\*"
rem WebApp関連ファイル
set "SRC_WEBAPP=%SRC_BASE%\32_WebAppServer\WebAppServe_Update\*"
set "SRC_WEBAPP_SH=%SRC_BASE%\32_WebAppServer\*.sh"
set "SRC_WEBAPP_APP_UP_DIR=%SRC_BASE%\32_WebAppServer\Application_Update\"
set "SRC_WEBAPP_MODEL_UPDATE_DIR=%SRC_BASE%\32_WebAppServer\Model_Update\"
set "SRC_WEBAPP_DEFAULT_REPORT_DIR=%SRC_BASE%\32_WebAppServer\Default_Report\"
rem Device関連ファイル
set "SRC_DEVICE_BIN=%SRC_BASE%\33_DeviceServer\DeviceServer_Update\*"
set "SRC_DEVICE_SH=%SRC_BASE%\33_DeviceServer\*.sh"
set "SRC_DEVICE_DE_UPDATE_ZIP=DE_Update*.zip"
set "SRC_DEVICE_DE_UPDATED_DIR=%SRC_BASE%\33_DeviceServer\DE_Updated\"
set "SRC_DEVICE_IFE_VERSIONUP_DIR=%SRC_BASE%\33_DeviceServer\IFE_Updated\versionup\"
rem --- 宛先サブディレクトリ名（パッケージ内構成） ---
set "WEBAPP_DST_APP_UD_SUBDIR=Application_Update"
set "WEBAPP_DST_MODEL_UPDATE_SUBDIR=Model_Update"
set "WEBAPP_DST_DEFAULT_REPORT_SUBDIR=default_report"
set "DEVICE_DE_UPDATED_SUBDIR=DE_Updated"
set "DEVICE_IFE_VERSIONUP_SUBDIR=IFE_Updated\versionup"
rem --- バージョンアップ設定 ---
rem パッケージ名（ローカル梱包用）
set "PKG_NAME_WEBAPP=webapp_pkg"
set "PKG_NAME_DEVICE=device_pkg"
rem リモート側の展開先ディレクトリ
set "WEBAPP_PKG_DIR=%DEFAULT_WORK_ROOT%%PKG_NAME_WEBAPP%"
set "DEVICE_PKG_DIR=%DEFAULT_WORK_ROOT%%PKG_NAME_DEVICE%"
rem 実行シェル（リモート側）
set "SH_DB=/root/migrate.sh"
set "SH_MONGO=%DST_MONGO%index_update.sh"
set "SH_WEBAPP=%WEBAPP_PKG_DIR%/deploy.sh"
set "SH_DEVICE=%DEVICE_PKG_DIR%/deploy.sh"
rem --- 運用設定 ---
rem ログ出力ディレクトリとファイル名プレフィックス
set "LOG_DIR=%~dp0"
set "LOG_PREFIX=FutureNetWebSi_バージョンアップ実行_"
rem コマンド名（SCP/SSH）
set "CMD_SCP=scp"
set "CMD_SSH=ssh"
rem スクリプトの実行ディレクトリ
set "SRC_DIR=%~dp0"
rem --- デフォルト値を実行時変数へ展開 ---
set "DB=%DEFAULT_DB%"
set "MONGO=%DEFAULT_MONGO%"
set "WEBAPP=%DEFAULT_WEBAPP%"
set "DEVICE=%DEFAULT_DEVICE%"

rem =============================================================================================
rem 【タイムスタンプ生成 & ログ初期化】
rem 1) 処理開始時に yyyyMMddHHmmss 形式のタイムスタンプを作成します。
rem 2) ログファイルをスクリプトと同じディレクトリに生成します。
rem 3) Windows ロケール依存の %date% / %time% を使用するため、ゼロ埋めで整形します。
rem =============================================================================================
rem --- 日付の分解（%date%を / または - 区切りで分割） ---
for /f "tokens=1-3 delims=/.-" %%a in ("%date%") do (
  set "YYYY=%%a"
  set "MM=00%%b"
  set "DD=00%%c"
)
rem 月・日を2桁に整形
set "MM=%MM:~-2%"
set "DD=%DD:~-2%"
rem --- 時刻の分解（%time%から時・分・秒を抽出） ---
set "HH=%time:~0,2%"
set "MN=%time:~3,2%"
set "SS=%time:~6,2%"
rem 時刻の先頭スペースをゼロ埋め
set "HH=%HH: =0%"
rem --- タイムスタンプ生成 ---
set "TS=%YYYY%%MM%%DD%%HH%%MN%%SS%"
rem --- ログディレクトリ確認 & 作成 ---
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%" >nul 2>&1
rem --- ログファイルパス設定 ---
set "LOG=%LOG_DIR%\%LOG_PREFIX%%TS%.log"

rem --- エラーフラグ初期化（0=成功、1=失敗） ---
set "HAS_ERROR=0"

rem =============================================================================================
rem ANSI エスケープ（配色するための設定）
rem =============================================================================================
for /F "delims=" %%A in ('echo prompt $E^| cmd') do set "ESC=%%A"
set "RED=%ESC%[31m"
set "GREEN=%ESC%[32m"
set "RESET=%ESC%[0m"

rem =============================================================================================
rem 1. 必須コマンド存在確認・起動メッセージ
rem =============================================================================================
echo FutureNetWeb+Siのバージョンアップを実行します。
call :LOGU8 " [開始] %date% %time%"

rem =============================================================================================
rem 2. 実施メニュー
rem =============================================================================================
:MENU_EXEC
echo.
echo ================================================================
echo 実施内容を選択してください。
if defined ERROR_MSG (
  echo !RED!エラー：%ERROR_MSG%!RESET!
  echo もう一度入力してください。
  call :LOGU8 "[ERROR] 入力値「%MENU_SEL%」は無効です。"
  set "ERROR_MSG="
)
echo ================================================================
echo 1．フルバージョンアップ（Postgresql + MongoDB + Webapp + Device）
echo 2．DBのみバージョンアップ（Postgresql + MongoDB）
echo 3．アプリのみバージョンアップ（Webapp + Device）
echo 4．Postgresql のみバージョンアップ
echo 5．MongoDB のみバージョンアップ
echo 6．Webapp のみバージョンアップ
echo 7．Device のみバージョンアップ
echo ----------------------------------------------------------------
set "MENU_SEL="
set /p MENU_SEL=番号を入力して Enter ＞ 

set "DO_DB=0"
set "DO_MONGO=0"
set "DO_WEB=0"
set "DO_DEVICE=0"

if "%MENU_SEL%"=="1" set "DO_DB=1" & set "DO_MONGO=1" & set "DO_WEB=1" & set "DO_DEVICE=1" & goto :CONFIRM
if "%MENU_SEL%"=="2" set "DO_DB=1" & set "DO_MONGO=1" & goto :CONFIRM
if "%MENU_SEL%"=="3" set "DO_WEB=1" & set "DO_DEVICE=1" & goto :CONFIRM
if "%MENU_SEL%"=="4" set "DO_DB=1" & goto :CONFIRM
if "%MENU_SEL%"=="5" set "DO_MONGO=1" & goto :CONFIRM
if "%MENU_SEL%"=="6" set "DO_WEB=1" & goto :CONFIRM
if "%MENU_SEL%"=="7" set "DO_DEVICE=1" & goto :CONFIRM
set "ERROR_MSG=入力値「%MENU_SEL%」は無効です。選択肢は 1, 2, 3, 4, 5, 6, 7 です。" & cls
goto :MENU_EXEC

rem =============================================================================================
rem 3. 接続先確認
rem =============================================================================================
:CONFIRM
echo.
echo ================================================================
echo バージョンアップサーバの確認
echo ================================================================
echo  サーバ名                     ^| 接続先IP
echo ----------------------------- ^| --------------------------------
if "%DO_DB%"=="1"     echo  データベース（PostgreSQL）   ^| %DB%
if "%DO_MONGO%"=="1"  echo  データベース（MongoDB）      ^| %MONGO%
if "%DO_WEB%"=="1"    echo  フロントエンド（Webapp）     ^| %WEBAPP%
if "%DO_DEVICE%"=="1" echo  バックエンド（Device）       ^| %DEVICE%
echo ----------------------------------------------------------------
echo ※　システムを停止します。運用中・治療中ではないことを確認してください。
echo ※　処理中は画面を閉じないでください。
echo ※　IPアドレスを変更したい場合、一度閉じて「FutureNetWebSi.hosts.env」を編集してください。
echo 上記IPアドレスでバージョンアップを実行してよいですか？

call :LOGU8 "============================================================================================="
call :LOGU8 "[情報] configuration details"
call :LOGU8 "============================================================================================="
call :LOGU8 "[情報] USER=%USER%, PORT=%PORT%"
call :LOGU8 "[情報] SRC_DIR=%SRC_DIR%"
call :LOGU8 "[情報] WORK_ROOT=%DEFAULT_WORK_ROOT%"
call :LOGU8 "[情報] WEBAPP_PKG_DIR=%WEBAPP_PKG_DIR%, DEVICE_PKG_DIR=%DEVICE_PKG_DIR%"
call :LOGU8 "[情報] DB:%DB% ( SEND : %SRC_DB%, TARGET : %DST_DB%, EXEC : %SH_DB% )"
call :LOGU8 "[情報] Mongo:%MONGO% ( SEND : %SRC_MONGO%, TARGET : %DST_MONGO%, EXEC : %SH_MONGO% )"
call :LOGU8 "[情報] Webapp:%WEBAPP% ( SEND : %SRC_WEBAPP_SH%, %SRC_WEBAPP%, %SRC_WEBAPP_APP_UP_DIR%, %SRC_WEBAPP_MODEL_UPDATE_DIR%, %SRC_WEBAPP_DEFAULT_REPORT_DIR%, TARGET : %DEFAULT_WORK_ROOT%, EXEC : %SH_WEBAPP% )"
call :LOGU8 "[情報] Device:%DEVICE% ( SEND : %SRC_DEVICE_SH%, %SRC_DEVICE_BIN%, %SRC_DEVICE_IFE_VERSIONUP_DIR%, %SRC_DEVICE_DE_UPDATE_ZIP%, TARGET : %DEFAULT_WORK_ROOT%, EXEC : %SH_DEVICE% )"

set /p USE_DEFAULT=Y (バージョンアップ実行) / N (バッチ処理終了)：
if /I "%USE_DEFAULT%"=="Y" goto PING_CHECK
if /I "%USE_DEFAULT%"=="N" goto END
echo 【終了】入力が Y/N ではないため、処理を終了します。
goto SHOW_ERR

rem =============================================================================================
rem 3-1. 最終確認後の疎通チェック（ping）
rem NOTE: [実施メニュー] で選択したサーバのみ確認
rem =============================================================================================
:PING_CHECK
echo.
echo 【疎通確認】ping による接続確認を行います
if "%DO_DB%"=="1"     call :PING_ONE "DB" "%DB%"
if "%DO_MONGO%"=="1"  call :PING_ONE "Mongo" "%MONGO%"
if "%DO_WEB%"=="1"    call :PING_ONE "WebApp" "%WEBAPP%"
if "%DO_DEVICE%"=="1" call :PING_ONE "Device" "%DEVICE%"
if "%HAS_ERROR%"=="1" goto PING_NG

echo 疎通確認OK
set "HAS_ERROR=0"
goto TRANSFER_START

rem =============================================================================================
rem 3-2. ping 実行（役割, ホスト）
rem 引数:
rem %1 = 役割表示（例：DB / Mongo / WebApp / Device）
rem %2 = ホスト（IP）
rem =============================================================================================
:PING_ONE
setlocal EnableDelayedExpansion
set "ROLE=%~1"
set "HOST=%~2"
rem -n 1 : 1回だけ送信、-w 1500 : タイムアウト(ms)（必要に応じて調整）
ping -n 1 -w 1500 "!HOST!" >nul
if errorlevel 1 ( call :PING_FAIL "!ROLE!" "!HOST!" & endlocal & set "HAS_ERROR=1" & goto :eof ) else ( call :PING_OK "!ROLE!" "!HOST!" & endlocal & goto :eof )

rem =============================================================================================
rem 3-3. PING 応答なし
rem =============================================================================================
:PING_NG
echo.
echo 【警告】疎通確認した結果、応答がないサーバがありました。
echo IPアドレスの見直しをしてください。
echo.
echo 【終了】処理を終了します。
goto SHOW_ERR

rem =============================================================================================
rem 4. サーバ毎の資源転送
rem =============================================================================================
:TRANSFER_START
call :LOGU8 "============================================================================================="
call :LOGU8 "[情報] file transfer start"
call :LOGU8 "============================================================================================="

rem --- ファイル転送（DB） ---
if "%DO_DB%"=="1" call :TRANSFER_DB
rem --- ファイル転送（Mongo） ---
if "%DO_MONGO%"=="1" call :TRANSFER_MONGO
rem --- ファイル転送（WebApp） ---
if "%DO_WEB%"=="1" call :TRANSFER_WEBAPP
rem --- ファイル転送（Device） ---
if "%DO_DEVICE%"=="1" call :TRANSFER_DEVICE
echo 【すべての資源転送完了】
goto REMOTE_SHELL_EXEC

rem =============================================================================================
rem 4-1. ファイル転送（DB）
rem =============================================================================================
:TRANSFER_DB
setlocal EnableDelayedExpansion
set "CUR_PATTERN=%SRC_DB%"

rem 末尾バックスラッシュの除去（パターンが "dir\" のような場合）
if "!CUR_PATTERN:~-1!"=="\" set "CUR_PATTERN=!CUR_PATTERN:~0,-1!"

rem 存在チェック（対象ディレクトリがない場合はスキップ）
if not exist "%SRC_DIR%!CUR_PATTERN!" goto DB_NO_FILES

set "RFLAG="
for /f "delims=" %%D in ('dir /b /ad "%SRC_DIR%!CUR_PATTERN!" 2^>nul') do set "RFLAG= -r"

echo.
echo 【資源転送】
echo DBサーバのrootユーザのパスワードを入力してください
call :LOGU8 "[情報] %CMD_SCP% %SCPPORTOPT%%RFLAG% %SRC_DIR%!CUR_PATTERN! %USER%@%DB%:%DST_DB%"

rem 転送対象のファイル名をログ追記
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$OutputEncoding=[Text.Encoding]::GetEncoding(932);" ^
 "$root = '%SRC_DIR%'; $pat = '!CUR_PATTERN!';" ^
 "$targets = Resolve-Path -Path (Join-Path $root $pat) -ErrorAction SilentlyContinue;" ^
 "foreach($t in $targets) { Get-ChildItem -Path $t.Path -File -Recurse -ErrorAction SilentlyContinue | ForEach-Object { Add-Content -LiteralPath '%LOG%' -Value $_.Name -Encoding UTF8 } }"

%CMD_SCP% %SCPPORTOPT%%RFLAG% "%SRC_DIR%!CUR_PATTERN!" "%USER%@%DB%:%DST_DB%"
set "RC=!ERRORLEVEL!"
if !RC! GEQ 1 ( call :ERR_TRANSFER "DB" "%DB%" & endlocal & set "HAS_ERROR=1" & goto :eof )

echo 【資源転送完了】 DB： %DB% (pattern=!CUR_PATTERN!)
call :LOGU8 "[情報] transfer complete: %DB% pattern=!CUR_PATTERN!"
call :LOGU8 "#############################################################################################"
endlocal & goto :eof

:DB_NO_FILES
call :SKIP_NO_FILES "DB" "%DB%" "!CUR_PATTERN!"
endlocal & goto :eof

rem =============================================================================================
rem 4-2. ファイル転送（Mongo）
rem =============================================================================================
:TRANSFER_MONGO
setlocal EnableDelayedExpansion
set "CUR_PATTERN=%SRC_MONGO%"

rem 末尾バックスラッシュの除去（パターンが "dir\" のような場合）
if "!CUR_PATTERN:~-1!"=="\" set "CUR_PATTERN=!CUR_PATTERN:~0,-1!"

rem 存在チェック（対象ディレクトリ/ファイルがない場合はスキップ）
if not exist "%SRC_DIR%!CUR_PATTERN!" goto MONGO_NO_FILES

set "RFLAG="
for /f "delims=" %%D in ('dir /b /ad "%SRC_DIR%!CUR_PATTERN!" 2^>nul') do set "RFLAG= -r"

echo.
echo 【資源転送】
echo Mongoサーバのrootユーザのパスワードを入力してください
call :LOGU8 "[情報] %CMD_SCP% %SCPPORTOPT%%RFLAG% %SRC_DIR%!CUR_PATTERN! %USER%@%MONGO%:%DST_MONGO%"

rem 転送対象のファイル名をログ追記
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$OutputEncoding=[Text.Encoding]::GetEncoding(932);" ^
 "$root = '%SRC_DIR%'; $pat = '!CUR_PATTERN!';" ^
 "$targets = Resolve-Path -Path (Join-Path $root $pat) -ErrorAction SilentlyContinue;" ^
 "foreach($t in $targets) { Get-ChildItem -Path $t.Path -File -Recurse -ErrorAction SilentlyContinue | ForEach-Object { Add-Content -LiteralPath '%LOG%' -Value $_.Name -Encoding UTF8 } }"

%CMD_SCP% %SCPPORTOPT%%RFLAG% "%SRC_DIR%!CUR_PATTERN!" "%USER%@%MONGO%:%DST_MONGO%"
set "RC=!ERRORLEVEL!"
if !RC! GEQ 1 ( call :ERR_TRANSFER "Mongo" "%MONGO%" & endlocal & set "HAS_ERROR=1" & goto :eof )

echo 【資源転送完了】 Mongo： %MONGO% (pattern=!CUR_PATTERN!)
call :LOGU8 "[情報] transfer complete: %MONGO% pattern=!CUR_PATTERN!"
call :LOGU8 "#############################################################################################"
endlocal & goto :eof

:MONGO_NO_FILES
call :SKIP_NO_FILES "Mongo" "%MONGO%" "!CUR_PATTERN!"
endlocal & goto :eof

rem =============================================================================================
rem 4-3. ファイル転送（WebApp）
rem =============================================================================================
:TRANSFER_WEBAPP
setlocal EnableDelayedExpansion
set "TMPDIR=%TEMP%\%PKG_NAME_WEBAPP%_%TS%_%RANDOM%"
set "PKGNAME=%PKG_NAME_WEBAPP%"
set "PKGLOCAL=%TMPDIR%\%PKGNAME%"
set "DST_ROOT=%DEFAULT_WORK_ROOT%"

mkdir "%PKGLOCAL%" >nul 2>&1
set "HAS_SRC=0"

if exist "%SRC_DIR%%SRC_WEBAPP_SH%" ( xcopy "%SRC_DIR%%SRC_WEBAPP_SH%" "%PKGLOCAL%\" /Y /I >nul 2>&1 & set "HAS_SRC=1" )
if exist "%SRC_DIR%%SRC_WEBAPP%" ( xcopy "%SRC_DIR%%SRC_WEBAPP%" "%PKGLOCAL%\" /Y /I >nul 2>&1 & set "HAS_SRC=1" )
if exist "%SRC_DIR%%SRC_WEBAPP_MODEL_UPDATE_DIR%" ( xcopy "%SRC_DIR%%SRC_WEBAPP_MODEL_UPDATE_DIR%" "%PKGLOCAL%\%WEBAPP_DST_MODEL_UPDATE_SUBDIR%\" /E /Y /I >nul 2>&1 & set "HAS_SRC=1" )

set "APPUP_SRC=%SRC_DIR%%SRC_WEBAPP_APP_UP_DIR%"
set "APPUP_DST=%PKGLOCAL%\%WEBAPP_DST_APP_UD_SUBDIR%"
if not exist "%APPUP_DST%\" mkdir "%APPUP_DST%" >nul 2>&1

rem 配下すべてを転送
if exist "%APPUP_SRC%" ( xcopy "%APPUP_SRC%\*" "%APPUP_DST%\" /E /Y /I >nul 2>&1 & set "HAS_SRC=1" )
if exist "%SRC_DIR%%SRC_WEBAPP_DEFAULT_REPORT_DIR%" ( xcopy "%SRC_DIR%%SRC_WEBAPP_DEFAULT_REPORT_DIR%" "%PKGLOCAL%\%WEBAPP_DST_DEFAULT_REPORT_SUBDIR%\" /E /Y /I >nul 2>&1 & set "HAS_SRC=1" )

if "%HAS_SRC%"=="0" goto WEBAPP_NO_FILES

echo.
echo 【資源転送】
echo WebAppサーバのrootユーザのパスワードを入力してください
call :LOGU8 "[情報] %CMD_SCP% %SCPPORTOPT% -r %PKGLOCAL% %USER%@%WEBAPP%:%DST_ROOT%"

rem 梱包内容のファイル名をログへ列挙
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$OutputEncoding=[Text.Encoding]::GetEncoding(932);" ^
 "Get-ChildItem -Path '%PKGLOCAL%' -File -Recurse | ForEach-Object { Add-Content -LiteralPath '%LOG%' -Value $_.Name -Encoding UTF8 }"

%CMD_SCP% %SCPPORTOPT% -r "%PKGLOCAL%" "%USER%@%WEBAPP%:%DST_ROOT%"
set "RC=%ERRORLEVEL%"
rmdir /S /Q "%TMPDIR%" >nul 2>&1
if %RC% GEQ 1 ( call :ERR_TRANSFER "WebApp" "%WEBAPP%" & endlocal & set "HAS_ERROR=1" & goto :eof )

echo 【資源転送完了】 WEBAPP： %WEBAPP%
call :LOGU8 "[情報] transfer complete: Webapp %WEBAPP%"
call :LOGU8 "#############################################################################################"
endlocal & goto :eof

:WEBAPP_NO_FILES
set "PATLIST=%SRC_WEBAPP_SH% / %SRC_WEBAPP% / %SRC_WEBAPP_APP_UP_DIR% / %SRC_WEBAPP_MODEL_UPDATE_DIR%"
call :SKIP_NO_FILES "WebApp" "%WEBAPP%" "%PATLIST%" "%TMPDIR%"
endlocal & goto :eof

rem =============================================================================================
rem 4-4. ファイル転送（Device）
rem =============================================================================================
:TRANSFER_DEVICE
setlocal
set "TMPDIR=%TEMP%\%PKG_NAME_DEVICE%_%TS%_%RANDOM%"
set "PKGNAME=%PKG_NAME_DEVICE%"
set "PKGLOCAL=%TMPDIR%\%PKGNAME%"
set "DST_ROOT=%DEFAULT_WORK_ROOT%"

mkdir "%PKGLOCAL%" >nul 2>&1
set "HAS_SRC=0"

if exist "%SRC_DIR%%SRC_DEVICE_SH%" ( xcopy "%SRC_DIR%%SRC_DEVICE_SH%" "%PKGLOCAL%\" /Y /I >nul 2>&1 & set "HAS_SRC=1" )
if exist "%SRC_DIR%%SRC_DEVICE_BIN%" ( xcopy "%SRC_DIR%%SRC_DEVICE_BIN%" "%PKGLOCAL%\" /Y /I >nul 2>&1 & set "HAS_SRC=1" )
if exist "%SRC_DIR%%SRC_DEVICE_IFE_VERSIONUP_DIR%" ( xcopy "%SRC_DIR%%SRC_DEVICE_IFE_VERSIONUP_DIR%" "%PKGLOCAL%\%DEVICE_IFE_VERSIONUP_SUBDIR%\" /E /Y /I >nul 2>&1 & set "HAS_SRC=1" )

rem DE_Updated の厳密一致 ZIP を同梱（大小完全一致のパターン選別）
if not exist "%PKGLOCAL%\%DEVICE_DE_UPDATED_SUBDIR%\" (
  mkdir "%PKGLOCAL%\%DEVICE_DE_UPDATED_SUBDIR%" >nul 2>&1
)

rem DE_Update*.zip（厳密一致／大小不一致候補は SKIP ログへ）
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$OutputEncoding=[Text.Encoding]::GetEncoding(932);" ^
  "$dir = '%SRC_DIR%%SRC_DEVICE_DE_UPDATED_DIR%';" ^
  "$pat = '%SRC_DEVICE_DE_UPDATE_ZIP%';" ^
  "$dst = '%PKGLOCAL%\%DEVICE_DE_UPDATED_SUBDIR%';" ^
  "$exact  = Get-ChildItem -LiteralPath $dir -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -clike $pat };" ^
  "$insens = Get-ChildItem -LiteralPath $dir -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -ilike $pat };" ^
  "if($exact -and $exact.Count -gt 0) {" ^
  "  foreach($f in $exact){ Copy-Item -LiteralPath $f.FullName -Destination $dst -Force };" ^
  "  exit 0" ^
  "} elseif($insens -and $insens.Count -gt 0) {" ^
  "  $names = ($insens | Select-Object -ExpandProperty Name) -join ', ';" ^
  "  Add-Content -LiteralPath '%LOG%' -Value ('[SKIP] case mismatch: expected pattern=' + $pat + ' actual candidates=' + $names) -Encoding UTF8;" ^
  "  exit 2" ^
  "} else {" ^
  "  Add-Content -LiteralPath '%LOG%' -Value ('[SKIP] not found: pattern=' + $pat) -Encoding UTF8;" ^
  "  exit 1" ^
  "}"

if %ERRORLEVEL% EQU 0 set "HAS_SRC=1"

if "%HAS_SRC%"=="0" goto DEVICE_NO_FILES

echo.
echo 【資源転送】
echo Deviceサーバのrootユーザのパスワードを入力してください
call :LOGU8 "[情報] %CMD_SCP% %SCPPORTOPT% -r %PKGLOCAL% %USER%@%DEVICE%:%DST_ROOT%"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$OutputEncoding=[Text.Encoding]::GetEncoding(932);" ^
 "Get-ChildItem -Path '%PKGLOCAL%' -File -Recurse | ForEach-Object { Add-Content -LiteralPath '%LOG%' -Value $_.Name -Encoding UTF8 }"

%CMD_SCP% %SCPPORTOPT% -r "%PKGLOCAL%" "%USER%@%DEVICE%:%DST_ROOT%"
set "RC=%ERRORLEVEL%"
rmdir /S /Q "%TMPDIR%" >nul 2>&1
if %RC% GEQ 1 ( call :ERR_TRANSFER "Device" "%DEVICE%" & endlocal & set "HAS_ERROR=1" & goto :eof )

echo 【資源転送完了】 DEVICE： %DEVICE%
call :LOGU8 "[情報] transfer complete: Device %DEVICE%"
call :LOGU8 "#############################################################################################"
endlocal & goto :eof

:DEVICE_NO_FILES
set "PATLIST=%SRC_DEVICE_SH% / %SRC_DEVICE_BIN% / %SRC_DEVICE_IFE_VERSIONUP_DIR% / %SRC_DEVICE_DE_UPDATE_ZIP%"
call :SKIP_NO_FILES "Device" "%DEVICE%" "%PATLIST%" "%TMPDIR%"
endlocal & goto :eof

rem =============================================================================================
rem 5. すべての転送が成功したら遠隔シェルを順番に実行
rem =============================================================================================
:REMOTE_SHELL_EXEC
if "%HAS_ERROR%"=="1" goto SUMMARY

call :LOGU8 "============================================================================================="
call :LOGU8 "[情報] start execute shell"
call :LOGU8 "============================================================================================="

rem --- DB ---
if "%DO_DB%"=="1" call :RUN_SHELL "DB" "%DB%" "bash -lc %SH_DB%"
if "%HAS_ERROR%"=="1" goto SUMMARY
rem --- Mongo ---
if "%DO_MONGO%"=="1" call :RUN_SHELL "Mongo" "%MONGO%" "chmod 700 %DST_MONGO%*.sh; bash -lc %SH_MONGO%"
if "%HAS_ERROR%"=="1" goto SUMMARY
rem --- WebApp ---
if "%DO_WEB%"=="1" call :RUN_SHELL "WebApp" "%WEBAPP%" "chmod 700 %WEBAPP_PKG_DIR%/*.sh; bash -lc %SH_WEBAPP%"
if "%HAS_ERROR%"=="1" goto SUMMARY
rem --- Device ---
if "%DO_DEVICE%"=="1" call :RUN_SHELL "Device" "%DEVICE%" "chmod 700 %DEVICE_PKG_DIR%/*.sh; bash -lc %SH_DEVICE%"

goto SUMMARY

rem =============================================================================================
rem ■ 共通：遠隔シェル実行（役割, ホスト, 実行コマンド）
rem 引数:
rem %1 = 役割表示（例：DB / Mongo / WebApp / Device）
rem %2 = ホスト（IP または FQDN）
rem %3 = 実行コマンド（例：bash -lc / chmod + bash -lc など）
rem =============================================================================================
:RUN_SHELL
setlocal EnableDelayedExpansion
set "ROLE=%~1"
set "HOST=%~2"
set "EX_CMD=%~3"
chcp 932 >nul
echo 【バージョンアップ処理】
echo !ROLE! サーバのrootユーザのパスワードを入力してください
call :LOGU8 "[情報] %CMD_SSH% %SSHPORTOPT% %USER%@!HOST! !EX_CMD!"

rem --- SSH 実行（UTF-8でログ追記） ---
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "[Console]::OutputEncoding=[Text.Encoding]::UTF8; $cmd = '%CMD_SSH% %SSHPORTOPT% \"%USER%@%HOST%\" \"%EX_CMD%\"';" ^
 "cmd /c $cmd 2>&1 | ForEach-Object { $line=$_.ToString(); $line; Add-Content -LiteralPath '%LOG%' -Value $line -Encoding UTF8 }; exit $LASTEXITCODE"

set "RC=%ERRORLEVEL%"
if !RC! GEQ 1 ( call :ERR_RUN_SHELL !ROLE! !HOST! "!EX_CMD!" & endlocal & set "HAS_ERROR=1" & goto :eof )

chcp 932 >nul
call :LOGU8 "[情報] remote shell done : !ROLE! host=!HOST! cmd=!EX_CMD!"
call :LOGU8 "#############################################################################################"
endlocal & goto :eof

rem =============================================================================================
rem 6. 終了
rem =============================================================================================
:SUMMARY
chcp 932 >nul
if "%HAS_ERROR%"=="1" goto SHOW_ERR
goto SHOW_OK

:SHOW_ERR
rem --- 一部失敗の最終メッセージ ---
echo.
echo [ERROR] 一部サーバで転送またはシェル実行の失敗がありました。ログを確認してください。
goto END

:SHOW_OK
rem --- 成功の最終メッセージ ---
echo.
echo 【バージョンアップ処理完了】
echo Errorが発生していないことを確認してください。
goto END

:END
call :LOGU8 "[終了] %date% %time%"
pause
goto :eof

rem =============================================================================================
rem 【共通処理】
rem =============================================================================================
rem =============================================================================================
rem 共通：指定ファイル/パターンが見つからない場合のスキップ処理
rem 引数:
rem %1 = 役割（DB / Mongo / WebApp / Device）
rem %2 = ホスト
rem %3 = パターン一覧または説明文字列
rem %4 = 後始末する一時ディレクトリ（任意／空文字なら何もしない）
rem =============================================================================================
:SKIP_NO_FILES
setlocal
set "ROLE=%~1"
set "HOST=%~2"
set "DESC=%~3"
set "CLEAN=%~4"
echo [SKIP] %HOST%: 指定ファイル/パターンが見つかりません - "%DESC%"
call :LOGU8 "[スキップ] %HOST% no files for %DESC%"
if not "%CLEAN%"=="" rmdir /S /Q "%CLEAN%" >nul 2>&1
endlocal & goto :eof

rem =============================================================================================
rem 共通：ping 疎通成功時の表示・ログ出力
rem 1) ping に成功した役割/ホストを標準出力へ表示します。
rem 2) ログへ「ping ok」情報を追記します（LOGU8 を使用、UTF-8出力）。
rem 引数:
rem %1 = 役割表示（例：DB / Mongo / WebApp / Device）
rem %2 = ホスト（IP）
rem 戻り値:
rem なし（goto :eof）
rem =============================================================================================
:PING_OK
echo %~1 ⇒ ping OK（設定IPアドレス: %~2 ）
call :LOGU8 "[情報] ping ok: role=%~1 host=%~2"
goto :eof

rem =============================================================================================
rem 共通：ping 疎通失敗時の表示・ログ出力
rem 1) ping に失敗した役割/ホストを標準出力へ表示します。
rem 2) ログへ「ping failed」エラー情報を追記します（LOGU8 を使用、UTF-8出力）。
rem 引数:
rem %1 = 役割表示（例：DB / Mongo / WebApp / Device）
rem %2 = ホスト（IP）
rem 戻り値:
rem なし（goto :eof）
rem =============================================================================================
:PING_FAIL
echo %~1 ⇒ ping NG（設定IPアドレス: %~2 ）
call :LOGU8 "[ERROR] ping failed: role=%~1 host=%~2"
goto :eof

rem =============================================================================================
rem 共通：SCP 転送失敗時のエラーメッセージ表示・ログ出力
rem 1) 指定サーバへの転送失敗を標準出力へ表示します。
rem 2) ログへ「SCP failed」エラー情報を追記します（LOGU8 を使用、UTF-8出力）。
rem 補足:
rem - 呼び出し元で HAS_ERROR=1 を立て、処理全体の失敗判定に使用します。
rem 引数:
rem %1 = 役割表示（例：DB / Mongo / WebApp / Device）
rem %2 = ホスト（IP または FQDN）
rem 戻り値:
rem なし（goto :eof）
rem =============================================================================================
:ERR_TRANSFER
set "ROLE=%~1"
set "HOST=%~2"
chcp 932 >nul
echo [ERROR] %ROLE% サーバへのSCP転送に失敗しました (%HOST%)
call :LOGU8 "[ERROR] SCP failed: %ROLE% host=%HOST%"
goto :eof

rem =============================================================================================
rem 共通：遠隔シェル実行失敗時のエラーメッセージ表示・ログ出力
rem 1) 指定サーバでのシェル実行失敗を標準出力へ表示します。
rem 2) ログへ「remote shell failed」エラー情報を追記します（LOGU8 を使用、UTF-8出力）。
rem 補足:
rem - 呼び出し元で HAS_ERROR=1 を立て、後続処理の打ち切り判定に使用します。
rem 引数:
rem %1 = 役割表示（例：DB / Mongo / WebApp / Device）
rem %2 = ホスト（IP または FQDN）
rem %3 = 実行コマンド（例：bash -lc / chmod +x ... など）
rem 戻り値:
rem なし（goto :eof）
rem =============================================================================================
:ERR_RUN_SHELL
set "ROLE=%~1"
set "HOST=%~2"
set "EX_CMD=%~3"
chcp 932 >nul
echo [ERROR] シェル実行失敗: %ROLE% @ %HOST% (%EX_CMD%)
call :LOGU8 "[ERROR] remote shell failed: %ROLE% host=%HOST% command=%EX_CMD%"
goto :eof

rem =============================================================================================
rem 共通：ログ追記（UTF-8）
rem 1) 引数で受け取った1行文字列をログファイルへ追記します。
rem 2) PowerShell Add-Content の -Encoding UTF8 を使用します。
rem 注意:
rem - ログファイルパスは環境変数 %LOG% を参照します（事前に初期化されていること）。
rem - "!" を含む文字列の意図しない展開を避けるため、DelayedExpansion は無効化します。
rem 引数:
rem %1 = ログへ追記する1行文字列（引用符込みで渡す想定）
rem 戻り値:
rem なし（goto :eof）
rem =============================================================================================
:LOGU8
setlocal DisableDelayedExpansion
set "LINE=%~1"
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "Add-Content -LiteralPath '%LOG%' -Value $env:LINE -Encoding UTF8"
endlocal & goto :eof

rem =============================================================================================
rem 前後空白の除去（単純トリム）
rem 使い方: call :TRIM " value " OUTVAR
rem =============================================================================================
:TRIM
set "_s=%~1"
for /f "tokens=* delims= " %%Z in ("!_s!") do set "_s=%%Z"
rem NOTE: 内部ループ用アンカー（外部からは呼び出さない）
:TRIM_TAIL
if "!_s:~-1!"==" " (set "_s=!_s:~0,-1!" & goto :TRIM_TAIL)
set "%~2=%_s%"
goto :eof

rem =============================================================================================
rem .env ローダー
rem 形式: KEY=VALUE / 空行と先頭が # or ; の行は無視
rem 使い方: if exist "%HOSTS_ENV_FILE%" call :LOAD_ENV_FILE "%HOSTS_ENV_FILE%"
rem =============================================================================================
:LOAD_ENV_FILE
set "ENV_PATH=%~1"
if not exist "%ENV_PATH%" goto :eof
for /f "usebackq tokens=1* delims==" %%A in (`
  findstr /R /V /C:"^$" /C:"^[#;]" "%ENV_PATH%"
`) do (
  set "K=%%~A"
  set "V=%%~B"
  if /I "!K:~0,7!"=="export " set "K=!K:~7!"
  call :TRIM "!K!" K
  call :TRIM "!V!" V
  if "!V:~0,1!"=="\"" if "!V:~-1!"=="\"" set "V=!V:~1,-1!"
  if not "!K!"=="" set "!K!=!V!"
)
goto :eof
