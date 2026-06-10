# mst_function_report

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_function_report`
- Logical name: 機能帳票マスタ
- Physical name: `mst_function_report`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `function_report_cd`
- Column count: 8
- NOT NULL columns: 4

## Related Config / Notes

- [../config/mst_pat_event_sub_category.md](../config/mst_pat_event_sub_category.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 機能帳票コード | function_report_cd | serial |  | 1 |  |  |
|  | 機能コード | function_cd | character varying | 8 | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  | mst_facility.facility_cd |
|  | レポートCD | report_cd | bigint |  | 1 |  | mst_report.report_cd |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
