# mst_implant

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_implant`
- Logical name: インプラントマスタ
- Physical name: `mst_implant`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `implant_cd`
- Column count: 9
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | インプラントコード | implant_cd | serial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  |  |
|  | インプラント名 | implant_name | character varying |  |  |  |  |
|  | 標準インプラントコード | standard_implant_cd | character varying |  |  |  | 標準インプラントマスタは作成しないが、後で紐づけが出来るようにカラムを用意 |
|  | 院内コード1 | in_hospital_cd_1 | character varying | 20 |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
