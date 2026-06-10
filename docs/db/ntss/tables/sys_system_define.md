# sys_system_define

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `sys_system_define`
- Logical name: システム設定
- Physical name: `sys_system_define`
- Prefix group: `system`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `ctl_no`
- Column count: 7
- NOT NULL columns: 1

## Related Config / Notes

- [../config/sys_system_define.md](../config/sys_system_define.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 管理番号 | ctl_no | numeric | 4,0 | 1 |  |  |
|  | サービスコード | service_cd | character varying | 3 |  |  | '000'：緊急発報<br>'001'：データ収集<br>'002'：死活監視<br>'003'：次世代FN |
|  | 名称 | name | character varying | 256 |  |  |  |
|  | 値 | value | jsonb |  |  |  | 「@sys_system_define」シート参照 |
|  | 説明 | description | character varying | 4000 |  |  |  |
|  | 編集可否フラグ | is_enable | character varying | 1 |  |  | 0：編集不可、1：編集可 |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
