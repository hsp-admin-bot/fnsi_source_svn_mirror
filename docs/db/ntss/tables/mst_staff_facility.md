# mst_staff_facility

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_staff_facility`
- Logical name: 担当施設マスタ
- Physical name: `mst_staff_facility`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `user_id,facility_cd`
- Column count: 4
- NOT NULL columns: 2

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 担当者ID | user_id | bigint |  | 1 |  | 利用者マスタ.利用者ID |
| 1 | 担当施設コード | facility_cd | character varying | 6 | 1 |  | 施設マスタ.施設コード |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
