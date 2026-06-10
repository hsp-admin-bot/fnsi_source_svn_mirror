# sys_personal_settings_define

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `sys_personal_settings_define`
- Logical name: 共通設定タブ定義
- Physical name: `sys_personal_settings_define`
- Prefix group: `system`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `personal_settings_cd`
- Column count: 8
- NOT NULL columns: 2

## Related Config / Notes

- [../config/sys_personal_settings_define.md](../config/sys_personal_settings_define.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 共通設定ID | personal_settings_cd | serial |  | 1 |  |  |
|  | タブ定義コード | tab_define_cd | integer |  | 1 |  | mst_personal_tab_define、UNIQUE制約あり |
|  | 表示管理レベル | edit_level | character varying | 1 |  |  | 1:全ユーザ、2:管理者のみ、<br>3:日機装社員のみ、4:日機装社員・管理者のみ<br>1～4以外：非表示 |
|  | 設定項目情報 | item_info | jsonb |  |  |  | タブに表示する設定項目の情報 |
|  | 固定コンボデータ | combo_data | jsonb |  |  |  | 設定項目のうちコンボに関する情報 |
|  | 参照型コンボデータ | reference_combo_def | jsonb |  |  |  | 設定項目のうちマスタ参照するコンボに関する情報 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
