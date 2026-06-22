@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 932 >nul
rem =============================================================================================
rem 【バッチ概要】
rem FutureNetWeb+Si 用のサーバ操作バッチです。
rem  WebApp / Device / PostgreSQL / MongoDB に対して以下の操作を行います：
rem   1) systemd サービスの状態確認（status）
rem   2) サービスの起動（start）
rem   3) サービスの停止（stop）
rem   4) サービスの再起動（restart）
rem   5) システムリソース確認（ディスク、メモリ、CPU使用率）
rem   6) DB接続確認（PostgreSQL / MongoDB のみ）
rem ---------------------------------------------------------------------------------------------
rem 【前提条件】
rem   1) Windows 環境に ssh（OpenSSH Client）がインストールされていること
rem   2) 本バッチと同フォルダに FutureNetWebSi.hosts.env を配置していること
rem ---------------------------------------------------------------------------------------------
rem 【注意事項】
rem   1) バッチ実行中 (サーバコマンド実行中) はウィンドウを閉じないでください。
rem   2) 業務中・治療中など、サーバ停止が影響を及ぼすタイミングでは実行しないでください。
rem =============================================================================================

rem =============================================================================================
rem 【環境設定】
rem =============================================================================================
set "HOSTS_ENV_FILE=%~dp0FutureNetWebSi.hosts.env"
rem SSH 既定
set "DEFAULT_SSH_USER=root"
set "DEFAULT_SSH_PORT=22"
rem 接続先ホスト（既定）
set "DEFAULT_DB_HOST=192.168.2.202"
set "DEFAULT_MONGO_HOST=192.168.2.203"
set "DEFAULT_WEB_HOST=192.168.2.204"
set "DEFAULT_DEVICE_HOST=192.168.2.205"
rem モジュール名、サービス名
set "WEB_ADMIN_NAME=admin-web"
set "WEB_ADMIN_SERVICE=ntss_admin_web.service"
set "WEB_COMM_NAME=client-comm"
set "WEB_COMM_SERVICE=ntss_client_comm.service"
set "WEB_COVERT_NAME=convert"
set "WEB_COVERT_SERVICE=ntss_convert.service"
set "DEVICE_SERVICE=tomcat.service"
set "DB_SERVICE=postgresql-15.service"
set "MONGO_SERVICE=mongod.service"

rem 実行モード: 1=表示のみ（DRY-RUN）, 0=本実行
set "DEFAULT_DRY_RUN=0"
rem 画面クリア: 1=する, 0=しない
set "CLEAR_SCREEN=1"

rem ---------------------------------------------------------------------------------------------
rem 外部 .env を読み込み（存在する場合）→ DEFAULT_* を上書き
rem 対応キー例: WEB_HOST / DEVICE_HOST / DB_HOST / MONGO_HOST
rem ---------------------------------------------------------------------------------------------
if exist "%HOSTS_ENV_FILE%" (
  call :LOAD_ENV_FILE "%HOSTS_ENV_FILE%"
  if defined DB_HOST     set "DEFAULT_DB_HOST=!DB_HOST!"
  if defined MONGO_HOST  set "DEFAULT_MONGO_HOST=!MONGO_HOST!"
  if defined WEB_HOST    set "DEFAULT_WEB_HOST=!WEB_HOST!"
  if defined DEVICE_HOST set "DEFAULT_DEVICE_HOST=!DEVICE_HOST!"
)

rem =============================================================================================
rem ANSI エスケープ（配色するための設定）
rem =============================================================================================
for /F "delims=" %%A in ('echo prompt $E^| cmd') do set "ESC=%%A"
set "RED=%ESC%[31m"
set "GREEN=%ESC%[32m"
set "RESET=%ESC%[0m"

rem =============================================================================================
rem 実行時変数の初期化
rem =============================================================================================
set "SSH_USER=%DEFAULT_SSH_USER%"
set "SSH_PORT=%DEFAULT_SSH_PORT%"
set "DRY_RUN=%DEFAULT_DRY_RUN%"
rem --- 対象サーバの選択 (WEB/DEV/DB/MONGO の識別コード と 表示用ラベル（日本語）)
set "TARGET_GROUP_CODE="
set "TARGET_GROUP_LABEL="
rem --- 対象接続・モジュール・サービス
set "TARGET_HOST="   & rem NOTE: 実行対象ホスト
set "TARGET_MODULE=" & rem NOTE: 表示／ログ向けの対象名（例：PostgreSQL）
set "SERVICE_NAME="  & rem NOTE: systemd サービス名
rem --- 実行アクション (status/start/stop/restart/sysinfo/conn と 表示用ラベル)
set "ACTION="
set "ACTION_LABEL="
rem --- 確認画面からの戻り先（呼び出し元で都度上書き）
set "CONFIRM_BACK=MENU_ACTION"   & rem NOTE:（既定）アクションメニュー
rem --- 入力誤りなどの一時メッセージ
set "ERROR_MSG="
rem --- ステータスチェック
set "STATUS_PARSE=0"
rem --- ログファイル生成
set "SCRIPT_DIR=%~dp0"
call :INIT_TIMESTAMP
set "LOG_FILE=%SCRIPT_DIR%FutureNetWebSi_サーバ操作_%TS_DATE%_%TS_TIME%.log"
type nul > "%LOG_FILE%"

rem ---------------------------------------------------------------------------------------------
rem バッチ開始ログ
rem ---------------------------------------------------------------------------------------------
call :LOGX "INFO" "開始" "バッチ処理を開始しました。" 0
goto :MENU_GROUP

rem ---------------------------------------------------------------------------------------------
rem トップメニュー（サーバ選択）
rem ---------------------------------------------------------------------------------------------
:MENU_GROUP
call :TRY_CLS
echo.
echo =======================================================================
echo 接続するサーバを選んでください
call :SHOW_DRYRUN_BANNER
rem エラーメッセージ
if defined ERROR_MSG ( call :SHOW_ERROR_INLINE & set "ERROR_MSG=" )
echo =======================================================================
echo  番号   種類                          ^| 接続先IP
echo ------ ------------------------------ ^| -------------------------------
echo   1    フロントエンド（Webapp）       ^| %DEFAULT_WEB_HOST%
echo   2    バックエンド（Device）         ^| %DEFAULT_DEVICE_HOST%
echo   3    データベース（PostgreSQL）     ^| %DEFAULT_DB_HOST%
echo   4    データベース（MongoDB）        ^| %DEFAULT_MONGO_HOST%
echo -----------------------------------------------------------------------
echo ※ バッチを終了する場合は^[0^]を入力してください
echo -----------------------------------------------------------------------
set "GROUP_SEL="
set /p GROUP_SEL=番号を入力して Enter ＞ 
if "%GROUP_SEL%"=="1" goto :GROUP_WEB
if "%GROUP_SEL%"=="2" goto :GROUP_DEVICE
if "%GROUP_SEL%"=="3" goto :GROUP_DB
if "%GROUP_SEL%"=="4" goto :GROUP_MONGO
if "%GROUP_SEL%"=="0" goto :END
call :SET_INVALID_INPUT "1, 2, 3, 4, 0" "%GROUP_SEL%"
goto :MENU_GROUP

:GROUP_WEB
set "TARGET_GROUP_CODE=WEB"
set "TARGET_GROUP_LABEL=フロントエンド（Webapp）"
set "TARGET_HOST=%DEFAULT_WEB_HOST%"
call :LOGX "INFO" "選択" "対象サーバ: %TARGET_GROUP_LABEL%" 0
goto :MENU_WEB_MODULE

:GROUP_DEVICE
set "TARGET_GROUP_CODE=DEV"
set "TARGET_GROUP_LABEL=バックエンド（Device）"
set "TARGET_HOST=%DEFAULT_DEVICE_HOST%"
set "TARGET_MODULE=DeviceServer"
set "SERVICE_NAME=%DEVICE_SERVICE%"
call :LOGX "INFO" "選択" "対象サーバ: %TARGET_GROUP_LABEL%" 0
goto :MENU_ACTION

:GROUP_DB
set "TARGET_GROUP_CODE=DB"
set "TARGET_GROUP_LABEL=DB（PostgreSQL）"
set "TARGET_HOST=%DEFAULT_DB_HOST%"
set "TARGET_MODULE=PostgreSQL"
set "SERVICE_NAME=%DB_SERVICE%"
call :LOGX "INFO" "選択" "対象サーバ: %TARGET_GROUP_LABEL%" 0
goto :MENU_ACTION

:GROUP_MONGO
set "TARGET_GROUP_CODE=MONGO"
set "TARGET_GROUP_LABEL=DB（MongoDB）"
set "TARGET_HOST=%DEFAULT_MONGO_HOST%"
set "TARGET_MODULE=MongoDB"
set "SERVICE_NAME=%MONGO_SERVICE%"
call :LOGX "INFO" "選択" "対象サーバ: %TARGET_GROUP_LABEL%" 0
goto :MENU_ACTION

rem ---------------------------------------------------------------------------------------------
rem Webapp モジュール選択
rem ---------------------------------------------------------------------------------------------
:MENU_WEB_MODULE
call :TRY_CLS
echo.
echo =======================================================================
echo フロントエンド（Webapp）の対象モジュールを選択してください
call :SHOW_DRYRUN_BANNER
rem エラーメッセージ
if defined ERROR_MSG ( call :SHOW_ERROR_INLINE & set "ERROR_MSG=" )
echo =======================================================================
echo 1．%WEB_ADMIN_NAME% に対する操作
echo 2．%WEB_COMM_NAME% に対する操作
echo 3．%WEB_COVERT_NAME% に対する操作
echo 5．システムリソース確認（ディスク、メモリ、CPU使用率）
echo 9．サーバ選択へ戻る
echo 0．バッチを終了する
echo -----------------------------------------------------------------------
set "WEB_MOD_CHOICE="
set /p WEB_MOD_CHOICE=番号を入力して Enter ＞ 
if "%WEB_MOD_CHOICE%"=="1" call :WEB_MOD_SELECT 1  & goto :MENU_ACTION
if "%WEB_MOD_CHOICE%"=="2" call :WEB_MOD_SELECT 2  & goto :MENU_ACTION
if "%WEB_MOD_CHOICE%"=="3" call :WEB_MOD_SELECT 3  & goto :MENU_CONVERT_AUTOSTART
if "%WEB_MOD_CHOICE%"=="5" call :WEB_MOD_SELECT "" & set "CONFIRM_BACK=MENU_WEB_MODULE" & call :SET_ACTION "sysinfo" & call :TRY_CLS & goto :CONFIRM
if "%WEB_MOD_CHOICE%"=="9" goto :MENU_GROUP
if "%WEB_MOD_CHOICE%"=="0" goto :END
call :SET_INVALID_INPUT "1, 2, 3, 5, 9, 0" "%WEB_MOD_CHOICE%"
goto :MENU_WEB_MODULE

rem ---------------------------------------------------------------------------------------------
rem アクション選択
rem ---------------------------------------------------------------------------------------------
:MENU_ACTION
call :TRY_CLS
rem DB系かどうかの判定フラグ
set "IS_DB=0"
if /I "%TARGET_GROUP_CODE%"=="DB"    set "IS_DB=1"
if /I "%TARGET_GROUP_CODE%"=="MONGO" set "IS_DB=1"
rem 戻り先文言設定
set "BACK_LABEL=サーバ選択へ戻る"
if /I "%TARGET_GROUP_CODE%"=="WEB" set "BACK_LABEL=モジュール選択へ戻る"
echo.
echo =======================================================================
echo %TARGET_GROUP_LABEL% に実行する操作を選択してください
call :SHOW_DRYRUN_BANNER
rem エラーメッセージ
if defined ERROR_MSG ( call :SHOW_ERROR_INLINE & set "ERROR_MSG=" )
echo =======================================================================
echo 1．動作状況の確認
echo 2．モジュールの起動
echo 3．モジュールの停止
echo 4．モジュールの再起動
if /I not "%TARGET_GROUP_CODE%"=="WEB" echo 5．システムリソース確認（ディスク、メモリ、CPU使用率）
if "%IS_DB%"=="1" echo 6．疎通確認
echo 9．%BACK_LABEL%
echo 0．バッチを終了する
echo -----------------------------------------------------------------------
set "ACTION_SEL="
set /p ACTION_SEL=番号を入力して Enter ＞
set "PARAM=1, 2, 3, 4, 9, 0"
if "%ACTION_SEL%"=="1" set "CONFIRM_BACK=MENU_ACTION" & call :SET_ACTION "status"  & call :TRY_CLS & goto :CONFIRM
if "%ACTION_SEL%"=="2" set "CONFIRM_BACK=MENU_ACTION" & call :SET_ACTION "start"   & call :TRY_CLS & goto :CONFIRM
if "%ACTION_SEL%"=="3" set "CONFIRM_BACK=MENU_ACTION" & call :SET_ACTION "stop"    & call :TRY_CLS & goto :CONFIRM
if "%ACTION_SEL%"=="4" set "CONFIRM_BACK=MENU_ACTION" & call :SET_ACTION "restart" & call :TRY_CLS & goto :CONFIRM
if "%ACTION_SEL%"=="5" (
  if /I NOT "%TARGET_GROUP_CODE%"=="WEB" (
    set "CONFIRM_BACK=MENU_ACTION" & call :SET_ACTION "sysinfo" & call :TRY_CLS & goto :CONFIRM
  )
)
if "%ACTION_SEL%"=="6" (
  if "%IS_DB%"=="1" (
    set "CONFIRM_BACK=MENU_ACTION" & call :SET_ACTION "conn" & call :TRY_CLS & goto :CONFIRM
  )
)
if "%ACTION_SEL%"=="9" goto :BACK_FROM_ACTION 
if "%ACTION_SEL%"=="0" goto :END
if /I "%TARGET_GROUP_CODE%"=="DEV" set "PARAM=1, 2, 3, 4, 5, 9, 0"   & rem NOTE: DEVは5が有効
if "%IS_DB%"=="1"                  set "PARAM=1, 2, 3, 4, 5, 6, 9, 0" & rem NOTE: DB/MONGOは5,6が有効
call :SET_INVALID_INPUT "%PARAM%" "%ACTION_SEL%"
goto :MENU_ACTION

rem 戻り先判定
:BACK_FROM_ACTION
if /I "%TARGET_GROUP_CODE%"=="WEB" goto :MENU_WEB_MODULE
goto :MENU_GROUP

rem ---------------------------------------------------------------------------------------------
rem Convert専用：自動起動メニュー（is-enabled / enable / disable）
rem ---------------------------------------------------------------------------------------------
:MENU_CONVERT_AUTOSTART
call :TRY_CLS
echo.
echo =======================================================================
echo %TARGET_GROUP_LABEL% ／ %TARGET_MODULE% の操作を選択してください
call :SHOW_DRYRUN_BANNER
rem エラーメッセージ
if defined ERROR_MSG ( call :SHOW_ERROR_INLINE & set "ERROR_MSG=" )
echo =======================================================================
echo 1．動作状況の確認
echo 2．モジュールの起動
echo 3．モジュールの停止
echo 4．モジュールの再起動
echo 5．自動起動の状態確認（is-enabled）
echo 6．自動起動をON（enable）
echo 7．自動起動をOFF（disable）
echo 9．モジュール選択へ戻る
echo 0．バッチを終了する
echo -----------------------------------------------------------------------
set "AUTO_SEL="
set /p AUTO_SEL=番号を入力して Enter ＞ 
if "%AUTO_SEL%"=="1" set "CONFIRM_BACK=MENU_CONVERT_AUTOSTART" & call :SET_ACTION "status"     & call :TRY_CLS & goto :CONFIRM
if "%AUTO_SEL%"=="2" set "CONFIRM_BACK=MENU_CONVERT_AUTOSTART" & call :SET_ACTION "start"      & call :TRY_CLS & goto :CONFIRM
if "%AUTO_SEL%"=="3" set "CONFIRM_BACK=MENU_CONVERT_AUTOSTART" & call :SET_ACTION "stop"       & call :TRY_CLS & goto :CONFIRM
if "%AUTO_SEL%"=="4" set "CONFIRM_BACK=MENU_CONVERT_AUTOSTART" & call :SET_ACTION "restart"    & call :TRY_CLS & goto :CONFIRM
if "%AUTO_SEL%"=="5" set "CONFIRM_BACK=MENU_CONVERT_AUTOSTART" & call :SET_ACTION "is_enabled" & call :TRY_CLS & goto :CONFIRM
if "%AUTO_SEL%"=="6" set "CONFIRM_BACK=MENU_CONVERT_AUTOSTART" & call :SET_ACTION "enable"     & call :TRY_CLS & goto :CONFIRM
if "%AUTO_SEL%"=="7" set "CONFIRM_BACK=MENU_CONVERT_AUTOSTART" & call :SET_ACTION "disable"    & call :TRY_CLS & goto :CONFIRM
if "%AUTO_SEL%"=="9" goto :MENU_WEB_MODULE
if "%AUTO_SEL%"=="0" goto :END
call :SET_INVALID_INPUT "1, 2, 3, 4, 5, 6, 7, 9, 0" "%AUTO_SEL%"
goto :MENU_CONVERT_AUTOSTART

rem ---------------------------------------------------------------------------------------------
rem 実行内容の確認
rem ---------------------------------------------------------------------------------------------
:CONFIRM
echo.
echo =======================================================================
echo 実行内容の確認
call :SHOW_DRYRUN_BANNER
echo =======================================================================
echo サーバ種類   ： !GREEN!%TARGET_GROUP_LABEL%!RESET!
echo 操作対象     ： !GREEN!%TARGET_MODULE%!RESET!
echo サービス名   ： !GREEN!%SERVICE_NAME%!RESET!
echo 実行する内容 ： !GREEN!%ACTION_LABEL%!RESET!
echo -----------------------------------------------------------------------
echo ※ １つ前に戻る場合は^[9^]を入力してください
echo ※ バッチを終了する場合は^[0^]を入力してください
echo =======================================================================
rem [実行内容の確認]をログ出力
call :LOGX "INFO" "確認" "種類: %TARGET_GROUP_LABEL%、対象: %TARGET_MODULE%、サービス: %SERVICE_NAME%、実行内容: %ACTION_LABEL%" 0

:CONFIRM_PROMPT
set "_YN="
set /p _YN="「実行： Y 、サーバ選択に戻る：N、戻る：9、終了：0」を入力して Enter ＞ "
call :TRIM "%_YN%" _YN
if /I "%_YN%"=="Y" goto :EXECUTE
if /I "%_YN%"=="N" goto :CANCELLED
if /I "%_YN%"=="9" (
  if defined CONFIRM_BACK ( goto %CONFIRM_BACK% ) else ( goto :MENU_ACTION )
)
if /I "%_YN%"=="0" goto :END
call :LOGX "WARN" "誤り" "入力値「%_YN%」は無効です。選択肢は Y, N, 9, 0 です。もう一度入力してください。" 1
echo.
goto :CONFIRM_PROMPT

rem ---------------------------------------------------------------------------------------------
rem 実行
rem ---------------------------------------------------------------------------------------------
:EXECUTE
echo.
rem 1) ACTION のコマンド生成
call :BUILD_REMCMD
rem 2) 実行（DRY-RUN なら表示のみ）
call :LOGX "INFO" "接続先ホスト" "%TARGET_HOST%" 1
rem --- status のときだけ PowerShell 側で状態要約を出すフラグを立てる ---
set "STATUS_PARSE=0" & if /I "%ACTION%"=="status" set "STATUS_PARSE=1"
call :MASK_CMD "%REMCMD%" _MASKED
call :LOGX "INFO" "実行コマンド" "%_MASKED%" 1
call :EXEC_REMOTE "%TARGET_HOST%" "%REMCMD%"
rem 起動/停止/再起動 要求は無反応なため、メッセージ出力
set "_REQMSG="
if /I "%ACTION%"=="start"   set "_REQMSG=1"
if /I "%ACTION%"=="stop"    set "_REQMSG=1"
if /I "%ACTION%"=="restart" set "_REQMSG=1"
if defined _REQMSG echo %GREEN%[%ACTION_LABEL%]を要求しました%RESET%
rem --- RC 設定（DRY-RUN=0 / それ以外は ERRORLEVEL） ---
set "RC=0" & if not "%DRY_RUN%"=="1" set "RC=%ERRORLEVEL%"

rem 3) DB疎通確認（conn）の場合は、人間向けの要約を表示
if /I "%ACTION%"=="conn" (
  call :SHOW_CONN_RESULT "%TARGET_GROUP_CODE%" "%RC%"
)
pause

rem DRY-RUN のときは案内を表示
if "%DRY_RUN%"=="1" (
  call :LOGX "INFO" "DRY-RUN" "実行はしません（コマンド表示のみ）。" 1
  echo.
)
goto :CONFIRM

rem ---------------------------------------------------------------------------------------------
rem キャンセル
rem ---------------------------------------------------------------------------------------------
:CANCELLED
echo.
call :LOGX "WARN" "中止" "操作を取り消しました。サーバ選択へ戻ります。" 1
goto :MENU_GROUP

rem ---------------------------------------------------------------------------------------------
rem 終了
rem ---------------------------------------------------------------------------------------------
:END
echo.
echo バッチ処理を終了しました。
call :LOGX "INFO" "終了" "バッチ処理を終了しました。" 0
echo.
endlocal
exit /b 0

rem =============================================================================================
rem 以降：ユーティリティ
rem =============================================================================================

rem ---------------------------------------------------------------------------------------------
rem 画面クリア（履歴保持したい場合は無効化）
rem ---------------------------------------------------------------------------------------------
:TRY_CLS
if "%CLEAR_SCREEN%"=="1" cls
goto :eof

rem ---------------------------------------------------------------------------------------------
rem DRY-RUN バナー表示（DRY_RUN=1 のときに案内を明示）
rem ---------------------------------------------------------------------------------------------
:SHOW_DRYRUN_BANNER
if "%DRY_RUN%"=="1" echo 【DRY-RUN（表示のみ実行モード）】
goto :eof

rem ---------------------------------------------------------------------------------------------
rem .env ローダー
rem 形式: KEY=VALUE / 空行と先頭が # or ; の行は無視
rem 使用例: if exist "%HOSTS_ENV_FILE%" call :LOAD_ENV_FILE "%HOSTS_ENV_FILE%"
rem ---------------------------------------------------------------------------------------------
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

rem ---------------------------------------------------------------------------------------------
rem 前後空白を除去（単純トリム）
rem 使い方: call :TRIM " value " OUTVAR
rem ---------------------------------------------------------------------------------------------
:TRIM
set "_s=%~1"
for /f "tokens=* delims= " %%Z in ("!_s!") do set "_s=%%Z"
:TRIM_TAIL
if "!_s:~-1!"==" " (set "_s=!_s:~0,-1!" & goto :TRIM_TAIL)
set "%~2=%_s%"
goto :eof

rem ---------------------------------------------------------------------------------------------
rem 日時ユーティリティ（出力: TS_DATE=yyyymmdd, TS_TIME=hhmmss）
rem ---------------------------------------------------------------------------------------------
:INIT_TIMESTAMP
for /f "tokens=1-2 delims=|" %%A in ('
  powershell -NoProfile -Command "$d = Get-Date; '{0:yyyyMMdd}|{0:HHmmss}' -f $d"
') do (
  set "TS_DATE=%%A"
  set "TS_TIME=%%B"
)
goto :eof

rem ---------------------------------------------------------------------------------------------
rem ログ出力
rem ＊ call :LOGX LEVEL "概要" "詳細" SHOW
rem SHOW : [0: ログのみ、 1: 画面出力あり]
rem ---------------------------------------------------------------------------------------------
:LOGX
setlocal DisableDelayedExpansion
set "LV=%~1"
set "SUM=%~2"
set "DET=%~3"
set "SHOW=%~4"
for /f "tokens=1-3 delims=/.- " %%a in ("%DATE%") do set "Y=%%a" & set "M=%%b" & set "D=%%c"
set "NOW_ISO=%Y%-%M%-%D% %TIME:~0,8%"
rem --- 画面出力（SHOW=1 のときのみ）
if "%SHOW%"=="1" ( echo "%SUM%" "%DET%")
>>"%LOG_FILE%" echo "%NOW_ISO%" [%LV%] "%SUM%" "%DET%"
endlocal & goto :eof

rem ---------------------------------------------------------------------------------------------
rem 無効入力の統一メッセージ化（ERROR_MSG に格納＋WARNログ）
rem 使い方: call :SET_INVALID_INPUT "1, 2, 3" "%ACTUAL%"
rem ---------------------------------------------------------------------------------------------
:SET_INVALID_INPUT
set "ERROR_MSG=入力値「%~2」は無効です。選択肢は %~1 です。"
goto :eof

rem ---------------------------------------------------------------------------------------------
rem 入力エラー表示
rem ---------------------------------------------------------------------------------------------
:SHOW_ERROR_INLINE
rem エラーメッセージ出力
echo !RED!エラー：%ERROR_MSG%!RESET!
echo もう一度入力してください。
rem ログ出力
call :LOGX "WARN" "誤り" "%ERROR_MSG% もう一度入力してください。" 0
goto :eof

rem ---------------------------------------------------------------------------------------------
rem Webモジュール選択
rem 入力: %1 = 1(admin_web) / 2(client_comm) / 3(convert) / ""(システムリソース用の空設定)
rem ---------------------------------------------------------------------------------------------
:WEB_MOD_SELECT
set "TARGET_MODULE="
set "SERVICE_NAME="
if "%~1"=="1" (
  rem ADMIN
  set "TARGET_MODULE=%WEB_ADMIN_NAME%"
  set "SERVICE_NAME=%WEB_ADMIN_SERVICE%"
)
if "%~1"=="2" (
  rem COMM
  set "TARGET_MODULE=%WEB_COMM_NAME%"
  set "SERVICE_NAME=%WEB_COMM_SERVICE%"
)
if "%~1"=="3" (
  rem CONVERT
  set "TARGET_MODULE=%WEB_COVERT_NAME%"
  set "SERVICE_NAME=%WEB_COVERT_SERVICE%"
)
call :LOGX "INFO" "選択" "Webモジュール: %TARGET_MODULE% (サービス: %SERVICE_NAME%)" 0
goto :eof

rem ---------------------------------------------------------------------------------------------
rem アクション共通設定
rem 入力: %~1 = status / start / stop / restart / sysinfo / conn
rem 出力: ACTION, ACTION_LABEL を設定しログも残す
rem ---------------------------------------------------------------------------------------------
:SET_ACTION
set "ACTION=%~1"
rem コード→表示ラベル
if /I "%ACTION%"=="status"     set "ACTION_LABEL=動作状況の確認"
if /I "%ACTION%"=="start"      set "ACTION_LABEL=モジュールの起動"
if /I "%ACTION%"=="stop"       set "ACTION_LABEL=モジュールの停止"
if /I "%ACTION%"=="restart"    set "ACTION_LABEL=モジュールの再起動"
if /I "%ACTION%"=="sysinfo"    set "ACTION_LABEL=システムリソース確認"
if /I "%ACTION%"=="conn"       set "ACTION_LABEL=疎通確認"
if /I "%ACTION%"=="is_enabled" set "ACTION_LABEL=自動起動の状態確認"
if /I "%ACTION%"=="enable"     set "ACTION_LABEL=自動起動を有効化"
if /I "%ACTION%"=="disable"    set "ACTION_LABEL=自動起動を無効化"
call :LOGX "INFO" "選択" "操作: %ACTION_LABEL%" 0
goto :eof

rem ---------------------------------------------------------------------------------------------
rem コマンド生成（ACTION -> REMCMD）
rem 入力: ACTION, SERVICE_NAME, TARGET_GROUP_CODE
rem 出力: REMCMD（リモートでそのまま実行されるコマンド）
rem ---------------------------------------------------------------------------------------------
:BUILD_REMCMD
rem systemd 共通（status フォールバックで再利用）
set "REMCMD="
set "SYSTEMCTL_SHOW=systemctl status --no-pager %SERVICE_NAME%"
rem 1) systemd 操作
if /I "%ACTION%"=="status"     set "REMCMD=%SYSTEMCTL_SHOW%"
if /I "%ACTION%"=="start"      set "REMCMD=systemctl start %SERVICE_NAME%"
if /I "%ACTION%"=="stop"       set "REMCMD=systemctl stop %SERVICE_NAME%"
if /I "%ACTION%"=="restart"    set "REMCMD=systemctl restart %SERVICE_NAME%"
if /I "%ACTION%"=="is_enabled" set "REMCMD=systemctl is-enabled %SERVICE_NAME%"
if /I "%ACTION%"=="enable"     set "REMCMD=systemctl enable %SERVICE_NAME%"
if /I "%ACTION%"=="disable"    set "REMCMD=systemctl disable %SERVICE_NAME%"

rem 2) 疎通確認（DB/MONGO 専用）
if /I "%ACTION%"=="conn" (
  if /I "%TARGET_GROUP_CODE%"=="DB" (
    rem Postgres: 先頭トークンが PGPASSWORD= である前提（:MASK_CMD と連携）
    set "REMCMD=PGPASSWORD=nkk5 psql -h localhost -p 5432 -d ntss_db5 -U nkk5 -t -A -q -c 'SELECT 1;'"
  ) else if /I "%TARGET_GROUP_CODE%"=="MONGO" (
    rem Mongo: mongosh ping (ok==1 を期待)
    set "REMCMD=mongosh --quiet --eval 'db.runCommand({ping:1}).ok'"
  ) else (
    rem Web/Deviceで conn が来た場合は status にフォールバック
    set "REMCMD=%SYSTEMCTL_SHOW%"
  )
)

rem 3) Linux コマンド実行
if /I "%ACTION%"=="sysinfo" set "REMCMD=echo +DF_RESULT=====; df -h; echo; echo +TOP_RESULT=====; top -b -n 1 | head -n 20"
goto :eof

rem ---------------------------------------------------------------------------------------------
rem リモート実行
rem 入力: %1=HOST, %2=COMMAND(without quotes)
rem ※ 実行結果は UTF-8 でファイル保存 → 画面は SJIS へ変換して表示
rem ---------------------------------------------------------------------------------------------
:EXEC_REMOTE
setlocal
set "HOST=%~1"
set "CMD=%~2"
if "%DRY_RUN%"=="1" ( endlocal & goto :eof )

rem === 一時ディレクトリ／UTF-8ファイル ===
set "TMP_DIR=%TEMP%\fnws_%RANDOM%_%RANDOM%"
md "%TMP_DIR%" >nul 2>&1
set "TMP_OUT=%TMP_DIR%\out.u8"

rem 1) SSHは1回だけ：UTF-8の“生”出力をファイル保存
ssh -p %SSH_PORT% %SSH_USER%@%HOST% "LANG=C.UTF-8 LC_ALL=C.UTF-8 %CMD%" > "%TMP_OUT%" 2>&1
set "SSH_RC=%ERRORLEVEL%"

rem 2) コンソール表示 + ログ追記：UTF-8 → CP932 に変換して追記（PowerShellで変換）
powershell -NoProfile -Command ^
 "$o = Get-Content -Raw '%TMP_OUT%' -Encoding UTF8; " ^
 "[Console]::OutputEncoding = [Text.Encoding]::GetEncoding(932); " ^
 "Write-Host $o -ForegroundColor DarkGray; " ^
 "$o | Out-File -FilePath '%LOG_FILE%' -Append -Encoding Default; " ^
 "if ($env:STATUS_PARSE -eq '1') { " ^
 "  $m = [regex]::Match($o, '(?m)^\s*Active:\s*([a-z-]+)\s*\(([^)]+)\)'); " ^
 "  $asVal = $m.Groups[1].Value.Trim().ToLower(); " ^
 "  $ssVal = ($m.Groups[2].Value -split '[; ,]')[0].Trim().ToLower(); " ^
 "  $summary = $null; " ^
 "  if ($asVal -and $ssVal) { " ^
 "    if ($asVal -eq 'active' -and $ssVal -eq 'running') { $summary = 'サーバは稼働中です' } " ^
 "    elseif ($asVal -eq 'inactive' -and $ssVal -eq 'dead') { $summary = 'サーバは停止しています' } " ^
 "    else { $summary = '状態: Active=' + $asVal + ', Detail=' + $ssVal } " ^
 "  } elseif ($asVal -or $ssVal) { " ^
 "    $av = if ([string]::IsNullOrEmpty($asVal)) { 'N/A' } else { $asVal }; " ^
 "    $sv = if ([string]::IsNullOrEmpty($ssVal)) { 'N/A' } else { $ssVal }; " ^
 "    $summary = '状態: Active=' + $av + ', Detail=' + $sv " ^
 "  } " ^
 "  if ($summary) { Write-Host $summary -ForegroundColor Green; $summary | Out-File -FilePath '%LOG_FILE%' -Append -Encoding Default } " ^
 "}"

rem 3) 一時ファイル削除
del /q "%TMP_OUT%" >nul 2>&1
rd /q "%TMP_DIR%" >nul 2>&1
endlocal & exit /b %SSH_RC%

rem ---------------------------------------------------------------------------------------------
rem コマンド表示用マスク（先頭が PGPASSWORD=... のときだけトークン分割で安全にマスク）
rem 使い方: call :MASK_CMD "original" OUTVAR
rem ---------------------------------------------------------------------------------------------
:MASK_CMD
setlocal EnableDelayedExpansion
set "_src=%~1"
set "_masked=%_src%"
rem 先頭 11 文字が 'PGPASSWORD=' なら、最初の空白までを 1 トークンとして切り出してマスク
if /I "!_src:~0,11!"=="PGPASSWORD=" (
  for /f "tokens=1,* delims= " %%A in ("!_src!") do (
    rem %%A … 先頭トークン（PGPASSWORD=xxxxx）
    rem %%B … 残りのコマンド（psql -h ...）
    set "_masked=PGPASSWORD=**** %%B"
  )
)
endlocal & set "%~2=%_masked%"
goto :eof

rem ---------------------------------------------------------------------------------------------
rem 疎通確認の結果表示 （入力: %1=グループコード(DB/MONGO), %2=終了コード(0=OK, 他=NG)）
rem ---------------------------------------------------------------------------------------------
:SHOW_CONN_RESULT
setlocal
set "GC=%~1"
set "RC=%~2"
rem 1) 既定値（成功パス）
set "LV=INFO"
set "TITLE=疎通確認"
set "MSG=正常に応答しました（サーバ稼働・接続成功）。"
rem 2) グループに応じたタイトル付与
if /I "%GC%"=="DB"    set "TITLE=疎通確認（PostgreSQL）"
if /I "%GC%"=="MONGO" set "TITLE=疎通確認（MongoDB）"
rem 3) 失敗パスならレベルとメッセージを上書き
if not "%RC%"=="0" (
  set "LV=WARN"
  set "MSG=応答がありません（接続/認証/ネットワーク/サービス状態をご確認ください）。"
)
rem 4) 画面は色付き、ログは LOGX(show=0) でプレーン出力
if /I "%LV%"=="INFO" (
  echo %GREEN%%TITLE% %MSG%%RESET%
) else (
  echo %RED%%TITLE% %MSG%%RESET%
)
call :LOGX %LV% "%TITLE%" "%MSG%" 0
endlocal & goto :eof
