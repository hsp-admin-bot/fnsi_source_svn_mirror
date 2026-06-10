# mnt_batch_manager

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `@mnt_batch_manager`
- Category: config/reference

## Content

| col1 | col2 | col3 | col4 | col5 | col6 |
| --- | --- | --- | --- | --- | --- |
| ■JSON情報 |  |  |  |  |  |
|  | 管理番号 | バッチ処理名称 | 処理区分 | 説明 |  |
|  | 1 | 入外区分更新 | 1 | ntss-web-apiのapplication.yml内、「cron」項目で指定した時刻に起動する<br>sys_system_define.ctl_no=13で指定した時間内のみ処理を行う |  |
|  | 2 | スケジュール自動延長 | 1 | ntss-web-apiのapplication.yml内、「cron」項目で指定した時刻に起動する<br>sys_system_define.ctl_no=13で指定した時間内のみ処理を行う |  |
|  | 3 | ログイン無効化 | 1 | ntss-web-apiのapplication.yml内、「cron」項目で指定した時刻に起動する<br>sys_system_define.ctl_no=13で指定した時間内のみ処理を行う |  |
|  | 4 | データ削除 | 1 | ntss-web-apiのapplication.yml内、「cron」項目で指定した時刻に起動する<br>sys_system_define.ctl_no=13で指定した時間内のみ処理を行う | バックアップ、施設解約、期間外削除を行う |
