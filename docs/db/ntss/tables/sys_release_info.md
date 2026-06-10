# sys_release_info

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `sys_release_info`
- Logical name: システムリリース情報
- Physical name: `sys_release_info`
- Prefix group: `system`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `ctl_no,release_date`
- Column count: 9
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 管理番号 | ctl_no | bigserial |  | 1 |  | シーケンス |
| 1 | リリース日 | release_date | character varying | 8 |  |  | yyyyMMdd <br>nullで「近日リリース予定」として最前列表記になる |
|  | タイトル | title | character varying | 256 |  |  |  |
|  | システムタイプ | system_type | character varying | 1 |  |  | 1:ReMS 2:FNSi |
|  | path | path_url | character varying | 2000 |  |  | ディレクトリ階層（絶対/相対パス) |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0':非表示、'1':表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':有効、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
