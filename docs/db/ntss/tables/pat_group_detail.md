# pat_group_detail

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `pat_group_detail`
- Logical name: 患者グループ詳細
- Physical name: `pat_group_detail`
- Prefix group: `patient`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `=IF(A8="","",A8)&IF(A9="","",","&A9)&IF(A10="","",","&A10)&IF(A11="","",","&A11)&IF(A12="","",","&A12)`
- Column count: 3
- NOT NULL columns: 2

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
|  | 患者グループID | pat_group_cd | bigint |  | 1 |  |  |
|  | 患者ID | pat_id | bigint |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  | mst_facility.facility_cd |
