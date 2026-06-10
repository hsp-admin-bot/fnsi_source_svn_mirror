# mst_equipment_set

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_equipment_set`
- Logical name: 医療材料セットマスタ
- Physical name: `mst_equipment_set`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `equipment_set_cd`
- Column count: 11
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 医療材料セットコード | equipment_set_cd | serial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  |  |
|  | 医療材料セット名 | equipment_set_name | character varying |  |  |  |  |
|  | 省略医療材料セット名 | equipment_set_short_name | character varying |  |  |  |  |
|  | セット情報 | set_info | jsonb |  |  |  | {<br>  cd：医療材料コード<br>  amount：数量<br>  "equip_type": (Number)医療材料区分 (*1)<br>},…<br>■概要<br>(*1) 0：医療材料、1：ダイアライザ |
|  | 院内コード1 | in_hospital_cd_1 | character varying | 20 |  |  |  |
|  | 院内コード2 | in_hospital_cd_2 | character varying | 20 |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
