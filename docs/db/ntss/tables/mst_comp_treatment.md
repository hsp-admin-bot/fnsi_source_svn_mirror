# mst_comp_treatment

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_comp_treatment`
- Logical name: 処置マスタ
- Physical name: `mst_comp_treatment`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `comp_treatment_cd`
- Column count: 23
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 処置コード | comp_treatment_cd | serial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  | mst_facility.facility_cd |
|  | 処置内容 | treatment | character varying | 256 |  |  |  |
|  | 処置区分 | treat_class | character varying | 1 |  |  | 0 : 調製薬剤 、1 : 薬剤、2 : 処置 |
|  | 処置薬剤コード | treat_medicine_cd | integer |  |  |  | 処置区分により下記を設定<br>0：mst_preparation_medicine<br>      .preparation_medicine_cd<br>1：mst_medicine.medicine_cd<br>2：null |
|  | 数量 | amount | numeric |  |  |  |  |
|  | 手技コード | procedure_cd | integer |  |  |  | mst_procedure.procedure_cd |
|  | 服用コード | take_medicine_cd | integer |  |  |  |  |
|  | 利用開始日A | in_hosp_a_startdate | timestamp(3) |  |  |  |  |
|  | 院内コードA1 | in_hospital_cd_a1 | character varying | 20 |  |  |  |
|  | 院内コードA2 | in_hospital_cd_a2 | character varying | 20 |  |  |  |
|  | 院内コードA3 | in_hospital_cd_a3 | character varying | 20 |  |  |  |
|  | 院内コードA4 | in_hospital_cd_a4 | character varying | 20 |  |  |  |
|  | 利用開始日B | in_hosp_b_startdate | timestamp(3) |  |  |  |  |
|  | 院内コードB1 | in_hospital_cd_b1 | character varying | 20 |  |  |  |
|  | 院内コードB2 | in_hospital_cd_b2 | character varying | 20 |  |  |  |
|  | 院内コードB3 | in_hospital_cd_b3 | character varying | 20 |  |  |  |
|  | 院内コードB4 | in_hospital_cd_b4 | character varying | 20 |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | FNW+で管理する施設内の一意なコード | fn_comp_treatment_cd | character varying | 10 |  |  |  |
