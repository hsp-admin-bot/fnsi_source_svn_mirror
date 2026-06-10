# mst_procedure

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_procedure`
- Logical name: 手技マスタ
- Physical name: `mst_procedure`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `procedure_cd`
- Column count: 14
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 手技コード | procedure_cd | serial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  |  |
|  | FNW+で管理する施設内の一意な手技コード | fn_procedure_cd | character varying | 3 |  |  | FNW+フィードバック用<br>FNW+で管理する施設内の一意なコード |
|  | 手技名称 | pricedure_name | character varying | 40 |  |  |  |
|  | 利用開始日A | in_hosp_a_startdate | timestamp(3) |  |  |  |  |
|  | 院内コードA1 | in_hospital_cd_a1 | character varying | 20 |  |  |  |
|  | 院内コードA2 | in_hospital_cd_a2 | character varying | 20 |  |  |  |
|  | 利用開始日B | in_hosp_b_startdate | timestamp(3) |  |  |  |  |
|  | 院内コードB1 | in_hospital_cd_b1 | character varying | 20 |  |  |  |
|  | 院内コードB2 | in_hospital_cd_b2 | character varying | 20 |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
