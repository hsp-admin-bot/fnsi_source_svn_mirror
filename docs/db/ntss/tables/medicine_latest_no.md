# medicine_latest_no

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `medicine_latest_no`
- Logical name: 投薬最新識別番号
- Physical name: `medicine_latest_no`
- Prefix group: `other`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `-`
- Column count: 7
- NOT NULL columns: 3

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 施設コード | facility_cd | character varying |  | 1 |  |  |
| 1 | 患者ID | pat_id | bigint |  | 1 |  |  |
|  | 投薬識別番号 | medi_info_no | bigint |  | 1 |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 表示フラグ | is_disp | character varying |  |  | '1' | '0':非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying |  |  | '0' | '0':通常、'1':削除 |
