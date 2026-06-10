@echo off
chcp 65001
setlocal enabledelayedexpansion
CD /D %0\..

:: 日付を取得
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (
  set "month=%%a"
  set "day=%%b"
  set "year=%%c"
)

:: 時刻を取得
for /f "tokens=1-2 delims=: " %%a in ('time /t') do (
  set "hour=%%a"
  set "minute=%%b"
)

:: 日付と時刻を連結して連番を生成
set "timestamp=!year!!month!!day!!hour!!minute!"

:: バックアップファイル名を作成
set "backupFileName=BK_StatisticsTool_2025_!timestamp!.exe.config"

:: コンソールにメッセージを表示
echo バックアップファイル名: !backupFileName!

:: ファイルをバックアップ
copy ..\StatisticsTool_2025.exe.config "!backupFileName!"

:: バックアップ完了メッセージ
echo バックアップが完了しました。

copy StatisticsTool_2025.exe.config ..\StatisticsTool_2025.exe.config

:: コピー完了メッセージ
echo コピーが完了しました。

:: 終了
endlocal