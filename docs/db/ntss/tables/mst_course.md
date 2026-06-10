# mst_course

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_course`
- Logical name: 診療科マスタ
- Physical name: `mst_course`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `course_cd`
- Column count: 10
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 診療科コード | course_cd | serial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  |  |
|  | FNW+で管理する施設内の一意な診療科コード | fn_course_cd | character varying | 4 |  |  | FNW+フィードバック用<br>FNW+で管理する施設内の一意なコード |
|  | 診療科名 | course_name | character varying |  |  |  |  |
|  | 標準診療科コード | standard_course_cd | character varying |  |  |  | 標準診療科マスタ.標準診療科コード |
|  | 院内コード1 | in_hospital_cd_1 | character varying | 20 |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
