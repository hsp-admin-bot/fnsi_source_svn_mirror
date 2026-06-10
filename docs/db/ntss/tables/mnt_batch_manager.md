# mnt_batch_manager

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mnt_batch_manager`
- Logical name: バッチ稼働状況管理
- Physical name: `mnt_batch_manager`
- Prefix group: `maintenance-state`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `ctl_no`
- Column count: 9
- NOT NULL columns: 1

## Related Config / Notes

- [../config/mnt_batch_manager.md](../config/mnt_batch_manager.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 管理番号 | ctl_no | numeric | 4,0 | 1 |  |  |
|  | バッチ処理名称 | batch_name | character varying |  |  |  |  |
|  | 処理区分 | division | character varying |  |  |  | '1':日次、'2':週次、'3':月次 |
|  | 処理ステータス | status | character varying | 1 |  | '0' | '0':処理完了、'1':処理中 |
|  | 説明 | description | character varying |  |  |  |  |
|  | 開始時刻 | start_time | timestamp(3) |  |  |  |  |
|  | 終了時刻 | end_time | timestamp(3) |  |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
