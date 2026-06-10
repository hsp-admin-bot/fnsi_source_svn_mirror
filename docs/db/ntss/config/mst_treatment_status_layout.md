# mst_treatment_status_layout

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `@mst_treatment_status_layout`
- Category: config/reference

## Content

| col1 | col2 | col3 |
| --- | --- | --- |
| /* 各種表示項目一覧に登録されるjsonb文字列 */ |  |  |
|  | order_no | 表示順[1～] |
|  | title | 表示する列名 |
|  | width | 表示幅(em) |
|  | data_class | データ種類 |
|  | table_name | データの取得先テーブル名称 |
|  | column_name | データの取得先列名称 |
|  | key_name | データの取得先キー名称(jsonのキー値) |
| 以下、jsonb文字列（例） |  |  |
| {<br> [<br>  {<br>   "order_no": 1,<br>   "title": "列名1",<br>   "width":150,<br>   "data_class":?,<br>   "table_name":"データの取得先テーブル名称",<br>   "column_name":"データの取得先列名",<br>   "key_name":"データの取得先キー名称"<br>  },<br>  …<br> ]<br>} |  |  |
