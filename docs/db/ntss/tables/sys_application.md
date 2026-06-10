# sys_application

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `sys_application`
- Logical name: アプリケーションダウンロード
- Physical name: `sys_application`
- Prefix group: `system`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `=IF(A8="","",A8)&IF(A9="","",","&A9)&IF(A10="","",","&A10)&IF(A11="","",","&A11)&IF(A12="","",","&A12)`
- Column count: 8
- NOT NULL columns: 0

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
|  | アプリケーション名 | application_name | character varying |  |  |  |  |
|  | バージョン | version | character varying |  |  |  |  |
|  | パス | path | character varying |  |  |  |  |
|  | 表示順 | disp_order | integer |  |  |  | 1からの連番 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
