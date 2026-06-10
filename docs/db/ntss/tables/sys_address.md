# sys_address

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `sys_address`
- Logical name: 住所マスタ
- Physical name: `sys_address`
- Prefix group: `system`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `=IF(A8="","",A8)&IF(A9="","",","&A9)&IF(A10="","",","&A10)&IF(A11="","",","&A11)&IF(A12="","",","&A12)`
- Column count: 17
- NOT NULL columns: 2

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
|  | 全国地方公共団体コード | city_cd | character varying | 5 |  |  | https://www.post.japanpost.jp/zipcode/dl/kogaki-zip.html |
|  | （旧）郵便番号（5桁） | zip_cd_old | character varying | 5 |  |  | https://www.post.japanpost.jp/zipcode/dl/readme.html |
|  | 郵便番号（7桁） | zip_cd | character varying | 7 |  |  |  |
|  | 都道府県名（カナ） | pref_name_kana | character varying |  |  |  |  |
|  | 市区町村名（カナ） | city_name_kana | character varying |  |  |  |  |
|  | 町域名（カナ） | town_name_kana | character varying |  |  |  |  |
|  | 都道府県名 | pref_name | character varying |  |  |  |  |
|  | 市区町村名 | city_name | character varying |  |  |  |  |
|  | 町域名 | town_name | character varying |  |  |  |  |
|  | 一町域が二以上の郵便番号で表される場合の表示 | flag1 | character varying | 1 |  |  | 0：該当しない、1：該当する<br>※「一町域が二以上の郵便番号で表される場合の表示」とは、町域のみでは郵便番号が特定できず、丁目、番地、小字などにより番号が異なる町域のこと |
|  | 小字毎に番地が起番されている町域の表示 | flag2 | character varying | 1 |  |  | 0：該当しない、1：該当する<br>※「小字毎に番地が起番されている町域の表示」とは、郵便番号を設定した町域（大字）が複数の小字を有しており、各小字毎に番地が起番されているため、町域（郵便番号）と番地だけでは住所が特定できない町域のこと |
|  | 丁目を有する町域の場合の表示 | flag3 | character varying | 1 |  |  | 0：該当しない、1：該当する |
|  | 一つの郵便番号で二以上の町域を表す場合の表示 | flag4 | character varying | 1 |  |  | 0：該当しない、1：該当する<br>※「一つの郵便番号で二以上の町域を表す場合の表示」とは、一つの郵便番号で複数の町域をまとめて表しており、郵便番号と番地だけでは住所が特定できないことを示す |
|  | 更新の表示 | flag5 | character varying | 1 |  |  | 0：変更なし、1：変更あり、2：廃止（廃止データのみ使用）<br>※「変更あり」とは追加および修正により更新されたデータを示す |
|  | 変更理由 | flag6 | character varying | 1 |  |  | 0：変更なし、1：市政・区政・町政・分区・政令指定都市施行、2：住居表示の実施、3：区画整理、4：郵便区調整等、5：訂正、6：廃止（廃止データのみ使用） |
|  | 住所 | address | character varying |  | 1 |  | 都道府県名＋市区町村名＋町域名 |
|  | 住所（カナ） | address_kana | character varying |  | 1 |  | 都道府県名（カナ）＋市区町村名（カナ）＋町域名（カナ） |
