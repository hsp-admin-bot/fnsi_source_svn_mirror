# mst_facility_setting

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_facility_setting`
- Logical name: 施設設定マスタ
- Physical name: `mst_facility_setting`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `facility_setting_no,facility_cd`
- Column count: 5
- NOT NULL columns: 2

## Related Config / Notes

- [../config/mst_facility_setting.md](../config/mst_facility_setting.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 施設設定番号 | facility_setting_no | character varying | 4 | 1 |  |  |
| 1 | 施設コード | facility_cd | character varying | 6 | 1 |  |  |
|  | 値 | value | character varying |  |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
