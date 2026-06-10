# mst_pat_hash

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_pat_hash`
- Logical name: 患者用施設マスタハッシュ
- Physical name: `mst_pat_hash`
- Prefix group: `master`
- User: `nkk4`
- Tablespace DB: `ntss_db4`
- Tablespace INDEX: `ntss_index4`
- Primary key definition: `facility_cd`
- Column count: 4
- NOT NULL columns: 2

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 施設コード | facility_cd | character varying | 6 | 1 |  | 外部キー制約（施設マスタ.施設コード） |
|  | ハッシュ値 | hash_value | character varying | 100 | 1 |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
