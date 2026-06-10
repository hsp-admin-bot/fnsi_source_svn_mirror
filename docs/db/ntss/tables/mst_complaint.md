# mst_complaint

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_complaint`
- Logical name: 愁訴マスタ
- Physical name: `mst_complaint`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `complaint_cd`
- Column count: 10
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 愁訴コード | complaint_cd | serial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  | mst_facility.facility_cd |
|  | 愁訴名 | complaint_name | character varying | 256 |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | FNW+で管理する施設内の一意なコード | fn_complaint_cd | character varying | 10 |  |  |  |
|  | 連携コード1 | in_hospital_cd_1 | character varying | 20 |  |  |  |
|  | 連携コード2 | in_hospital_cd_2 | character varying | 20 |  |  |  |
