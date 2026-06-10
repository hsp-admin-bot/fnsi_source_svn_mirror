# ord_exception_period

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `ord_exception_period`
- Logical name: 除外期間
- Physical name: `ord_exception_period`
- Prefix group: `order-treatment`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `-`
- Column count: 9
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 除外期間番号 | exception_period_no | character varying |  | 1 |  |  |
|  | 施設コード | facility_cd | bigint |  |  |  |  |
|  | 患者ID | pat_id | bigint |  |  |  |  |
|  | 除外期間開始日 | exception_period_from | timestamp(3) |  |  |  |  |
|  | 除外期間終了日 | exception_period_to | timestamp(3) |  |  |  |  |
|  | 登録日時 | reg_date | character varying |  |  |  |  |
|  | 登録者ID | reg_staff_id | character varying |  |  |  |  |
|  | 更新日時 | up_date |  |  |  |  |  |
|  | 更新者ID | upd_staff_id |  |  |  |  |  |
