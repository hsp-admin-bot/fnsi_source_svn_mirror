# mst_insurance

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_insurance`
- Logical name: 保険情報マスタ
- Physical name: `mst_insurance`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `insu_cd`
- Column count: 15
- NOT NULL columns: 2

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | システムで管理する一意な保険マスタコード | insu_cd | bigserial |  | 1 |  | シーケンス |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  | mst_facility.facility_cd |
|  | 保険名 | name | character varying |  |  |  |  |
|  | 保険者名 | insu_name | character varying |  |  |  |  |
|  | 保険略称 | insu_short_name | character varying | 4 |  |  |  |
|  | 負担率（外来） | futan_g | integer |  |  |  | 例：７０ |
|  | 負担率（入院） | futan_n | integer |  |  |  | 例：３０ |
|  | 保険区分 | insu_type | integer |  |  |  | 1:保険、２：公費 |
|  | 院内コード1 | in_hospital_cd_1 | character varying | 20 |  |  |  |
|  | 院内コード2 | in_hospital_cd_2 | character varying | 20 |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  |  |  |
|  | 削除フラグ | is_del | character varying | 1 |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 保険略称 | insu_name_short | character varying | 4 |  |  |  |
