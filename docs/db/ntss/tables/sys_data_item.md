# sys_data_item

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `sys_data_item`
- Logical name: データ項目設定
- Physical name: `sys_data_item`
- Prefix group: `system`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `facility_cd,template_no,item_category,item_sub_category`
- Column count: 13
- NOT NULL columns: 7

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 施設コード | facility_cd | character varying | 6 |  |  | 施設マスタ.施設コード |
| 1 | テンプレート番号 | template_no | int |  | 1 |  | 施設毎にMAX+1 |
| 1 | 項目区分 | item_category | smallint |  | 1 |  |  |
| 1 | サブ項目区分 | item_sub_category | smallint |  | 1 |  |  |
|  | 項目名タイプ | item_type | smallint |  | 1 |  |  |
|  | 値タイプ | value_type | smallint |  | 1 |  |  |
|  | 表示位置 | disp_position | smallint |  |  |  |  |
|  | 項目名 | item_title | character varying | 40 | 1 |  |  |
|  | 項目単位 | item_unit | character varying | 20 |  |  |  |
|  | 項目テーブル | item_table | character varying | 40 |  |  |  |
|  | 項目キー | item_key | character varying | 100 |  |  |  |
|  | 表示順 | disp_order | smallint |  |  |  |  |
|  | 表示設定 | is_disp | character varying | 1 | 1 | '1' | '0'：非表示、'1'：表示 |
