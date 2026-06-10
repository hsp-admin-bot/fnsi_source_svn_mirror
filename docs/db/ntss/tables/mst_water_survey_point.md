# mst_water_survey_point

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_water_survey_point`
- Logical name: 水質検査箇所マスタ
- Physical name: `mst_water_survey_point`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `survey_point_cd`
- Column count: 12
- NOT NULL columns: 2

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 水質検査箇所コード | survey_point_cd | bigserial |  | 1 |  | シーケンス |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  | mst_facility.facility_cd |
|  | 水質検査箇所名 | point_name | character varying | 64 |  |  |  |
|  | 対象装置 | machine_no | bigint |  |  |  |  |
|  | 水質調査種別 | survey_type_cd | bigint |  |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  |  |  |
|  | 削除フラグ | is_del | character varying | 1 |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | FNW+で管理する施設内の一意なコード | fn_survey_point_cd | varchar | 10 |  |  |  |
|  | 連携コード1 | in_hospital_cd_1 | character varying | 20 |  |  |  |
|  | 連携コード2 | in_hospital_cd_2 | character varying | 20 |  |  |  |
