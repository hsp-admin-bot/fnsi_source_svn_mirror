# ord_prescription

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `ord_prescription`
- Logical name: 処方情報
- Physical name: `ord_prescription`
- Prefix group: `order-treatment`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `ord_prescription_no`
- Column count: 13
- NOT NULL columns: 5

## Related Config / Notes

- [../config/ord_prescription.md](../config/ord_prescription.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 処方オーダー番号 | ord_prescription_no | bigserial |  | 1 |  | シーケンス番号 |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  | mst_facility.facility_cd |
|  | 患者ID | pat_id | bigint |  | 1 |  | pat_main.pat_id |
|  | 処方種別 | prescription_type | character varying | 1 | 1 |  | 1：院外、2：院内 |
|  | 交付日 | issue_date | character varying | 8 |  |  | YYYYMMDD形式 |
|  | 使用期限 | expiration_date | character varying | 8 |  |  | YYYYMMDD形式 |
|  | 処方詳細 | prescription_detail | jsonb |  |  |  | @ord_prescriptionシートで参考 |
|  | 交付状態 | issue_state | character varying | 1 | 1 |  | 0：未交付、1：交付済み |
|  | 表示フラグ | is_disp | character varying | 1 |  |  |  |
|  | 削除フラグ | is_del | character varying | 1 |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  |  | fn_ord_prescription_no | varchar | 50 |  |  |  |
