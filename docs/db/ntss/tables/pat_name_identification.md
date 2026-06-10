# pat_name_identification

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `pat_name_identification`
- Logical name: 名寄せ
- Physical name: `pat_name_identification`
- Prefix group: `patient`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `pat_name_id`
- Column count: 14
- NOT NULL columns: 3

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 名寄せID | pat_name_id | bigserial |  | 1 |  | シーケンス |
|  | ソース患者ID | pat_id_src | bigint |  |  |  |  |
|  | ソース施設コード | facility_cd_src | character varying | 6 | 1 |  | mst_facility.facility_cd |
|  | ターゲット患者ID | pat_id_dst | bigint |  |  |  |  |
|  | ターゲット施設コード | facility_cd_dst | character varying | 6 | 1 |  | mst_facility.facility_cd |
|  | 承認フラグ | approve | character varying | 1 |  |  | 1:承認済、0:未承認、9:中止 |
|  | 受理フラグ | receive | character varying | 1 |  |  | 1:受理済、0:未受理、9:中止 |
|  | 開示フラグ | is_open | character varying | 1 |  |  | 1:開示済、0:未開示、9:中止 |
|  | 登録フラグ | sign_up | character varying | 1 |  |  | 0 - 既存患者から選択<br>1- 新規患者として登録 |
|  | 担当医 | doctor_in_charge | bigint |  |  |  |  |
|  | 承認日時 | approve_date | timestamp(3) |  |  |  |  |
|  | 登録日時 | create_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
