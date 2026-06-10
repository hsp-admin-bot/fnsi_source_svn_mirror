# log_json_comment

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `log_json_comment(db6)`
- Logical name: Json論理名設定テーブル
- Physical name: `log_json_comment`
- Prefix group: `log`
- User: `nkk6`
- Tablespace DB: `ntss_db6`
- Tablespace INDEX: `ntss_index6`
- Primary key definition: `tbl_name,col_name,json_key_name`
- Column count: 4
- NOT NULL columns: 3

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | テーブル物理名 | tbl_name | character varying | 50 | 1 |  |  |
| 1 | コラム物理名 | col_name | character varying | 100 | 1 |  |  |
| 1 | Jsonキー物理名 | json_key_name | character varying | 50 | 1 |  |  |
|  | Jsonキー論理名 | json_key_comment | character varying | 100 |  |  |  |
