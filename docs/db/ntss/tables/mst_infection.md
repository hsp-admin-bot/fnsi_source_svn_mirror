# mst_infection

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_infection`
- Logical name: 感染症マスタ
- Physical name: `mst_infection`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `infection_cd`
- Column count: 10
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 感染症コード | infection_cd | serial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  |  |
|  | FNW+で管理する施設内の一意な感染症コード | fn_infection_cd | character varying | 20 |  |  | FNW+フィードバック用<br>FNW+で管理する施設内の一意なコード |
|  | 感染症名 | infection_name | character varying |  |  |  |  |
|  | 標準感染症コード | standard_infection_cd | integer     character varying |  |  |  | 標準感染症マスタは作成しないが、後で紐づけが出来るようにカラムを用意 |
|  | 院内コード1 | in_hospital_cd_1 | character varying | 20 |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
