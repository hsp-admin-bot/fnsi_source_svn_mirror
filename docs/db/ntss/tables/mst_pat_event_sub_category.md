# mst_pat_event_sub_category

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_pat_event_sub_category`
- Logical name: 患者イベントサブカテゴリマスタ
- Physical name: `mst_pat_event_sub_category`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `sub_category_cd`
- Column count: 23
- NOT NULL columns: 2

## Related Config / Notes

- [../config/mst_pat_event_sub_category.md](../config/mst_pat_event_sub_category.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | サブカテゴリコード | sub_category_cd | bigserial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  | mst_facility.facility_cd |
|  | サブカテゴリ名称 | sub_category_name | character varying | 40 |  |  |  |
|  | カテゴリコード | category_cd | bigint |  |  |  |  |
|  | テンプレートコード | template_cd | bigint |  |  |  | mst_pat_event_data_template.template_cd |
|  | 利用種別 | use_type | smallint |  |  |  | 0:通常, 1:VA, 2:観察記録, 3:紹介状 |
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
|  | レポート一覧 | disp_item_info | jsonb |  |  |  | 表示項目についてはシート「@mst_pat_event_sub_category」を参照 |
|  | FNW+で管理する施設内の一意なサブカテゴリコード | fn_event_category_cd_2 | bigint |  |  |  |  |
|  | FNW用サブカテゴリ区分 | fn_event_category_class | character varying | 1 |  |  | 0:イベントサブカテゴリマスタ, 1:観察記録種別マスタ, 2:心身状況, 3:ADL |
