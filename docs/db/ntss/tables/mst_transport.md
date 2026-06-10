# mst_transport

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_transport`
- Logical name: 搬送区分マスタ
- Physical name: `mst_transport`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `transport_cd`
- Column count: 9
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 搬送区分コード | transport_cd | serial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  |  |
|  | FNW+で管理する施設内の一意な搬送区分コード | fn_transport_cd | character varying | 10 |  |  | FNW+フィードバック用<br>FNW+で管理する施設内の一意なコード |
|  | 搬送区分名 | transport_name | character varying |  |  |  |  |
|  | 院内コード | in_hospital_cd_1 | character varying | 20 |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
