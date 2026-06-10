# sys_notification_list

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `sys_notification_list`
- Logical name: 通知先リスト
- Physical name: `sys_notification_list`
- Prefix group: `system`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `terminal_unique_string`
- Column count: 6
- NOT NULL columns: 1

## Related Config / Notes

- [../config/sys_notification_list.md](../config/sys_notification_list.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 端末固有文字列 | terminal_unique_string | character varying | 16 | 1 |  | localStorageに保存したもの |
|  | 施設コード | facility_cd | character varying | 6 |  |  |  |
|  | 利用者ID | user_id | bigint |  |  |  |  |
|  | Push通知先情報 | notification_data | jsonb |  |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
