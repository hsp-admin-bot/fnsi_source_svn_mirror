# mst_favorite_facility

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_favorite_facility`
- Logical name: テーブル名(論理名)
- Physical name: `mst_favorite_facility`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `master_cd`
- Column count: 8
- NOT NULL columns: 4

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | お気に入り施設マスタコード | master_cd | character varying |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  | mst_facility.facility_cd |
|  | お気に入り施設コード | favorite_facility_cd | character varying | 6 | 1 |  | sys_facility.facility_cd |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' |  |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 医療機関コード | medical_institution_cd | character varying | 10 | 1 |  |  |
