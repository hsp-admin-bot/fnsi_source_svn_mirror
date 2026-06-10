# mst_medicine_set

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_medicine_set`
- Logical name: 薬剤セットマスタ
- Physical name: `mst_medicine_set`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `medicine_set_cd`
- Column count: 11
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 薬剤セットコード | medicine_set_cd | serial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  |  |
|  | 薬剤セット名 | medicine_set_name | character varying |  |  |  |  |
|  | 省略薬剤セット名 | medicine_set_short_name | character varying |  |  |  |  |
|  | セット情報 | set_info | jsonb |  |  |  | {<br>  class：分類（1：通常薬剤、2：調製薬剤）<br>  cd：薬剤コード or 調製薬剤コード<br>  amount：数量<br>  procedure_timing_cd：手技コード<br>  medicate_timing_cd：投与タイミングコード<br>},… |
|  | 院内コード1 | in_hospital_cd_1 | character varying | 20 |  |  |  |
|  | 院内コード2 | in_hospital_cd_2 | character varying | 20 |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
