# sys_generic_medicine

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `sys_generic_medicine`
- Logical name: 一般名処方マスタ
- Physical name: `sys_generic_medicine`
- Prefix group: `system`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `medicine_type,generic_cd`
- Column count: 16
- NOT NULL columns: 2

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 区分 | medicine_type | character varying |  | 1 |  | 1：内服、2外用 |
| 1 | 一般名コード | generic_cd | character varying | 12 | 1 |  |  |
|  | 一般名処方の標準的な記載 | generic_name | character varying |  |  |  |  |
|  | 成分名 | ingredient | character varying |  |  |  |  |
|  | 規格 | strength | character varying |  |  |  |  |
|  | 第一単位 | unit_first | character varying |  |  |  |  |
|  | 第二単位 | unit_second | character varying |  |  |  |  |
|  | 一般名処方加算対象 | addition_type | character varying |  |  |  |  |
|  | 例外コード | exception_cd | character varying |  |  |  |  |
|  | 同一剤形・規格内の最低薬価 | min_price | character varying |  |  |  |  |
|  | 備考 | notes | character varying |  |  |  |  |
|  | 検索コードリスト | search_code_list | character varying |  |  |  | mst_medicine.standard_medicine_cdをカンマ区切りかjsonで格納 |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0'：通常、'1'：削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
