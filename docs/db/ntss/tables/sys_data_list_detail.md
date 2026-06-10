# sys_data_list_detail

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `sys_data_list_detail`
- Logical name: データリストカテゴリ詳細
- Physical name: `sys_data_list_detail`
- Prefix group: `system`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `data_list_detail_cd`
- Column count: 11
- NOT NULL columns: 4

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | データリスト詳細コード | data_list_detail_cd | bigserial |  | 1 |  |  |
|  | カテゴリコード | category_cd | bigint |  | 1 |  |  |
|  | マスタ表示パターン | master_display_name | character varying |  |  |  | 例：SQL利用の場合<br>select class_cd as id, class_name as name from mst_medicine_class<br>上記のSQLの「name」パラメータの利用する場合： [name]で記載 |
|  | マスタ表示区分 | master_display_type | character varying | 1 | 1 |  | 1：データ取得SQLの利用<br>2：固定文字 |
|  | マスタデータ取得SQL | master_display_sql | character varying |  |  |  | ※SQL文の中にidはQuery用のキーなので必ず設定。 |
|  | 一覧表示パターン | function_display_name | character varying |  |  |  | 例：SQL利用の場合<br>select medicine_cd as id, medicine_name as name from mst_medicine where class_cd in (@ids)<br>上記のSQLの「name」パラメータの利用する場合： [name]で記載 |
|  | 一覧表示区分 | function_display_type | character varying | 1 | 1 |  | 1：データ取得SQLの利用<br>2：固定文字 |
|  | 一覧データ取得SQL | function_display_sql | character varying |  |  |  | ※SQL文の中にidはQuery用のキーなので必ず設定。 |
|  | データセット | data_set | jsonb |  |  |  | [{<br>"param": Text <br>"sql_cd": Number<br>}] |
|  | セル表示パターン | cell_display | character varying |  |  |  | データセットのテープル：<br>・sql_code 1001： select unit from mst_medicine where medicine_cd = @id<br>・sql_code 1002：select count(*) as count from ord_main where treat_date = '20200608'<br><br>data_setカラム：<br>'[<br>{"param": unit<br>"sql_cd": 1001},<br>{"param": count<br>"sql_cd": 1002}<br>]<br><br>data_setカラムで設定するパラメータを使って設定する<br>例： [count]  [unit] |
|  | 表示順 | disp_order | integer |  |  |  |  |
