# mst_temporary_dialysis

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_temporary_dialysis`
- Logical name: 臨時透析区分マスタ
- Physical name: `mst_temporary_dialysis`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `temporary_dialysis_cd`
- Column count: 8
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 臨時透析区分コード | temporary_dialysis_cd | serial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  |  |
|  | 臨時透析区分名 | temporary_dialysis_name | character varying |  |  |  |  |
|  | 院内コード | in_hospital_cd_1 | character varying | 20 |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
