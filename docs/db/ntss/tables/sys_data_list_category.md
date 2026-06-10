# sys_data_list_category

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `sys_data_list_category`
- Logical name: データリストカテゴリ
- Physical name: `sys_data_list_category`
- Prefix group: `system`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `category_cd`
- Column count: 4
- NOT NULL columns: 3

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | カテゴリコード | category_cd | bigserial |  | 1 |  |  |
|  | カテゴリ名 | category_name | character varying |  | 1 |  |  |
|  | テンプレートコード | template_cd | integer |  | 1 |  |  |
|  | 表示順 | disp_order | integer |  |  |  |  |
