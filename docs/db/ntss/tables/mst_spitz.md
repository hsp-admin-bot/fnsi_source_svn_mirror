# mst_spitz

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_spitz`
- Logical name: 採血管マスタ
- Physical name: `mst_spitz`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `spitz_cd`
- Column count: 11
- NOT NULL columns: 3

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | システムで管理する一意な採血管コード | spitz_cd | bigserial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  |  |
|  | 採血管名 | spitz_name | character varying | 40 | 1 |  |  |
|  | ラベル印字項目 | label_print | character varying | 10 |  |  | ラベル印刷時に印字する文言 |
|  | 院内院外フラグ | is_in_hospital | character varying | 1 |  |  | '0'：院外（デフォルト）、'1'：院内 |
|  | 至急フラグ | emergency_flg | character varying | 1 |  | '0' | '0'：通常、'1'：至急可 |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0'：通常、'1'：削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | FNW+で管理する施設内の一意なコード | fn_exam_set_cd | character varying | 4 |  |  |  |
