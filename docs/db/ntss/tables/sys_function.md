# sys_function

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `sys_function`
- Logical name: 機能一覧
- Physical name: `sys_function`
- Prefix group: `system`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `function_cd`
- Column count: 10
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 機能コード | function_cd | character varying | 4 | 1 |  | 設定値は機能コード一覧シート参照 |
|  | メニュー機能名 | function_name | character varying | 100 |  |  |  |
|  | 表示設定 | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 表示順 | disp_order | integer |  |  |  |  |
|  | 対象施設 | target_facility | jsonb |  |  |  | mst_facility.facility_cd<br>[ <br>facility_cd (文字列型)<br>, …. <br>] |
|  | 日機装フラグ | is_nkk | character varying | 1 |  |  | '0':全施設向け、'1':日機装施設専用 |
|  | システム利用設定区分 | system_use_disp | character varying | 1 |  |  | '0':FNSi・ReMS共通、'1':ReMSがある場合、'2':FNSiがある場合 |
