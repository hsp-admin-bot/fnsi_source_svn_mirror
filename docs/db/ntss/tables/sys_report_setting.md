# sys_report_setting

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `sys_report_setting`
- Logical name: データリストカテゴリ
- Physical name: `sys_report_setting`
- Prefix group: `system`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `function_cd`
- Column count: 8
- NOT NULL columns: 1

## Related Config / Notes

- [../config/sys_report_setting.md](../config/sys_report_setting.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 機能コード | function_cd | character varying | 8 | 1 |  |  |
|  | 機能名 | function_name | character varying | 100 |  |  |  |
|  | 機能帳票種別設定 | print_report_class | json |  |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | 0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 機能コードデジタル | report_setting_no | int4 |  |  |  |  |
