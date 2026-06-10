# mst_va

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_va`
- Logical name: VAマスタ
- Physical name: `mst_va`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `va_cd`
- Column count: 11
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | VAコード | va_cd | serial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  |  |
|  | FNW+で管理する施設内の一意なVAコード | fn_va_cd | character varying | 4 |  |  | FNW+フィードバック用<br>FNW+で管理する施設内の一意なコード |
|  | VA名 | va_name | character varying |  |  |  |  |
|  | VA方向 | va_direct | character varying | 1 |  |  | '0':両方、'1':左、'2':右、'3':なし、'-':不明 |
|  | 院内コード1 | in_hospital_cd_1 | character varying | 20 |  |  |  |
|  | 院内コード2 | in_hospital_cd_2 | character varying | 20 |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
